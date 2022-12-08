
module "nodegroup" {

  for_each =  var.eks_nodegroups

  source = "github.com/terraform-aws-modules/terraform-aws-eks//modules/eks-managed-node-group"


  name            = each.value.name
  cluster_name    = each.value.cluster_name

  create_launch_template = try(each.value.create_launch_template, false)
  ami_id = each.value.ami_id
  enable_bootstrap_user_data = try(each.value.enable_bootstrap_user_data, false)
  pre_bootstrap_user_data = try(each.value.pre_bootstrap_user_data, "export USE_MAX_PODS=false\n")
  bootstrap_extra_args = "--docker-config-json '{\"bridge\":\"none\",\"log-driver\":\"json-file\",\"log-opts\":{\"max-size\":\"2g\",\"max-file\":\"3\"},\"live-restore\":true,\"max-concurrent-downloads\":10}'"


  launch_template_name     = each.value.launch_template_name
  launch_template_version = each.value.launch_template_version
  //该参数create_launch_template为true时，必须填入，默认的ami硬盘大小为50G，gp2
  block_device_mappings = each.value.block_device_mappings

  vpc_id          = each.value.vpc_id
  subnet_ids      = each.value.subnet_ids

  create_security_group = try(each.value.create_security_group, false)
  cluster_primary_security_group_id = each.value.cluster_primary_security_group_id
  cluster_security_group_id  = each.value.cluster_security_group_id

  create_iam_role = try(each.value.create_iam_role, false)
  iam_role_arn = try(each.value.iam_role_arn, var.iam_role_arn)
 
  
  min_size     = each.value.min_size
  max_size     = each.value.max_size
  desired_size = each.value.desired_size

  instance_types = try(each.value.instance_types, var.instance_types)
  capacity_type  = try(each.value.capacity_type, var.capacity_type)

  tags    = merge(each.value.tags, var.tags)
  
}
