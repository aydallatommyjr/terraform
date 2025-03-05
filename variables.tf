#Initialize Variables

variable "aws_access_key" {
  description = "aws access key"
}

variable "aws_secret_key" {
  description = "aws secret key"
}

variable "aws_region" {
  description = "aws default region"
}

variable "aws_vpc_cidr" {
  description = "aws default region"
}

variable "aws_private_subnet_cidrs"{
  description = "list of private subnet"
  type=list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}
variable "aws_public_subnet_cidrs" {
  description = "list of public subnet"
  type = list(string)
  default = [ "10.0.3.0/24", "10.0.4.0/24" ]
}
variable "aws_private_subnet_cidrs_AZ" {
  type = string
  description = "Availability Zone for private subnet cidrs"
}
variable "aws_public_subnet_cidrs_AZ" {
  type = string
  description = "Availability Zone for public subnet cidrs"
}