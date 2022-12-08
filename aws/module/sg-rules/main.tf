
resource "aws_security_group_rule" "this" {
  for_each = var.sg_rules

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = each.value.security_group_id

  description              = try(each.value.description, var.description)
  self                     = try(each.value.self, null) == null ? null : true
  cidr_blocks              = try(each.value.cidr_blocks, null) == null ? null : split(",", each.value.cidr_blocks)
  source_security_group_id = try(each.value.source_security_group_id, null) == null ? null : each.value.source_security_group_id
  prefix_list_ids          = try(each.value.prefix_list_ids, null) == null ? null : split(",", each.value.prefix_list_ids)
}