variable "allocated_storage" {
  type = number
}

variable "db_name" {
  type = string 
}

variable "subnet_group_name" {
  type = string
}

variable "identifier_name" {
  type = string
}

variable "username" {
  type = string
}

variable "tags_rds" {
  type = map
}

variable "vpc_security_group_ids" {
  type = list 
}