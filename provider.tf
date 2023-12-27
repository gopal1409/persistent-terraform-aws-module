##we will create the terraform provider 
##who is the provider
##aws we will create aws provider. 
##3how to get the provider setting. 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" ###this version number of optional but recommended in production
    }
     
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

