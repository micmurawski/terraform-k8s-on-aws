variable "project_name" {
  type    = string
  default = "k8s-on-aws"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "num_private_subnets" {
  type    = number
  default = 2
}
variable "num_public_subnets" {
  type    = number
  default = 2
}

variable "cidr" {
  type    = string
  default = "10.10.0.0/16"
}
