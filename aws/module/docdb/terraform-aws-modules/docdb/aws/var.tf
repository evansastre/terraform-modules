# required
variable "vpc_id" {
  type = string
  default = ""
}


variable "db_cluster_name" {
  type = string 
}

variable "backup_retention_period" {
  type = number
  default = 7
}

variable "db_subnet_group_name" {
  type = string
  default = null
}

variable "instance_class" {
  type = string
  default = "db.r6g.large"
}

variable "db_cluster_parameter_group_name" {
  type = string
  default = null
}

variable "engine_version" {
  type = string
  default = "4.0.0"
}

variable "vpc_security_group_ids" {
  type = list
  default = []
  
}

variable "all_stage_password" {
  type = string
  default = ""
  sensitive = true
}

variable "skip_final_snapshot" {
  type = bool
  default = false
}

variable "docdb_cluster_deletion_protection" {
  type = bool
  default = true
}

variable "enabled_cloudwatch_logs_exports" {
  type = list(string)
  default = [
    "audit",
    "profiler",
  ]
}

variable "master_username" {
  type =  string
  default = "enterprisedbaadmin"
  
}

variable "tags" {
  type = map
  default = {}
}

variable "tags_all" {
  type = map
  default = {}
}

variable "default_tags" {
  type = map
  default = {}
}

variable "instance_count" {
  type = number
  default = 3
}

variable "create_security_group" {
  type =  bool 
  default = false
  
}

variable "vault_path" {
  type = string
  default = null
}
