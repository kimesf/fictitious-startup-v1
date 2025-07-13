resource "aws_launch_template" "app" {
  name_prefix   = "app-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  monitoring {
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
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
