terraform {
  source = "../../module/sg-rules"

}

include {
  path = find_in_parent_folders()
}

locals{
  test = "sg-xxxxxxxxxxxxxxxxx"
}

dependency "security-group"{
    config_path  = "../security-group"
    mock_outputs = {
       id = { "security-name-1" = "test-111111" }
    }
}

inputs = {

    sg_rules = {
      sg_rule_1 = {
        security_group_id = local.test
        description =  "test"
        type = "ingress"
        from_port = 53
        to_port = 53
        protocol = "tcp"
        self = true
      }
       sg_rule_2 = {
        security_group_id = try(dependency.security-group.outputs.id["security-name-1"], null)
        type = "egress"
        from_port = 53
        to_port = 53
        protocol = "tcp"
        cidr_blocks = "10.0.0.0/16"
      }
       sg_rule_3 = {
        security_group_id = "sg-xxxxxxxxxxxxxxxxx"
        type = "ingress"
        from_port = 53
        to_port = 53
        protocol = "tcp"
        source_security_group_id = "sg-xxxxxxxxxxxxxxxxx"
      }
       sg_rule_4 = {
        security_group_id = "sg-xxxxxxxxxxxxxxxxx"
        type = "egress"
        from_port = 53
        to_port = 53
        protocol = "tcp"
        prefix_list_ids = "pl-xxxxxxx"
      }
    }
  

}