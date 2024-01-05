provider "helm" {
  kubernetes {
    host                   = element(concat(data.aws_eks_cluster.this[*].endpoint, [""]), 0)
    cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.this[*].certificate_authority.0.data, [""]), 0))
    token                  = element(concat(data.aws_eks_cluster_auth.this[*].token, [""]), 0)
  }
}

provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.this[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.this[*].certificate_authority.0.data, [""]), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.this[*].token, [""]), 0)
}

