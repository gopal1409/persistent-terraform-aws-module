variable "tags_alb" {
  type = map(any)
}

variable "security_group" {
  type = list 
}

variable "name" {
  type = string
}

variable "subnet" {
  type = list
}

variable "is_internal" {
  type = bool 
  default = false
}
