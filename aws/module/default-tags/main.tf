data "aws_default_tags" "this" {}
data "external" "env" {
  program = ["${path.module}/env.sh"]
}

