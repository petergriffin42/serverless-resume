variable "custom_domain" {
  type        = string
  description = "URL of the website"
  default     = "peter.griffin-resume.com"
}

variable "azure_resource_group_location" {
  type        = string
  description = "Location of the resource group."
  default     = "westus2"
}

variable "aws_bucket_location" {
  type        = string
  description = "Location of the resource group."
  default     = "us-west-2"
}

