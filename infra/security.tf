# --- EC2 セキュリティグループ ---------------------------------------------
resource "aws_security_group" "ec2" {
  name        = "${var.project}-ec2"
  description = "App server (EC2)"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project}-ec2" }
}

resource "aws_security_group_rule" "ec2_ingress" {
  for_each          = toset([for p in var.ec2_ingress_ports : tostring(p)])
  security_group_id = aws_security_group.ec2.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  cidr_blocks       = [var.allowed_ingress_cidr]
  description       = "port ${each.value}"
}

resource "aws_security_group_rule" "ec2_egress_all" {
  security_group_id = aws_security_group.ec2.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "all outbound"
}

# --- RDS セキュリティグループ --------------------------------------------
# インバウンドは EC2 の SG からの 3306 のみ。CIDR は一切許可しない。
resource "aws_security_group" "rds" {
  name        = "${var.project}-rds"
  description = "MySQL (RDS) - reachable only from the EC2 security group"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project}-rds" }
}

resource "aws_security_group_rule" "rds_ingress_from_ec2" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.ec2.id
  description              = "MySQL from EC2 SG only"
}

resource "aws_security_group_rule" "rds_egress_all" {
  security_group_id = aws_security_group.rds.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "all outbound"
}
