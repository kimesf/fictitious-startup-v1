packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    amazon-ami-management = {
      version = ">= 1.0.0"
      source = "github.com/wata727/amazon-ami-management"
    }
  }
}

variable "region" {
  default = "us-east-2"
}

variable "version" {
  type = string
}

source "amazon-ebs" "ubuntu" {
  region                  = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  instance_type               = "t2.micro"
  ssh_username                = "ubuntu"
  ami_name                    = "cloudtalents-startup-${var.version}"
  vpc_id                      = "vpc-0d7a451d098b295b7"
  subnet_id                   = "subnet-0b7eaa6297f378e42"
  associate_public_ip_address = true

  tags = {
    Amazon_AMI_Management_Identifier = "true"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "."
    destination = "/tmp/app"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/app",
      "sudo mv /tmp/app/* /opt/app/",
      "sudo rm -rf /tmp/app"
    ]
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh"
    ]
  }

  post-processor "amazon-ami-management" {
    ami_regions     = [var.region]
    keep_releases   = 2
    ami_name_filter = "cloudtalents-startup-*"
    tag_value_filter {
      key   = "Amazon_AMI_Management_Identifier"
      value = "true"
    }
  }
}
