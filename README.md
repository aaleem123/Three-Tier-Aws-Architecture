# Three Tier Architecture on AWS using Terraform
This project implements a three-tier architecture on AWS using Terraform for codesecure, modular, and production-grade AWS infrastructure. The architecture follows best practices for high availability, scalability, and security. We are having the following components in this project:

<img width="1022" height="1051" alt="Three Tier Aws Architecture drawio" src="https://github.com/user-attachments/assets/e4a5a620-f073-4e2f-b464-ce896bb55620" />

## ✅ Prerequisites
Before running this project, ensure you have the following tools and configurations set up:
- AWS CLI – for managing AWS resources from the terminal: aws configure to log in as your user with AWS Access Key ID and AWS Secret Access Key.
- Terraform – for Infrastructure as Code: download latest version of Terraform 
- Git – for version control and pushing to GitHub: configure github once

## 🔐 IAM & Bucket Policies (Secure Access Controls)
We’ve implemented strong access control mechanisms to ensure Terraform can interact securely with the S3 backend:
- 👤 IAM User:
A dedicated IAM user named terraform-mainuser is used to run Terraform. This avoids using the root user and aligns with AWS best practices.
- 🪪 S3 Bucket Policy:
The backend S3 bucket has a bucket policy that:
- ✅ Grants full access (GetObject, PutObject, DeleteObject, ListBucket) only to the terraform-mainuser
- 🚫 Denies all access over insecure transport (http) using the aws:SecureTransport condition: over HTTPs 
- 🔐 Ensures least privilege and secure, encrypted communication at all times
- 🛡️ No root access used:
We intentionally do not use the root account in any policies or operations. The project is built around delegated access through a least-privilege IAM user.

## 1. Bootstrap Stage (Secure Terraform Backend)
Creating a dedicated S3 bucket to store Terraform state files safely:
- 🔒 Uses KMS encryption
- ✅ Has versioning and object locking (protects against accidental deletion)
- 🧾 Bucket policy allows access only to your terraform-mainuser IAM user
- 📂 Separate logging bucket for audit trails
- 🛡️ S3 Gateway Endpoint is used instead of a NAT Gateway — this allows private subnets to access S3 at zero cost, making it a highly sustainable and cost-effective option.

## 2. Network Layer (VPC, Subnets, NAT, Routes)
We are provisioning the core network:
- 🛡️ Custom VPC
- 🌐 Public subnets (for web tier)
- 🔐 Private subnets (for app + DB tier)
- 🗺️ Route tables created and correctly associated with the respective public and private subnets, along with IGW/NAT
- 🚪 NAT Gateways (one per AZ) to allow outbound internet access from private instances — ensures high availability if one AZ goes down
- 📡 Internet Gateway for public access
This gives you a solid foundation for isolation, security, and control.

## 3. Compute Layer (EC2, ALBs, Launch Templates)
Launching EC2 instances in the web and app tiers via:
- 🧬 Launch templates
- 🔄 Auto Scaling Groups
- 🌐 Public-facing ALB (for user traffic to web tier)
- 🔁 Internal ALB (for communication between web ↔ app tiers)
This provides high availability and scalability.

## 4. Security Layer (Security Groups, ACM, WAF)
We’ve implemented security best practices:
- 🚧 Security Groups for web, app, and DB tiers
- 🔐 ACM Certificates for TLS/SSL
- 🌍 Route53 records to map DNS
- 🛡️ Optional WAF to block malicious traffic
Everything is restricted by least privilege and follows zero trust.

## 5. Observability Layer (CloudWatch, SNS)
We are adding monitoring and alerting using:
- 📈 CloudWatch Alarms (e.g. ALB 5xx errors, CPU usage)
- 🔔 SNS Topic + Email Subscription for real-time alerts
This helps with early detection of issues and proactive response.

## 6. RDS (Relational Database Service)
We are provisioning a secure and private Amazon RDS instances to serve the database tier.
- 🧱 Engine: MySQL (can be easily swapped with PostgreSQL, MariaDB, etc.)
- 🏷️ Instance Class: e.g., db.t3.micro (customizable for dev/prod)
- 🚫 No Public Access: RDS is placed in private subnets for isolation

## 📦 Modular Structure & Backend with Native S3 State Locking
We’ve structured the project for scalability and reusability using a modular Terraform layout:
  📁 envs/dev/
- This is our environment layer that wires all modules together for the dev environment. Uses module blocks to call network, compute, security, observability, and rds.
- Loads environment-specific variables via terraform.tfvars
- 🔗 Remote Backend Setup with Native State Locking: The backend is defined directly inside envs/dev to enable secure and remote state storage. We are using S3 native state locking for to prevent concurrent runs from modifying the state at the same time.
  
## Best Practices
- ✅ Modules: Clean, reusable code in modules/
- ✅ .gitignore: Keeps secrets, states, and local files out of Git
- ✅ Remote backend: Ensures shared, protected state management
- ✅ S3 VPC Gateway Endpoint: Allows private subnets to access S3 securely (no NAT cost)
