# Rails の SECRET_KEY_BASE を生成して SSM に保存する。
# EC2 の IAM ロールは /$${project}/* を読めるため、デプロイ時に取得できる。
resource "random_id" "secret_key_base" {
  byte_length = 64 # hex 128 文字
}

resource "aws_ssm_parameter" "secret_key_base" {
  name  = "/${var.project}/secret_key_base"
  type  = "SecureString"
  value = random_id.secret_key_base.hex
}
