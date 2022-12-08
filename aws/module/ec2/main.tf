data "aws_subnet" "selected" {
  for_each = var.ec2_instances
  id = each.value.subnet_id
}

data "aws_security_group" "selected" {
  for_each = data.aws_subnet.selected
  name = "devops-${each.value.vpc_id}"
}


module "ec2_instance" {
  source  = "./terraform-aws-modules/ec2-instance/aws"

  for_each = var.ec2_instances

  name = each.value.name

### spot instance use only
  create_spot_instance = try(each.value.create_spot_instance, false)
  spot_price           = try(each.value.spot_price, null)
  spot_type            = try(each.value.spot_type, null)

####
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  iam_instance_profile   = try(each.value.iam_instance_profile, null)
  # EC2 associate with security group devops-{current_subnet_associated_vpc-id}
  vpc_security_group_ids = concat(tolist(each.value.vpc_security_group_ids),["${data.aws_security_group.selected[each.key].id}"])
  subnet_id              = each.value.subnet_id

  key_name               = try(each.value.key_name, null)
  monitoring             = try(each.value.monitoring,null)
  availability_zone      = try(each.value.availability_zone,null)
  placement_group             = try(each.value.placement_group,null)
  associate_public_ip_address = try(each.value.associate_public_ip_address,null)
  disable_api_stop            = try(each.value.disable_api_stop,null)

  # only one of these can be enabled at a time
  hibernation = try(each.value.hibernation,null)
  # enclave_options_enabled = true

  user_data_base64            = try(base64encode(each.value.user_data), null)
  user_data_replace_on_change = try(each.value.user_data_replace_on_change,null)

  cpu_core_count       = try(each.value.cpu_core_count,null)
  cpu_threads_per_core = try(each.value.cpu_threads_per_core,null)

  capacity_reservation_specification = try(each.value.capacity_reservation_specification,null)

  enable_volume_tags = try(each.value.enable_volume_tags, false)
  root_block_device = try(each.value.root_block_device,[])

  ebs_block_device = try(each.value.ebs_block_device, [])
  ebs_optimized    = try(each.value.ebs_optimized ,null)
  tags = merge(each.value.tags, 
              { repo = try(each.value.default_tags["repo"],"")}, 
              { iac_managed_by = try(each.value.default_tags["iac_managed_by"],"terraform")}, 
              null)
  default_tags = try(each.value.default_tags, null)

}