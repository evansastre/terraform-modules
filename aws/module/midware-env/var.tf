# common var
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

variable "db_subnet_groups" {
  type = map
  default = {}
}


variable "elasticache_subnet_groups" {
  type = map
  default = {}
}

variable "create_pg12-paragroup" {
  default = false
}

variable "create_mysql-paragroup" {
  default = false
  
}

variable "create_cluster-pg12-paragroup" {
  default = false
  
}

variable "create_cluster-mysql-paragroup" {
  default = false
  
}

variable "create_docdb-paragroup" {
  default = false
}

variable "create_msk-configuration" {
  default = false
  
}