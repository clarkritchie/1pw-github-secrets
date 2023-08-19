Tips and tricks for exporting known problem env vars from Heroku

Splits on `=` so we change .env to be `==`

### GOOGLE_CLOUD_CREDENTIALS
- JSON
```
heroku config:get GOOGLE_CLOUD_CREDENTIALS --json -a blueboard-staging | tr -d '\n' | sed 's/\\n/ /g'
``````