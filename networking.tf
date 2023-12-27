module "my_vpc" {
  source = "./modules/vpc"
  cidr_vpc = var.cidr_vpc
  tags_vpc = var.tags_vpc
}