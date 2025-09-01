output "vpc_id" { value = aws_vpc.three_tier_vpc.id }
output "aws_internet_gateway" { value = aws_internet_gateway.three_tier_igw.id}
  
output "public_subnet_ids" { value = [for s in aws_subnet.web_public_subnet : s.id] }
output "private_app_subnet_ids" { value = [for s in aws_subnet.private_app_subnet : s.id] }
output "private_db_subnet_ids" { value = [for s in aws_subnet.private_db_subnet : s.id] }
