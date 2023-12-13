#!/usr/bin/env bash

set -e

tempfile() {
    tempprefix=$(basename "$0")
    mktemp /tmp/${tempprefix}.XXXXXX
}

if [[ ! -f /opt/homebrew/bin/op || ! -f git.env ]]; then
    cat <<-EOT

1PW CLI line tools not found or git.env not in the current directory

See README.md for setup instructions.

EOT
    exit 1
fi

cat <<-EOT
This script retrieves env vars from 1PW notes and creates them as GitHub secrets.

This workflow DOES NOT remove old values from GitHub!  That is important.

1PW is our source of truth.

Some env vars are can be problematic -- specifically if they contain JSON, XML, have
line breaks, are certificates, and/or just have other special characters. The best
workaround here is to simply Base64 encode the values before you upload them to
GitHub.  Please name these with a _B64 suffix, e.g. FOO_B64.

These can also be ignored, see the array VARS_TO_SKIP array in main.py.
EOT

printf "\nSelect the GitHub repository to use, or choose organization.\n\n"
PS3="
Your choice: "

options=(
    "Account"
    "ADO API"
    "Blueboard (Rails API)"
    "Docker Shared"
    "GSD"
    "Menu"
    "Milestones API"
    "Monofront"
    "Organization"
    "Run"
    "Send"
    "Survey"
    "Wellness"
    "YASS"
    "Quit"
)

select repo in "${options[@]}";
do
    case $repo in
        "Account")
            export GITHUB_REPO="account"
            break;;
        "ADO")
            export GITHUB_REPO="ado_api"
            break;;
        "Blueboard (Rails API)")
            export GITHUB_REPO="blueboard"
            break;;
        "Docker Shared")
            export GITHUB_REPO="docker_shared"
            break;;
        "GSD")
            export GITHUB_REPO="gsd"
            break;;
        "Menu")
            export GITHUB_REPO="menu"
            break;;
        "Milestones API")
            export GITHUB_REPO="milestones_api"
            break;;
        "Monofront")
            export GITHUB_REPO="monofront"
            break;;
        "Survey API")
            export GITHUB_REPO="survey_api"
            break;;
        "Organization")
            export GITHUB_REPO="organization"
            break;;
        "Run")
            export GITHUB_REPO="run"
            break;;
        "Send")
            export GITHUB_REPO="send"
            break;;
        "Wellness")
            export GITHUB_REPO="wellness"
            break;;
        "YASS")
            export GITHUB_REPO="yass"
            break;;
        "Quit")
            echo "Goodbye..."
            exit 0
            break;;
        *)
           echo "Entry was not recognized";;
    esac
done

printf "\nSelect the scope -- i.e. environment (dev, staging, prod) or create repository or organization secrets.\n\n"
PS3="
Your choice: "

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

# Read the 1PW secure note into a temporary file
#
# The syntax is:
#
#   op read op://<VAULT>/<NOTE_TITLE>/notesPlain
#
# e.g.
#   op read op://set-github-secrets/ado_api_dev/notesPlain
#
# 1PW docs:  https://developer.1password.com/docs/cli/reference/commands/read
# Lots of stuff!  https://1password.community/discussion/91068/cli-secure-note-utilities-written-in-python
#
# TODO come up with a naming convention here, names must be unique in a vault
# Since we're making a temp file, --force is here only to suppress the op lient from warning us that
# the file already exists
op read --out-file ${FILE} --force "op://set-github-secrets/${GITHUB_REPO}_${ENVIRONMENT}/notesPlain" > /dev/null
if [ ! -f ${FILE} ]; then
    echo "There was a problem, the environment file \"${FILE}\" was not created!"
    exit 1
fi

echo -e "\nThe contents of the Secure Note named ${GITHUB_REPO}_${ENVIRONMENT} are:\n"
cat ${FILE}
echo -e "\n"
cat <<-EOT
   _______________  ____         ____  _________    ____         ________  _______   ____ __
  / ___/_  __/ __ \/ __ \       / __ \/ ____/   |  / __ \       /_  __/ / / /  _/ | / / //_/
  \__ \ / / / / / / /_/ /      / /_/ / __/ / /| | / / / /        / / / /_/ // //  |/ / ,<
 ___/ // / / /_/ / ____/      / _, _/ /___/ ___ |/ /_/ /        / / / __  // // /|  / /| |_
/____//_/  \____/_/   (_)    /_/ |_/_____/_/  |_/_____(_)      /_/ /_/ /_/___/_/ |_/_/ |_(_)

EOT
read -p "Review the contents above.  Press Y to push these values to GitHub ${GITHUB_REPO}/${ENVIRONMENT}.  Are you sure?  " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    python3 -m venv venv
    source ./venv/bin/activate
    pip3 install -r requirements.txt
    ENVIRONMENT=${ENVIRONMENT} GITHUB_REPO=${GITHUB_REPO} ENV_FILE=${FILE} python3 main.py
fi
