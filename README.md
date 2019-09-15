<!-- TODO: to enable integration with CircleCI
[![CircleCI](https://circleci.com/gh/weseek/mariadb-awesome-backup/tree/master.svg?style=shield)](https://circleci.com/gh/weseek/mariadb-awesome-backup/tree/master)
-->

What is mariadb-awesome-backup?
-------------------------------

mariadb-awesome-backup is the collection of scripts which backup MariaDB databases to Amazon S3 or Google Cloud Storage.

This software has almost the same options of [mongodb-awesome-backup](https://github.com/weseek/mongodb-awesome-backup).


Requirements
------------

* Amazon IAM Access Key ID/Secret Access Key
  * which must have the access lights of the target Amazon S3 bucket.

OR

* Google Cloud Interoperable storage access keys (see https://cloud.google.com/storage/docs/migrating#keys)
  * `GCP_ACCESS_KEY_ID`, `GCP_SECRET_ACCESS_KEY`, and `GCP_PROJECT_ID` are only required if using HMAC authentication.
  * When using oauth authentication, a docker mount ` -v ~:/mab` and is the can be added to save auth0 credentials to your home directory after mariadb-awesome-backup is run.  On subsequent runs, the same `~/.boto` file will be used for authentication.
  * The name 'mab' was chosen as the Docker container mount point simply because it's an acronym for "`m`ongodb-`a`wesome-`b`ackup").  The /mab mount point maps to the home directory of whatever user is used to run mariadb-awesome-backup, and is where the .boto file will be saved.

Usage
-----
Note that either `AWS_` or `GCP_` vars are required not both.

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=<Your IAM Access Key ID> \
  -e AWS_SECRET_ACCESS_KEY=<Your IAM Secret Access Key> \
  [ -e GCP_ACCESS_KEY_ID=<Your GCP Access Key> \ ]
  [ -e GCP_SECRET_ACCESS_KEY=<Your GCP Secret> \ ]
  [ -e GCP_PROJECT_ID=<Your GCP Project ID> \ ]
  -e TARGET_BUCKET_URL=<Target Bucket URL ([s3://...|gs://...])> \
  [ -e BACKUPFILE_PREFIX=<Prefix of Backup Filename (default: "backup") \ ]
  [ -e MARIADB_HOST=<Target MariaDB Host (default: "mariadb")> \ ]
  [ -e MARIADB_DBNAME=<Target DB name> \ ]
  [ -e MARIADB_USERNAME=<DB login username> \ ]
  [ -e MARIADB_PASSWORD=<DB login password> \ ]
  [ -e MYSQLDUMP_OPTS=<Options list of mysqldump> \ ]
  [ -v ~:/mab \ ]
  weseek/mariadb-awesome-backup
```

And after running this, `backup-YYYYMMdd.tar.bz2` will be placed on the target S3 or GCS bucket.

### How to backup in cron mode

Execute a docker container with `CRONMODE=true`.

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=<Your IAM Access Key ID> \
  -e AWS_SECRET_ACCESS_KEY=<Your IAM Secret Access Key> \
  [ -e GCP_ACCESS_KEY_ID=<Your GCP Access Key> \ ]
  [ -e GCP_SECRET_ACCESS_KEY=<Your GCP Secret> \ ]
  [ -e GCP_PROJECT_ID=<Your GCP Project ID> \ ]
  -e TARGET_BUCKET_URL=<Target Bucket URL ([s3://...|gs://...])> \
  -e CRONMODE=true \
  -e CRON_EXPRESSION=<Cron expression (ex. "CRON_EXPRESSION='0 4 * * *'" if you want to run at 4:00 every day)> \
  [ -e BACKUPFILE_PREFIX=<Prefix of Backup Filename (default: "backup") \ ]
  [ -e MARIADB_HOST=<Target MariaDB Host (default: "mariadb")> \ ]
  [ -e MARIADB_DBNAME=<Target DB name> \ ]
  [ -e MARIADB_USERNAME=<DB login username> \ ]
  [ -e MARIADB_PASSWORD=<DB login password> \ ]
  [ -e MYSQLDUMP_OPTS=<Options list of mysqldump> \ ]
  [ -v ~:/mab \ ]
  weseek/mariadb-awesome-backup
```

### How to restore

You can use "**restore**" command to restore database from backup file.

```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=<Your IAM Access Key ID> \
  -e AWS_SECRET_ACCESS_KEY=<Your IAM Secret Access Key> \
  [ -e GCP_ACCESS_KEY_ID=<Your GCP Access Key> \ ]
  [ -e GCP_SECRET_ACCESS_KEY=<Your GCP Secret> \ ]
  [ -e GCP_PROJECT_ID=<Your GCP Project ID> \ ]
  -e TARGET_BUCKET_URL=<Target Bucket URL ([s3://...|gs://...])> \
  -e TARGET_FILE=<Target S3 or GS file name to restore> \
  [ -e MARIADB_HOST=<Target MariaDB Host (default: "mariadb")> \ ]
  [ -e MARIADB_USERNAME=<DB login username> \ ]
  [ -e MARIADB_PASSWORD=<DB login password> \ ]
  [ -e MYSQL_OPTS=<Options list of mysql> \ ]
  [ -v ~:/mab \ ]
  weseek/mariadb-awesome-backup restore
```


Environment variables
---------

### For `backup`, `prune`, `list`
#### Required

| Variable                | Description                                                                         |
| ----------------------- | ----------------------------------------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`     | Your IAM Access Key ID                                                              |
| `AWS_SECRET_ACCESS_KEY` | Your IAM Secret Access Key                                                          |
| `GCP_ACCESS_KEY_ID`     | Your GCP Access Key                                                                 |
| `GCP_SECRET_ACCESS_KEY` | Your GCP Secret                                                                     |
| `GCP_PROJECT_ID`        | Your GCP Project ID                                                                 |
| `TARGET_BUCKET_URL`     | Target Bucket URL ([s3://... or gs://...]).<br>**URL is needed to be end with '/'** |

#### Optional

| Variable            | Description                                                                                                                                                                       | Default     |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `BACKUPFILE_PREFIX` | Prefix of Backup Filename                                                                                                                                                         | `"backup"`  |
| `MARIADB_HOST`      | Target MariaDB Host                                                                                                                                                               | `"mariadb"` |
| `MARIADB_DBNAME`    | Target DB name<br>If omitted, all databases will be backed up.                                                                                                                    | -           |
| `MARIADB_USERNAME`  | DB login username                                                                                                                                                                 | -           |
| `MARIADB_PASSWORD`  | DB login password                                                                                                                                                                 | -           |
| `MYSQLDUMP_OPTS`    | Options list of mysqldump                                                                                                                                                         | -           |
| `CRONMODE`          | If set `"true"`, this container is executed in cron mode.<br>In cron mode, the script will be executed with the specified arguments and at the time specified by `CRON_EXPRESSION`. | `"false"`   |
| `CRON_EXPRESSION`   | Cron expression (ex. `"CRON_EXPRESSION=0 4 * * *"` if you want to run at 4:00 every day)                                                                                          | -           |
| `HEALTHCHECKS_URL`  | URL that gets called after a successful backup (eg. https://healthchecks.io)                                                                                                      | -           |

### For `restore`

#### Required

| Variable                | Description                                                                          |
| ----------------------- | ------------------------------------------------------------------------------------ |
| `AWS_ACCESS_KEY_ID`     | Your IAM Access Key ID                                                               |
| `AWS_SECRET_ACCESS_KEY` | Your IAM Secret Access Key                                                           |
| `GCP_ACCESS_KEY_ID`     | Your GCP Access Key                                                                  |
| `GCP_SECRET_ACCESS_KEY` | Your GCP Secret                                                                      |
| `GCP_PROJECT_ID`        | Your GCP Project ID                                                                  |
| `TARGET_BUCKET_URL`     | Target Bucket URL ([s3://...  or gs://...]).<br>**URL is needed to be end with '/'** |
| `TARGET_FILE`           | Target S3 or GS file name to restore                                                 |

#### Optional

| Variable           | Description                     | Default   |
| ------------------ | ------------------------------- | --------- |
| `MARIADB_HOST`     | Target MariaDB Host             | `"mongo"` |
| `MARIADB_USERNAME` | DB login username               | -         |
| `MARIADB_PASSWORD` | DB login password               | -         |
| `MYSQL_OPTS`       | Options list of mysql (ex `-v`) | -         |
