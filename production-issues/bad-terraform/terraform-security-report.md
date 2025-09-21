# Terraform Security Scan Report

## Executive Summary

A comprehensive security scan was performed on the Terraform configuration files in `/root/production-issues/bad-terraform/` using Checkov. The scan identified **20 failed security checks** across 6 resources, with **12 checks passing**. The configuration contains critical security vulnerabilities, particularly in ECR repository policies, security group configurations, and S3 bucket settings.

**Overall Risk Level: CRITICAL**

Key findings include:
- ECR repository with overly permissive access policies allowing any AWS user to perform all ECR operations
- Security groups exposing SSH and application ports to the entire internet
- S3 bucket configured with public read access
- Missing encryption, monitoring, and access controls across multiple resources

## ECR-Specific Findings

### 1. ECR Repository Access Policy (CKV_AWS_32) - HIGH
**Issue:** The ECR repository policy allows any AWS principal (`"AWS": "*"`) to perform all ECR operations including push, pull, and delete.

**Risk:** Unauthorized users with AWS credentials can access, modify, or delete container images, potentially introducing malicious code or disrupting deployments.

**Location:** `ecr.tf:19-43`

**Code Snippet:**
```hcl
resource "aws_ecr_repository_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = "AllowAll"
        Effect = "Allow"
        Principal = {
          AWS = "*"  # CRITICAL: Allows anyone with AWS credentials!
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}
```

### 2. Missing Image Scanning (CKV_AWS_163) - MEDIUM
**Issue:** Image scanning on push is not enabled for the ECR repository.

**Risk:** Vulnerabilities in container images may go undetected, allowing deployment of insecure containers.

**Location:** `ecr.tf:2-16`

### 3. Mutable Image Tags (CKV_AWS_51) - MEDIUM
**Issue:** Image tag mutability is set to "MUTABLE", allowing tags to be overwritten.

**Risk:** Inability to reliably reference specific image versions, potential for accidental overwrites of production images.

**Location:** `ecr.tf:15`

### 4. Missing Encryption (CKV_AWS_136) - MEDIUM
**Issue:** ECR repository is not configured with KMS encryption.

**Risk:** Container images stored unencrypted, vulnerable to data breaches if storage is compromised.

**Location:** `ecr.tf:2-16`

## General Security Findings

### Security Group Vulnerabilities

#### 1. SSH Open to World (CKV_AWS_24) - HIGH
**Issue:** Security group allows SSH access (port 22) from any IP address (0.0.0.0/0).

**Risk:** Unauthorized SSH access to EC2 instances, potential for credential theft or system compromise.

**Location:** `main.tf:5-36`

#### 2. Application Port Open to World - HIGH
**Issue:** Security group allows access to application port (5000) from any IP address.

**Risk:** Unauthorized access to application, potential for data breaches or service disruption.

**Location:** `main.tf:18-25`

#### 3. Overly Permissive Egress (CKV_AWS_382) - MEDIUM
**Issue:** Security group allows all outbound traffic to any destination.

**Risk:** Instances can communicate with any external service, increasing attack surface.

**Location:** `main.tf:27-32`

#### 4. Missing Descriptions (CKV_AWS_23) - LOW
**Issue:** Security group rules lack descriptions.

**Risk:** Poor documentation makes security review and maintenance difficult.

### EC2 Instance Vulnerabilities

#### 1. IMDSv1 Enabled (CKV_AWS_79) - MEDIUM
**Issue:** Instance Metadata Service Version 1 is not disabled.

**Risk:** Vulnerable to Server-Side Request Forgery (SSRF) attacks that can steal instance credentials.

**Location:** `main.tf:55-70`

#### 2. Missing Detailed Monitoring (CKV_AWS_126) - MEDIUM
**Issue:** Detailed CloudWatch monitoring is not enabled.

**Risk:** Limited visibility into instance performance and security events.

#### 3. Unencrypted Root Volume (CKV_AWS_8) - MEDIUM
**Issue:** Root EBS volume is not encrypted.

