variable "docdb_clusters" {
    type = map
    default = {}
    description = "maps contain the configuration for docdb cluster"
    validation {
    condition = alltrue(flatten(concat([for docdb in var.docdb_clusters: [for key in ["school", "project", "subproject", "envir", "contact","cluster"] : contains(keys(docdb.default_tags), key)]], [for docdb in var.docdb_clusters: [contains(["bus1","bus2","bus3","bus4"], docdb.default_tags["school"])]])))
    error_message = "Please include tags for school, project, subproject, envir, contact and cluster. allowed values for school: bus1, bus2, bus3, bus4."
    }  
}


# optional
variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "product_line" {
  type = string
  default = ""
}

variable "instance_count" {
    type = number
    default = 3
  
}

variable "db_name" {
  type = string
  default = ""
}


variable "instance_class" {
  type = string
  default = "db.r6g.large"
}
