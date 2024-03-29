module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = var.public_subnet_ids

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    # coredns = {
    #   configuration_values = jsonencode({
    #     computeType = "Fargate"
    #   })
    # }
  }

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_node_security_group      = false
  # create_cluster_security_group   = true
  # cluster_security_group_id = data.aws_default_security_group.default.id

  create_iam_role = true
  iam_role_name   = "${var.cluster_name}-role"

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      a = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
      # b = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    }
  }

  # Fargate Profile(s)
  fargate_profiles = {
    system = {
      name = "system"
      selectors = [
        {
          namespace = "kube-system"
        }
      ]
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "${aws_iam_role.eks_admin_role.arn}"
      username = "eks-admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "${aws_iam_role.eks_readonly_role.arn}"
      username = "eks-readonly"
      groups   = ["${kubernetes_cluster_role_binding_v1.eksreadonly_clusterrolebinding.subject[0].name}"]
    },
    {
      rolearn  = "${var.additional_eks_admin_role_arn}"
      username = "additional-admin"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [local.aws_account_id]

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.tags
  )

}

resource "null_resource" "k8s_patcher" {
  depends_on = [module.eks]

  triggers = {
    endpoint = module.eks.cluster_endpoint
    ca_crt   = base64decode(local.cluster_ca_data)
    token    = local.cluster_token
  }

  provisioner "local-exec" {
    command = <<COMMANDS
cat >/tmp/ca.crt <<EOF
${base64decode(local.cluster_ca_data)}
EOF
kubectl \
  --server="${module.eks.cluster_endpoint}" \
  --certificate_authority=/tmp/ca.crt \
  --token="${local.cluster_token}" \
  patch deployment coredns \
  -n kube-system --type json \
  -p='[{"op": "replace", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type", "value": "fargate"}]'
kubectl \
  --server="${module.eks.cluster_endpoint}" \
  --certificate_authority=/tmp/ca.crt \
  --token="${local.cluster_token}" \
  rollout restart deployment coredns -n kube-system
COMMANDS
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}

resource "aws_ec2_tag" "subnets" {
  for_each = { for subnet_id in concat(var.private_subnet_ids, var.public_subnet_ids) : subnet_id => subnet_id }

  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"

  depends_on = [null_resource.check_vpc_exists]
}

/////////////////////////////////
// OUTPUTS
/////////////////////////////////

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by the EKS cluster on 1.14 or later. Referred to as 'Cluster security group' in the EKS console."
  value       = module.eks.cluster_security_group_id
}
