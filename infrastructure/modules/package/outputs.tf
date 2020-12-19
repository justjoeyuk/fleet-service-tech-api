output "key" {
  value = aws_s3_bucket_object.default.key
}

output "output_path" {
  value = data.archive_file.default.output_path
}
