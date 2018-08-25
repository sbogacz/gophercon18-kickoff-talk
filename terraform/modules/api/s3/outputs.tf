output "bucket_name" {
  description = "the name of the created bucket"
  value       = "${aws_s3_bucket.store.id}"
}

output "bucket_arn" {
  description = "the ARN of the created bucket"
  value       = "${aws_s3_bucket.store.arn}"
}
