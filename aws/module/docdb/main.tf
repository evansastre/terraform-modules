


module "docdb_cluster" {
  source  = "./terraform-aws-modules/docdb/aws"

  for_each = var.docdb_clusters

  #db_cluster_name = join("-", ["aws-${var.region}-${var.product_line}", try(each.value.db_name, var.db_name),"${var.env}"])
  db_cluster_name = join("-", ["aws-${var.region}", try(each.value.db_name, var.db_name),"${var.env}"])
  #db_cluster_name = try(each.value.db_name, var.db_name)
  db_subnet_group_name            = each.value.db_subnet_group_name
  db_cluster_parameter_group_name = each.value.db_cluster_parameter_group_name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  instance_count = try(each.value.instance_count, var.instance_count)
  instance_class = try(each.value.instance_class, var.instance_class)
  vault_path = try(each.value.vault_path, null)
  vpc_id = each.value.vpc_id

  tags = merge(each.value.tags, 
              { repo = try(each.value.default_tags["repo"],"")}, 
              { iac_managed_by = try(each.value.default_tags["iac_managed_by"],"terraform")}, 
              {db_name : "${each.value.db_name}"},
              )
  tags_all = merge(each.value.default_tags, each.value.tags)


}