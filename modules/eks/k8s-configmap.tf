# data "kubernetes_config_map_v1" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
# }

# locals {
#   configmap_roles = [
#     {
#       rolearn  = "${aws_iam_role.eks_admin_role.arn}"
#       username = "eks-admin" # Just a place holder name
#       groups   = ["system:masters"]
#     },
#     {
#       rolearn  = "${aws_iam_role.eks_readonly_role.arn}"
#       username = "eks-readonly" # Just a place holder name
#       #groups   = [ "eks-readonly-group" ]
#       # Important Note: The group name specified in clusterrolebinding and in aws-auth configmap groups should be same. 
#       groups = ["${kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding.subject[0].name}"]
#     }
#   ]
#   updated_map_roles = concat(yamldecode(data.kubernetes_config_map_v1.aws_auth.data["mapRoles"]), local.configmap_roles)
# }


# # resource "kubernetes_config_map_v1_data" "aws_auth" {
# #   metadata {
# #     name      = "aws-auth"
# #     namespace = "kube-system"
# #   }

# #   data = {
# #     "mapRoles" = data.template_file.aws_auth_template.rendered
# #   }

# #   force = true
# # }

# # data "template_file" "aws_auth_template" {
# #   template = "${file("${path.module}/aws-auth-template.yml")}"
# #   vars = {
# #     cluster_admin_arn = "${local.accounts["${var.env}"].cluster_admin_arn}"
# #   }
# # }


# # # Resource: Kubernetes Config Map
# # resource "kubernetes_config_map_v1" "aws_auth" {
# #   depends_on = [
# #     aws_eks_cluster.this,
# #     kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding
# #     # kubernetes_cluster_role_binding_v1.eksdeveloper_clusterrolebinding,
# #     # kubernetes_role_binding_v1.eksdeveloper_rolebinding
# #   ]
# #   metadata {
# #     name      = "aws-auth"
# #     namespace = "kube-system"
# #   }
# #   data = {
# #     mapRoles = yamlencode(local.configmap_roles)
# #   }
# # }


# resource "kubernetes_config_map_v1_data" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }
#   data = {
#     mapRoles = jsonencode(local.updated_map_roles)
#   }

#   force = true

# }

# # resource "kubernetes_config_map_v1" "aws_auth" {
# #   depends_on = [
# #     aws_eks_cluster.this,
# #     kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding
# #   ]
# #   metadata {
# #     name      = "aws-auth"
# #     namespace = "kube-system"
# #   }

# #   data = {
# #     mapRoles = jsonencode(local.updated_map_roles)
# #   }

# # }

# resource "kubernetes_config_map" "aws_logging" {
#   metadata {
#     name      = "aws-logging"
#     namespace = "kube-system"
#   }

#   data = {
#     "clusterLogging" = jsonencode([{
#       "types"   = ["api", "audit", "authenticator", "controllerManager", "scheduler"],
#       "enabled" = true
#     }])
#   }
# }
