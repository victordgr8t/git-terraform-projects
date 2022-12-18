output "us-east-1a-Public-IP" {
  value       = aws_instance.wordpress.public_ip
  description = "The Public IP address of the Web Server"
}

output "us-east-1b-Public-IP" {
  value       = aws_instance.bastion_host.public_ip
  description = "The Public IP address of Bastion Host"
}

output "us-east-1a-Private-IP" {
  value       = aws_instance.mysql.private_ip
  description = "The Private IP address of MySQL Database"
}

output "vpc_id" {
  value       = aws_vpc.prod_vpc.id
  description = "The Virtual Private Cloud(VPC) ID "
}
