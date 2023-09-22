# Seet Github Secrets

This is a Python script to create GitHub environment, repo and organization secrets from a `.env` file.

It was originally written by @n3rdkid (see link below) but has been highly customized for Blueboard's migration off of Heroku.

## Warning!  Proceed with extreme caution!

Because GitHub Secrets are encrypted, the workflow here is presently very dangerous.  A secret set by person A could be inadvertently overwritten by person B as there is not a good canonical source for `.env` files.

Note that GitHub seems to have an upper limit of 100 environment secrets.

Your GitHub personal access token needs Read and Write access to:

- administration
- environments
- secrets
- organization

More documentation is needed here!

See `./run.sh` for usage.

## Links

- [Automate Adding Github Environments/Repository Secrets](https://articles.wesionary.team/automate-adding-github-environments-repository-secrets-64de7d1235e7)
- [Original code](https://github.com/n3rdkid/medium-github-secrets/)

