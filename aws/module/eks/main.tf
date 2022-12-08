
module "cluster" {

  for_each =  var.eks_clusters

  source  = "terraform-aws-modules/eks/aws"
  version = "18.20.5"

  cluster_name    = each.value.cluster_name
  vpc_id          = each.value.vpc_id
  subnet_ids      = each.value.subnet_ids
  cluster_version = try(each.value.k8s_version, var.k8s_version)
  enable_irsa     = true
  cluster_tags    = merge(each.value.default_tags, var.cluster_tags)

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = try(each.value.cluster_endpoint_public_access, var.cluster_endpoint_public_access)
  # eks cluster additional security group rules
  cluster_security_group_additional_rules = {
    open_to_office = {
      description                = "open to office"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      cidr_blocks                = ["172.19.0.0/16"]
      source_node_security_group = false
    }
    open_to_devops = {
      description                = "open to devops"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      cidr_blocks                = ["10.140.0.0/20"]
      source_node_security_group = false
    }
  }

  # eks node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    # disk_size      = 150
    
    block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 150
            volume_type           = "gp2"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    instance_types = [try(each.value.instance_type, var.instance_type)]
    bootstrap_extra_args = "--docker-config-json '{\"bridge\":\"none\",\"log-driver\":\"json-file\",\"log-opts\":{\"max-size\":\"2g\",\"max-file\":\"3\"},\"live-restore\":true,\"max-concurrent-downloads\":10}'"
    iam_role_additional_policies = try(each.value.iam_role_additional_policies, var.iam_role_additional_policies)
  }
  eks_managed_node_groups = each.value.eks_managed_node_groups
  
}


module "iam_assumable_role_lbc" {
  for_each = var.eks_clusters

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.14.0"
  create_role = true
  role_name                     = "serviceRole-loadbalancer-${each.value.cluster_name}"
  provider_url                  = replace(module.cluster[each.value.cluster_name].cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/pol-aws-eks-load-banlancer-controller"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}

module "iam_assumable_role_ebs" {
  for_each = var.eks_clusters
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.14.0"
  create_role = true
  role_name                     = "serviceRole-ebs-${each.value.cluster_name}"
  provider_url                  = replace(module.cluster[each.value.cluster_name].cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/pol-aws-eks-ebs-csi-driver"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

module "iam_assumable_role_efs" {
  for_each = var.eks_clusters
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.14.0"
  create_role = true
  role_name                     = "serviceRole-efs-${each.value.cluster_name}"
  provider_url                  = replace(module.cluster[each.value.cluster_name].cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/pol-aws-eks-efs-csi-driver"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:efs-csi-controller-sa","system:serviceaccount:kube-system:efs-csi-node-sa"]
}

###################
# Allow traffic from APIServer to all nodes on port 9443
###################
resource "aws_security_group_rule" "api_to_nodes" {
  for_each =  var.eks_clusters

  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  security_group_id        = module.cluster[each.value.cluster_name].node_security_group_id
  source_security_group_id = module.cluster[each.value.cluster_name].cluster_primary_security_group_id
  description              = "Allow traffic from APIServer to all nodes on port 9443"
}
