variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_app_subnet_ids" { type = list(string)}

variable "instance_type" { 
  type = string
  default = "t3.micro" 
  }
variable "target_port" { type = number }
variable "health_path" { 
  type = string
  default = "/" 
  }
variable "enable_detailed_monitoring" { 
  type = bool 
  default = true 
  }

variable "alb_sg_id" { type = list(string) }
variable "web_sg_id" { type = list(string) }
variable "app_sg_id" { type = list(string) }
variable "desired_capacity" { 
  type = number 
  default = 2 
  }

variable "min_size" { 
  type = number
  default = 2 
  }

variable "max_size" { 
  type = number 
  default = 4 
  }

variable "enable_https" { 
  type = bool 
  default = false 
  }
  
variable "certificate_arn" { 
  type = string 
  default = "" 
  }

variable "redirect_http_to_https" { 
  type = bool 
  default = true 
  }

variable "environment" {
  type    = string
  default = "dev"
}

variable "create_internal_alb" {
  type    = bool
  default = true
}

variable "internal_alb_sg_id" {
  type = list(string)
}

variable "db_sg_id" {
  type = list(string)
}

variable "web_instance_type" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "user_data_web" {
  type = string
}

variable "user_data_app" {
  type = string
}
