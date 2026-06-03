output "ip_publico_servidor" {
  description = "O endereço ID publico para acessar o Apache"
  value       = aws_instance.meu-servidor.public_ip
}