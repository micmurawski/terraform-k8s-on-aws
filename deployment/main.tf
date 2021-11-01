module "shared_infra" {
  source = "./shared_infra"
  prefix = var.project_name
  tags   = local.tags
  subnets_config = {
    public  = local.public_subnets
    private = local.private_subnets
  }
}