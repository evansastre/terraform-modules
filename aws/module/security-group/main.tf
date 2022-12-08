resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description      = try(ingress.value["description"], null)
      from_port        = ingress.value["from_port"]
      to_port          = ingress.value["to_port"]
      protocol         = ingress.value["protocol"]
      cidr_blocks      = [ingress.value["cidr_blocks"]]
    }
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all traffic out"
  }

 tags = merge( try(each.value.tags, null), 
              { repo = try(each.value.default_tags["repo"],"")}, 
              { iac_managed_by = try(each.value.default_tags["iac_managed_by"],"terraform")}, 
              null)

}