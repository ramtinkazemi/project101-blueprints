locals {
  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
  cluster_name   = "${var.name_prefix}-${var.cluster_name}"
  oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  oidc_issuer       = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_provider_arn = module.eks.oidc_provider_arn
}