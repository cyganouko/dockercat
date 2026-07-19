variable "aws_region" {
  description = "AWS region where the Dockercat server will be created"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for the selected AWS region"
  type        = string
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the private SSH key used to connect to the EC2 instance"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR range allowed to SSH into the EC2 instance"
  type        = string
  default     = "0.0.0.0/0"
}
