variable "create_bucket" {
  description = "Controls if S3 bucket should be created"
  type        = bool
  default     = true
}

variable "bucket" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  type        = string
  default     = null
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}

variable "policy_enabled" {
  description = "Whether S3 bucket should have bucket policy or not."
  type        = bool
  default     = false
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "acceleration_status" {
  description = "(Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended."
  type        = string
  default     = "Suspended"
}

variable "request_payer" {
  description = "(Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information."
  type        = string
  default     = null
}

variable "website" {
  description = "Map containing static web-site hosting or redirect configuration."
  type        = any # map(string)
  default     = {}
}

variable "cors_rule" {
  description = "List of maps containing rules for Cross-Origin Resource Sharing."
  type        = any
  default     = [
    # {
    #   allowed_methods = ["PUT", "POST"]
    #   allowed_origins = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
    #   allowed_headers = ["*"]
    #   expose_headers  = ["ETag"]
    #   max_age_seconds = 3000
    #   }, {
    #   allowed_methods = ["PUT"]
    #   allowed_origins = ["https://example.com"]
    #   allowed_headers = ["*"]
    #   expose_headers  = ["ETag"]
    #   max_age_seconds = 3000
    # }
  ]
}

variable "enable_versioning" {
  description = "versioning configuration."
  type        = bool
  default     = false
}

variable "versioning_mfa" {
  description = "The concatenation of the authentication device's serial number, a space, and the value that is displayed on your authentication device."
  type = string
  default = null
  
}

## If you enabled logging configuration, make sure the log bucket is already applied.
variable "logging_enabled" {
  description = "Whether S3 bucket should have a logging configuration enabled."
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "bucket name for saving the logs."
  type        = string 
  default     = ""
}

## If you enabled logging configuration, make sure the log bucket is already applied.
variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {
    target_bucket = ""
    target_prefix = "log/"
  }
}

variable "grant" {
  description = "An ACL policy grant. Conflicts with `acl`"
  type        = any
  default     = []
}

variable "owner" {
  description = "Bucket owner's display name and ID. Conflicts with `acl`"
  type        = map(string)
  default     = {}
}

variable "expected_bucket_owner" {
  description = "The account ID of the expected bucket owner"
  type        = string
  default     = null
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = [
        # {
        #   id      = "log"
        #   enabled = true

        #   filter = {
        #     tags = {
        #       some    = "value"
        #       another = "value2"
        #     }
        #   }

        #   transition = [
        #     {
        #       days          = 30
        #       storage_class = "ONEZONE_IA"
        #       }, {
        #       days          = 60
        #       storage_class = "GLACIER"
        #     }
        #   ]

        #   #        expiration = {
        #   #          days = 90
        #   #          expired_object_delete_marker = true
        #   #        }

        #   #        noncurrent_version_expiration = {
        #   #          newer_noncurrent_versions = 5
        #   #          days = 30
        #   #        }
        # },
        # {
        #   id                                     = "log1"
        #   enabled                                = true
        #   abort_incomplete_multipart_upload_days = 7

        #   noncurrent_version_transition = [
        #     {
        #       days          = 30
        #       storage_class = "STANDARD_IA"
        #     },
        #     {
        #       days          = 60
        #       storage_class = "ONEZONE_IA"
        #     },
        #     {
        #       days          = 90
        #       storage_class = "GLACIER"
        #     },
        #   ]

        #   noncurrent_version_expiration = {
        #     days = 300
        #   }
        # },
        # {
        #   id      = "log2"
        #   enabled = true
        #   filter = {
        #     prefix                   = "log1/"
        #     object_size_greater_than = 200000
        #     object_size_less_than    = 500000
        #     tags = {
        #       some    = "value"
        #       another = "value2"
        #     }
        #   }

        #   noncurrent_version_transition = [
        #     {
        #       days          = 30
        #       storage_class = "STANDARD_IA"
        #     },
        #   ]

        #   noncurrent_version_expiration = {
        #     days = 300
        #   }
        # },
      ]
}

variable "replication_configuration" {
  description = "Map containing cross-region replication configuration."
  type        = any
  default     = {}
}

variable "server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration."
  type        = any
  default     = {}
}

variable "intelligent_tiering" {
  description = "Map containing intelligent tiering configuration."
  type        = any
  default     = {}
}

variable "object_lock_configuration" {
  description = "Map containing S3 object locking configuration."
  type        = any
  default     = {}
}

variable "object_lock_enabled" {
  description = "Whether S3 bucket should have an Object Lock configuration enabled."
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL."
  type        = string
  default     = "ObjectWriter"
}

variable "s3_buckets" {
  type = any
  default = []
}

variable "sse_algorithm" {
  type = string
  default = "aws:kms"
}

variable "bucket_key_enabled" {
  default = false
  type = bool
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
}