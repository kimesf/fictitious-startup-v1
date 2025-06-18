resource "aws_instance" "app_a" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.zone_a_public.id]
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name = "app-a"
  }
}

resource "aws_eip" "app_a_ip" {
  domain = "vpc"

  instance                  = aws_instance.app_a.id
  associate_with_private_ip = aws_instance.app_a.private_ip
  depends_on                = [aws_internet_gateway.main]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["self"]

  filter {
    name= "name"
    values = ["cloudtalents-startup-${var.release_version}"]
  }
}
