output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_private_subnets_ids" {
  value = module.vpc.private_subnets_ids
}

output "vpc_public_subnets_ids" {
  value = module.vpc.public_subnets_ids
}