**Risk:** Data at rest is not protected, vulnerable to unauthorized access if disk is compromised.

#### 4. Not EBS Optimized (CKV_AWS_135) - LOW
**Issue:** Instance is not EBS optimized.

**Risk:** Reduced I/O performance for EBS volumes.

#### 5. Missing IAM Role (CKV2_AWS_41) - MEDIUM
**Issue:** No IAM instance profile attached to EC2 instance.

**Risk:** Instance cannot access AWS services securely, forcing use of hardcoded credentials or overly permissive policies.

### S3 Bucket Vulnerabilities

#### 1. Public Read Access (CKV_AWS_20) - CRITICAL
**Issue:** S3 bucket ACL is set to "public-read", allowing anyone to read bucket contents.

**Risk:** Sensitive data exposure, potential data breaches, compliance violations.

**Location:** `main.tf:49-52`

#### 2. Missing Public Access Block (CKV2_AWS_6) - HIGH
**Issue:** No public access block configuration to prevent accidental public exposure.

**Risk:** Increased risk of accidental public exposure of sensitive data.

#### 3. Missing Versioning (CKV_AWS_21) - MEDIUM
**Issue:** S3 bucket versioning is not enabled.

**Risk:** No protection against accidental deletion or overwrites, difficult disaster recovery.

#### 4. Missing Server-Side Encryption (CKV_AWS_145) - MEDIUM
**Issue:** S3 bucket is not configured with KMS encryption by default.

**Risk:** Data stored unencrypted, vulnerable to unauthorized access.

#### 5. Missing Access Logging (CKV_AWS_18) - MEDIUM
**Issue:** S3 access logging is not enabled.

**Risk:** No audit trail for bucket access, difficult to detect security incidents.

#### 6. Missing Lifecycle Configuration (CKV2_AWS_61) - LOW
**Issue:** No lifecycle rules for automatic data management.

**Risk:** Accumulation of unnecessary data, increased storage costs.

#### 7. Missing Event Notifications (CKV2_AWS_62) - LOW
**Issue:** S3 event notifications are not configured.

**Risk:** No automated responses to bucket changes, reduced operational efficiency.

#### 8. Missing Cross-Region Replication (CKV_AWS_144) - LOW
**Issue:** No cross-region replication for disaster recovery.

**Risk:** Single point of failure, no geographic redundancy.

## Severity Assessment

- **CRITICAL (2 issues):** ECR policy allowing public access, S3 bucket with public read ACL
- **HIGH (3 issues):** SSH and application ports open to world, missing S3 public access block
- **MEDIUM (13 issues):** Various encryption, monitoring, and configuration issues
- **LOW (2 issues):** Missing descriptions and lifecycle configurations

## Remediation Steps

### Immediate Actions (Critical Issues)

1. **Fix ECR Repository Policy**
   ```hcl
   resource "aws_ecr_repository_policy" "app" {
     repository = aws_ecr_repository.app.name

     policy = jsonencode({
       Version = "2008-10-17"
       Statement = [
         {
           Sid    = "AllowSpecificPrincipals"
           Effect = "Allow"
           Principal = {
             AWS = "arn:aws:iam::123456789012:root"  # Replace with specific account/role ARNs
           }
           Action = [
             "ecr:GetDownloadUrlForLayer",
             "ecr:BatchGetImage",
             "ecr:BatchCheckLayerAvailability"
           ]
         }
       ]
     })
   }
   ```

2. **Remove S3 Public Access**
   ```hcl
   resource "aws_s3_bucket_acl" "data" {
     bucket = aws_s3_bucket.data.id
     acl    = "private"
   }

   resource "aws_s3_bucket_public_access_block" "data" {
     bucket = aws_s3_bucket.data.id

     block_public_acls       = true
     block_public_policy     = true
     ignore_public_acls      = true
     restrict_public_buckets = true
   }
   ```

