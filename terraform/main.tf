provider "aws" {
  region = "us-east-1"
}

# Security Group for EC2 Instance
resource "aws_security_group" "instance_sg" {
  name_prefix = "instance-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = "ami-05b10e08d247fb927" # Replace AMI with Cloud Prover(AWS) EC2
  instance_type = "t2.micro"
  key_name      = "quest-key" # Replace with your key pair name
  security_groups = [aws_security_group.instance_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo docker run -d -p 80:3000 -e SECRET_WORD=CLOUDY --name quest-app prajshet/quest-app
              EOF

  tags = {
    Name = "CloudQuestApp"
  }
}

# Load Balancer
resource "aws_lb" "app_lb" {
  name               = "cloud-quest-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = ["subnet-04dcc7a12712d21d8", "subnet-01e68483d3948bc68"] # Replace with your subnet IDs
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "cloud-quest-tg"
  port     = 80 # Changed to match the container's exposed port
  protocol = "HTTP"
  vpc_id   = "vpc-0d1ad4f4b38184581" # Replace with your VPC ID

  health_check {
    path = "/"
    port = 80
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name_prefix = "lb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Attach EC2 Instance to Target Group
resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 80
}