# --- AMI: Amazon Linux 2023 (x86_64) の最新 ------------------------------
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# --- SSH キーペア（ssh_public_key_path が空なら作らない） ----------------
locals {
  create_key_pair = trimspace(var.ssh_public_key_path) != ""
}

resource "aws_key_pair" "main" {
  count      = local.create_key_pair ? 1 : 0
  key_name   = "${var.project}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# --- IAM: SSM Session Manager ＋ DB 資格情報(SSM Parameter)の読み取り ----
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.project}-ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "read_db_params" {
  statement {
    actions   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/*"]
  }
}

resource "aws_iam_role_policy" "read_db_params" {
  name   = "read-db-params"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.read_db_params.json
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-ec2"
  role = aws_iam_role.ec2.name
}

data "aws_caller_identity" "current" {}

# --- EC2 本体 -----------------------------------------------------------
resource "aws_instance" "app" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  key_name               = local.create_key_pair ? aws_key_pair.main[0].key_name : null

  root_block_device {
    volume_size = var.ec2_root_volume_gb
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens   = "required" # IMDSv2 のみ
    http_endpoint = "enabled"
  }

  # SSM パラメータより後に作成し、user_data 実行時には接続情報が存在するようにする
  depends_on = [aws_ssm_parameter.db_host, aws_ssm_parameter.db_password]

  # user_data は初回起動時のみ実行される。内容変更で既存インスタンスを作り直さない
  # （作り直したいときは terraform taint / -replace を明示する）。
  user_data_replace_on_change = false

  user_data = <<-EOF
    #!/bin/bash
    set -uxo pipefail

    # --- 開発ツール ---
    dnf update -y
    dnf install -y git docker
    systemctl enable --now docker
    usermod -aG docker ec2-user
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -sSL "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64" \
      -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # --- DB 接続情報を SSM Parameter Store から取得して env ファイルに書き出す ---
    # パラメータや IAM 権限の伝播待ちのためリトライする。失敗してもインスタンス作成は継続。
    write_db_env() {
      for i in $(seq 1 20); do
        DB_HOST=$(aws ssm get-parameter --region ${var.region} --name /${var.project}/db_host --query Parameter.Value --output text 2>/dev/null) || { sleep 15; continue; }
        DB_PASS=$(aws ssm get-parameter --region ${var.region} --name /${var.project}/db_password --with-decryption --query Parameter.Value --output text 2>/dev/null) || { sleep 15; continue; }
        {
          echo "DB_HOST=$DB_HOST"
          echo "DB_PORT=3306"
          echo "DB_NAME=${var.db_name}"
          echo "DB_USERNAME=${var.db_username}"
          echo "DB_PASSWORD=$DB_PASS"
        } > /etc/inquiry-management.env
        chmod 600 /etc/inquiry-management.env
        return 0
      done
      echo "WARN: /etc/inquiry-management.env を作成できませんでした。手動で aws ssm get-parameter してください" >&2
      return 1
    }
    write_db_env || true
  EOF

  tags = { Name = "${var.project}-app" }
}
