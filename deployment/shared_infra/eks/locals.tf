locals {
  tags = merge(var.tags, { module = var.name })
}