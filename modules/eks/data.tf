data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

resource "null_resource" "check_eks_cluster" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command     = <<EOF
    TIME_OUT=600
    end=$((SECONDS+TIME_OUT))
    while [ $SECONDS -lt $end ]; do
      if aws eks describe-cluster --name ${var.cluster_name} --query 'cluster.name' --output text 2>/dev/null; then
        exit 0
      fi
      sleep 30
    done
    echo "Timeout reached"
    exit 1
    EOF
    interpreter = ["/bin/bash", "-c"]
  }
}

data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [null_resource.check_eks_cluster]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [null_resource.check_eks_cluster]
}

data "http" "load_balancer_controller_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
  request_headers = {
    Accept = "application/json"
  }
}
