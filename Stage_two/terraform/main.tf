terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "dockercat" {
  name        = "dockercat-stage2"
  description = "Security group for Dockercat Stage 2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Dockercat frontend"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Dockercat backend API"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "dockercat-stage2-security-group"
    Project     = "Dockercat"
    Environment = "Stage2"
  }
}

resource "aws_instance" "dockercat" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.dockercat.id]

  tags = {
    Name        = "dockercat-stage2-server"
    Project     = "Dockercat"
    Environment = "Stage2"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for EC2 instance SSH to become available..."
      sleep 30
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i '${self.public_ip},' \
        --private-key '${var.ssh_private_key_path}' \
        -u ubuntu \
        ../playbook.yml
    EOT
  }
}
