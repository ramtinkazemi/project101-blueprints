
module "network" {
  source      = "./modules/network"
  name_prefix = "modules-network"
  vpc_name    = "test"
}

module "eks" {
  source             = "./modules/eks"
  name_prefix        = "modules-eks"
  cluster_name       = "test"
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  admin_role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin"
}

module "app" {
  source        = "./modules/app"
  name_prefix   = "modules-app"
  vpc_id        = module.network.vpc_id
  cluster_name  = module.eks.cluster_name
  app_name      = "test"
  app_namespace = "test"
}
