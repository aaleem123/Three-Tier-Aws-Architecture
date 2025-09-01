output "rds_endpoint" { value = aws_db_instance.rds_instances.endpoint }
output "db_identifier" { value = aws_db_instance.rds_instances.id }
output "db_endpoint" {
  description = "RDS instance endpoint hostname"
  value       = aws_db_instance.rds_instances.address
}
