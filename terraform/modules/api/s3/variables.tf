/**************************
 * General 
 **************************/
variable "environment" {
  description = "development, production, etc."
  type        = "string"
  default     = "development"
}

variable "tags" {
  type        = "map"
  description = "mandatory tags to prevent Krampus from our killing services"
  default     = {}
}

/**************************
 * S3 
 **************************/
variable "bucket_name" {
  description = "the name of the bucket to create"
}

variable "ttl" {
  description = "the TTL (in days) to set on the objects created in S3"
  default     = 1
}

variable "enable_expiration" {
  description = "whether to enable to object expiration on the bucket"
}
