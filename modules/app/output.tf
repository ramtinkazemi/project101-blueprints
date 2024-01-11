output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.this.arn
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.this.repository_url
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.bucket
}

output "cloudfront_distribution_name" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.s3_distribution.arn
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "image_url" {
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/image.jpeg"
  description = "URL of the image served through CloudFront"
}