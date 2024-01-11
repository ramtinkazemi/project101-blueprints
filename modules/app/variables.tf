variable "namespace" {
  description = "The namespace in Terragrunt"
  type        = string
}

variable "stack" {
  description = "The stack in Terragrunt"
  type        = string
}

variable "env" {
  description = "The env in Terragrunt"
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