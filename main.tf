#Create VPC
resource "aws_vpc" "terraform-vpc" {
 cidr_block = var.aws_vpc_cidr   
  
  tags = {
    Name = "terraform-vpc"
  }
}


#Create internet Gateway attached to terraform-vpc
resource "aws_internet_gateway" "terraform-vpc-ig" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "Terraform VPC IG"
  }
}

#Create a route table attached to terraform-vpc, 
resource "aws_route_table" "terraform-vpc-rtb" {
  vpc_id = aws_vpc.terraform-vpc.id
  
#route internet gateway to internet  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-vpc-ig.id
  }

  tags = {
    Name = "Terraform VPC RTB"
  }
}


#create subnets for AZ1
resource "aws_subnet" "aws-az1-subnets" {
    count = length(var.aws_az1_subnets_cidr)
    vpc_id = aws_vpc.terraform-vpc.id
    cidr_block = element(var.aws_az1_subnets_cidr, count.index)
    availability_zone = var.aws_subnet_cidrs_AZ1

    tags = {
      Name = "${var.aws_subnet_cidrs_AZ1} subnet ${count.index + 1}"
    }
}

#create subnets for AZ2
resource "aws_subnet" "aws-az2-subnets" {
  count = length(var.aws_az2_subnets_cidr)
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = element(var.aws_az2_subnets_cidr, count.index)
  availability_zone = var.aws_subnet_cidrs_AZ2

    tags = {
      Name = "${var.aws_subnet_cidrs_AZ2} subnet ${count.index + 1}"
    }
}


#create security group for ALB
resource "aws_security_group" "terraform-alb-sg" {
  name = "Terraform ALB SG"
  description = "allow HTTP"
  vpc_id = aws_vpc.terraform-vpc.id
  
  ingress {
    description = "HTTP ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create Application Load Balancer 
resource "aws_lb" "terraform-alb" {
  name = "Terraform-ALB"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.terraform-alb-sg.id]
  subnets = [aws_subnet.aws-az1-subnets[0].id, aws_subnet.aws-az2-subnets[0].id]

  tags = {
    Name = "Terraform ALB"
  }
}

#create target group for the ALB
resource "aws_lb_target_group" "terraform-alb-aws_lb_target_group" {
  name = "target-group-1"
  port = "80"
  protocol = "HTTP"
  vpc_id = aws_vpc.terraform-vpc.id
  }


#create ALB Listener to forward to the target group on port 80
resource "aws_lb_listener" "terraform-alb-listener" {
  load_balancer_arn = aws_lb.terraform-alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.terraform-alb-aws_lb_target_group.arn
  }
}


#find latest Ubuntu image 
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



#launch EC2 instance with nginx installed
resource "aws_instance" "terraform-instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.micro"
  subnet_id = aws_subnet.aws-az1-subnets[0].id
  security_groups = [aws_security_group.terraform-alb-sg.id]
  user_data = file("script.sh")

  tags = {
    Name = "Terraform Ubuntu Instance"
  }
}

#attach EC2 to the target group
resource "aws_lb_target_group_attachment" "terraform-target-group-attachment" {
  target_group_arn = aws_lb_target_group.terraform-alb-aws_lb_target_group.arn
  target_id = aws_instance.terraform-instance.id
  port = "80"
}

