# Resource: AWS IAM Role - EKS Admin
resource "aws_iam_role" "eks_admin_role" {
  name = "${local.cluster_name}-eks-admin-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${local.aws_account_id}:root"
        }
      },
    ]
  })
  inline_policy {
    name = "eks-full-access-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "iam:ListRoles",
            "ssm:GetParameter"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "eks:*",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:eks:${local.aws_region}:${local.aws_account_id}:cluster/${local.cluster_name}"
        },
      ]
    })
  }

  tags = {
    tag-key = "${local.cluster_name}-eks-admin-role"
  }
}

output "cluster_admin_role_arn" {
  description = "EKS cluster admin role arn"
  value       = aws_iam_role.eks_admin_role.arn
}