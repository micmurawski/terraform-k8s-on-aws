variable "prefix" {
  type = string
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "subnets_config" {
  type    = map(any)
  default = {}

}