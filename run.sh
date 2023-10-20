#!/usr/bin/env bash

echo ""
echo "Remember, some env vars are maybe problematic as they are known to contain JSON, XML, line breaks or other special characters"
echo ""
echo " - These can be ignored -- see the array VARS_TO_SKIP in main.py"
echo " - SSH keys, certificates, private keys, should be base64 encoded"
echo ""

PS3="Select the repo to target or choose organizaiton: "
select repo in blueboard docker-shared milestones-api ado_api survey_api organization quit
do
    case $repo in
        "blueboard")
            export GITHUB_REPO="blueboard"
            break;;
        "docker-shared")
            export GITHUB_REPO="docker-shared"
            break;;
        "milestones-api")
            export GITHUB_REPO="milestones-api"
            break;;
        "ado_api")
            export GITHUB_REPO="ado_api"
            break;;
        "survey_api")
            export GITHUB_REPO="survey_api"
            break;;
        "organization")
            export GITHUB_REPO="organization"
            break;;
        "quit")
            echo "Goodbye..."
            break;;
        *)
           echo "Entry was not recognized";;
    esac
done

PS3="Select an environment, or create a repo or organization secret: "
select env in dev staging prod repo organization
do
    case $env in
        "prod")
            export ENVIRONMENT="prod"
            break;;
        "staging")
            export ENVIRONMENT="staging"
            break;;
        "repo")
            export ENVIRONMENT="repo"
            break;;
        "organization")
            export ENVIRONMENT="secrets"
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
read -p "Push variables to Github from the file ${FILE} now?  Are you sure?  Press Y to confirm. " -n 1 -r
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
