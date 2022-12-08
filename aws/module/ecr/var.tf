
variable "name" {
  type = string
  description = "purpose of this resource"
  default = ""
}

variable "principals_read_write_access" {
  type = list
  description = "a list of ARN which has the ECR read-write access"
  default = []
}

variable "image_tag_mutability" {
  type = string 
  description = "enable image tag immutability or not"
  default = "MUTABLE"
}

variable "encryption_type" {
  type = string
  description = "Encryption type"
  default = "AES256"
}

variable "kms_key" {
  type = string 
  description = "the arn of the CMK key"
  default = ""
}

variable "enable_scan_on_push" {
  type = bool 
  description = "scanning configuration for image scanning"
  default = false
}

variable "max_image_count" {
  type = number 
  description = "max number of the image"
  default = 500
}

variable "tags" {
  type = map
  description = "tags"
  validation {
    condition = alltrue(concat([for key in ["school", "project", "subproject", "envir", "contact","cluster"] : contains(keys(var.tags), key)], [contains(["bus1","bus2","bus3","bus4"], var.tags["school"])]))
    error_message = "Please include tags for school, project, subproject, envir, contact and cluster. allowed values for school: bus1, bus2, bus3, bus4."
    }
}

