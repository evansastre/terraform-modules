# required
variable "db_name" {
  type = string
  default = ""
}

variable "vpc_id" {
  type = string
  default = null
}

variable "db_subnet_group_name" {
  type = string
  default = null
}

variable "db_cluster_parameter_group_name" {
  type = string
  default = null
}

variable "db_parameter_group_name" {
  type = string
  default = ""
}

# optional
variable "env" {
  type = string
  default = "dummyenv"
}

variable "region" {
  type = string
  default = "dummyregion"
}

variable "product_line" {
  type = string
  default = "bus2"
}

variable "engine" {
  type = string
  default = "postgresql"
}

variable "engine_version" {
  type = string
  default = "12.8"
}

variable "instance_class" {
  type = string
  default = "db.r6g.large"
}

variable "publicly_accessible" {
  type = bool
  default = false
}

variable "rds_cluster_deletion_protection" {
  type = bool
  default = true
}

variable "enabled_cloudwatch_logs_exports" {
  type = list(string)
  default = ["postgresql"]
}

variable "all_stage_password" {
  type = string
  default = ""
  sensitive = true
}

variable "tags" {
  type = map
  description = "tags"
  default = {}
}

variable "default_tags" {
  type = map
  description = "tags"
  default = {}
}

variable "rds_clusters" {
  type = any
  validation {
    condition = alltrue(flatten(concat([for rds in var.rds_clusters: [for key in ["school", "project", "subproject", "envir", "contact","cluster"] : contains(keys(rds.default_tags), key)]], [for rds in var.rds_clusters: [contains(["bus1","bus2","bus3","bus4"], rds.default_tags["school"])]])))
    error_message = "Please include tags for school, project, subproject, envir, contact and cluster. allowed values for school: bus1, bus2, bus3, bus4."
    }
}

variable "instances" {
  type = any
  default = {
    1 = {}
    2 = {}
  }
}

variable "create_security_group" {
  type = bool 
  default = false
}