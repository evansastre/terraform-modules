resource "aws_db_parameter_group" "pg12-paragroup" {
  count = var.create_pg12-paragroup == true ? 1 : 0

  description = "${var.env} ${var.region} ${var.product_line} parameter group"
  family      = "aurora-postgresql12"
  name        = "${var.env}-${var.region}-${var.product_line}-postgresqldb"

  parameter {
    apply_method = "immediate"
    name         = "log_min_duration_statement"
    value        = "1000"
  }

  parameter {
    apply_method = "immediate"
    name         = "log_min_messages"
    value        = "log"
  }

  parameter {
    apply_method = "immediate"
    name         = "log_min_error_statement"
    value        = "warning"
  }
}

resource "aws_db_parameter_group" "mysql-paragroup" {
  count = var.create_mysql-paragroup == true ? 1 : 0

  description = "${var.env} ${var.region} ${var.product_line} parameter group"
  family      = "aurora-mysql5.7"
  name        = "${var.env}-${var.region}-${var.product_line}-mysqldb"

}



resource "aws_rds_cluster_parameter_group" "pg12-paragroup" {
  count = var.create_cluster-pg12-paragroup == true ? 1 : 0

  description = "${var.env} ${var.region} ${var.product_line} parameter group"
  family      = "aurora-postgresql12"
  name        = "${var.env}-${var.region}-${var.product_line}-postgresqlcluster"

  parameter {
    apply_method = "immediate"
    name         = "log_min_duration_statement"
    value        = "1000"
  }

  parameter {
    apply_method = "immediate"
    name         = "log_min_error_statement"
    value        = "warning"
  }

  parameter {
    apply_method = "immediate"
    name         = "log_min_messages"
    value        = "log"
  }

  parameter {
    apply_method = "immediate"
    name         = "log_statement"
    value        = "ddl"
  }

  parameter {
    apply_method = "immediate"
    name         = "rds.log_retention_period"
    value        = "1440"
  }
}

resource "aws_rds_cluster_parameter_group" "mysql-paragroup" {
  count = var.create_cluster-mysql-paragroup == true ? 1 : 0

  name        = "${var.env}-${var.region}-${var.product_line}-mysqlcluster"
  family      = "aurora-mysql5.7"
  description = "${var.env} ${var.region} ${var.product_line} mysql parameter group"

  parameter {
    apply_method = "immediate"
    name         = "character_set_client"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_connection"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_database"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_results"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_server"
    value        = "utf8mb4"
  }
  parameter {
    apply_method = "immediate"
    name         = "long_query_time"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "max_allowed_packet"
    value        = "1073741824"
  }
  parameter {
    apply_method = "immediate"
    name         = "server_audit_logging"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "server_audit_logs_upload"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "slow_query_log"
    value        = "1"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "lower_case_table_names"
    value        = "1"
  }
}

resource "aws_docdb_cluster_parameter_group" "docdb-paragroup" {
  count = var.create_docdb-paragroup == true ? 1 : 0
  name        = "${var.env}-${var.region}-${var.product_line}-docdbcluster"
  description = "${var.env} ${var.region} ${var.product_line} docdb parameter group"
  family      = "docdb4.0"

  parameter {
    apply_method = "immediate"
    name         = "audit_logs"
    value        = "enabled"
  }
  parameter {
    apply_method = "immediate"
    name         = "profiler"
    value        = "enabled"
  }
}

resource "aws_msk_configuration" "this" {
  count = var.create_msk-configuration == true ? 1 : 0
  name        = "${var.env}-${var.region}-${var.product_line}-msk"
  description = "${var.env} ${var.region} ${var.product_line} msk configuration"

  server_properties = <<PROPERTIES
auto.create.topics.enable=true
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


resource "aws_db_subnet_group" "this" {
  for_each = var.db_subnet_groups

  name       = each.value.name
  subnet_ids = each.value.subnet_ids

  tags = {
    Name = "${var.env} ${var.region} ${var.product_line} ${each.value.name} DB subnet group"
  }
}

resource "aws_elasticache_subnet_group" "this" {
  for_each = var.elasticache_subnet_groups

  name        = each.value.name
  description = "${var.env} ${var.region} ${var.product_line} ${each.value.name} redis subnet group"
  subnet_ids  = each.value.subnet_ids
}
