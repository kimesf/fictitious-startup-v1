# Launch template for the Auto Scaling Group
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-launch-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.zone_a_public.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }

  # Enable detailed monitoring
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-asg-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-autoscaling-group"
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  target_group_arns         = []
  health_check_type         = "EC2"
  health_check_grace_period = 300

  min_size         = 1
  max_size         = 5
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  # Enable instance scale-in protection for manual control if needed
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "app-asg"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
  }
}