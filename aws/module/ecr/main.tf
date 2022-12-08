data "aws_caller_identity" "current" {}

locals {
  principals_read_write_access = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksNodeInstanceRole"]
  
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "EKSNodeInstanceAcccess"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = concat(var.principals_read_write_access, local.principals_read_write_access)
    }

    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",  
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
  }
}


resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability


  encryption_configuration {
      encryption_type = try(var.encryption_type, null)
      kms_key         = try(var.kms_key, null)
    
  } 
   image_scanning_configuration {
      scan_on_push = var.enable_scan_on_push
  }

  tags_all = var.tags
}

resource "aws_ecr_repository_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Rotate images when reach ${var.max_image_count} images stored",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": ${var.max_image_count}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}