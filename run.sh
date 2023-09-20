#!/usr/bin/env bash

echo ""
echo "Friendly reminder that some env vars are maybe problematic as they are known to contain JSON, XML, line breaks, private keys or other special characters"
echo "See the list hard coded in main.py!!!]"
echo ""

echo "Usage: ./run.sh docker-swarm dev -- create the dev environment in the docker-swarm project using docker-swarm-dev.env config file"
echo "       ./run.sh blueboard staging -- create the destagingv environment in theblueboard repo using blueboard-staging.env config file"
echo ""

# GITHUB_ACCESS_TOKEN is hardcoded in git.env

GITHUB_REPO=${1:-blueboard}
ENVIRONMENT=${2:-dev}

read -p "Push variables to Github environment ${ENVIRONMENT} to the ${GITHUB_REPO} GitHub repo?  Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Creating a virtual environment"
    python3 -m venv venv
    echo "Activating the virtual environment"
    source ./venv/bin/activate
    echo "Installing requirements"
    pip3 install -r requirements.txt
    echo "Creating/Updating environments/repository secrets"
    ENVIRONMENT=${ENVIRONMENT} GITHUB_REPO=${GITHUB_REPO} python3 main.py
fi