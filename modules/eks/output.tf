output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_role_arn" {
  description = "ARN of the IAM role used by EKS Fargate"
  value       = module.eks.cluster_iam_role_arn
}

output "eks_cluster_oidc_issuer" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = local.oidc_issuer
}

output "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = local.oidc_issuer_url
}


output "load_balancer_controller_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value       = aws_iam_role.load_balancer_controller_role.arn
}

output "load_balancer_controller_iam_policy_arn" {
  value = aws_iam_policy.load_balancer_controller_iam_policy.arn
}