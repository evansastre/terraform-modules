data "aws_caller_identity" "current" {}

data "aws_msk_configuration" "this" {
  count = var.create_msk_configuration == false ? 1 : 0
  name = var.existing_msk_configuration_name
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "Enable IAM User Permissions"

    actions = [
      "kms:*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }
  statement {
    sid = "Allow access for Key Administrators"

    actions = [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
    ]
    principals {
      type        = var.principal_type
      identifiers = var.kms_key_admin
    }
    resources = ["*"]
  }

  statement {
    sid = "Allow use of the key"

    actions = [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
    ]
    principals {
      type        = var.principal_type
      identifiers = var.kms_key_user
    }
    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources"

    actions = [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            
    ]
    principals {
      type        = var.principal_type
      identifiers = var.kms_key_attachment
    }
    resources = ["*"]

    condition {
            test = "Bool"
            variable = "kms:GrantIsForAWSResource"
            values = ["true"]
        }
  }
}
