variable "namespace" {
  description = "Namespace in Terragrunt"
  type        = string
}

variable "env" {
  description = "env in Terragrunt"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "app"
}

variable "vpc_id" {
  description = "Id of the VPC"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "app"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}