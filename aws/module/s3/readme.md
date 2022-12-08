# Terraform module for AWS S3 management

S3 have many features.If you don't have any special feature settings, only the bucket name parameter is necessary.


to create a new bucket to stock your terraform.tfstate file.


## Inputs

| Name | Type | Description | Default Value |
| ------ | ------ | ------------- | ------------- |
| bucket | String | Name of S3 bucket | No default Value,You must set a unique name for your bukcet |
| default_tags| map| default tags for the resource, must provide and to be validated| yes|
| policy|map(String) | bucket policy | |
| policy_enabled| bool | Whether use bucket policy or not | false |
| intelligent_tiering | map(String) | S3 intelligent tiering settings | |
| object_lock_enabled | bool|Whether enable S3 object lock | false |
| object_lock_configuration | map(String) | S3 object lock settings | |
| lifecycle_rule | list[map(String)] | S3 bucket lifecycle settings | |
| cors_rule | list[map(String)] | S3 bucket cors rule | |
| acceleration_status | String | Whether enable S3 bucket acceleration | Suspended |
| enable_versioning | bool | Whether to enable S3 bucket versioning or not | default false |
| logging_enabled | bool | Whether enable S3 bucket logging | false |


## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_intelligent_tiering_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_object_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_request_payment_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_request_payment_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |

## Examples

### Create a new bucket with default settings

```yaml
terraform {
  source = "git::https://gitlab.enterprise.com/devops/terraform-modules.git//aws/ecr"
}
include root {
  path = find_in_parent_folders()
  expose =true
}

inputs {
    s3_buckets = {
        default-settings-bucket = {
            bucket = "default-settings-bucket"
            enable_versioning = true
        }
    }
}
```

### Create multi buckets with default settings
```yaml
terraform {
  source = "git::https://gitlab.enterprise.com/devops/terraform-modules.git//aws/ecr"
}
include root {
  path = find_in_parent_folders()
  expose =true
}

inputs {
    s3_buckets = {
        default-settings-bucket-1 = {
            bucket = "default-settings-bucket-1"
        },
        default-settings-bucket-2 = {
            bucket = "default-settings-bucket-2"
        },
    }
}
```

### Create multi buckets with different settings
```yaml
terraform {
  source = "git::https://gitlab.enterprise.com/devops/terraform-modules.git//aws/ecr"
}
include root {
  path = find_in_parent_folders()
  expose =true
}

inputs {
    s3_buckets = {
        enterprise-test-bucket-for-special-intelligent-tiering = {
            bucket = "enterprise-test-bucket-for-special-intelligent-tiering"
            attach_policy = true
            policy = jsondecode(file("./bucket_policy/bucket_policy.json"))
            intelligent_tiering = {
                general = {
                status = "Enabled"
                filter = {
                    prefix = "/"
                    tags = {
                    Environment = "dev"
                    }
                }
                tiering = {
                    ARCHIVE_ACCESS = {
                    days = 180
                    }
                }
                },
                documents = {
                status = false
                filter = {
                    prefix = "documents/"
                }
                tiering = {
                    ARCHIVE_ACCESS = {
                    days = 125
                    }
                    DEEP_ARCHIVE_ACCESS = {
                    days = 200
                    }
                }
                }
            }
        },
        enterprise-test-bucket-for-object-lock = {
            bucket = "enterprise-test-bucket-for-object-lock"
            attach_policy = true
            policy = jsondecode(file("./bucket_policy/default_bucket_policy.json"))
            object_lock_enabled = true
            object_lock_configuration = {
                rule = {
                default_retention = {
                    mode = "GOVERNANCE"
                    days = 1
                }
                }
            }
        },
        enterprise-test-bucket-for-special-lifecycle-rule = {
            bucket = "enterprise-test-bucket-for-special-lifecycle-rule"
            attach_policy = true
            policy = jsondecode(file("./bucket_policy/default_bucket_policy.json"))
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
        enterprise-test-bucket-for-special-cors-rule = {
            bucket = "enterprise-test-bucket-for-special-cors-rule"
            attach_policy = true
            policy = jsondecode(file("./bucket_policy/default_bucket_policy.json"))
            cors_rule = [
                {
                allowed_methods = ["PUT", "POST"]
                allowed_origins = ["https://zhangtest.tf"]
                allowed_headers = ["*"]
                expose_headers  = ["ETag"]
                max_age_seconds = 3000
                }
            ]
        },
        enterprise-test-bucket-for-acceleration = {
            bucket = "enterprise-test-bucket-for-acceleration"
            attach_policy = true
            policy = jsondecode(file("./bucket_policy/default_bucket_policy.json"))
            acceleration_status = "Enabled"
        }
    }
}
```

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_s3_bucket_bucket_domain_name"></a> [s3\_bucket\_bucket\_domain\_name](#output\_s3\_bucket\_bucket\_domain\_name) | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| <a name="output_s3_bucket_bucket_regional_domain_name"></a> [s3\_bucket\_bucket\_regional\_domain\_name](#output\_s3\_bucket\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| <a name="output_s3_bucket_hosted_zone_id"></a> [s3\_bucket\_hosted\_zone\_id](#output\_s3\_bucket\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region this bucket resides in. |
| <a name="output_s3_bucket_website_domain"></a> [s3\_bucket\_website\_domain](#output\_s3\_bucket\_website\_domain) | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| <a name="output_s3_bucket_website_endpoint"></a> [s3\_bucket\_website\_endpoint](#output\_s3\_bucket\_website\_endpoint) | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |