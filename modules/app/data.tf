data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    tier = "private"
  }
}

data "aws_eks_cluster" "this" {
  name       = var.cluster_name
  depends_on = [null_resource.check_eks_cluster_active]
}

data "aws_eks_cluster_auth" "this" {
  name       = var.cluster_name
  depends_on = [null_resource.check_eks_cluster_active]
}

resource "null_resource" "check_eks_cluster_active" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command     = <<EOF
TIME_OUT=900
end=$((SECONDS+TIME_OUT))
while [ $SECONDS -lt $end ]; do
  status=$(aws eks describe-cluster --name ${var.cluster_name} --region ${local.aws_region} --query 'cluster.status' --output text 2>/dev/null)
  [ "$status" = "ACTIVE" ] && exit 0
  sleep 5
done
echo "WARNING: Timeout reached!" && exit 1
EOF
    interpreter = ["/bin/bash", "-c"]
  }
}