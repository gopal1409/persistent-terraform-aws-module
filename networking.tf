##this will create the vpc
module "my_vpc" {
  source = "./modules/vpc"
  cidr_vpc = var.cidr_vpc
  tags_vpc = var.tags_vpc
}

###igw
module "igw" {
  source = "./modules/internet_gw"
  vpc_id = module.my_vpc.my_vpc_id
  #we map the vpc id from the output.tf file inside vpc module folder
  #output "my_vpc_id" {
  #value = aws_vpc.my_vpc.my_vpc_id
 #}
  tags_igw = var.tags_igw
}

module "eip" {
    source = "./modules/elastic_ip"
    tags_eip = var.tags_eip 
    igw = module.igw   
}

