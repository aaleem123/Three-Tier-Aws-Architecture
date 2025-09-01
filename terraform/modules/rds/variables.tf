variable "project_name" { type = string }
variable "private_db_subnet_ids" { type = list(string) }

variable "engine_version" { 
  type = string
  default = "8.0" 
  }

variable "instance_class" { 
  type = string
  default = "db.t3.micro" 
  }

variable "allocated_storage" { 
  type = number 
  default = 20 
  }

variable "username" { type = string }
variable "password" { type = string }

variable "multi_az" { 
  type = bool
  default = false 
  }

variable "db_sg_id" {
  type = list(string)
}