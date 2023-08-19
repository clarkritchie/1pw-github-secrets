# Github Secrets

This is a basic Python script to create GitHub environment secrets from a `.env` file.  It was originally written by @n3rdkid (see links below) but has been slightly customized for Blueboard's migration off of Heroku.

Note that your GitHub personal access token needs Read and Write access to:
- administration
- environments
- secrets

Note that these are the env vars that are known to be problematic as they contain JSON, certs, line breaks, the `=` character (what the Python script splits strings on), and so on.  You must handle these ones manually.
- `GOOGLE_CLOUD_CREDENTIALS`
- `PUBSUB_CREDENTIALS`
- `ONELOGIN_IDP_METADATA`
- `RESTFORCE_PRIVATE_KEY`

## Links

- [Automate Adding Github Environments/Repository Secrets](https://articles.wesionary.team/automate-adding-github-environments-repository-secrets-64de7d1235e7)
- [Original code](https://github.com/n3rdkid/medium-github-secrets/)


## Heroku Misc

GOOGLE_CLOUD_CREDENTIALS

Potentially useful tips and tricks for exporting known problem env vars from Heroku

### GOOGLE_CLOUD_CREDENTIALS
- JSON
```
heroku config:get GOOGLE_CLOUD_CREDENTIALS --json -a blueboard-staging | tr -d '\n' | sed 's/\\n/ /g'
```
