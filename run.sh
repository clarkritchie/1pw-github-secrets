#!/usr/bin/env bash

tempfile() {
    tempprefix=$(basename "$0")
    mktemp /tmp/${tempprefix}.XXXXXX
}

cat <<-EOT

Remember, some env vars are can be problematic -- specifically if they contain JSON,
XML, have line breaks, are certificates, and/or just have other special characters.

The best workaround here is to simply Base64 encode the values before you upload them
as GitHub secrets.  Please name these with a _B64 suffix!  e.g. FOO_B64

These can also be ignored, see the array VARS_TO_SKIP array in main.py.
EOT

echo ""
PS3="Select the repo to use or choose organizaiton: "
echo ""
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
            exit 0
            break;;
        *)
           echo "Entry was not recognized";;
    esac
done

echo ""
PS3="Select an environment (dev, staging, prod), or choose repository or organization secret: "
select env in dev staging prod repository organization quit
do
    case $env in
        "prod")
            export ENVIRONMENT="prod"
            break;;
        "staging")
            export ENVIRONMENT="staging"
            break;;
        "repository")
            export ENVIRONMENT="repo"
            break;;
        "organization")
            export ENVIRONMENT="secrets"
            break;;
        "quit")
            echo "Goodbye..."
            exit 0
            break;;
        *)
            export ENVIRONMENT="dev"
            break;;
    esac
done

# create a temporary file to save the contents from 1PW
FILE=$(tempfile)
trap 'rm -f ${FILE}' EXIT

# Read the 1PW note to a temporary file
# Syntax is:
#   op read op://set-github-secrets/ado_api-dev/ado_api-dev
# 1PW docs:  https://developer.1password.com/docs/cli/reference/commands/read
#
# TODO come up with a naming convention here, names must be unique in a vault
# Since we're making a temp file, --force is here only to suppress the op lient from warning us that
# the file already exists
op read --out-file ${FILE} --force "op://set-github-secrets/${GITHUB_REPO}-${ENVIRONMENT}/notesPlain"
if [ ! -f ${FILE} ]; then
    echo "There was a problem, the environment file \"${FILE}\" was not created!"
    exit 1
fi

echo "Push the contents of ${FILE} to GitHub now, are you sure?  "
read -p "Press Y to confirm, any other key to exit. " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python3 -m venv venv
    source ./venv/bin/activate
    pip3 install -r requirements.txt
    ENVIRONMENT=${ENVIRONMENT} GITHUB_REPO=${GITHUB_REPO} python3 main.py
fi
