resource "aws_mskconnect_worker_configuration" "this" {
  for_each = var.aws_mskconnect_worker_configuration

  name                    = each.value.name
  description =  each.value.name
  properties_file_content = each.value.properties_file_content

  lifecycle {
    ignore_changes= [properties_file_content]
  }
}


resource "aws_mskconnect_custom_plugin" "this" {
  for_each = var.aws_mskconnect_custom_plugin

  name         = each.value.mskconnect_custom_plugin_name
  description =  try(each.value.description,null)
  content_type = "ZIP"
  location {
    s3 {
      bucket_arn = each.value.s3_bucket_arn
      file_key   = each.value.s3_file_key
    }
  }
}

# data "aws_mskconnect_custom_plugin" "this" {
#   for_each = var.aws_mskconnect_custom_plugin

#   name = each.value.mskconnect_custom_plugin_name
# }

# data "aws_mskconnect_worker_configuration" "this" {
#   for_each = var.aws_mskconnect_worker_configuration

#   name = each.value.name
# }

resource "aws_mskconnect_connector" "this" {
  for_each = var.aws_mskconnect_connector

  name = each.value.name

  description = each.value.name

  kafkaconnect_version = try(each.value.kafkaconnect_version, var.kafkaconnect_version)

  capacity {
    autoscaling {
      mcu_count        = try(each.value.mcu_count, var.mcu_count)
      min_worker_count = try(each.value.min_worker_count, var.min_worker_count)
      max_worker_count = try(each.value.max_worker_count, var.max_worker_count)

      scale_in_policy {
        cpu_utilization_percentage = try(each.value.scale_in_cpu_utilization_percentage, var.scale_in_cpu_utilization_percentage)
      }

      scale_out_policy {
        cpu_utilization_percentage = try(each.value.scale_out_cpu_utilization_percentage, var.scale_out_cpu_utilization_percentage)
      }
    }
  }

  connector_configuration = each.value.connector_configuration

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = each.value.bootstrap_servers

      vpc {
        security_groups = each.value.security_groups
        subnets         = each.value.subnets
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = try(each.value.authentication_type, var.authentication_type)
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = try(each.value.encryption_type, var.encryption_type)
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.this[each.value.mskconnect_custom_plugin_name].arn
      revision = aws_mskconnect_custom_plugin.this[each.value.mskconnect_custom_plugin_name].latest_revision
    }
  }

  service_execution_role_arn = each.value.service_execution_role_arn


  log_delivery {
    worker_log_delivery{

      dynamic "cloudwatch_logs"{
        for_each = try(each.value.enable_cloudwatch_logs, null) != null? [1] : []
        content {
          enabled = try(each.value.enable_cloudwatch_logs, true)
          log_group = try(each.value.log_group, var.log_group)
        }
      }
      dynamic "s3" {
        for_each = try(each.value.enable_s3_logs, null) != null? [1] : []
        content {
          enabled = try(each.value.enable_s3_logs, null)
          bucket = try(each.value.s3_bucket, null)
          prefix = try(each.value.s3_prefix, null)
        }
      }
    }
  }

  dynamic "worker_configuration" {
    for_each = try(each.value.worker_configuration_name, null) != null ? [1] : []
    content{
      arn = try(aws_mskconnect_worker_configuration.this[each.value.worker_configuration_name].arn, null)
      revision = try(aws_mskconnect_worker_configuration.this[each.value.worker_configuration_name].latest_revision, null)
    }
  }


  lifecycle {
    ignore_changes= [log_delivery]
  }

}