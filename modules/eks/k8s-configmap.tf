locals {
  configmap_roles = [
    {
      rolearn  = "${aws_iam_role.eks_admin_role.arn}"
      username = "eks-admin" # Just a place holder name
      groups   = ["system:masters"]
    },
    {
      rolearn  = "${aws_iam_role.eks_readonly_role.arn}"
      username = "eks-readonly" # Just a place holder name
      #groups   = [ "eks-readonly-group" ]
      # Important Note: The group name specified in clusterrolebinding and in aws-auth configmap groups should be same. 
      groups = ["${kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding.subject[0].name}"]
    },
    # {
    #   rolearn  = "${aws_iam_role.eks_developer_role.arn}"
    #   username = "eks-developer" # Just a place holder name
    #   #groups   = [ "eks-developer-group" ]
    #   # Important Note: The group name specified in clusterrolebinding and in aws-auth configmap groups should be same.       
    #   groups   = [ "${kubernetes_role_binding_v1.eksdeveloper_rolebinding.subject[0].name}" ]
    # },         
  ]
}

# Resource: Kubernetes Config Map
resource "kubernetes_config_map_v1" "aws_auth" {
  depends_on = [
    aws_eks_cluster.this,
    kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding
    # kubernetes_cluster_role_binding_v1.eksdeveloper_clusterrolebinding,
    # kubernetes_role_binding_v1.eksdeveloper_rolebinding
  ]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(local.configmap_roles)
  }
}

