# Postgres Backup

This little Docker container is for using `pg_dump` to backup a PostgreSQL instance to Google Cloud Storage.

It's designed to be run as a Kubernetes CronJob.

## Environment Variables

- `POSTGRES_HOST` - Postgres host (or Kubernetes service) to connect to.
- `POSTGRES_USER` - Username with permissions for database.
- `POSTGRES_PASSWORD` - Password for user.
- `POSTGRES_DATABASE` - Database to dump
- `DUMP_ARGS` - Extra arguments to pass to `pg_dump` in case you want to ignore files or otherwise.
  - Such as `--exclude-table-data bad_table`
- `PROJECT` - Name of the project 
- `BUCKET_NAME` - Bucket to store the backups in.
- `CREDENTIAL_PATH` - Path to where the Google Cloud service account with permissions for the given bucket are stored.

## What happens

After a little shuffling of environment variables, it will run `pg_dump` and stream the raw sql dump into `gsutil` to create a object with a name like `2018-09-30_09:49:04.dump.sql` in the given bucket.


## Service Account Permissions

The service account will need 'Storage Object Creator' and 'Storage Object Viewer' permissions.

## Example CronJob config

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: postgresql-backup
spec:
  schedule: "45 1 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: abkfenris/postgres-gs-backup:0.17
            env:
            - name: POSTGRES_USER
              value: postgres
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: shared-secrets
                  key: POSTGRES_PASSWORD
            - name: POSTGRES_HOST
              value: postgresql
            - name: POSTGRES_DATABASE
              value: postgres
            - name: PROJECT
              value: my_project
            - name: BUCKET_NAME
              value: auto-backup
            - name: CREDENTIAL_PATH
              value: /credentials/service-account.json
            - name: DUMP_ARGS
              value: "--exclude-table-data=massiveTable"
            volumeMounts:
            - name: credentials
              mountPath: "/credentials"
          restartPolicy: Never
          volumes:
          - name: credentials
            secret:
              secretName: backup-account
```
