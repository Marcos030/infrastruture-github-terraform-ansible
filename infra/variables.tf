# variables.tf
variable "region" {
  default = "us-east-1"
}

variable "admin_password" {
  description = "Senha para o usuario ubuntu"
  type        = string
  sensitive   = true
  default     = "Torresmo!@123!(*@)"
}