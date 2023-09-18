#!/usr/bin/env bash

# skipped=('GOOGLE_CLOUD_CREDENTIALS' 'PUBSUB_CREDENTIALS' 'ONELOGIN_IDP_METADATA' 'RESTFORCE_PRIVATE_KEY' 'PGHOST' 'PGUSER' 'PGPASSWORD')
echo ""
echo "Friendly reminder that some env vars are maybe problematic as they are known to contain JSON, XML, line breaks, private keys or other special characters"
echo "See the list hard coded in main.py!!!"
# for v in "${skipped[@]}"
# do
#    echo "- $v"
# done
# echo ""

# TBD what about about these:
# - DATABASE_URL
# - REDIS_URL

# GITHUB_ACCESS_TOKEN is hardcoded in git.env

ENVIRONMENT=${1:-dev}
read -p "Push variables to Github environment ${ENVIRONMENT}?  Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Creating a virtual environment"
    python3 -m venv venv
    echo "Activating the virtual environment"
    source ./venv/bin/activate
    echo "Installing requirements"
    pip3 install -r requirements.txt
    echo "Creating/Updating environments/repository secrets"
    ENVIRONMENT=${ENVIRONMENT} python3 main.py
fi