# locals {
#   #db_cluster_name = var.db_cluster_name
#   db_cluster_name = join("-", ["aws-${var.region}-${var.product_line}-%s","${var.env}"])
#   generic_tags =  {
#     environment  = var.env
#     region       = var.region
#     product_line = var.product_line
#     db_type      = "docdb"
#   }
#   #db_cluster_tags = merge(var.tags, local.generic_tags)
# }

# data "vault_kv_secret_v2" "this" {
#   count  = try(var.vault_kv_name, null) == null ? 0 : 1

#   mount = var.vault_path
#   name  = var.vault_kv_name
# }


resource "random_password" "master" {
  length = 16
  special = false
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier              = var.db_cluster_name
  backup_retention_period         = var.backup_retention_period
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  db_subnet_group_name            = var.db_subnet_group_name
  deletion_protection             = var.docdb_cluster_deletion_protection
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  engine_version                  = var.engine_version
  preferred_backup_window         = "17:00-20:00"
  preferred_maintenance_window    = "mon:03:00-mon:04:00"
  
  # Todo: this should be replaced by dynamic content block based on skip_final_snapshot
  final_snapshot_identifier       = "final-${var.db_cluster_name}"
  skip_final_snapshot             = var.skip_final_snapshot

  # should have all usernames & passwords to automatically saved to vault or secret manager
  master_username                 = var.master_username
  master_password                 = coalesce(var.all_stage_password, random_password.master.result)

  storage_encrypted               = true
  tags                            = var.tags
  tags_all = var.tags_all

  vpc_security_group_ids = concat(var.vpc_security_group_ids, try(aws_security_group.this[0].id, null) == null ? []: [aws_security_group.this[0].id])

  lifecycle {
    ignore_changes = [master_password]
  }
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.instance_count

  identifier         = "${aws_docdb_cluster.this.cluster_identifier}-${count.index}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class
  tags = var.tags
  tags_all = var.tags_all
}

resource "aws_security_group" "this" {
  count = var.create_security_group == true ? 1 : 0

  name_prefix = "${var.db_cluster_name}-"
  vpc_id      = var.vpc_id
  description = "Control traffic to/from Document DB ${var.db_cluster_name}"

  tags                            = var.tags
  tags_all = var.tags_all
}

resource "aws_security_group_rule" "egress_all" {
  count = var.create_security_group == true ? 1 : 0

  type                     = "egress"
  to_port                  = 0
  from_port                = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.this[0].id
  description              = "Allow all traffic out"
}

data "aws_region" "current" {}


resource "null_resource" "local_provisioner" {
  count =  try(var.vault_path, null) == null ? 0 : 1

  provisioner "local-exec" {
    command = <<EOT

      password=`vault kv  get  -field=${var.master_username}   ${var.vault_path}`
      aws docdb modify-db-cluster --db-cluster-identifier ${aws_docdb_cluster.this.id}  --master-user-password $password --apply-immediately --region ${data.aws_region.current.name}
    EOT
    
  }
  depends_on = [
    aws_docdb_cluster.this
  ]
}