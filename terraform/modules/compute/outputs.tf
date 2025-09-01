
output "web_asg_name" {
  description = "Auto Scaling Group name for web tier"
  value       = aws_autoscaling_group.asg-web.name
}

output "app_asg_name" {
  description = "Auto Scaling Group name for app tier"
  value       = aws_autoscaling_group.asg-app.name
}

output "web_launch_template_id" {
  description = "Launch Template ID for web tier"
  value       = aws_launch_template.ec2_lt_web.id
}

output "app_launch_template_id" {
  description = "Launch Template ID for app tier"
  value       = aws_launch_template.ec2_lt_app.id
}

output "public_alb_arn_suffix" {
  description = "frontend application load balancer arn suffix"
  value = aws_lb.app_load_balancer.arn_suffix
  
}

output "internal_alb_dns" {
  description = "DNS name of internal ALB"
  value       = aws_lb.internal_load_balancer.dns_name
   }

output "app_internal_tg_arn" {
  description = "Target group ARN of app behind internal ALB"
  value       = aws_lb_target_group.app_internal_tg.arn
}

output "public_alb_dns" {
  description = "DNS name of the public ALB"
  value       = aws_lb.app_load_balancer.dns_name
}