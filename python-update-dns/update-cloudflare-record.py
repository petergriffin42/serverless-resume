import os
import requests
import argparse
import logging
import subprocess
from decouple import Config, RepositoryEnv

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

cloudflare_api = "https://api.cloudflare.com/client/v4/"

# For testing locally. Checking if the secret variables are set and if not load them from a secrets file. Pipeline runs them from CICD environment variables
if 'CF_API_KEY' not in os.environ or 'CF_ZONE_ID' not in os.environ and 'CF_API_EMAIL' not in os.environ:
  config = Config(RepositoryEnv('python-update-dns/cloudflare-secrets.env'))
  api_key = config('CF_API_KEY')
  zone_id = config('CF_ZONE_ID')
  api_email = config('CF_API_EMAIL')
else:
  api_key = os.environ.get('CF_API_KEY')
  zone_id = os.environ.get('CF_ZONE_ID')
  api_email = os.environ.get('CF_API_EMAIL')

def update_dns_record(api_key, api_email, zone_id, record_name, record_type, record_content, proxied):
    # Cloudflare API endpoint for updating DNS records
    api_url = f"{cloudflare_api}zones/{zone_id}/dns_records"
    # Headers for the API request
    headers = {
        'X-Auth-Key': api_key,
        'X-Auth-Email': api_email,
        'Content-Type': 'application/json'
    }

    # Check if DNS record already exists
    record_check = requests.get(api_url, headers=headers, params={'name': record_name})
    record_check_json = record_check.json()

    # Data for creating/updating the DNS record
    data = {
        'type': record_type,
        'name': record_name,
        'content': record_content,
        'proxied': proxied
    }

    # Updating the DNS record requries a PUT request to the unique identifier. If it does not exist it instead will do a POST request and create the record
    if record_check_json['result']:
      if record_name in record_check_json['result'][0]['name']:
        api_identifier = f"{api_url}/{record_check_json['result'][0]['id']}"
        response = requests.put(api_identifier, headers=headers, json=data)
        action = "updated"
    else:
        response = requests.post(api_url, headers=headers, json=data)
        action = "created"

    # Check the response
    if response.status_code == 200:
        logger.info(f"DNS record for {record_name} {action} successfully.")
    else:
        logger.error(f"Failed to update DNS record. Status code: {response.status_code}, Response: {response.json()}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create/Update Cloudflare DNS record.')
    parser.add_argument('--record-name', required=True, help='DNS record name')
    parser.add_argument('--record-type', required=True, help='DNS record type (e.g., A)')
    parser.add_argument('--record-content', required=True, help='New IP address or CNAME content')
    parser.add_argument("--proxied", action="store_true", help="Whether the record is proxied (default: False)")

    args = parser.parse_args()

    # Using f-string
    logger.debug(f"Record Name: {args.record_name}")
    logger.debug(f"Record Type: {args.record_type}")
    logger.debug(f"Record Content: {args.record_content}")

    update_dns_record(
        api_key,
        api_email,
        zone_id,
        record_name=args.record_name,
        record_type=args.record_type,
        record_content=args.record_content,
        proxied=args.proxied
    )