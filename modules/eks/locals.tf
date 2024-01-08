locals {
  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
  cluster_name   = "${var.name_prefix}-${var.cluster_name}"
}