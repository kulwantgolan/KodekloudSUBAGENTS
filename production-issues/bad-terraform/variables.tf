# Variables file with security issues

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "admin123"  # SECURITY ISSUE: Hardcoded password!
}

variable "api_key" {
  description = "API Key for external service"
  type        = string
  default     = "sk-1234567890abcdef"  # SECURITY ISSUE: Hardcoded API key!
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"  # Using production as default is risky
}

variable "ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"  # SECURITY ISSUE: Default allows all IPs
}

# MISSING: Variable validation rules
# MISSING: Sensitive flag for secrets