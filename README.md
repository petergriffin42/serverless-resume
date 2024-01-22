# Serverless Resume Deployment

This repository documents the complete automation of deploying my serverless resume to Azure Blob Storage and an Amazon S3 Bucket. Previously hosted on a Kubernetes cluster in AWS, the expenses prompted a shift to a more cost-effective approach. The current deployment minimizes costs while showcasing my proficiency in navigating multiple Cloud platforms, utilizing Python, and leveraging Terraform.

## Deployment Process

### 1. Hugo Static Site Generation
   - Hugo, a fast and flexible static site generator, is employed to generate the website's content and structure. It produces the static files ready for upload utilizing a template.

### 2. Terraform Infrastructure Provisioning
   - Terraform automates the provisioning of Azure Blob Storage and an Amazon S3 Bucket, forming the foundational infrastructure for the serverless resume.

### 3. Python Cloudflare DNS Automation (Workaround)
   - To address an open issue preventing Terraform from handling the DNS records a Python script is utilized. This Python script dynamically configures DNS records on Cloudflare during the Terraform process, serving as a workaround for the existing module limitation.

## Getting Started

### Prerequisites

This repository requires the following accounts and their associated API key secrets. These secrets must be securely set in your GitHub repository under Settings -> Secrets and Variables -> Actions.

1. **Azure Account:**
    - `ARM_CLIENT_ID`
    - `ARM_CLIENT_SECRET`
    - `ARM_SUBSCRIPTION_ID`
    - `ARM_TENANT_ID`

2. **AWS Account:**
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`

3. **Cloudflare Account and Registered Domain:**
    - `CF_API_EMAIL`
    - `CF_API_KEY`
    - `CF_ZONE_ID`

### Setup Instructions

To fork this repository, follow these setup instructions:

1. Set a default domain under `vars.tf`.
2. Make necessary tweaks to the branching strategy in the GitHub Workflows for the domain name.
3. If your static files are in a different filepath, update the corresponding configuration in `main.tf`.