# EC2 の停止・起動でパブリック IP が変わらないよう Elastic IP を割り当てる。
# 2024年以降、パブリック IPv4 は EIP でも自動割り当てでも同額課金のため追加コストはない。
resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"
  tags     = { Name = "${var.project}-app" }

  depends_on = [aws_internet_gateway.main]
}
