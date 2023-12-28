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
 ##natgw
 module "nat" {
   source = "./modules/nat_gw"
   eip_id = module.eip.eip_id
   tags_nat = var.tags_nat
   nat_subnet_id = module.subnet-pub-1a.subnet_id
 }
###public_RTB
module "public_rt" {
  source = "./modules/route_tables"
  rt_tags = var.rt_tags_pub
  rt_cidr_block = var.rt_cidr_block_priv
  gateway_id = module.igw.my_igw_id
  vpc_id = module.my_vpc.my_vpc_id
}

module "private_rt" {
  source = "./modules/route_tables"
  rt_tags = var.rt_tags_priv
  rt_cidr_block = var.rt_cidr_block_priv
  gateway_id = module.nat.nat_id
  vpc_id = module.my_vpc.my_vpc_id
}