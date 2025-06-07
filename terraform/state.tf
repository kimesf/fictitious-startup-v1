terraform {
  backend "s3" {
    bucket = "aws-bootcamp-cm-42"
    key    = "terraform.tfstate"
    region = locals.region
    use_lockfile = true
  }
}

