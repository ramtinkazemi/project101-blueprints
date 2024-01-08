locals {
  cluster_name = "${var.name_prefix}-${var.cluster_name}"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = var.public_subnet_ids

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cluster_security_group   = false
  create_node_security_group      = false
  create_iam_role                 = true
  iam_role_arn                    = "${local.cluster_name}-cluster-role"

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "${aws_iam_role.eks_admin_role.arn}"
      username = "eks-admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "${aws_iam_role.eks_readonly_role.arn}"
      username = "eks-readonly"
      groups   = ["${kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding.subject[0].name}"]
    }
  ]

  aws_auth_accounts = [data.aws_caller_identity.current.account_id]

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.tags
  )

}


# # Create AWS EKS Cluster
# resource "aws_eks_cluster" "this" {
#   name     = local.cluster_name
#   role_arn = aws_iam_role.eks_master_role.arn
#   version  = var.cluster_version

#   vpc_config {
#     subnet_ids              = var.public_subnet_ids
#     endpoint_private_access = var.cluster_endpoint_private_access
#     endpoint_public_access  = var.cluster_endpoint_public_access
#     public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
#     # control_plane_subnet_ids = var.private_subnet_ids
#   }

#   kubernetes_network_config {
#     service_ipv4_cidr = var.cluster_service_ipv4_cidr
#   }

#   # Enable EKS Cluster Control Plane Logging
#   enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

#   # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
#   # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy,
#     aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController,
#   ]

#   tags = var.tags

# }


/////////////////////////////////
// OUTPUTS
/////////////////////////////////

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

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = module.eks.cluster_security_group_id
}
