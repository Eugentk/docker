output "Elastic_IP" {
  value = aws_eip.static_ip[*].public_ip
}