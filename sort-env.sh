#!/usr/bin/env bash

ENV_FILES=( $( ls *.env ) )

for f in "${ENV_FILES[@]}"
do
    TMP_FILE=$(mktemp)
    echo "sorting ${f} to ${TMP_FILE}"
    sort ${f} --output ${TMP_FILE}
done