# required
variable "vpc_id" {
  type = string
}

variable "name" {
  type = string
  description = "purpose of this msk cluster"
}

variable "client_subnets" {
  type = list(string)
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

variable "key_usage" {
  type = string
  default = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  type = string
  default = "SYMMETRIC_DEFAULT"
}

variable "retention_in_days" {
  type = number
  default = 30
}

variable "msk_instance_type" {
  type = string
  default = "kafka.t3.small"
}

variable "all_stage_password" {
  type = string
  default = ""
  sensitive = true
}

variable "ebs_volume_size" {
  type = number
  default = 1
}

variable "kafka_version" {
  type = string
  default = "2.6.2"
}

variable "number_of_broker_nodes" {
  type = number
  default = 3
}

variable "create_msk_configuration" {
  type = bool 
  default = true
}

variable "msk_config_revision" {
  type = number
  default = 1
}

variable "existing_msk_configuration_name" {
  type = string 
  default = null
}


variable "auto_create_topics" {
  type = bool 
  description = "whether to auto create kafka topics"
  default = false
}

variable "kms_key_admin"{
  type = list
  description = "list of user arn"
  default = []
}


variable "kms_key_user"{
  type = list
  description = "list of user arn"
  default = []
}


variable "kms_key_attachment"{
  type = list
  description = "list of user arn"
  default = []
}

variable "principal_type" {
  type = string 
  description = "the original IdP of the pricinpal could be AWS or Federated"
  default = "AWS"
}  

variable "kms_key_policy"{
  type = string
  description = "kms key policy"
  default = ""
}

variable "tags" {
  type = map
  description = "tags"
  default = {}
}


variable "default_tags" {
  type = map
  description = "tags"
  validation {
    condition = alltrue(concat([for key in ["school", "project", "subproject", "envir", "contact","cluster"] : contains(keys(var.default_tags), key)], [contains(["bus1","bus2","bus3","bus4"], var.default_tags["school"])]))
    error_message = "Please include tags for school, project, subproject, envir, contact and cluster. allowed values for school: bus1, bus2, bus3, bus4."
    }
}

variable "extra_secret_arn_list" {
  type = list
  default = []
}