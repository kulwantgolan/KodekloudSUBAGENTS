provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security group for application"

  # SECURITY ISSUE: SSH open to the world!
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # CRITICAL: Never do this in production!
  }

  # SECURITY ISSUE: Application port open to the world
  ingress {
    description = "App port from anywhere"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Should be restricted to load balancer
  }

  # Overly permissive egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MISSING: No tags for resource management
}

# SECURITY ISSUE: S3 bucket without encryption
resource "aws_s3_bucket" "data" {
  bucket = "my-app-data-bucket"

  # MISSING: Server-side encryption configuration
  # MISSING: Versioning
  # MISSING: Logging
  # MISSING: Public access block
}

# SECURITY ISSUE: S3 bucket with public read access
resource "aws_s3_bucket_acl" "data" {
  bucket = aws_s3_bucket.data.id
  acl    = "public-read"  # CRITICAL: Bucket is publicly readable!
}

# EC2 Instance with security issues
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"  # Hardcoded AMI
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.app.id]

  # SECURITY ISSUE: No key pair for SSH access control
  # MISSING: IAM instance profile
  # MISSING: Monitoring enabled
  # MISSING: Encryption for root volume

  tags = {
    Name = "app-server"
    # MISSING: Environment, Owner, Project tags
  }
}