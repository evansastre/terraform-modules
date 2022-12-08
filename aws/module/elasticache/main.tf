locals {
  ## var.env-var.region-var.product_line-each.value.db_name

  #db_cluster_name = format("%s-%s-%s-%%s-redis", var.env, var.region, var.product_line)
  db_cluster_name = join("-", ["aws-${var.region}-%s","${var.env}"])
  #db_cluster_name = join("-", ["aws-${var.region}-%s","${var.env}"])
  cloudwatch_log_group = format("/aws/elasticache/cluster/%s/redis", local.db_cluster_name)
  generic_tags =  {
    environment  = var.env
    region       = var.region
    product_line = var.product_line
    db_type      = "redis"
  }
  #modifyLogGroup_cmd = "${format("aws elasticache modify-replication-group --replication-group-id %s --apply-immediately --log-delivery-configurations '{\"LogType\": \"slow-log\",\"DestinationType\": \"cloudwatch-logs\",\"DestinationDetails\": {\"CloudWatchLogsDetails\": {\"LogGroup\": \"%s\"}},\"LogFormat\": \"text\"}'\"}", local.db_cluster_name, local.cloudwatch_log_group)}"
}

# data "null_data_source" "this" {
#   for_each =  var.redis_instances

#   inputs = {
#     db_cluster_name = "${var.env}-${var.region}-${var.product_line}-${each.value.db_name}-redis"
#     cloudwatch_log_group = "/aws/vendedlogs/${var.env}-${var.region}-${var.product_line}-${each.value.db_name}-redis/slowlog"
#   }
# }

resource "random_password" "master" {
  length = 20
  special = false
}

# to be replaced when official terraform provider supports log-delivery-configurations
resource "aws_cloudwatch_log_group" "this" {
  for_each = var.redis_instances

  #name = format("${local.cloudwatch_log_group}", each.value.db_name)
  name = format(local.cloudwatch_log_group, each.value.db_name)
  #name = local.cloudwatch_log_group
  retention_in_days = 30
  tags = each.value.tags
  tags_all = merge(each.value.default_tags, each.value.tags)
}

# elasticache cluster
resource "aws_elasticache_replication_group" "this" {
  for_each = var.redis_instances

  #replication_group_id          = data.null_data_source.this[each.key].outputs["db_cluster_name"]
  #replication_group_id = each.value.db_name
  replication_group_id = format(local.db_cluster_name, each.value.db_name)
  description = format(local.db_cluster_name, each.value.db_name)
  #description = each.value.db_name
  multi_az_enabled              = true
  snapshot_retention_limit      = try(each.value.snapshot_retention_limit, var.snapshot_retention_limit)
  automatic_failover_enabled    = true
  subnet_group_name             = try(each.value.redis_subnet_group_name,var.redis_subnet_group_name)
  node_type = try(each.value.node_type, var.node_type) 
  engine_version = try(each.value.engine_version, var.engine_version)
  auth_token = coalesce(var.all_stage_password, random_password.master.result)
  maintenance_window = "mon:03:00-mon:04:00"
  snapshot_window = "17:00-20:00"
  at_rest_encryption_enabled = try(each.value.at_rest_encryption_enabled, var.at_rest_encryption_enabled)
  transit_encryption_enabled = true
  auto_minor_version_upgrade = false

  parameter_group_name = try(each.value.parameter_group_name, var.parameter_group_name)
  num_cache_clusters = try(each.value.num_cache_clusters, var.num_cache_clusters)
  security_group_ids = try(each.value.security_group_ids ,[aws_security_group.this[each.key].id])
  tags = merge(each.value.tags, 
              { repo = try(each.value.default_tags["repo"],"")}, 
              { iac_managed_by = try(each.value.default_tags["iac_managed_by"],"terraform")}, 
            null)
  tags_all = merge(each.value.default_tags, each.value.tags)

  lifecycle {
    ignore_changes = [log_delivery_configuration,
                      auth_token
                     ]
  }

  log_delivery_configuration {
    #destination      = aws_cloudwatch_log_group.this[each.value.db_name].name
    destination      = format(local.cloudwatch_log_group, each.value.db_name)
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    #destination      = aws_cloudwatch_log_group.this[each.value.db_name].name
    destination      = format(local.cloudwatch_log_group, each.value.db_name)
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  depends_on = [
    aws_cloudwatch_log_group.this
  ]
}

# security group
resource "aws_security_group" "this" {
  for_each = var.create_security_group == true ? var.redis_instances : {}

  #name_prefix = "${data.null_data_source.this[each.key].outputs["db_cluster_name"]}-"
  name_prefix = format("${local.db_cluster_name}-", each.value.db_name)
  vpc_id      = var.vpc_id
  description = format("Control traffic to/from Document DB ${local.db_cluster_name}",each.value.db_name)
  tags = each.value.tags
  tags_all = merge(each.value.default_tags, each.value.tags)
}

resource "aws_security_group_rule" "egress_all" {
  for_each = var.create_security_group == true ? var.redis_instances : {}

  type                     = "egress"
  to_port                  = 0
  from_port                = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.this[each.key].id
  description              = "Allow all traffic out"
}



#resource "null_resource" "modifyLogGroup" {
#  for_each = var.redis_instances
#
#  provisioner "local-exec" {
#    command = <<-EOT
#      aws elasticache modify-replication-group --replication-group-id ${format("${local.db_cluster_name}", each.value.db_name)} --apply-immediately --log-delivery-configurations '
#        {
#          "LogType": "slow-log",
#          "DestinationType": "cloudwatch-logs",
#          "DestinationDetails": {
#              "CloudWatchLogsDetails": {
#                  "LogGroup": "${format("${local.cloudwatch_log_group}", each.value.db_name)}"
#              }
#          },
#          "LogFormat": "json"
#        }'
#    EOT
#  }
#  depends_on = [aws_cloudwatch_log_group.this, aws_elasticache_replication_group.this]
#}


data "aws_region" "current" {}


resource "null_resource" "local_provisioner" {
  for_each = {
    for redis,v in var.redis_instances : redis => v
      if try(v.vault_path, null) != null
    }

  provisioner "local-exec" {
    command = <<EOT

      auth_token=`pwgen -cn 20 1 | sed 's/\(.\{6\}\)./\1!/'`
      vault kv put "${each.value.vault_path}/${format(local.db_cluster_name, each.value.db_name)}" passcode="$auth_token" && \
      aws elasticache modify-replication-group   --replication-group-id ${format(local.db_cluster_name, each.value.db_name)} --auth-token "$auth_token"   --apply-immediately  --region ${data.aws_region.current.name}
    EOT
    
  }
  depends_on = [
    aws_elasticache_replication_group.this
  ]
}