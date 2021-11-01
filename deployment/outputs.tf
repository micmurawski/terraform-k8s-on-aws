output "vpc_id" {
  value = module.shared_infra.vpc_id
}

output "vpc_private_subnets_ids" {
  value = module.shared_infra.vpc_private_subnets_ids
}

output "vpc_private_public_ids" {
  value = module.shared_infra.vpc_public_subnets_ids
}