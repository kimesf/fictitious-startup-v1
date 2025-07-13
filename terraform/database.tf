resource "aws_db_parameter_group" "default" {
  name   = "default-postgres16"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

resource "aws_db_subnet_group" "zone_a" {
  name       = "zone-a-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_db_instance" "mvp_db_instance" {
  allocated_storage      = 20
  db_name                = "mvp"
  engine                 = "postgres"
  engine_version         = "16.8"
  instance_class         = "db.t3.micro"
  username               = aws_ssm_parameter.secure_parameters["db_user"].value
  password               = aws_ssm_parameter.secure_parameters["db_password"].value
  skip_final_snapshot    = true
  availability_zone      = local.region_a
  parameter_group_name   = aws_db_parameter_group.default.name
  db_subnet_group_name   = aws_db_subnet_group.zone_a.name
  vpc_security_group_ids = [aws_security_group.zone_a_private.id]
  apply_immediately      = true

  tags = {
    Name = "mvp-db-instance"
  }
}
