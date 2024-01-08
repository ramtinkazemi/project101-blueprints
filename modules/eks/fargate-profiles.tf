# Resource: EKS Fargate Profile
resource "aws_eks_fargate_profile" "eks_fargate" {
  depends_on             = [null_resource.check_eks_cluster_ready]
  cluster_name           = local.cluster_name
  fargate_profile_name   = "eks_fargate"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn
  subnet_ids             = var.private_subnet_ids
  selector {
    namespace = "default"
  }
  selector {
    namespace = "kube-system"
  }  
}

# Resource: IAM Role for EKS Fargate Profile
resource "aws_iam_role" "fargate_profile_role" {
  name = "${local.cluster_name}-fargate-profile-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile_role.name
}

# resource "aws_iam_role_policy_attachment" "eks_fargate_cni" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.fargate_profile_role.name
# }


# resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.fargate_profile_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_AmazonEKSVPCResourceController" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.fargate_profile_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_AmazonEKSServicePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   role       = aws_iam_role.fargate_profile_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_AmazonEKSCloudWatchMetricsPolicy" {
#   policy_arn = aws_iam_policy.eks_cloudwatch_metrics_policy.arn
#   role       = aws_iam_role.fargate_profile_role.name
# }
