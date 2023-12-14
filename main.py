import os
import sys
from json import dumps
from dotenv import load_dotenv
from ghapi.all import GhApi
from loguru import logger
from base64 import b64encode
from nacl import encoding, public

# Load GIT HUB CREDENTIALS
load_dotenv("./git.env")
GITHUB_ACCESS_TOKEN = os.getenv('GITHUB_ACCESS_TOKEN')
GITHUB_REPO_OWNER = os.getenv('GITHUB_REPO_OWNER')

# these are passed in as env vars but are really sort of arugments
GITHUB_REPO = os.getenv('GITHUB_REPO')#
ENVIRONMENT = os.getenv('ENVIRONMENT')
ENV_FILE = os.getenv('ENV_FILE')
#
# Full API:  https://github.com/fastai/ghapi/blob/master/50_fullapi.ipynb
#

# these may be special or problematic variables we want to skip over
# 'PGUSER','PGPASSWORD','PGHOST','PUBSUB_CREDENTIALS','ONELOGIN_IDP_METADATA','RESTFORCE_PRIVATE_KEY', etc.
VARS_TO_SKIP = ['']

if GITHUB_REPO != "organization":
    print(f"Instantiating client with {GITHUB_REPO} Repo API")
    api = GhApi(owner=GITHUB_REPO_OWNER, repo=GITHUB_REPO, token=GITHUB_ACCESS_TOKEN)
else:
    print("Instantiating client with Organization API")
    api = GhApi(token=GITHUB_ACCESS_TOKEN)

# Function to encrypt our secret
def encrypt(public_key: str, secret_value: str) -> str:
    """
    Encrypt a Unicode string using the public key.
    """
    public_key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return b64encode(encrypted).decode("utf-8")

# Parse env file and convert data to dict
def get_env_data_as_dict(path: str) -> dict:
    logger.info(f'Loading "{ENV_FILE}" to populate "{ENVIRONMENT}" environment')
    key_value_dict = {}
    with open(path, 'r') as file:
        for line in file:
            if not line.startswith('#'):
                # Split the line into key and value using the first '=' as the delimiter
                key, value = line.strip().split('=',1)
                key = key.strip()
                value = value.strip()
                key_value_dict[key] = value
        return key_value_dict

logger.info(f'Using ENV_FILE: {ENV_FILE}')
env_data = get_env_data_as_dict(ENV_FILE)

# logger.info(f'Keys and values from file:')
# print(dumps(env_data, indent=4))

#
# Repository Secrets
#
if ENVIRONMENT == "repo":
    logger.info(f'Fetching repository information for {GITHUB_REPO}')
    public_key = api.actions.get_repo_public_key()
    for key,value in env_data.items():
        if key in VARS_TO_SKIP:
            logger.info(f'{key} is in list of variables to skip, ignoring...')
        else:
            # TODO this may be problematic, remove the leading or trailing ' or ""
            value = value.replace("'","")
            encrypted_value=encrypt(public_key.key, value)
            logger.info(f'Adding repo secret {key} to {GITHUB_REPO}')
            # logger.info(f' - key {key}')
            # logger.info(f' - encrypted_value {encrypted_value}')
            # logger.info(f' - public_key.key_id {public_key.key_id}')
            try:
                api.actions.create_or_update_repo_secret(key, encrypted_value, public_key.key_id)
                logger.info(f'Successfully added repo secret {key} to repo {GITHUB_REPO}')
            except Exception as e:
                logger.error(f'There was a problem with {key} with repo {GITHUB_REPO}')
                print(f"An error occurred: {str(e)}")
                sys.exit(1)

#
# Environment Secrets
#
elif ENVIRONMENT in ["dev","staging","prod"]:
    logger.info(f'Fetching repository information for {GITHUB_REPO}')
    repoId = api.repos.get().id
    # logger.info(f'Creating/Updating new environment {ENVIRONMENT}')
    api.repos.create_or_update_environment(ENVIRONMENT)
    logger.info(f'Created/Updated environment {ENVIRONMENT}')
    # logger.info(f'Fetching environment public key for {ENVIRONMENT}')
    public_key= api.actions.get_environment_public_key(repoId, ENVIRONMENT)

    for key,value in env_data.items():
        if key in VARS_TO_SKIP:
            logger.info(f'{key} is in list of variables to skip, ignoring...')
        else:
            # print(f'loading value... key is {key}')
            # TODO this may be problematic, remove the leading or trailing ' or ""
            value = value.replace("'","")
            encrypted_value=encrypt(public_key.key,value)
            # logger.info(f'Adding environment secret {key} for {ENVIRONMENT}')
            # logger.debug(f' - repoId {repoId}')
            # logger.info(f' - ENVIRONMENT {ENVIRONMENT}')
            # logger.info(f' - key {key}')
            # logger.info(f' - encrypted_value {encrypted_value}')
            # logger.info(f' - public_key.key_id {public_key.key_id}')

            try:
                api.actions.create_or_update_environment_secret(repoId, ENVIRONMENT, key, encrypted_value, public_key.key_id)
                logger.info(f'Successfully added environment secret {key} for {ENVIRONMENT} in repo {GITHUB_REPO}')
            except Exception as e:
                logger.error(f'There was a problem with {key} for {ENVIRONMENT} in repo {GITHUB_REPO}')
                print(f"An error occurred: {str(e)}")
                sys.exit(1)
#
# Organization Secrets
#
else:
    public_key=api.actions.get_org_public_key(GITHUB_REPO_OWNER)
    for key,value in env_data.items():
        encrypted_value=encrypt(public_key.key,value)
        # logger.info(f'Adding organization secret {key}')
        # logger.info(f' - GITHUB_REPO_OWNER {GITHUB_REPO_OWNER}')
        # logger.info(f' - key {key}')
        # logger.info(f' - encrypted_value {encrypted_value}')
        # logger.info(f' - public_key.key_id {public_key.key_id}')
        if key in VARS_TO_SKIP:
            logger.info(f'{key} is in list of variables to skip, ignoring...')
        else:
            try:
                api.actions.create_or_update_org_secret(
                    org=GITHUB_REPO_OWNER,
                    secret_name=key,
                    encrypted_value=encrypted_value,
                    key_id=public_key.key_id,
                    visibility='private'
                )
                logger.info(f'Successfully added organization secret {key}')
            except Exception as e:
                logger.error(f'There was a problem with {key}')
                print(f"An error occurred: {str(e)}")
                sys.exit(1)

# there is no Python method for setting environment variables???
if ENVIRONMENT == "prod":
    logger.info(f'*** REMEMBER TO SET REPLICAS VARIABLE ***')