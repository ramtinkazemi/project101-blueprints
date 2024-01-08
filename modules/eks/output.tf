output "aws_region" {
  value = data.aws_region.current.name
}

output "aws_account_id" {
  value = local.aws_account_id
}
