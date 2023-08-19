# Github Secrets

This is a basic Python script to create GitHub environment secrets from a `.env` file.  It was originally made by another person, but has been customized Slightly for Blueboard.

Your GitHub personal access token needs Read and Write access to:
- administration
- environments
- secrets

## Links

- [Automate Adding Github Environments/Repository Secrets](https://articles.wesionary.team/automate-adding-github-environments-repository-secrets-64de7d1235e7)
- [Original code](https://github.com/n3rdkid/medium-github-secrets/)

## Heroku Misc

Potentially useful tips and tricks for exporting known problem env vars from Heroku

### GOOGLE_CLOUD_CREDENTIALS
- JSON
```
heroku config:get GOOGLE_CLOUD_CREDENTIALS --json -a blueboard-staging | tr -d '\n' | sed 's/\\n/ /g'
``````%
