#!/usr/bin/env bash

echo ""
echo "Friendly reminder that some env vars are maybe problematic as they are known to contain JSON, XML, line breaks, private keys or other special characters"
echo "See the list hard coded in main.py!!!]"
echo ""

echo "Usage: ./run.sh docker-swarm dev -- create the dev environment in the docker-swarm project using docker-swarm-dev.env config file"
echo "       ./run.sh blueboard staging -- create the destagingv environment in theblueboard repo using blueboard-staging.env config file"
echo ""

PS3="Select your repo: "
select repo in blueboard docker other quit
do
    case $repo in
        "blueboard")
            export GITHUB_REPO="blueboard"
            break;;
        "docker")
            export GITHUB_REPO="docker-swarm"
            break;;
        "other")
            export GITHUB_REPO="foo"
            break;;
        "quit")
            echo "Goodbye..."
            break;;
        *)
           echo "Entry was not recognized";;
    esac
done

PS3="Select your env: "
select env in dev staging prod
do
    case $env in
        "prod")
            export ENVIRONMENT="prod"
            break;;
        "staging")
            export ENVIRONMENT="staging"
            break;;
        *)
            export ENVIRONMENT="dev"
            break;;
    esac
done

FILE=${GITHUB_REPO}-${ENVIRONMENT}.env
if [ ! -f ${FILE} ]; then
    echo "Environment file named \"${FILE}\" was not found!"
    exit 1
fi

echo ""
read -p "Push variables to Github environment ${ENVIRONMENT} to the ${GITHUB_REPO} GitHub repo from the file ${FILE}?  Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then

    # echo "Creating a virtual environment"
    python3 -m venv venv
    # echo "Activating the virtual environment"
    source ./venv/bin/activate
    # echo "Installing requirements"
    pip3 install -r requirements.txt
    # echo "Creating/Updating environments/repository secrets"
    ENVIRONMENT=${ENVIRONMENT} GITHUB_REPO=${GITHUB_REPO} python3 main.py
fi