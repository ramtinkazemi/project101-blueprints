locals {
  aws_region    = data.aws_region.current.name
  aws_accoun_id = data.aws_caller_identity.current.account_id
  vpc_name      = "${var.name_prefix}-${var.vpc_name}"
}
