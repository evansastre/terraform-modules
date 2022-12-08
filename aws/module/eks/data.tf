data "aws_caller_identity" "current" {}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.k8s_version}-v*"]
  }
}
