variable "security_groups" {
  type = any
  description = "list of security group blocks"
  validation {
    condition = alltrue(flatten(concat([for sg in var.security_groups: [for key in ["school", "project", "subproject", "envir", "contact","cluster"] : contains(keys(sg.default_tags), key)]], [for sg in var.security_groups: [contains(["bus1","bus2","bus3","bus4"], sg.default_tags["school"])]])))
    error_message = "Please include tags for school, project, subproject, envir, contact and cluster. allowed values for school: bus1, bus2, bus3, bus4."
    }
}
