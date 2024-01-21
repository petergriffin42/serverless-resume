data "azurerm_client_config" "current" {}

locals {
    
    # An open github issue involves indirect CNAME validation not working. https://github.com/hashicorp/terraform-provider-azurerm/issues/12737
    # In the interest of cost I want to use Cloudflare Proxy instead of Azure Front Door for SSL. So as a workaround I will set the azure_web that seems to fit uswest2
    azure_web     = "z5"
    azure_storage_account_name = join("", ["resume",random_string.storage_account_name.result])
    azure_storage_web = join("", [local.azure_storage_account_name,".", local.azure_web, ".web.core.windows.net"])

    content_types = {
    css         = "text/css"
    html        = "text/html"
    ico         = "image/x-icon"
    png         = "image/png"
    svg         = "image/svg+xml"
    webmanifest = "application/manifest+json"
    xml         = "application/xml"
  }
}

# Generate random value for the storage account name. Names can be taken already
resource "random_string" "storage_account_name" {
  length  = 5
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_resource_group" "resume_resource_group" {
  name     = "resume_resource_group"
  location = var.azure_resource_group_location
}

resource "azurerm_storage_account" "storage_account" {
  resource_group_name = azurerm_resource_group.resume_resource_group.name
  location            = azurerm_resource_group.resume_resource_group.location

  name = local.azure_storage_account_name

  
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Cloudflare proxy is handling https in front of it so it will connect via http
  enable_https_traffic_only = false

  custom_domain {
    name                   = var.custom_domain
    use_subdomain          = false
  }

  static_website {
    index_document = "index.html"
  }
  depends_on = [null_resource.update_dns_record_proxy_off]
}

resource "null_resource" "update_dns_record_proxy_off" {
  triggers = {
    random_string = random_string.storage_account_name.result
}
  provisioner "local-exec" {
    command = <<-EOT
      ${path.module}/python-update-dns/env/bin/python ${path.module}/python-update-dns/update-cloudflare-record.py --record-name ${var.custom_domain} --record-type CNAME --record-content ${local.azure_storage_web}
    EOT
  }
}

resource "null_resource" "update_dns_record_proxy_on" {
  triggers = {
    storage_created = azurerm_storage_account.storage_account.id
}

# For those that are closely looking at the code you may be wondering why I am deploying an s3 bucket but only adding the DNS for Azure.
# To minimize costs I decided against adding a Load Balancer to the website. My original intent was to have an LB so the setup is mostly there so I kept the code for the s3 buckets.
  provisioner "local-exec" {
    command = <<-EOT
      ${path.module}/python-update-dns/env/bin/python ${path.module}/python-update-dns/update-cloudflare-record.py --record-name ${var.custom_domain} --record-type CNAME --record-content ${local.azure_storage_web} --proxied
    EOT
  }
}

resource "azurerm_storage_blob" "resume_files" {
  for_each = fileset(path.module, "hugo-website/public/**/*")

  name                   = replace(each.key, "hugo-website/public/", "")
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = each.key
  # Below variable required to know when the files change
  content_md5            = filemd5(each.key)
  # Make sure it sets the content_type for css and other files correctly
  content_type = lookup(local.content_types, reverse(split(".", each.key))[0], "text/html")
}


# AWS does not require verification for hosting your domain through s3. The only restriction is the bucket name has to match the domain name
resource "aws_s3_bucket" "resume" {
  bucket = var.custom_domain
}

resource "aws_s3_bucket_website_configuration" "resume" {
  bucket = aws_s3_bucket.resume.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "resume" {
  bucket = aws_s3_bucket.resume.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_public_access_block" "resume" {
  bucket = aws_s3_bucket.resume.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Need to enable the ability to have public acls before it will allow you to make it public
resource "aws_s3_bucket_acl" "resume" {
  depends_on = [
    aws_s3_bucket_ownership_controls.resume,
    aws_s3_bucket_public_access_block.resume,
  ]

  bucket = aws_s3_bucket.resume.id
  acl    = "public-read"
}

resource "aws_s3_object" "resume_files" {
  depends_on = [
    aws_s3_bucket_acl.resume
  ]

  for_each = fileset(path.module, "hugo-website/public/**/*")

  bucket = aws_s3_bucket.resume.bucket
  key    = replace(each.key, "hugo-website/public/", "")
  source = each.key
  content_type = lookup(local.content_types, reverse(split(".", each.key))[0], "text/html")
  acl    = "public-read"
  source_hash = filemd5(each.key)
}
