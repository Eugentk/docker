terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.29.0"
    }
  }
}
provider "aws" {
  region = var.region #Main region
}
#-------------------------------------------------------------------------------
#                                 EC2 AMI
#-------------------------------------------------------------------------------
data "aws_ami" "ubuntu_ami" { # Use latest version Ubuntu 22.04
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
#-------------------------------------------------------------------------------
#                                 EC2
#-------------------------------------------------------------------------------
resource "aws_instance" "server" {
  key_name               = var.ssh_key_name
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  count                  = var.servers_count
  user_data              = file("docker.sh")
  vpc_security_group_ids = [aws_security_group.datadog_servers.id]
  subnet_id              = element(aws_subnet.aws-subnet-public-primary.*.id, count.index)
  root_block_device {
    volume_type = "gp2"
    volume_size = var.volume_size
  }
  tags = merge(var.main_tags, {
    Name = "Server for ${var.main_tags["Environment"]}-${count.index}"
  })
}
#-------------------------------------------------------------------------------
#                                 EC2 Elastic IP
#-------------------------------------------------------------------------------
resource "aws_eip" "static_ip" {
  count    = var.servers_count
  instance = aws_instance.server.*.id[count.index]
  tags = merge(var.main_tags, {
    Name = "Elastic IP for ${var.main_tags["Environment"]}-${count.index}"
  })
}
#-------------------------------------------------------------------------------
#                                 EC2 SSH Key
#-------------------------------------------------------------------------------
resource "aws_key_pair" "EC2" {
  key_name   = var.ssh_key_name
  public_key = file(var.public_key_path)
}
#-------------------------------------------------------------------------------
#                                 EC2 Security group
#-------------------------------------------------------------------------------
resource "aws_security_group" "datadog_servers" {
  name   = "Server SG"
  vpc_id = aws_vpc.Application_VPC.id
  tags = merge(var.main_tags, {
    Name = "Security Group ${var.main_tags["Environment"]}"
  })
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    protocol    = "icmp"
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
    description = "PING"
  }

  ingress {
    from_port   = 2377
    protocol    = "tcp"
    to_port     = 2377
    cidr_blocks = [var.vpc_cidr]
    description = "Docker Swarm for communication with and between manager nodes"
  }

  ingress {
    from_port   = 4789
    protocol    = "udp"
    to_port     = 4789
    cidr_blocks = [var.vpc_cidr]
    description = "Docker Swarm for overlay network traffic"
  }

  ingress {
    from_port   = 7946
    protocol    = "tcp"
    to_port     = 7946
    cidr_blocks = [var.vpc_cidr]
    description = "Docker Swarm for overlay network node discovery"
  }

  ingress {
    from_port   = 7946
    protocol    = "udp"
    to_port     = 7946
    cidr_blocks = [var.vpc_cidr]
    description = "Docker Swarm for overlay network node discovery"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}