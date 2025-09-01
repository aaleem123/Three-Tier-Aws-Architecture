module "network" {
  source                   = "../../modules/network"
  project_name             = var.project_name
  vpc_cidr                 = var.vpc_cidr
  aws_region               = var.aws_region
  azs                      = var.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  bucket_name              = "three-tier-bucket-yagjidrfdh0"
}

module "security" {
  source       = "../../modules/security"
  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  # hosted_zone_id     = var.hosted_zone_id
  # public_domain_name = var.public_domain_name
  # public_alb_arn is only known after compute; pass placeholder, then re-run plan/apply
  # enable_waf         = false
}

module "rds" {
  source                = "../../modules/rds"
  project_name          = var.project_name
  private_db_subnet_ids = module.network.private_db_subnet_ids
  db_sg_id              = [module.security.db_sg_id]
  engine_version        = var.db_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  username              = var.db_username
  password              = var.db_password
  multi_az              = var.db_multi_az
}

module "compute" {
  source                 = "../../modules/compute"
  project_name           = var.project_name
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_app_subnet_ids = module.network.private_app_subnet_ids
  target_port            = var.target_port

  alb_sg_id = [module.security.alb_sg_id]
  web_sg_id = [module.security.web_sg_id]
  app_sg_id = [module.security.app_sg_id]
  db_sg_id  = [module.security.db_sg_id]

  web_instance_type = var.web_instance_type
  app_instance_type = var.app_instance_type

  internal_alb_sg_id = [module.security.internal_alb_sg_id]

  # use local user_data scripts from this env folder
  user_data_web = file("${path.module}/user_data_web.sh")
  user_data_app = file("${path.module}/user_data_app.sh")

  # optionally override health paths or capacities here
}

#module "edge" {
#  source             = "..//modules/edge"
#  hosted_zone_id     = var.hosted_zone_id
#  public_domain_name = var.public_domain_name
#  public_alb_dns     = module.compute.public_alb_dns
#  public_alb_zone_id = module.compute.public_alb_zone_id
#}

module "observability" {
  source                = "../../modules/observability"
  project_name          = var.project_name
  notification_email    = var.notification_email
  public_alb_arn_suffix = module.compute.public_alb_arn_suffix
  rds_identifier        = module.rds.db_identifier
  web_asg_name          = module.compute.web_asg_name
  app_asg_name          = module.compute.app_asg_name
}

output "public_alb_dns" { value = module.compute.public_alb_dns }
#output "public_domain_fqdn" { value = module.edge.fqdn }
output "internal_alb_dns" { value = module.compute.internal_alb_dns }
output "db_endpoint" { value = module.rds.db_endpoint }
