# --- マスターパスワードを自動生成 --------------------------------------
resource "random_password" "db" {
  length  = 24
  special = false # MySQL / URL で扱いやすいよう記号なし
}

# --- サブネットグループ（プライベートサブネット 2 AZ） ----------------
resource "aws_db_subnet_group" "main" {
  name       = var.project
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = var.project }
}

# --- RDS (MySQL, Single-AZ, 非公開) -----------------------------------
resource "aws_db_instance" "main" {
  identifier     = var.project
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  allocated_storage     = var.db_allocated_storage_gb
  max_allocated_storage = 0 # ストレージオートスケーリング無効（コスト予測しやすく）
  storage_type          = "gp2"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  performance_insights_enabled = false

  tags = { Name = var.project }
}

# --- 接続情報を SSM Parameter Store に保存（EC2 から取得する） --------
resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.project}/db_host"
  type  = "String"
  value = aws_db_instance.main.address
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project}/db_password"
  type  = "SecureString"
  value = random_password.db.result
}
