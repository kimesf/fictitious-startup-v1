# TODO: move both to dictionary
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
  secure_ssm_parameters = {
    secret_key  = "/cloudtalents/startup/secret_key"
    db_user     = "/cloudtalents/startup/db_user"
    db_password = "/cloudtalents/startup/db_password"
  }

  dynamic_ssm_parameters = {
    database_endpoint = {
      name  = "/cloudtalents/startup/database_endpoint"
      value = aws_db_instance.mvp_db_instance.endpoint
    }
    image_storage_bucket_name = {
      name  = "/cloudtalents/startup/image_storage_bucket_name"
      value = aws_s3_bucket.assets.bucket
    }
    image_storage_cloudfront_domain = {
      name  = "/cloudtalents/startup/image_storage_cloudfront_domain"
      value = aws_cloudfront_distribution.assets_cdn.domain_name
    }
  }
}

resource "aws_ssm_parameter" "secure_parameters" {
  for_each = local.secure_ssm_parameters

  name  = each.value
  type  = "SecureString"
  value = "will-be-replaced"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "dynamic_parameters" {
  for_each = local.dynamic_ssm_parameters

  name  = each.value.name
  type  = "String"
  value = each.value.value
}
