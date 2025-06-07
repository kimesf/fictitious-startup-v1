resource "aws_db_parameter_group" "default" {
  name = "default-postgres16"
  family = "postgres16"

  parameter {
    name = "rds.force_ssl"
    value = "0"
  }
}

resource "aws_db_subnet_group" "zone_a" {
  name = "zone-a-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id]
}

resource "aws_security_group" "zone_a_private" {
  name = "zone-a-private-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic from server"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.zone_a_public.id]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage = 1
  db_name = "mvp"
  engine = "postgres"
  engine_version = "16.3"
  instance_class = "db.t3.micro"
  username = var.db_username
  password = var.db_password
  skip_final_snapshot = true
  availability_zone = "us-east-2a"
  parameter_group_name = aws_db_parameter_group.default.name
  db_subnet_group_name = aws_db_subnet_group.zone_a.name
  vpc_security_group_ids = [aws_security_group.zone_a_private.id]

  tags = {
    Name = "mvp-db-instance"
  }
}
