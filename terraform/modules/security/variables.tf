variable "project_name" { type = string }
variable "vpc_id" { type = string }

#variable "domain_name" { type = string }
#variable "zone_id" { type = string }

#variable "name" { type = string }
#variable "scope" { type = string, default = "REGIONAL" }
#variable "associate_resource_arn" { type = string }
#variable "enable_ip_rate_limit" { type = bool, default = true }
#variable "rate_limit" { type = number, default = 2000 }

variable "web_sg_id" {
  type = string
  default = ""
}