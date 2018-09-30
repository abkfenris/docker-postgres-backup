#!/bin/bash
set -e

# Check that all environment variables are set
if [[ -z "${POSTGRES_HOST}" ]] || [[ -z "${POSTGRES_USER}" ]] || [[ -z "${POSTGRES_PASSWORD}" ]] || \
 [[ -z "${POSTGRES_DATABASE}" ]] || [[ -z "${PROJECT}" ]] || [[ -z "${BUCKET_NAME}" ]] || \
 [[ -z "${CREDENTIAL_PATH}" ]] || [[ ! -a $CREDENTIAL_PATH ]]; then
    if [[ -z "${POSTGRES_HOST}" ]]; then
        echo "POSTGRES_HOST is not set"
    fi
    if [[ -z "${POSTGRES_USER}" ]]; then
        echo "POSTFGRES_USER is not set"
    fi
    if [[ -z "${POSTGRES_PASSWORD}" ]]; then
        echo "POSTGRES_PASSWORD is not set"
    fi
    if [[ -z "${POSTGRES_DATABASE}" ]]; then
        echo "POSTGRES_DATABASE is not set"
    fi
    if [[ -z "${PROJECT}" ]]; then
        echo "PROJECT is not set"
    fi
    if [[ -z "${BUCKET_NAME}" ]]; then
        echo "BUCKET_NAME is not set"
    fi
    if [[ -z "${CREDENTIAL_PATH}" ]]; then
        echo "CREDENTIAL_PATH is not set"
    fi
    if [[ ! -a $CREDENTIAL_PATH ]]; then
        echo "It doesn't looke like there is a file at $CREDENTIAL_PATH"
    fi

    # Some variable was missing, getting out of here
    exit 1
fi

# Looks like everything is in order, lets do this
DT=$(date "+%Y-%m-%d_%H:%M:%S")
FILE_NAME="/tmp/$DT.dump.sql"
FILE_URL="gs://$BUCKET_NAME/$DT.dump.sql"
export PGPASSWORD=$POSTGRES_PASSWORD

cat > ~/.boto <<-EOT
[Credentials]
gs_service_key_file = $CREDENTIAL_PATH

[GSUtil]
default_project_id = $PROJECT
EOT

# export BOTO_PATH=~/.boto 

echo $FILE_URL

set -x # echo on

pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $DUMP_ARGS $POSTGRES_DATABASE -f $FILE_NAME
# echo $(ls -lh $FILE_NAME)
# echo $(ls -lh $CREDENTIAL_PATH)
# echo $(cat $CREDENTIAL_PATH)
# echo $(cat /tmp/.boto)
gsutil cp $FILE_NAME $FILE_URL

echo "Backed up $POSTGRES_DATABASE on $POSTGRES_HOST to $FILE_URL"
