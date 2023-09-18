import os
import traceback
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
GITHUB_REPO = os.getenv('GITHUB_REPO')
ENVIRONMENT = os.getenv('ENVIRONMENT')
# 'PGUSER','PGPASSWORD','PGHOST',
VARS_TO_SKIP = ['REDIS_URL','DATABASE_URL','GOOGLE_CLOUD_CREDENTIALS','PUBSUB_CREDENTIALS','ONELOGIN_IDP_METADATA','RESTFORCE_PRIVATE_KEY']

api = GhApi(owner=GITHUB_REPO_OWNER, repo=GITHUB_REPO, token=GITHUB_ACCESS_TOKEN)

# Function to encrypt our secret
def encrypt(public_key: str, secret_value: str) -> str:
    """Encrypt a Unicode string using the public key."""
    public_key = public.PublicKey(public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return b64encode(encrypted).decode("utf-8")

# Parse env file and convert data to dict
def get_env_data_as_dict(path: str) -> dict:
    logger.info(f'Loading "{env_file_path}" to populate "{ENVIRONMENT}" environment')
    with open(path, 'r') as f:
       return dict(tuple(line.replace('\n', '').split('=')) for line
            in f.readlines() if not line.startswith('#'))

# LOAD ENV FILE
env_file_switch={
    "dev": "./dev.env",
    "staging": "./staging.env",
    "prod": "./prod.env",
    "REPO": "./repo.env"
}

env_file_path = env_file_switch[ENVIRONMENT]

env_data = get_env_data_as_dict(env_file_path)

print(dumps(env_data, indent=4))
# sys.exit(0)

if ENVIRONMENT != "REPO":
    logger.info(f'Fetching repository information for {GITHUB_REPO}')
    repoId = api.repos.get().id
    logger.info(f'Creating/Updating new environment {ENVIRONMENT}')
    api.repos.create_or_update_environment(ENVIRONMENT)
    logger.info(f'Created/Updated environment {ENVIRONMENT}')

    logger.info(f'Fetching environment public key for {ENVIRONMENT}')
    public_key= api.actions.get_environment_public_key(repoId, ENVIRONMENT)
    for key,value in env_data.items():
        if key in VARS_TO_SKIP:
            logger.info(f'{key} is in list of variables to skip, ignoring...')
        else:
            # TODO this may be problematic, remove the leading or trailing ' or ""
            value = value.replace("'","")
            encrypted_value=encrypt(public_key.key,value)
            logger.info(f'Adding environment secret {key} for {ENVIRONMENT}')
            # logger.info(f' - repoId {repoId}')
            # logger.info(f' - ENVIRONMENT {ENVIRONMENT}')
            # logger.info(f' - key {key}')
            # logger.info(f' - encrypted_value {encrypted_value}')
            # logger.info(f' - public_key.key_id {public_key.key_id}')

            try:
                api.actions.create_or_update_environment_secret(repoId, ENVIRONMENT, key, encrypted_value, public_key.key_id)
                logger.info(f'Successfully added environment secret {key} for {ENVIRONMENT}')
            except Exception as e:
                logger.error(f'There was a problem with {key} for {ENVIRONMENT}')
                print(e)
                # traceback.print_exc()
                sys.exit(1)

else:
    logger.info(f'Adding repository secrets')
    public_key=api.actions.get_repo_public_key()
    for key,value in env_data.items():
        encrypted_value=encrypt(public_key.key,value)
        logger.info(f'Adding repository secret {key}')
        api.actions.create_or_update_repo_secret(key, encrypted_value, public_key.key_id)
        logger.info(f'Successfully added repository secret {key}')
