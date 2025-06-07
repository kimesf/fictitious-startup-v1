resource "aws_dms_replication_subnet_group" "dms_replication_subnet_group" {
  replication_subnet_group_description = "DMS Replication Subnet Group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "dms-replication-subnet-group"
  }
}

resource "aws_dms_replication_instance" "test" {
  allocated_storage = 20
  apply_immediately = true
  availability_zone = locals.availability_zone_a
  replication_instance_class = "dms.t3.micro"
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_replication_subnet_group.id

  vpc_security_group_ids = [
    aws_security_group.zone_a_private.id
  ]

  depends_on = [
    aws_iam_role_policy_attachment.dms_access_for_endpoint_AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms_cloudwatch_logs_role_AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms_vpc_role_AmazonDMSVPCManagementRole
  ]
}
