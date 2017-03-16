#!/bin/bash

set +e

JOB_SERVER_HOST="0.0.0.0"

# Script trace mode
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
    python run.py -n ${JOB_SERVER_HOST} --debug
else
    python run.py -n ${JOB_SERVER_HOST}
fi
