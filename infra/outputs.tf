output "public_ip_address" {
  value       = aws_instance.vm.public_ip
  description = "Endereço IP público da instância"
}

output "instance_id" {
  value       = aws_instance.vm.id
  description = "ID da instância EC2"
}