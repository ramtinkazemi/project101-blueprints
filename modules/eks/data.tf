data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

resource "null_resource" "check_eks_cluster_active" {
  triggers = {
    cluster_name = local.cluster_name
  }

  provisioner "local-exec" {
    command     = <<EOF
TIME_OUT=900
end=$((SECONDS+TIME_OUT))
while [ $SECONDS -lt $end ]; do
  status=$(aws eks describe-cluster --name ${local.cluster_name} --region ${local.aws_region} --query 'cluster.status' --output text 2>/dev/null)
  [ "$status" = "ACTIVE" ] && exit 0
  sleep 5
done
echo "WARNING: Timeout or EKS Cluster is not acive!" && exit 1
EOF
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "null_resource" "check_vpc_exists" {
  triggers = {
    vpc_id = var.vpc_id
  }

  provisioner "local-exec" {
    command     = <<EOF
TIME_OUT=900
end=$((SECONDS+TIME_OUT))
while [ $SECONDS -lt $end ]; do
  vpc_info=$(aws ec2 describe-vpcs --vpc-ids "${var.vpc_id}" --region "${local.aws_region}" --query 'Vpcs[0].VpcId' --output text 2>/dev/null)
  if [ "$vpc_info" = "${var.vpc_id}" ]; then
    exit 0
  fi
  sleep 5
done
echo "WARNING: Timeout or VPC not found!" && exit 1
EOF
    interpreter = ["/bin/bash", "-c"]
  }
}


data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [null_resource.check_eks_cluster_active]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [null_resource.check_eks_cluster_active]
}
