output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "The IDs of the private subnets"
}
