variable "project_name" { type = string }
variable "notification_email" { type = string }
variable "public_alb_arn_suffix" { 
  type = string 
  }

variable "rds_identifier" { type = string }
variable "web_asg_name" {
  type = string
}

variable "app_asg_name" {
  type = string
}