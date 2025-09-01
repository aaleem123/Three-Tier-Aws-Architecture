variable "aws_region" { type = string }
variable "project_name" { type = string }

variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_app_subnet_cidrs" { type = list(string) }
variable "private_db_subnet_cidrs" { type = list(string) }

variable "web_instance_type" {
  type    = string
  default = "t3.micro"
}
variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}
variable "target_port" {
  type        = number
  description = "Port your app listens on"
}

variable "db_engine_version" {
  type    = string
  default = "8.0"
}
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_username" { type = string }
variable "db_password" { type = string }
variable "db_multi_az" {
  type    = bool
  default = false
}
variable "alb_condition" {
  description = "Set to true if ALB should be internal"
  type        = bool
}

# # Route 53 + ACM
# variable "hosted_zone_id" { type = string }
# variable "public_domain_name" { type = string }

# Monitoring
variable "notification_email" { type = string }
variable "bucket_name" { type = string }

# S3
variable "s3_kms_key_arn" {
  type        = string
  description = "KMS key ARN for S3 bucket encryption"
}
