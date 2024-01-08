# resource "aws_iam_role" "eks_master_role" {
#   name = "${local.cluster_name}-eks-master-role"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_policy" "eks_cloudwatch_metrics_policy" {
#   name   = "${local.cluster_name}-AmazonEKSClusterCloudWatchMetricsPolicy"
#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#       {
#           "Action": [
#               "cloudwatch:PutMetricData"
#           ],
#           "Resource": "*",
#           "Effect": "Allow"
#       }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "eks_master_AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_master_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_master_AmazonEKSVPCResourceController" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.eks_master_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_master_AmazonEKSServicePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   role       = aws_iam_role.eks_master_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_master_AmazonEKSCloudWatchMetricsPolicy" {
#   policy_arn = aws_iam_policy.eks_cloudwatch_metrics_policy.arn
#   role       = aws_iam_role.eks_master_role.name
# }

# resource "aws_iam_role_policy_attachment" "eks_master_AmazonEKSCNIPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_master_role.name
# }

# /////////////////////////////////
# // OUTPUTS
# /////////////////////////////////

# output "cluster_iam_role_name" {
#   description = "IAM role name of the EKS cluster."
#   value       = aws_iam_role.eks_master_role.name
# }

# output "cluster_iam_role_arn" {
#   description = "IAM role ARN of the EKS cluster."
#   value       = aws_iam_role.eks_master_role.arn
# }