output "ec2_public_ip" {
  description = "EC2 の Elastic IP（固定）"
  value       = aws_eip.app.public_ip
}

output "app_url" {
  description = "デプロイ後のアプリ URL"
  value       = "http://${aws_eip.app.public_ip}"
}

output "ec2_instance_id" {
  description = "EC2 インスタンス ID（SSM Session Manager で使用）"
  value       = aws_instance.app.id
}

output "ssh_command" {
  description = "SSH 接続コマンド（キーペアを作成した場合）"
  value       = local.create_key_pair ? "ssh -i ${replace(var.ssh_public_key_path, ".pub", "")} ec2-user@${aws_instance.app.public_ip}" : "（キーペア未作成: aws ssm start-session --target ${aws_instance.app.id} を使用）"
}

output "rds_endpoint" {
  description = "RDS のエンドポイント（EC2 内からのみ到達可能）"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS のホスト名"
  value       = aws_db_instance.main.address
}

output "db_name" {
  value = var.db_name
}

output "db_username" {
  value = var.db_username
}

output "db_password" {
  description = "RDS マスターパスワード（自動生成）"
  value       = random_password.db.result
  sensitive   = true
}

output "db_password_ssm_parameter" {
  description = "パスワードを保存した SSM パラメータ名"
  value       = aws_ssm_parameter.db_password.name
}
