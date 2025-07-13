resource "aws_launch_template" "app" {
  name_prefix   = "app-a-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.zone_a_public.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-a"
    }
  }

  monitoring {
    enabled = true
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity     = 1
  min_size             = 1
  max_size             = 5
  vpc_zone_identifier  = [aws_subnet.public_a.id]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "cloudtalents-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["cloudtalents-startup-${var.release_version}"]
  }
}
