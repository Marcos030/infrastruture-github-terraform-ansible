# infra/backend.tf
terraform {
  backend "s3" {
    bucket         = "nome-do-seu-bucket-s3"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock" # Opcional, mas recomendado
  }
}