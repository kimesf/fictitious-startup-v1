terraform {
  backend "s3" {
    bucket       = "aws-bootcamp-cm-42"
    key          = "terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}

