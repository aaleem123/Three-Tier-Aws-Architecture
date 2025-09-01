# resource "aws_route53_record" "a_record" {
#   zone_id = var.zone_id
#   name    = var.record_name
#   type    = "A"
#   alias {
#     name                   = var.alias_name
#     zone_id                = var.alias_zone_id
#     evaluate_target_health = true
#   }
# }
