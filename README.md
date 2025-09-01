## Three-Tier Architecture on AWS using Terraform
This project implements a three-tier architecture on AWS using Terraform for codesecure, modular, and production-grade AWS infrastructure. The architecture follows best practices for high availability, scalability, and security. We are having the following components in this project:

## 1. Bootstrap Stage (Secure Terraform Backend)
Creating a dedicated S3 bucket to store Terraform state files safely:
🔒 Uses KMS encryption
✅ Has versioning and object locking (protects against accidental deletion)
🧾 Bucket policy allows access only to your terraform-mainuser IAM user
📂 Separate logging bucket for audit trails
This ensures your infrastructure state is centralized, secure, and immutable.

## 2. Network Layer (VPC, Subnets, NAT, Routes)
We are provisioning the core network:
🛡️ Custom VPC
🌐 Public subnets (for web tier)
🔐 Private subnets (for app + DB tier)
🚪 NAT Gateways for outbound access from private instances
📡 Internet Gateway for public access
This gives you a solid foundation for isolation, security, and control.

## 3. Compute Layer (EC2, ALBs, Launch Templates)
Launching EC2 instances in the web and app tiers via:
🧬 Launch templates
🔄 Auto Scaling Groups
🌐 Public-facing ALB (for user traffic to web tier)
🔁 Internal ALB (for communication between web ↔ app tiers)
This provides high availability and scalability.

## 4. Security Layer (Security Groups, ACM, WAF)
We’ve implemented security best practices:
🚧 Security Groups for web, app, and DB tiers
🔐 ACM Certificates for TLS/SSL
🌍 Route53 records to map DNS
🛡️ Optional WAF to block malicious traffic
Everything is restricted by least privilege and follows zero trust.

## 5. Observability Layer (CloudWatch, SNS)
We are adding monitoring and alerting using:
📈 CloudWatch Alarms (e.g. ALB 5xx errors, CPU usage)
🔔 SNS Topic + Email Subscription for real-time alerts
This helps with early detection of issues and proactive response.

## 6. Best Practices
✅ Modules: Clean, reusable code in modules/
✅ .gitignore: Keeps secrets, states, and local files out of Git
✅ Remote backend: Ensures shared, protected state management
✅ Least privilege: Only terraform-mainuser can access the backend
✅ S3 VPC Gateway Endpoint: Allows private subnets to access S3 securely (no NAT cost)
