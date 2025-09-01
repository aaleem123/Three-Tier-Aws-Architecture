output "alb_sg_id" {
  description = "Security Group ID for the public ALB"
  value       = aws_security_group.alb_sg.id
}

output "web_sg_id" {
  description = "Security Group ID for the Web instances"
  value       = aws_security_group.web_sg.id
}

output "app_sg_id" {
  description = "Security Group ID for the App instances"
  value       = aws_security_group.app_sg.id
}

output "db_sg_id" {
  description = "Security Group ID for the database"
  value       = aws_security_group.db_sg.id
}

output "internal_alb_sg_id" {
  value = aws_security_group.internal_alb_sg.id
}
