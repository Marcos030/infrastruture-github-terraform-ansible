# infra/backend.tf
terraform {
  backend "s3" {
    bucket         = "vm-automation-git-terraform-ansible-01"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock" # Opcional, mas recomendado
  }
}