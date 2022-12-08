variable "vpc_id" {
  type = string
  default = "default"
}

variable "subnet_ids" {
  type = list(string)
  default = null
}

variable "instance_type" {
  default = "c5.4xlarge"
  
}

# specific param
variable "k8s_version" {
  type = string
  default = "1.21"
}

variable "cluster_endpoint_public_access" {
  type = bool
  default = false
}

variable "eks_managed_node_groups" {
  type = any
  default = {}
}

variable "tags" {
  default = {}
  
}

variable "cluster_tags" {
  default = {}
  
}
variable "iam_role_additional_policies" {
  type = list
  default = []
}

variable "eks_clusters" {
  type = any
  default = {}
  validation {
    condition = alltrue(flatten(concat([for eks in var.eks_clusters: [for key in ["school", "project", "subproject", "envir", "contact","cluster"] : contains(keys(eks.default_tags), key)]], [for eks in var.eks_clusters: [contains(["bus1","bus2","bus3","bus4"], eks.default_tags["school"])]])))
    error_message = "Please include tags for school, project, subproject, envir, contact and cluster. allowed values for school: bus1, bus2, bus3, bus4."
    }
  
}

variable "key_name" {
  default = null
}
