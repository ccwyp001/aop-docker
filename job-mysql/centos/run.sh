#!/bin/bash

set +e

BIND_INTERFACE="0.0.0.0"
JOB_BASE_DIR='/app'

update_config_var() {
    local config_path=$1
    local var_name=$2
    local var_value=$3

    if [ ! -f "$config_path" ]; then
        echo "**** Configuration file '$config_path' does not exist"
        return
    fi

    # Escaping "/" character in parameter value
    var_value=${var_value//\//\\/}

    if [ "$(grep -E "^$var_name\ *=" $config_path)" ]; then
        sed -i -e "/^$var_name\ *=/s/=.*/=\ \'$var_value\'/" "$config_path"
        echo "updated $config_path: $var_name $var_value"
    fi
}

prepare_baseline_config() {
    echo "** Preparing baseline parameter"

    BASELINE_CONFIG="$JOB_BASE_DIR/cron/baseline"

    if [ -f "$BASELINE_CONFIG" ]; then
        update_config_var "$BASELINE_CONFIG" "AOP_DB_HOST" "${DB_SERVER_HOST}"
        update_config_var "$BASELINE_CONFIG" "AOP_DB_PORT" "${DB_SERVER_PORT}"
        update_config_var "$BASELINE_CONFIG" "AOP_DB_NAME" "${MYSQL_DATABASE}"
        update_config_var "$BASELINE_CONFIG" "AOP_DB_USER" "${MYSQL_USER}"
        update_config_var "$BASELINE_CONFIG" "AOP_DB_PASS" "${MYSQL_PASSWORD}"
    else
        echo "**** baseline file not found"
        exit 1
    fi
}


prepare_orcl_lld_config() {
    echo "** Preparing oracle lld parameter"

    BASELINE_CONFIG="$JOB_BASE_DIR/externalscripts/lld.orcl.dbms"

    if [ -f "$BASELINE_CONFIG" ]; then
        update_config_var "$BASELINE_CONFIG" "MCDB_HOST" "${JOB_SERVER_HOST}"
        update_config_var "$BASELINE_CONFIG" "MCDB_PORT" "${JOB_SERVER_PORT}"
    else
        echo "**** oracle lld file not found"
        exit 1
    fi
}

prepare_orcl_chk_config() {
    echo "** Preparing oracle chk parameter"

    BASELINE_CONFIG="$JOB_BASE_DIR/externalscripts/chk.orcl.dbms"

    if [ -f "$BASELINE_CONFIG" ]; then
        update_config_var "$BASELINE_CONFIG" "MCDB_HOST" "${JOB_SERVER_HOST}"
        update_config_var "$BASELINE_CONFIG" "MCDB_PORT" "${JOB_SERVER_PORT}"
    else
        echo "**** oracle chk file not found"
        exit 1
    fi
}


prepare_baseline_config
prepare_orcl_lld_config
prepare_orcl_chk_config

# start crontab
crond

# start mcdb
if [ "${DEBUG_MODE}" == "true" ]; then
    set -o xtrace
    python run.py -n ${BIND_INTERFACE} -p ${JOB_SERVER_PORT} --debug
else
    python run.py -n ${BIND_INTERFACE} -p ${JOB_SERVER_PORT}
fi
