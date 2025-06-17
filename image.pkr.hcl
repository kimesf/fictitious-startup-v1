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

locals {
  tags = {
    Amazon_AMI_Management_Identifier = "true"
  }
  ssh_username = "ubuntu"
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
  ssh_username                = local.ssh_username
  ami_name                    = "cloudtalents-startup-${var.version}"
  vpc_id                      = "vpc-0f770dae34d7b300c"
  subnet_id                   = "subnet-0b7eaa6297f378e42"
  associate_public_ip_address = true
  tags                        = local.tags
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /tmp/app",
      "sudo chown -R ${local.ssh_username}:${local.ssh_username} /tmp/app",
    ]
  }

  provisioner "file" {
    source      = "./"
    destination = "/tmp/app/"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/app",
      "sudo cp -r /tmp/app/* /opt/app/",
      "sudo rm -rf /tmp/app",
      "sudo chown -R ${local.ssh_username}:${local.ssh_username} /opt/app",
    ]
  }

  provisioner "shell" {
    inline = [
      "chmod +x /opt/app/setup.sh",
      "sudo /opt/app/setup.sh"
    ]
  }

  post-processor "amazon-ami-management" {
    regions       = [var.region]
    keep_releases = 2
    tags          = local.tags
  }
}
