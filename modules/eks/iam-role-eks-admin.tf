# Resource: AWS IAM Role - EKS Admin
resource "aws_iam_role" "eks_admin_role" {
  name = "${var.cluster_name}-admin"

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
            "eks:*",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:eks:${local.aws_region}:${local.aws_account_id}:cluster/${var.cluster_name}"
        },
      ]
    })
  }

  tags = {
    tag-key = "${var.cluster_name}-admin"
  }
}



/////////////////////////////////
// OUTPUTS
/////////////////////////////////


output "cluster_admin_role_arn" {
  description = "EKS cluster admin role arn"
  value       = aws_iam_role.eks_admin_role.arn
}