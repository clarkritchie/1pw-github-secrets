#!/usr/bin/env bash

export TEST_B64=$( cat test.json | base64 )
echo $TEST_B64

export TEST=$( echo $TEST_B64 | base64 --decode | tr -d '\n' )

echo $TEST

echo $TEST | tr -d \n

envsubst < test.yml