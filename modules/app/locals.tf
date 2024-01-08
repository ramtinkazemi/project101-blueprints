locals {
  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
  app_name       = "${var.name_prefix}-${var.app_name}"
}