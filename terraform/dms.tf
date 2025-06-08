resource "aws_dms_replication_subnet_group" "dms_replication_subnet_group" {
  replication_subnet_group_id = "dms-replication-subnet-group"
  replication_subnet_group_description = "DMS Replication Subnet Group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "dms-replication-subnet-group"
  }
}

resource "aws_dms_replication_instance" "dms_replication_instance" {
  allocated_storage = 20
  apply_immediately = true
  availability_zone = local.region_a
  replication_instance_class = "dms.t3.micro"
  replication_instance_id= "dms-replication-instance"
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_replication_subnet_group.id

  vpc_security_group_ids = [
    aws_security_group.zone_a_private.id
  ]

  depends_on = [
    aws_iam_role_policy_attachment.dms_vpc_management_attachment
  ]
}

resource "aws_dms_endpoint" "source" {
  endpoint_id = "dms-instance-source-endpoint"
  endpoint_type = "source"
  engine_name = "postgres"
  username = var.db_username
  password = var.db_password
  server_name = aws_instance.app_a.private_ip
  port = 5432
  database_name = aws_db_instance.mvp_db_instance.db_name

  ssl_mode = "none"
}

resource "aws_dms_endpoint" "target" {
  endpoint_id = "dms-rds-target-endpoint"
  endpoint_type = "target"
  engine_name = "postgres"
  username = var.db_username
  password = var.db_password
  server_name = aws_db_instance.mvp_db_instance.address
  port = 5432
  database_name = aws_db_instance.mvp_db_instance.db_name

  ssl_mode         = "none"
}

# resource "aws_dms_replication_task" "full_load_task" {
#   replication_task_id          = "full-load-task"
#   migration_type               = "full-load"
#   replication_instance_arn     = aws_dms_replication_instance.dms_replication_instance.replication_instance_arn
#   source_endpoint_arn          = aws_dms_endpoint.source.endpoint_arn
#   target_endpoint_arn          = aws_dms_endpoint.target.endpoint_arn
#
#   table_mappings               = jsonencode(local.dms_table_mappings)
#   replication_task_settings    = jsonencode(local.dms_task_settings)
#
#   start_replication_task       = false
#
#   tags = {
#     Name = "full-load-task"
#   }
# }
#
# locals {
#   dms_table_mappings = {
#     rules = [
#       {
#         "rule-type" = "selection"
#         "rule-id" = "1"
#         "rule-name" = "include-all-tables-and-schemas"
#         "object-locator" = {
#           "schema-name" = "%"
#           "table-name" = "%"
#         }
#         "rule-action" = "include"
#       }
#     ]
#   }
#
#   dms_task_settings = {
#     TargetMetadata = {
#       TargetSchema = ""
#       BatchApplyEnabled = true
#     },
#     FullLoadSettings = {
#       TargetTablePrepMode = "DROP_AND_CREATE"
#     }
#   }
# }
