resource "aws_security_group" "zone_a" {
  name = "zone-a-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "zone_a_private" {
  name = "zone-a-private-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "zone_a_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.zone_a.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow inbound HTTP from anywhere"
}

resource "aws_security_group_rule" "zone_a_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.zone_a.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "allow_database_access_to_zone_a" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.zone_a.id
  source_security_group_id = aws_security_group.zone_a_private.id
  description       = "Allow inbound traffic to postgres from zone_a_private"
}

resource "aws_security_group_rule" "allow_database_access_to_zone_a_private" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.zone_a_private.id
  source_security_group_id = aws_security_group.zone_a.id
  description       = "Allow inbound traffic to postgres from zone_a"
}
