## AUTO SCALING GROUP ## 
data "aws_ami" "my_amazonlinux2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

# launch configuration
resource "aws_launch_configuration" "lauchconfig" {
  name_prefix     = format("%s-%s", var.name, "lauchconfig")
  image_id        = data.aws_ami.my_amazonlinux2.id
  instance_type   = var.instance_type
  security_groups = var.sg
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              wget https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
              mv busybox-x86_64 busybox
              chmod +x busybox
              RZAZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
              IID=$(curl 169.254.169.254/latest/meta-data/instance-id)
              LIP=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
              echo "<h1>RegionAz($RZAZ) : Instance ID($IID) : Private IP($LIP) : Web Server</h1>" > index.html
              nohup ./busybox httpd -f -p 80 &
              EOF

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

# auto scaling group
resource "aws_autoscaling_group" "myasg" {
  name                 = format("%s-%s", var.name, "asg")
  launch_configuration = aws_launch_configuration.lauchconfig.name
  vpc_zone_identifier  = var.vpc_zone_identifier
  min_size = var.min_size
  max_size = var.max_size
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.myalbtg.arn]

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}

###############################
## APPLICATION LOAD BALANCER ##
###############################
resource "aws_lb" "myalb" {
  name               = format("%s-%s", var.name, "alb")
  load_balancer_type = "application"
  subnets            = var.subnet
  security_groups = var.sg

  tags = {
    Name = format("%s-%s", var.name, "alb")
  }
}

resource "aws_lb_listener" "myhttp" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found - T101 Study"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "myalbtg" {
  name = format("%s-%s", var.name, "targetgroup")
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "myalbrule" {
  listener_arn = aws_lb_listener.myhttp.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalbtg.arn
  }
}