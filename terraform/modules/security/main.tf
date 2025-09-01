#########Controls external traffic coming from users
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  vpc_id      = var.vpc_id
  description = "Public ALB - 80/443 from internet"

  ingress { 
    from_port = 80  
    to_port = 80  
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
    }

  ingress { 
    from_port = 443 
    to_port = 443 
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
    }
    
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }

  tags = { Name = "${var.project_name}-alb-sg" }
}

resource "aws_security_group" "internal_alb_sg" {
  name        = "${var.project_name}-internal-alb-sg"
  description = "Allow web tier to access internal ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-internal-alb-sg"
    Tier = "alb"
  }
}

resource "aws_security_group_rule" "web_to_internal_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.web_sg_id   
  security_group_id        = aws_security_group.internal_alb_sg.id
}



#########Controls internal traffic that only the ALB should be able to send. ALB to EC2 Layers
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  vpc_id      = var.vpc_id
  description = "Web instances - only from ALB on app port"

  ingress { 
    from_port = 80
    to_port = 80
    protocol = "tcp" 
    security_groups = [aws_security_group.alb_sg.id] 
    }

  egress  { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }

  tags = { Name = "${var.project_name}-web-sg" }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  vpc_id      = var.vpc_id
  description = "App instances - only from ALB on app port"

  ingress { 
    from_port = 8080
    to_port = 8080
    protocol = "tcp" 
    security_groups = [aws_security_group.internal_alb_sg.id] 
    }

  egress  { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }

  tags = { Name = "${var.project_name}-app-sg" }
}


##########Allows traffic only from the App SG on port 3306
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  vpc_id      = var.vpc_id
  description = "DB - allow 3306 from App ASG"

  ingress { 
    from_port = 3306 
    to_port = 3306 
    protocol = "tcp" 
    security_groups = [aws_security_group.app_sg.id] 
    }

  egress  { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }

  tags = { Name = "${var.project_name}-db-sg" }
}

############################################################################

# #resource "aws_acm_certificate" "this" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"
#   lifecycle { create_before_destroy = true }
# }

# resource "aws_route53_record" "validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.this.domain_validation_options :
#     dvo.domain_name => {
#       name  = dvo.resource_record_name
#       type  = dvo.resource_record_type
#       value = dvo.resource_record_value
#     }
#   }
#   zone_id = var.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60
#   records = [each.value.value]
# }

# resource "aws_acm_certificate_validation" "this" {
#   certificate_arn         = aws_acm_certificate.this.arn
#   validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
# }

# resource "aws_wafv2_web_acl" "this" {
#   name  = "${var.project_name}-web-acl"
#   scope = var.scope
#   default_action { allow {} }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "${var.project_name}-web-acl"
#     sampled_requests_enabled   = true
#   }

#   rule {
#     name     = "AWSCommonRules"
#     priority = 1
#     override_action { none {} }
#     statement { managed_rule_group_statement { name = "AWSManagedRulesCommonRuleSet", vendor_name = "AWS" } }
#     visibility_config { cloudwatch_metrics_enabled = true, metric_name = "AWSCommonRules", sampled_requests_enabled = true }
#   }

#   rule {
#     name     = "KnownBadInputs"
#     priority = 2
#     override_action { none {} }
#     statement { managed_rule_group_statement { name = "AWSManagedRulesKnownBadInputsRuleSet", vendor_name = "AWS" } }
#     visibility_config { cloudwatch_metrics_enabled = true, metric_name = "KnownBadInputs", sampled_requests_enabled = true }
#   }

#   dynamic "rule" {
#     for_each = var.enable_ip_rate_limit ? [1] : []
#     content {
#       name     = "RateLimit"
#       priority = 3
#       action { block {} }
#       statement { rate_based_statement { limit = var.rate_limit, aggregate_key_type = "IP" } }
#       visibility_config { cloudwatch_metrics_enabled = true, metric_name = "RateLimit", sampled_requests_enabled = true }
#     }
#   }
# }

# resource "aws_wafv2_web_acl_association" "assoc" {
#   resource_arn = var.associate_resource_arn
#   web_acl_arn  = aws_wafv2_web_acl.this.arn
# }
