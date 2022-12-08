locals {
  msk_cluster_name = "${var.env}-${var.region}-${var.product_line}-${var.name}-msk"
  cloudwatch_log_group = "/aws/msk/cluster/${local.msk_cluster_name}/msk"
  secrets = {
    user = {
      name = "AmazonMSK_${local.msk_cluster_name}-user"
      username = "mskuser"
      password = "${coalesce(var.all_stage_password, random_password.user.result)}"
    }
    admin = {
      name = "AmazonMSK_${local.msk_cluster_name}-admin"
      username = "mskadmin"
      password = "${coalesce(var.all_stage_password, random_password.admin.result)}"
    }
  }
}

resource "random_password" "user" {
  length = 16
  special = false
}

resource "random_password" "admin" {
  length = 16
  special = false
}


resource "aws_kms_key" "this" {
  description = local.msk_cluster_name
  key_usage = var.key_usage # default "ENCRYPT_DECRYPT"
  customer_master_key_spec = var.customer_master_key_spec # default "SYMMETRIC_DEFAULT"
  # should have policy to extend with certain group of users, however it's not recommended here.
  policy = try(var.kms_key_policy, null)
  tags = merge(var.tags, 
              { repo = try(var.default_tags["repo"],"")}, 
              { iac_managed_by = try(var.default_tags["iac_managed_by"],"terraform")}, 
              null)
}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.msk_cluster_name}"
  target_key_id = aws_kms_key.this.key_id
}



resource "aws_cloudwatch_log_group" "this" {
  name = local.cloudwatch_log_group
  retention_in_days = var.retention_in_days # default = 30
  tags = merge(var.tags, 
              { repo = try(var.default_tags["repo"],"")}, 
              { iac_managed_by = try(var.default_tags["iac_managed_by"],"terraform")}, 
              null)
}

resource "aws_secretsmanager_secret" "this" {
  for_each = local.secrets

  name       = each.value.name
  description = "MSK Cluster ${local.msk_cluster_name}'s linked ${each.key} secret"
  kms_key_id = aws_kms_key.this.key_id
  depends_on = [
    aws_msk_configuration.this
  ]
  tags = merge(var.tags, 
              { repo = try(var.default_tags["repo"],"")}, 
              { iac_managed_by = try(var.default_tags["iac_managed_by"],"terraform")}, 
              null)
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = local.secrets

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode({ username = each.value.username, password = each.value.password })

  lifecycle {
    ignore_changes = [secret_string]
  }
}


resource "aws_secretsmanager_secret_policy" "this" {
  for_each = local.secrets
  
  secret_arn = aws_secretsmanager_secret.this[each.key].arn
  policy     = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Sid": "AWSKafkaResourcePolicy",
    "Effect" : "Allow",
    "Principal" : {
      "Service" : "kafka.amazonaws.com"
    },
    "Action" : "secretsmanager:getSecretValue",
    "Resource" : "${aws_secretsmanager_secret.this[each.key].arn}"
  } ]
}
POLICY
}

resource "aws_security_group" "this" {
  name_prefix = "${local.msk_cluster_name}-"
  vpc_id      = var.vpc_id
  description = "Control traffic to/from MSK ${local.msk_cluster_name}"

  tags = merge(var.tags, 
              { repo = try(var.default_tags["repo"],"")}, 
              { iac_managed_by = try(var.default_tags["iac_managed_by"],"terraform")}, 
              null)
  # tags = local.db_cluster_tags
}

resource "aws_security_group_rule" "egress_all" {
  type                     = "egress"
  to_port                  = 0
  from_port                = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.this.id
  description              = "Allow all traffic out"
}


resource "aws_msk_configuration" "this" {
  count = var.create_msk_configuration == true ? 1 : 0

  name        = "${var.env}-${var.region}-${var.product_line}-msk"
  description = "${var.env} ${var.region} ${var.product_line} msk configuration"

  server_properties = <<PROPERTIES
auto.create.topics.enable=${var.auto_create_topics}
default.replication.factor=3
min.insync.replicas=2
num.io.threads=8
num.network.threads=5
num.partitions=3
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
socket.send.buffer.bytes=102400
unclean.leader.election.enable=true
zookeeper.session.timeout.ms=18000
PROPERTIES
}


resource "aws_msk_cluster" "this" {

  cluster_name           = local.msk_cluster_name
  kafka_version          = var.kafka_version # default "2.6.2"
  number_of_broker_nodes = var.number_of_broker_nodes # default 3

  broker_node_group_info {
    az_distribution = "DEFAULT"
    client_subnets  = var.client_subnets # ["subnet-07326c2ea5469364c", "subnet-017c6a6e7fed00875", "subnet-0c5fb9904c6ddb3ec"]
    instance_type   = var.msk_instance_type # "kafka.t3.small"
    # should use flatten to adopt more sg to be added
    security_groups = [aws_security_group.this.id]
    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
      }
    }
  }



  client_authentication {
    sasl {
      iam   = "false"
      scram = "true"
    }
  }

  configuration_info {
    arn      = try(aws_msk_configuration.this[0].arn, data.aws_msk_configuration.this[0].arn)
    revision = var.msk_config_revision # 1
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.this.arn

    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = "true"
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = "true"
        log_group = local.cloudwatch_log_group
      }

      firehose {
        enabled = "false"
      }

      s3 {
        enabled = "false"
      }
    }
  }

  enhanced_monitoring = "PER_TOPIC_PER_PARTITION"
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = "true"
      }

      node_exporter {
        enabled_in_broker = "true"
      }
    }
  }
  tags = merge(var.tags, 
              { repo = try(var.default_tags["repo"],"")}, 
              { iac_managed_by = try(var.default_tags["iac_managed_by"],"terraform")}, 
              null)
  tags_all = var.tags
}


resource "aws_msk_scram_secret_association" "this" {
  cluster_arn     = aws_msk_cluster.this.arn
  secret_arn_list = concat([for r in aws_secretsmanager_secret.this : "${r.arn}"], var.extra_secret_arn_list)

  depends_on = [aws_secretsmanager_secret_version.this]
}
