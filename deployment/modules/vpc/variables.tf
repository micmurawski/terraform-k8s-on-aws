variable "prefix" {
  type = string
}

variable "flow_logs" {
  type    = bool
  default = false
}

variable "cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "number_of_nat_gateways" {
  type    = number
  default = 2
}

variable "subnets_config" {
  type = map(any)
  default = {
    public = [
      {
        availability_zone = "us-east-1a"
        cidr              = "10.10.0.0/22"
      },
      {
        availability_zone = "us-east-1b"
        cidr              = "10.10.4.0/22"
      }
    ]
    private = []
  }

}