# Resource: k8s namespace
resource "kubernetes_namespace_v1" "k8s_dev" {
  metadata {
    name = var.app_namespace
  }
}

resource "aws_ecr_repository" "this" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tags
}

resource "aws_s3_bucket" "static_assets" {
  bucket = "static-assets-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  acl    = "private"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = var.tags
}

# resource "aws_s3_object" "image" {
#   bucket = aws_s3_bucket.static_assets.bucket
#   key    = "images/image.jpeg"
#   source = "./image.jpeg"
#   acl    = "public-read"
# }

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.static_assets.id}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_oai.cloudfront_access_identity_path
    }
  }
  enabled             = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.static_assets.id}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "OAI for ${aws_s3_bucket.static_assets.bucket}"
}

resource "aws_s3_bucket_policy" "static_assets_policy" {
  bucket = aws_s3_bucket.static_assets.bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.static_assets.arn}/*",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.s3_oai.iam_arn
        }
      },
      {
        Action    = "s3:ListBucket",
        Effect    = "Deny",
        Resource  = aws_s3_bucket.static_assets.arn,
        Principal = "*",
        Condition = {
          StringNotEquals = {
            "aws:Referer" : aws_cloudfront_distribution.s3_distribution.domain_name
          }
        }
      }
    ]
  })
}

# Resource: IAM Role for EKS Fargate Profile
resource "aws_iam_role" "fargate_profile_role" {
  name = "${var.app_name}-eks-fargate-profile-role"

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

# Resource: IAM Policy Attachment to IAM Role
resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile_role.name
}


# Resource: IAM Policy Attachment to IAM Role
resource "aws_iam_role_policy_attachment" "eks_fargate_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.fargate_profile_role.name
}

resource "aws_eks_fargate_profile" "fargate_profile" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = var.app_name
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn
  subnet_ids             = data.aws_subnets.private.ids
  selector {
    namespace = var.app_namespace
  }
}

resource "aws_ssm_parameter" "ecr_repository_arn" {
  name  = "/facts/v1/app/${var.app_name}/ecr_repository_arn"
  type  = "String"
  value = aws_ecr_repository.this.arn
}

resource "aws_ssm_parameter" "ecr_repository_url" {
  name  = "/facts/v1/app/${var.app_name}/ecr_repository_url"
  type  = "String"
  value = aws_ecr_repository.this.repository_url
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  name  = "/facts/v1/app/${var.app_name}/s3_bucket_name"
  type  = "String"
  value = aws_s3_bucket.static_assets.bucket
}

resource "aws_ssm_parameter" "cloudfront_distribution_name" {
  name  = "/facts/v1/app/${var.app_name}/cloudfront_distribution_name"
  type  = "String"
  value = aws_cloudfront_distribution.s3_distribution.id
}

resource "aws_ssm_parameter" "cloudfront_distribution_arn" {
  name  = "/facts/v1/app/${var.app_name}/cloudfront_distribution_arn"
  type  = "String"
  value = aws_cloudfront_distribution.s3_distribution.arn
}

resource "aws_ssm_parameter" "cloudfront_distribution_domain_name" {
  name  = "/facts/v1/app/${var.app_name}/cloudfront_distribution_domain_name"
  type  = "String"
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

