variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

locals {
  ssm_parameters = {
    secret_key   = "/cloudtalents/startup/secret_key"
    db_user      = "/cloudtalents/startup/db_user"
    db_password  = "/cloudtalents/startup/db_password"
  }
}

resource "aws_ssm_parameter" "webserver_secrets" {
  for_each = local.ssm_parameters

  name  = each.value
  type  = "SecureString"
  value = "will-be-replaced"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "database_endpoint" {
  name  = "/cloudtalents/startup/database_endpoint"
  type  = "String"
  value = aws_db_instance.mvp_db_instance.endpoint
}

resource "aws_ssm_parameter" "image_storage_bucket_name" {
  name  = "/cloudtalents/startup/image_storage_bucket_name"
  type  = "String"
  value = aws_s3_bucket.assets.bucket
}

resource "aws_ssm_parameter" "image_storage_cloudfront_domain" {
  name  = "/cloudtalents/startup/image_storage_cloudfront_domain"
  type  = "String"
  value = aws_cloudfront_distribution.assets_cdn.domain_name
}

