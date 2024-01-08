data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
# data "aws_availability_zones" "available" {
#   state = "available"
# }

resource "null_resource" "check_eks_cluster_ready" {
  triggers = {
    cluster_name = local.cluster_name
  }

  provisioner "local-exec" {
    command     = <<EOF
    TIME_OUT=600
    end=$((SECONDS+TIME_OUT))
    while [ $SECONDS -lt $end ]; do
      status=$(aws eks describe-cluster --name ${local.cluster_name} --query 'cluster.status' --output text 2>/dev/null)
      [ "$status" = "ACTIVE" ] && exit 0
      sleep 5
    done
    echo "Timeout reached"
    exit 1
    EOF
    interpreter = ["/bin/bash", "-c"]
  }
}

data "aws_eks_cluster" "this" {
  name       = aws_eks_cluster.this.name
  depends_on = [null_resource.check_eks_cluster_ready]
}

data "aws_eks_cluster_auth" "this" {
  name       = aws_eks_cluster.this.name
  depends_on = [null_resource.check_eks_cluster_ready]
}
