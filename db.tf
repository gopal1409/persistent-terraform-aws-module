###subnet for web layer
module "subnet-rds-private-1a" {
  source = "./modules/subnet"
  vpc_id = module.my_vpc.my_vpc_id
  cidr_subnet = "172.16.5.0/24"
  az_subnet = "us-east-1a"
  public = false
  tags_subnet = {
    Name = "tf-private-rds-us-east-1a"
  }
}

###subnet for web layer
module "subnet-rds-private-1b" {
  source = "./modules/subnet"
  vpc_id = module.my_vpc.my_vpc_id
  cidr_subnet = "172.16.6.0/24"
  az_subnet = "us-east-1b"
  public = false
  tags_subnet = {
    Name = "tf-private-rds-us-east-1b"
  }
}

###associate with public route table
module "rt_ass_rds_priv_1a" {
  source = "./modules/rt_association"
  subnet_id = module.subnet-rds-private-1a.subnet_id
  route_table_id = module.private_rt.rt_id
}

module "rt_ass_rds_priv_1b" {
  source = "./modules/rt_association"
  subnet_id = module.subnet-rds-private-1b.subnet_id
  route_table_id = module.private_rt.rt_id
}

module "sg_rds" {
  source = "./modules/sg"
  ingress_rules = [
    {
      description     = "allow on 3306"
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      cidr_blocks     = null
      security_groups = [module.sg_app_server.sg_id]
    }
    
  ] #var.ingress_rules_web_server
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = "tf_sg_rds"
  sg_description = "sg for rds"
  egress_rules   = [
    { 
      description     = "allow on 3306"
      from_port       = 3306
      to_port         =3306
      protocol        = "tcp"
      cidr_blocks     = null
      security_groups = [module.sg_app_server.sg_id]
  }
  ]
  #security_groups = var.security_groups_web_server
  tags_sg = {
    Name = "tf-db-sg"
  }
}

  module "db_subnet_group" {
    source = "./modules/subnet_group"
    subnet_ids_subnet_group = [module.subnet-rds-private-1a.subnet_id,module.subnet-rds-private-1b.subnet_id]
    subnet_group_name = "tf-main"

    tags_subnet_group = {
    Name = "tf-db-subnetgrup"
  }
  }

module "db" {
  source = "./modules/rds"
  identifier_name = "tf-db"
  allocated_storage = 10
  db_name = "persona"
  username = "admin"
  vpc_security_group_ids = [module.sg_rds.sg_id]
  subnet_group_name = module.db_subnet_group.subnet_group_id
  tags_rds = {
    Name = "tf-db"
  }
}
