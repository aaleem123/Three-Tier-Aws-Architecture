resource "aws_lb" "app_load_balancer" {
  name                       = "${var.project_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.alb_sg_id
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false

  tags = { Name = "${var.project_name}-alb" }
}

resource "aws_lb_target_group" "alb_ec2_tg" {
  name     = "${var.project_name}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = var.health_path
    matcher             = "200,301,302"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
  tags = { Name = "${var.project_name}-tg" }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = var.target_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ec2_tg.arn
  }
}

###### Internal load Balancer Web to App layer
resource "aws_lb" "internal_load_balancer" {
  name                       = "${var.project_name}-internal-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = var.internal_alb_sg_id
  subnets                    = var.private_app_subnet_ids
  enable_deletion_protection = false

  tags = { Name = "${var.project_name}-internal-alb" }
}

resource "aws_lb_target_group" "app_internal_tg" {
  name     = "${replace(var.project_name, "_", "-")}-app-int-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = var.health_path
    matcher             = "200,301,302"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
  tags =  {
    Name = "${replace(var.project_name, "_", "-")}-app-int-tg"
  }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_internal_tg.arn
  }
}

# Register App ASG to the internal ALB TG
resource "aws_autoscaling_attachment" "app_asg_to_internal_tg" {
  autoscaling_group_name = aws_autoscaling_group.asg-app.name
  lb_target_group_arn    = aws_lb_target_group.app_internal_tg.arn
}


####### Lauch template for our auto scaling groups for Web and App tier
resource "aws_launch_template" "ec2_lt_web" {
  name_prefix   = "${var.project_name}-lt-Web"
  image_id      = "ami-0abcdef1234567890"
  instance_type = var.instance_type

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  vpc_security_group_ids = var.web_sg_id
  user_data              = base64encode(templatefile("${path.module}/../../envs/dev/user_data_web.sh", {}))

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-lt-web" }
  }
}

resource "aws_launch_template" "ec2_lt_app" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = "ami-0abcdef1234567890"
  instance_type = var.instance_type

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  vpc_security_group_ids = var.app_sg_id

  user_data = base64encode(templatefile("${path.module}/../../envs/dev/user_data_app.sh", {}))

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-lt-app" }
  }
}


resource "aws_autoscaling_group" "asg-web" {
  name                = "${var.project_name}-web-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.alb_ec2_tg.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.ec2_lt_web.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web"
    propagate_at_launch = true
  }

  lifecycle { create_before_destroy = true }
}


resource "aws_autoscaling_group" "asg-app" {
  name                = "${var.project_name}-app-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.private_app_subnet_ids
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.ec2_lt_app.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }


  lifecycle { create_before_destroy = true }
}
