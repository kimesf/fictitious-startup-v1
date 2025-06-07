resource "aws_security_group" "zone_a" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "zone_a_private" {
  name = "zone-a-private-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic from server"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.zone_a.id]
  }
}

