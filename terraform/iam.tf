# TODO: rename and move to aws_instance.tf
resource "aws_iam_role" "ssm_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ec2_ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_policy" "assets_crud" {
  name        = "assets-crud-policy"
  description = "Policy to allow CRUD operations on S3 assets bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.assets.arn,
          "${aws_s3_bucket.assets.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_app_a_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.assets_crud.arn
}

resource "aws_iam_policy" "ssm_read_startup_params" {
  name        = "ssm-read-startup-params"
  description = "Allow reading all SSM parameters under /cloudtalents/startup/"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect = "Allow",
        Action : [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParameterHistory",
          "ssm:DescribeParameters"
        ],
        Resource : "arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/cloudtalents/startup/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_startup_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.ssm_read_startup_params.arn
}

# TODO: rename and move to dms.tf
data "aws_iam_policy_document" "dms_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["dms.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "dms_vpc_role" {
  name               = "dms-vpc-role"
  assume_role_policy = data.aws_iam_policy_document.dms_assume_role.json
}

resource "aws_iam_role_policy_attachment" "dms_vpc_management_attachment" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"

  depends_on = [aws_iam_role.dms_vpc_role]
}
