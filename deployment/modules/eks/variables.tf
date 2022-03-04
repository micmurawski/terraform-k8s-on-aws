variable "name" {
  type = string
}

variable "subnets_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "cluster_enabled_log_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}


variable "instance_type" {
  type    = string
  default = "t2.micro"
  validation {
    condition     = contains(["t2.micro", ], var.instance_type)
    error_message = "Not allowed values."
  }
}

variable "vpc_id" {
  type = string
}

variable "cluster_security_group_ids" {
  type    = list(string)
  default = []
}

variable "source_security_group_ids" {
  type    = list(string)
  default = []
}

variable "key_name" {
  type    = string
  default = null
}