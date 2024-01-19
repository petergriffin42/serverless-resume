# Serverless Resume Deployment

This repository documents the complete automation of deploying my serverless resume to Azure Blob Storage and an Amazon S3 Bucket. Previously hosted on a Kubernetes cluster in AWS, the expenses prompted a shift to a more cost-effective approach. The current deployment minimizes costs while showcasing my proficiency in navigating multiple Cloud platforms, utilizing Python, and leveraging Terraform.

## Deployment Process

### 1. Hugo Static Site Generation
   - Hugo, a fast and flexible static site generator, is employed to generate the website's content and structure. It produces the static files ready for upload utilizing a template.

### 2. Terraform Infrastructure Provisioning
   - Terraform automates the provisioning of Azure Blob Storage and an Amazon S3 Bucket, forming the foundational infrastructure for the serverless resume.

### 3. Python Cloudflare DNS Automation (Workaround)
   - To address an open issue preventing Terraform from handling the DNS records a Python script is utilized. This Python script dynamically configures DNS records on Cloudflare during the Terraform process, serving as a workaround for the existing module limitation.