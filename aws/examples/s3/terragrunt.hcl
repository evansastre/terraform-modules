terraform {
  source = "../../module//s3"
}

include root {
  path = find_in_parent_folders()
  expose = true
}


dependency "default-tags"{
    config_path  = "../default-tags"
    mock_outputs = {
      tags = {
        school = "bus2"
        project = "bus2"
        subproject = "null"
        envir = "demo"
        contact = "contact"
      }
    }
} 


inputs = {

  s3_buckets = {

    test-bucket-for-special-intelligent-tiering = {
      bucket = "test-bucket-for-special-intelligent-tiering"
      enable_versioning = false
      default_tags = dependency.default-tags.outputs.tags
      sse_algorithm = "AES256"
      #logging_enabled = true
      #logging_bucket_name = "enterprise-bus2-aiden-test-log-bucket"

    }
    /* test-bucket-for-object-lock = {
      bucket = "test-bucket-for-object-lock"
      object_lock_enabled = false
      object_lock_configuration = {
        rule = {
          default_retention = {
            mode = "GOVERNANCE"
            days = 1
          }
        }
      }
    },
    test-bucket-for-special-lifecycle-rule = {
      bucket = "test-bucket-for-special-lifecycle-rule"
      lifecycle_rule = [
        {
          id      = "diff_with_default_lifecycle_rules"
          enabled = true

          filter = {
            tags = {
              some    = "value"
              another = "value2"
            }
          }

          transition = [
            {
              days          = 30
              storage_class = "ONEZONE_IA"
              }, {
              days          = 60
              storage_class = "GLACIER"
            }
          ]

          #        expiration = {
          #          days = 90
          #          expired_object_delete_marker = true
          #        }

          #        noncurrent_version_expiration = {
          #          newer_noncurrent_versions = 5
          #          days = 30
          #        }
        },
        {
          id                                     = "log1"
          enabled                                = true
          abort_incomplete_multipart_upload_days = 7

          noncurrent_version_transition = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 60
              storage_class = "ONEZONE_IA"
            },
            {
              days          = 90
              storage_class = "GLACIER"
            },
          ]

          noncurrent_version_expiration = {
            days = 300
          }
        }
      ]
    },
    test-bucket-for-special-cors-rule = {
      bucket = "test-bucket-for-special-cors-rule"
      cors_rule = [
        {
          allowed_methods = ["PUT", "POST"]
          allowed_origins = ["https://test.tf"]
          allowed_headers = ["*"]
          expose_headers  = ["ETag"]
          max_age_seconds = 3000
          }
      ]
    },
    test-bucket-for-acceleration = {
      bucket = "test-bucket-for-acceleration"
      acceleration_status = "Enabled"
    },
    test-bucket-for-server_side_encryption = {
      bucket = "test-bucket-for-acceleration"
      server_side_encryption_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            kms_master_key_id = aws_kms_key.this.arn
            sse_algorithm     = "aws:kms"
          }
        }
    }
    },
    test-bucket-for-versioning = {
      bucket = "test-bucket-for-versioning"
      versioning = {
        status     = "Enabled"
      }
    },
    test-bucket-for-stock-log = {
      bucket = "test-bucket-for-stock-log"
    },
    test-bucket-for-enable-logging = {
      bucket = "test-bucket-for-enable-logging"
      logging_enabled = true
    },
    test-bucket-for-special-bucket-policy = {
      bucket = "test-bucket-for-bucket-policy"
      policy = file("./bucket_policy/bucket_policy.json")
    }, */
  }
  
}