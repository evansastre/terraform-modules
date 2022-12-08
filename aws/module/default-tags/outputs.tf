
output "tags" {
    description = "aws default tags"
    value = merge(data.aws_default_tags.this.tags, {"repo" = data.external.env.result["repo"]}, {"iac_managed_by" = "terraform"})

}