# Resource: k8s namespace
resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.app_name
  }
}

resource "aws_ecr_repository" "this" {
  name                 = "${var.app_name}-ecr"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tags
}

resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.app_name}-static-${local.aws_account_id}-${local.aws_region}"
  # acl    = "public-read"
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

resource "aws_s3_object" "image" {
  bucket = aws_s3_bucket.static_assets.bucket
  key    = "image.jpeg"
  source = "./image.jpeg"
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
        Action   = "s3:*",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.static_assets.arn}*",
        Principal = {
          AWS = "arn:aws:iam::${local.aws_account_id}:role/gha-oidc-infra-role-${local.aws_region}"
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

resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "OAI for ${aws_s3_bucket.static_assets.bucket}"
}

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

resource "aws_ssm_parameter" "ecr_repository_arn" {
  name  = "/facts/v1/${var.app_name}/ecr_repository_arn"
  type  = "String"
  value = aws_ecr_repository.this.arn
}

resource "aws_ssm_parameter" "ecr_repository_url" {
  name  = "/facts/v1/${var.app_name}/ecr_repository_url"
  type  = "String"
  value = aws_ecr_repository.this.repository_url
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  name  = "/facts/v1/${var.app_name}/s3_bucket_name"
  type  = "String"
  value = aws_s3_bucket.static_assets.bucket
}

resource "aws_ssm_parameter" "cloudfront_distribution_name" {
  name  = "/facts/v1/${var.app_name}/cloudfront_distribution_name"
  type  = "String"
  value = aws_cloudfront_distribution.s3_distribution.id
}

resource "aws_ssm_parameter" "cloudfront_distribution_arn" {
  name  = "/facts/v1/${var.app_name}/cloudfront_distribution_arn"
  type  = "String"
  value = aws_cloudfront_distribution.s3_distribution.arn
}

resource "aws_ssm_parameter" "cloudfront_distribution_domain_name" {
  name  = "/facts/v1/${var.app_name}/cloudfront_distribution_domain_name"
  type  = "String"
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
