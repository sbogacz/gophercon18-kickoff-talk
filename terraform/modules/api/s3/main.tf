resource "aws_s3_bucket" "store" {
  bucket = "${format("%s-%s", var.bucket_name, var.environment)}"
  acl    = "private"

  tags = "${var.tags}"

  lifecycle_rule {
    enabled = "${var.enable_expiration}"

    expiration {
      days = "${var.ttl}"
    }
  }
}
