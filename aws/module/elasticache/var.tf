# required
variable "vpc_id" {
  type = string
  default = ""
}

variable "redis_instances" {
  type =  map
  description = "a list of redis instances to be created"
  validation {
    condition = alltrue(flatten(concat([for redis in var.redis_instances: [for key in ["school", "project", "subproject", "envir", "contact","cluster"] : contains(keys(redis.default_tags), key)]], [for redis in var.redis_instances: [contains(["bus1","bus2","bus3","bus4"], redis.default_tags["school"])]])))
    error_message = "Please include tags for school, project, subproject, envir, contact and cluster. allowed values for school: bus1, bus2, bus3, bus4."
    }  
}

variable "redis_subnet_group_name" {
  type = string
  default = ""
}

# optional
variable "env" {
  type = string
  default = "dev"
}

variable "region" {
  type = string
  default = "tky"
}

variable "product_line" {
  type = string
  default = "bus2"
}

variable "multi_az_enabled" {
  type = bool
  default = true
}

variable "snapshot_retention_limit" {
  type = number
  default = 7
}

variable "automatic_failover_enabled" {
  type = bool
  default = true
}

variable "node_type" {
  type = string
  default = "cache.r6g.large"
}

variable "all_stage_password" {
  type = string
  default = ""
  sensitive = true
}

variable "engine_version" {
  type = string
  default = "6.x"
}

variable "at_rest_encryption_enabled" {
  type = bool
  default = true
}

variable "transit_encryption_enabled" {
  type = bool
  default = true
}

variable "auto_minor_version_upgrade" {
  type = bool
  default = true
}

variable "parameter_group_name" {
  type = string
  default = "default.redis6.x"
}

variable "num_cache_clusters" {
  type = number
  default = 2
}


variable "create_security_group" {
  type = bool
  default = false
}

variable "auth_token" {
  type = string
  default = "auth_token"
  
}
