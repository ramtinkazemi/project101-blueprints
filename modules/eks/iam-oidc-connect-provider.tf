# locals {
#   oidc_issuer       = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
#   oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
#   oidc_provider_arn = aws_iam_openid_connect_provider.oidc_provider.arn
#   # # Extract OIDC Provider from OIDC Provider ARN
#   # aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
# }

# # Resource: AWS IAM Open ID Connect Provider
# resource "aws_iam_openid_connect_provider" "oidc_provider" {
#   client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
#   thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
#   url             = local.oidc_issuer_url

#   tags = merge(
#     {
#       Name = "${local.cluster_name}-eks-irsa"
#     },
#     var.tags
#   )
# }


# /////////////////////////////////
# // OUTPUTS
# /////////////////////////////////

# # Output: AWS IAM Open ID Connect Provider ARN
# output "aws_iam_openid_connect_provider_arn" {
#   description = "AWS IAM Open ID Connect Provider ARN"
#   value       = local.oidc_provider_arn
# }

# # # Output: AWS IAM Open ID Connect Provider
# # output "aws_iam_openid_connect_provider_extract_from_arn" {
# #   description = "AWS IAM Open ID Connect Provider extract from ARN"
# #    value = local.aws_iam_oidc_connect_provider_extract_from_arn
# # }

# output "cluster_oidc_issuer" {
#   description = "The OIDC issuer URL for the EKS cluster"
#   value       = local.oidc_issuer
# }

# output "cluster_oidc_issuer_url" {
#   description = "The OIDC issuer URL for the EKS cluster"
#   value       = local.oidc_issuer_url
# }
