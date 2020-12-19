variable "zip_dir" {
  type = string
  description = "The directory to ZIP"
}

variable "zip_output_path" {
  type = string
  description = "The output path for the ZIP"
}

variable "bucket_id" {
  type = string
  description = "The id of the bucket to upload the ZIP to"
}

variable "name" {
  type = string
  description = "The name of the packaged zip in the bucket"
}
