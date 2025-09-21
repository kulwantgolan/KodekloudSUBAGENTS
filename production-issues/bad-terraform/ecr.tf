# ECR Repository with multiple security issues
resource "aws_ecr_repository" "app" {
  name = "my-app"

  # SECURITY ISSUE: No image scanning enabled
  # MISSING: image_scanning_configuration block

  # SECURITY ISSUE: No encryption configuration
  # MISSING: encryption_configuration block

  # MISSING: Lifecycle policy for old image cleanup
  # This can lead to unnecessary costs

  # MISSING: Image tag mutability should be IMMUTABLE
  image_tag_mutability = "MUTABLE"  # Bad practice - allows tag overwriting
}

# SECURITY ISSUE: Overly permissive ECR policy
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

# MISSING: ECR lifecycle policy to manage image retention
# MISSING: ECR replication configuration for disaster recovery