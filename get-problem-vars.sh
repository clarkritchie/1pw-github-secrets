#!/usr/bin/env bash

ENV=${1:-staging}
APP="blueboard-${ENV}"

problems=('GOOGLE_CLOUD_CREDENTIALS' 'PUBSUB_CREDENTIALS' 'ONELOGIN_IDP_METADATA' 'RESTFORCE_PRIVATE_KEY')

for v in "${problems[@]}"
do
    echo "Getting ${v} from ${APP}"
    echo " "
    # Note that typically the "-----" following the header/footer in a private requires a trailing space
    heroku config:get ${v} --json --app ${APP} | tr -d '\n' | sed 's/\\n/ /g'
    echo " "
done