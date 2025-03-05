terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.89.0"
    }
  }
}




#Set provider config
provider "aws" {
  region = var.aws_region
  access_key= var.aws_access_key 
  secret_key= var.aws_secret_key
 #shared_credentials_files = ["~/.aws/credentials"]
  #profile = "testprofile"
}