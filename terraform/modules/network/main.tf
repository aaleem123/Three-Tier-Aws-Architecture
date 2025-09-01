resource "aws_vpc" "three_tier_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { 
    Name = "${var.project_name}-vpc" }
}

##### Internet Gateway
resource "aws_internet_gateway" "three_tier_igw" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = { Name = "${var.project_name}-igw" }
}

##### Public Subnets
resource "aws_subnet" "web_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-web-public-${count.index + 1}"
  }
}

##### Private Subnets
resource "aws_subnet" "private_app_subnet" {
  count             = length(var.private_app_subnet_cidrs)
  vpc_id            = aws_vpc.three_tier_vpc.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "${var.project_name}-private-app-${count.index + 1}" }
}

resource "aws_subnet" "private_db_subnet" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.three_tier_vpc.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = { Name = "${var.project_name}-private-db-${count.index + 1}" }
}

####### NAT GATEWAY One NAT per AZ (best HA)
resource "aws_eip" "nat_gateway_eip" {
  count      = length(var.azs)
  domain     = "vpc"

  tags = { Name = "${var.project_name}-eip-nat-${count.index}" }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat_gateway_eip[count.index].id
  subnet_id     = aws_subnet.web_public_subnet[count.index].id

  tags = { Name = "${var.project_name}-nat-${count.index + 1}" }

  depends_on = [aws_internet_gateway.three_tier_igw]
}

####### Route Tables & Associations 
##### Public route tables
resource "aws_route_table" "public_route_table" {
  vpc_id   = aws_vpc.three_tier_vpc.id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three_tier_igw.id
    }

  tags = { Name = "${var.project_name}-rt-public"}
}

resource "aws_route_table_association" "public_subnet_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.web_public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

#### Private route tables
### Each route table for since we have 2 NAT Gateways per each subnet here
resource "aws_route_table" "private_app_route_table" {
  count    = length(var.private_app_subnet_cidrs)
  vpc_id   = aws_vpc.three_tier_vpc.id

  route { 
    cidr_block = "0.0.0.0/0" 
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
    }

  tags = { Name = "${var.project_name}-rt-private-app-${count.index + 1}" }
}

resource "aws_route_table_association" "private_subnet_assoc" {
  count          = length(var.private_app_subnet_cidrs)
  subnet_id      = aws_subnet.private_app_subnet[count.index].id
  route_table_id = aws_route_table.private_app_route_table[count.index].id
}

# Database Route Tables
resource "aws_route_table" "database_route_table" {
  count  = length(var.private_db_subnet_cidrs)
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name        = "${var.project_name}-database-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_db_assoc" {
  count          = length(var.private_db_subnet_cidrs)
  subnet_id      = aws_subnet.private_db_subnet[count.index].id
  route_table_id = aws_route_table.database_route_table[count.index].id
}



####s3 vpc endpoint 

resource "aws_vpc_endpoint" "s3_vpc_ep_gateway" {
  vpc_id            = aws_vpc.three_tier_vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = concat(
      aws_route_table.private_app_route_table[*].id,
      aws_route_table.database_route_table[*].id
  )

    # Inline read-only policy for bucket
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::${var.bucket_name}"
      },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject","s3:GetObjectVersion"],
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }
  ]
}
EOT

  tags = {
    Name = "${var.project_name}-s3-gateway-endpoint"
  }
}
