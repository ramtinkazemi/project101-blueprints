locals {
  aws_region    = data.aws_region.current.name
  aws_accoun_id = data.aws_caller_identity.current.account_id
}
