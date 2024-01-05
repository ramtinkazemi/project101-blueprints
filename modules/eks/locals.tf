locals {
  oidc_issuer     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_issuer_url = module.eks.cluster_oidc_issuer_url
}
