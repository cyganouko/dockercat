output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.dockercat.id
}

output "public_ip" {
  description = "Public IP address of the Dockercat EC2 instance"
  value       = aws_instance.dockercat.public_ip
}

output "frontend_url" {
  description = "Dockercat frontend URL"
  value       = "http://${aws_instance.dockercat.public_ip}:3000"
}

output "backend_url" {
  description = "Dockercat backend API URL"
  value       = "http://${aws_instance.dockercat.public_ip}:5000"
}
