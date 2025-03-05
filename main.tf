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

#Create a route table attached to terraform-vpc
resource "aws_route_table" "terraform-vpc-rtb" {
  vpc_id = aws_vpc.terraform-vpc.id
  
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-vpc-ig.id
  }

  tags = {
    Name = "Terraform VPC RTB"
  }
}



resource "aws_subnet" "aws-private-subnets" {
    count = length(var.aws_private_subnet_cidrs)
    vpc_id = aws_vpc.terraform-vpc.id
    cidr_block = element(var.aws_private_subnet_cidrs, count.index)
    availability_zone = var.aws_private_subnet_cidrs_AZ

    tags = {
      Name = "Private Subnet ${count.index + 1}"
    }
}

  
resource "aws_subnet" "aws-public-subnets" {
  count = length(var.aws_public_subnet_cidrs)
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = element(var.aws_public_subnet_cidrs, count.index)
  availability_zone = var.aws_public_subnet_cidrs_AZ

    tags = {
      Name = "Public Subnet ${count.index + 1}"
    }
}


