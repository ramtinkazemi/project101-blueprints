variable "name_prefix" {
  description = "A prefix prepended to all resource names"
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

variable "app_namespace" {
  description = "Namespace for the app in EKS"
  default     = "app"
}


# variable "image_repository" {
#   description = "The repository URL of the Docker image"
#   type        = string
# }

# variable "image_tag" {
#   description = "The tag of the Docker image"
#   type        = string
#   default = "latest"
# }

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}