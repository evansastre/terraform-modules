data "aws_canonical_user_id" "this" {}

data "aws_s3_bucket" "log-bucket" {
  for_each = { for item in var.s3_buckets:
                item.bucket => item.logging_bucket_name
                if try(item.logging_bucket_name, null) !=null
  }
  bucket = each.value
}

resource "aws_s3_bucket" "this" {
  for_each              = var.s3_buckets
  bucket        = each.value.bucket

  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags = merge(try(each.value.tags, var.tags), 
              { repo = try(each.value.default_tags["repo"],"null")}, 
              { iac_managed_by = try(each.value.default_tags["iac_managed_by"],"terraform")}, 
              null)

  lifecycle {
    ignore_changes = [
      ## Deprecated settings
      acceleration_status,
      acl,
      grant,
      cors_rule,
      lifecycle_rule,
      logging,
      object_lock_configuration,
      replication_configuration,
      request_payer,
      server_side_encryption_configuration,
      versioning,
      website
    ]
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each   = {
    for bucket,v in var.s3_buckets : bucket => v
    if try(v.policy_enabled, var.policy_enabled, false)
    }

  bucket                = each.value.bucket
  policy                = try(each.value.policy, file("./bucket_policy/default_bucket_policy.json"))
}

resource "aws_s3_bucket_logging" "this" {
  for_each   = {
    for bucket,v in var.s3_buckets : bucket => v
    if try(v.logging_enabled, var.logging_enabled, false)
    }

  bucket                = each.value.bucket

  target_bucket = data.aws_s3_bucket.log-bucket[each.value.bucket].bucket
  target_prefix = try(var.logging["target_prefix"], null)
}



resource "aws_s3_bucket_versioning" "this" {
  for_each              = var.s3_buckets
  bucket                = each.value.bucket
  mfa                   = try(each.value.versioning_mfa, null)

  versioning_configuration {
    # Valid values: "Enabled" or "Suspended"
    status = try(each.value.enable_versioning, false) == true ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each   = {
    for bucket,v in var.s3_buckets : bucket => v
    }

  bucket     = each.value.bucket
  rule {

    bucket_key_enabled = try(each.value.bucket_key_enabled, var.bucket_key_enabled)
    apply_server_side_encryption_by_default {
      kms_master_key_id = try(each.value.sse_algorithm, var.sse_algorithm) == "AES256" ? null : try(aws_kms_key.this[each.value.bucket].arn, null)
      sse_algorithm     = try(each.value.sse_algorithm, var.sse_algorithm)
    }
  }

  lifecycle {
    ignore_changes  = [
      rule
    ]
  }

}

/* resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each   = {
    for bucket,v in var.s3_buckets : bucket => v
    }

  bucket     = each.value.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = try(aws_kms_key.this[0].arn, null)
      sse_algorithm     = var.sse_algorithm
    }
  }

  dynamic "rule" {
    for_each = try(flatten([each.value.server_side_encryption_configuration["rule"]]), flatten([var.server_side_encryption_configuration["rule"]]), [])

    content {
      bucket_key_enabled = try(rule.value.bucket_key_enabled, null)

      dynamic "apply_server_side_encryption_by_default" {
        for_each = try([rule.value.apply_server_side_encryption_by_default], [])

        content {
          sse_algorithm     = var.sse_algorithm
          kms_master_key_id = try(aws_kms_key.this.id, null)
        }
      }
    }
  }
} */

resource "aws_kms_key" "this" {
  for_each                = {
    for bucket,v in var.s3_buckets : bucket => v
      if try(v.sse_algorithm, var.sse_algorithm) != "AES256"
    }

  description             = each.value.bucket
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "this" {
  for_each                = {
    for bucket,v in var.s3_buckets : bucket => v
      if try(v.sse_algorithm, var.sse_algorithm) != "AES256"
    }

  name          = "alias/${each.value.bucket}"
  target_key_id = aws_kms_key.this[each.value.bucket].key_id

  depends_on = [
    aws_kms_key.this
  ]
}

resource "aws_s3_bucket_accelerate_configuration" "this" {
  for_each   = {
    for bucket,v in var.s3_buckets : bucket => v
    }
  bucket        = each.value.bucket

  # Valid values: "Enabled" or "Suspended"
  status = title(lower(try(each.value.acceleration_status, var.acceleration_status)))
}

resource "aws_s3_bucket_cors_configuration" "this" {
  for_each   = {
    for bucket,v in var.s3_buckets : bucket => v
      if try(bucket.cors_rule, null) !=null
    }

  bucket     = each.value.bucket

  dynamic "cors_rule" {
    for_each = try(each.value.cors_rule, var.cors_rule, null)

    content {
      id              = try(cors_rule.value.id, null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each   = {
    for bucket,v in var.s3_buckets : bucket => v
      if try(bucket.lifecycle_rule, null) !=null
    }

  bucket     = each.value.bucket

  dynamic "rule" {
    for_each = try(each.value.lifecycle_rule, var.lifecycle_rule)

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }


      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      # Max 1 block - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [true] : []

        content {
          #          prefix = ""
        }
      }

      # Max 1 block - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) == 1]

        content {
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)
          prefix                   = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = try(filter.value.tags, filter.value.tag, [])

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1]

        content {
          and {
            object_size_greater_than = try(filter.value.object_size_greater_than, null)
            object_size_less_than    = try(filter.value.object_size_less_than, null)
            prefix                   = try(filter.value.prefix, null)
            tags                     = try(filter.value.tags, filter.value.tag, null)
          }
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  for_each   = {
    for bucket,v in var.s3_buckets : bucket => v
    if try(v.object_lock_enabled, var.object_lock_enabled, false)
    }
  bucket        = each.value.bucket
  token         = try(each.value.object_lock_configuration.token, null)

  rule {
    default_retention {
      mode  = each.value.object_lock_configuration.rule.default_retention.mode
      days  = try(each.value.object_lock_configuration.rule.default_retention.days, null)
      years = try(each.value.object_lock_configuration.rule.default_retention.years, null)
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each              = var.s3_buckets

  bucket                = each.value.bucket

  block_public_acls       = try(each.value.block_public_acls, true)
  block_public_policy     = try(each.value.block_public_policy, true)
  ignore_public_acls      = try(each.value.ignore_public_acls, true)
  restrict_public_buckets = try(each.value.restrict_public_buckets, true)
}