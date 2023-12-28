###subnet for web layer
module "subnet-priv-1a" {
  source = "./modules/subnet"
  vpc_id = module.my_vpc.my_vpc_id
  cidr_subnet = var.cidr_subnet_3
  az_subnet = var.az_subnet_3
  public = var.public_3
  tags_subnet = var.tags_subnet_3
}

###subnet for web layer
module "subnet-priv-1b" {
  source = "./modules/subnet"
  vpc_id = module.my_vpc.my_vpc_id
  cidr_subnet = var.cidr_subnet_4
  az_subnet = var.az_subnet_4
  public = var.public_4
  tags_subnet = var.tags_subnet_4
}

###associate with public route table
module "rt_ass_priv_1a" {
  source = "./modules/rt_association"
  subnet_id = module.subnet-priv-1a.subnet_id
  route_table_id = module.private_rt.rt_id
}

module "rt_ass_priv_1b" {
  source = "./modules/rt_association"
  subnet_id = module.subnet-priv-1b.subnet_id
  route_table_id = module.private_rt.rt_id
}

##lets create the security group
module "sg_alb_app" {
  source = "./modules/sg"
  ingress_rules = var.ingress_rules_app
  vpc_id = module.my_vpc.my_vpc_id
  sg_name = var.sg_name_app
  sg_description = var.sg_description_app
  egress_rules = var.egress_rules_app
  tags_sg = var.tags_sg_app
}
###3lets create the alb for web app

module "app-alb" {
    source = "./modules/application_load_balancer"
    name = "tf-apptier-alb"
    #internal = false
    #load_balancer_type = "application"
    security_group = [module.sg_alb_app.sg_id]
    subnet = [module.subnet-priv-1a.subnet_id,module.subnet-priv-1b.subnet_id]
    tags_alb = var.tags_alb_app
}

##target group
module "appTier-tg" {
   source = "./modules/target_group"
   name = "tf-appTier-tg"
   port = 80
   protocol = "HTTP"
   vpc_id   = module.my_vpc.my_vpc_id
   tags_tg = var.tags_app_tg
}

module "http_listener_app" {
  source   = "./modules/listener_group"
  lb_arn   = module.app-alb.alb_arn
  port     = "80"
  protocol = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  tg_arn = module.appTier-tg.tg_arn
}

#autoscaling
module "app_asg1" {
  source              = "./modules/autoscaling"
  vpc_zone_identifier = [module.subnet-priv-1a.subnet_id]
  #  availability_zones = ["ap-south-1a"]
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  target_group_arns = [module.appTier-tg.tg_arn]
  launch_template   = module.apptier_lt.lt_id

}

module "app_asg2" {
  source              = "./modules/autoscaling"
  vpc_zone_identifier = [module.subnet-priv-1b.subnet_id]
  #  availability_zones = ["ap-south-1a"]
  desired_capacity  = 1
  max_size          = 1
  min_size          = 1
  target_group_arns = [module.appTier-tg.tg_arn]
  launch_template   = module.apptier_lt.lt_id

}


# security group for webserver

module "sg_app_server" {
  source = "./modules/sg"
  ingress_rules = [
    {
      description     = "allow on 443"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      cidr_blocks     = null
      security_groups = [module.sg_alb_web.sg_id]
    },
    {
      description     = "allow on 80"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks     = null
      security_groups = [module.sg_alb_web.sg_id]
    }
  ] #var.ingress_rules_web_server
  vpc_id         = module.my_vpc.my_vpc_id
  sg_name        = var.sg_name_app_server
  sg_description = var.sg_description_app_server
  egress_rules   = var.egress_rules_app_server
  #security_groups = var.security_groups_web_server
  tags_sg = var.tags_sg_app_server
}


# launch template

module "apptier_lt" {
  source                 = "./modules/launch_template"
  name_prefix            = "tf-appserver-"
  image_id               = "ami-079db87dc4c10ac91"
  instance_type          = "t2.micro"
  key_name               = "tf-keypair"
  user_data              = filebase64("${path.module}/app.sh")
  vpc_security_group_ids = [module.sg_app_server.sg_id]
  tags_lt = {
    Name = "tf-webtier_lt",
    Kind = "practice"
  }
}

# output "webtier_lt-id" {
#   value = module.webtier_lt.lt_id
# }

###we need to create another ingress rule so that this app tier machine can communicate with db server