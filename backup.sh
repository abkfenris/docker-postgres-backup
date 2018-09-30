#!/bin/bash
set -e

# Check that all environment variables are set
if [[ -z "${POSTGRES_HOST}" ]] || [[ -z "${POSTGRES_USER}" ]] || [[ -z "${POSTGRES_PASSWORD}" ]] || \
 [[ -z "${POSTGRES_DATABASE}" ]] || [[ -z "${PROJECT}" ]] || [[ -z "${BUCKET_NAME}" ]] || \
 [[ -z "${CREDENTIAL_PATH}" ]] || [[ -a $CREDENTIAL_PATH ]]; then
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
    if [[ -a $CREDENTIAL_PATH ]]; then
        echo "It doesn't looke like there is a file at $CREDENTIAL_PATH"
    fi

    # Some variable was missing, getting out of here
    exit 1
fi

# Looks like everything is in order, lets do this
DT=$(date "+%Y-%m-%d_%H:%M:%S")
FILE_URL="gs://$BUCKET_NAME/$DT.dump.sql"
PGPASS=$POSTGRES_PASSWORD

echo $FILE_URL

pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $DUMP_ARGS $POSTGRES_DATABASE | \
gsutil -o "Credentials:gs_service_key_file=$CREDENTIAL_PATH" \
    -o "default_project_id=$PROJECT" \
    cp - $FILE_URL

echo "Backed up $POSTGRES_DATABASE on $POSTGRES_HOST to $FILE_URL"
