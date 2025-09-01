####Defines a DB subnet group (a requirement for launching RDS in specific subnets)
resource "aws_db_subnet_group" "rds_launcher" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = { 
    Name = "${var.project_name}-db-subnet-group" 
    }
}
######Purpose: Creates a MySQL RDS instance inside the specified subnet group
resource "aws_db_instance" "rds_instances" {
  identifier              = "${var.project_name}-mysql"
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.username
  password                = var.password
  allocated_storage       = var.allocated_storage
  db_subnet_group_name    = aws_db_subnet_group.rds_launcher.name
  vpc_security_group_ids  = var.db_sg_id
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = var.multi_az
  publicly_accessible     = false
  apply_immediately       = true
  tags = { Name = "${var.project_name}-mysql" }
}

#What are we doing here:
#Asking AWS:
#“Hey AWS, can you run a managed MySQL database for me using 
#these settings (storage, version, username, password, etc)?”
#AWS creates and manages the actual database instance
#You just define the specs (via your terraform code)