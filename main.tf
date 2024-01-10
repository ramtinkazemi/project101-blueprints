
// As abest practice, we should always override the default values of the variables in the root module.

module "network" {
  source                  = "./modules/network"
  name_prefix             = "modules-network"
  vpc_name                = "test"
  cidr_block              = "10.1.0.0/16"
  public_subnet_cidrs     = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs    = ["10.1.101.0/24", "10.1.102.0/24"]
  enable_nat_gateway      = true
  single_nat_gateway      = true
  vpce_interface_services = ["logs", "sts", "eks", "ecr.api", "ecr.dkr", "dynamodb", "ec2"]
  enable_s3_gateway       = true
  tags = {
    "extra" = "tag"
  }
}

module "eks" {
  source                               = "./modules/eks"
  name_prefix                          = "modules-eks"
  cluster_name                         = "test"
  vpc_id                               = module.network.vpc_id
  public_subnet_ids                    = module.network.public_subnet_ids
  private_subnet_ids                   = module.network.private_subnet_ids
  cluster_version                      = "1.28"
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  tags = {
    "extra" = "tag"
  }
}

module "app" {
  source       = "./modules/app"
  name_prefix  = "modules-app"
  vpc_id       = module.network.vpc_id
  cluster_name = module.eks.cluster_name
  app_name     = "test"
  tags = {
    "extra" = "tag"
  }
}
