
variable "ec2_instances" {
  type = any
  description = "a map of ec2 instances to be created"
  validation {
    condition = alltrue(flatten(concat([for instance in var.ec2_instances: [for key in ["school", "project", "subproject", "envir", "contact","cluster"] : contains(keys(instance.default_tags), key)]], [for instance in var.ec2_instances: [contains(["bus1","bus2","bus3","bus4"], instance.default_tags["school"])]])))
    error_message = "Please include tags for school, project, subproject, envir, contact and cluster. allowed values for school: bus1, bus2, bus3, bus4."
    }
}
