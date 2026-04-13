variable "credentials" {
  description = "My Credentials"
  default     = "./keys/terraform-key.json"
}


variable "project" {
  description = "Project"
  default     = "sensor-data-pipeline-492507"
}

variable "region" {
  description = "Region"
  default     = "us-central1"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "sensor_data"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "sensor-data-lake-hamed"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}