3. **Restrict Security Group Access**
   ```hcl
   resource "aws_security_group" "app" {
     name        = "app-sg"
     description = "Security group for application"

     ingress {
       description = "SSH from specific IP ranges"
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Replace with actual allowed ranges
     }

     ingress {
       description = "App port from load balancer"
       from_port   = 5000
       to_port     = 5000
       protocol    = "tcp"
       cidr_blocks = ["10.0.0.0/8"]  # Replace with load balancer subnets
     }

     egress {
       description = "Allow outbound traffic to required services"
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
     }
   }
   ```

### ECR Security Improvements

4. **Enable Image Scanning**
   ```hcl
   resource "aws_ecr_repository" "app" {
     name = "my-app"

     image_scanning_configuration {
       scan_on_push = true
     }

     image_tag_mutability = "IMMUTABLE"

     encryption_configuration {
       encryption_type = "KMS"
       kms_key         = aws_kms_key.ecr.arn  # Create KMS key
     }
   }
   ```

5. **Add Lifecycle Policy**
   ```hcl
   resource "aws_ecr_lifecycle_policy" "app" {
     repository = aws_ecr_repository.app.name

     policy = jsonencode({
       rules = [{
         rulePriority = 1
         description  = "Keep last 10 images"
         selection = {
           tagStatus   = "any"
           countType   = "imageCountMoreThan"
           countNumber = 10
         }
         action = {
           type = "expire"
         }
       }]
     })
   }
   ```

### EC2 Security Improvements

6. **Secure EC2 Instance**
   ```hcl
   resource "aws_instance" "app" {
     ami           = data.aws_ami.amazon_linux.id  # Use data source instead of hardcoded
     instance_type = "t2.micro"

     iam_instance_profile = aws_iam_instance_profile.app.name
     monitoring          = true
     ebs_optimized      = true

     metadata_options {
       http_tokens = "required"  # Disable IMDSv1
     }

     root_block_device {
       encrypted = true
     }

     vpc_security_group_ids = [aws_security_group.app.id]

     tags = {
       Name        = "app-server"
       Environment = "production"
       Owner       = "team-name"
       Project     = "my-app"
     }
   }
   ```

### S3 Security Improvements

7. **Secure S3 Bucket**
   ```hcl
   resource "aws_s3_bucket" "data" {
     bucket = "my-app-data-bucket"
   }

   resource "aws_s3_bucket_versioning" "data" {
     bucket = aws_s3_bucket.data.id
     versioning_configuration {
       status = "Enabled"
     }
   }

   resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
     bucket = aws_s3_bucket.data.id

     rule {
       apply_server_side_encryption_by_default {
         sse_algorithm = "aws:kms"
         kms_master_key_id = aws_kms_key.s3.arn
       }
       bucket_key_enabled = true
     }
   }

   resource "aws_s3_bucket_logging" "data" {
     bucket = aws_s3_bucket.data.id

     target_bucket = aws_s3_bucket.logs.id
     target_prefix = "s3-access-logs/"
   }

   resource "aws_s3_bucket_lifecycle_configuration" "data" {
     bucket = aws_s3_bucket.data.id

     rule {
       id     = "delete_old_versions"
       status = "Enabled"

       noncurrent_version_expiration {
         noncurrent_days = 30
       }
     }
   }
   ```

## Recommendations

1. **Implement Least Privilege Access:** Replace wildcard principals with specific IAM roles/users
2. **Enable Encryption Everywhere:** Use KMS encryption for all data at rest
3. **Implement Monitoring:** Enable CloudWatch monitoring and alerts
4. **Use Infrastructure as Code Best Practices:** Avoid hardcoded values, use variables and data sources
5. **Regular Security Scans:** Implement automated security scanning in CI/CD pipelines
6. **Access Reviews:** Regularly review and audit access policies
7. **Backup and Recovery:** Implement backup strategies and disaster recovery plans
8. **Documentation:** Maintain comprehensive documentation of security configurations

## Scan Summary

- **Total Checks:** 32
- **Passed:** 12
- **Failed:** 20
- **Resources Scanned:** 6
- **Checkov Version:** 3.2.471

This configuration requires immediate attention to address critical security vulnerabilities before deployment to production environments.