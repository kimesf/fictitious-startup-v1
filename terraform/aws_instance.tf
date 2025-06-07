resource "aws_instance" "app_a" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.zone_a.id]
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name= "name"
    values = ["ubuntu/images/*ubuntu-jammy-22.04-amd64-server*"]
  }
}
