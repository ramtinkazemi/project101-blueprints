resource "aws_ssm_parameter" "cluster_name" {
  name  = "/facts/v1/${local.cluster_name}/cluster_name"
  type  = "String"
  value = module.eks.cluster_name
}

resource "aws_ssm_parameter" "cluster_arn" {
  name  = "/facts/v1/${local.cluster_name}/cluster_arn"
  type  = "String"
  value = module.eks.cluster_arn
}

resource "aws_ssm_parameter" "cluster_endpoint" {
  name  = "/facts/v1/${local.cluster_name}/cluster_endpoint"
  type  = "String"
  value = module.eks.cluster_endpoint
}

resource "aws_ssm_parameter" "cluster_role_arn" {
  name  = "/facts/v1/${local.cluster_name}/cluster_role_arn"
  type  = "String"
  value = module.eks.cluster_iam_role_arn
}

resource "aws_ssm_parameter" "eks_cluster_oidc_provider_arn" {
  name  = "/facts/v1/${local.cluster_name}/eks_cluster_oidc_issuer_url"
  type  = "String"
  value = module.eks.oidc_provider_arn
}

resource "aws_ssm_parameter" "eks_cluster_oidc_issuer_url" {
  name  = "/facts/v1/${local.cluster_name}/eks_cluster_oidc_issuer_url"
  type  = "String"
  value = module.eks.cluster_oidc_issuer_url
}
