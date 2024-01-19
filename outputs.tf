output "resource_group_name" {
  value = azurerm_resource_group.resume_resource_group.name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "azure_web_host" {
  value = azurerm_storage_account.storage_account.primary_web_host
}

output "aws_web_host" {
  value = aws_s3_bucket_website_configuration.resume.website_endpoint
}