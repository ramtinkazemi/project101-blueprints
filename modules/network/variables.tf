variable "name_prefix" {
  description = "A prefix prepended to all resource names"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "app"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24"]
}

# variable "availability_zones" {
#   type        = list(string)
#   description = "Availability zones"
#   default     = ["ap-southeast-2a", "ap-southeast-2b"]
# }

# VPC Enable NAT Gateway (True or False) 
variable "enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
  default     = true
}

# VPC Single NAT Gateway (True or False)
variable "single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
  default     = true
}

variable "vpce_interface_services" {
  description = "List of VPC Interface Endpoint services"
  type        = list(string)
  default     = ["logs", "sts", "eks", "ecr.api", "ecr.dkr", "dynamo-db", "ec2"]
}

variable "enable_s3_gateway" {
  description = "Flag to enable S3 Gateway"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}




