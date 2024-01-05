variable "name_prefix" {
  description = "A prefix prepended to all resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "app"
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "public_subnet_ids" {
  description = "A list of subnet IDs for the EKS control plane."
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "A list of subnet IDs for the EKS Fargate Profile. Must be private."
  type        = list(string)
  default     = []
}

variable "admin_role_arn" {
  description = "ARN of the IAM role to be used by the EKS cluster for cluster administration"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}