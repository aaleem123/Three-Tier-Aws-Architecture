resource "aws_sns_topic" "alerts" { 
  name = "${var.project_name}-alerts" 
  }

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60  #seconds
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "High ALB 5xx"
  dimensions          = { 
    LoadBalancer = var.public_alb_arn_suffix 
  }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

# Web ASG CPU alarm
resource "aws_cloudwatch_metric_alarm" "web_asg_cpu_high" {
  alarm_name          = "${var.project_name}-web-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Web ASG CPU > 80%"
  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }
  # alarm_description = "High CPU usage on Web ASG"
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# App ASG CPU alarm
resource "aws_cloudwatch_metric_alarm" "app_asg_cpu_high" {
  alarm_name          = "${var.project_name}-app-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AutoScaling"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "App ASG CPU > 80%"
  dimensions = {
    AutoScalingGroupName = var.app_asg_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}


resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project_name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU > 80%"
  dimensions          = { DBInstanceIdentifier = var.rds_identifier }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.project_name}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5e9 # ~5 GB
  alarm_description   = "RDS low free storage"
  dimensions          = { DBInstanceIdentifier = var.rds_identifier }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
