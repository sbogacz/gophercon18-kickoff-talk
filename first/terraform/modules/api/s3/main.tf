resource "aws_s3_bucket" "store" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  tags = "${var.tags}"

  lifecycle {}
}
