
variable "eks_nodegroups" {
  type = any
  default = {}
  
}

variable "iam_role_arn" {
  default = "arn:aws:iam::123456789012:role/eksNodeInstanceRole"
}

variable "capacity_type" {
  default = "SPOT"
}

variable "tags" {
  default = {}
  
}

variable "instance_types" {
  default = ["t3.medium"]
}
