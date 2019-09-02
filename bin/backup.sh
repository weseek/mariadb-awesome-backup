#!/bin/bash -e

# settings
BACKUPFILE_PREFIX=${BACKUPFILE_PREFIX:-backup}
MARIADB_HOST=${MARIADB_HOST:-mariadb}
CRONMODE=${CRONMODE:-false}
#MARIADB_DBNAME=
#MARIADB_USERNAME=
#MARIADB_PASSWORD=
#MYSQLDUMP_OPTS=
#TARGET_BUCKET_URL=[s3://... | gs://...] (must be ended with /)

# start script
CWD=`/usr/bin/dirname $0`
cd $CWD

. ./functions.sh
NOW=`create_current_yyyymmddhhmmss`

echo "=== $0 started at `/bin/date "+%Y/%m/%d %H:%M:%S"` ==="

TMPDIR="/tmp"
TARGET_FILENAME="${BACKUPFILE_PREFIX}-${NOW}.sql"
TARGET="${TMPDIR}/${TARGET_FILENAME}"
COMPRESS_CMD="bzip2"
COMPRESS_OPTS=""
COMPRESSED_FULLPATH="${TMPDIR}/${TARGET_FILENAME}.bz2"


# check parameters
# deprecate the old option
if [ "x${S3_TARGET_BUCKET_URL}" != "x" ]; then
  echo "WARNING: The environment variable S3_TARGET_BUCKET_URL is deprecated.  Please use TARGET_BUCKET_URL instead."
  TARGET_BUCKET_URL=$S3_TARGET_BUCKET_URL
fi
if [ "x${TARGET_BUCKET_URL}" == "x" ]; then
  echo "ERROR: The environment variable TARGET_BUCKET_URL must be specified." 1>&2
  exit 1
fi


# dump database
if [ "x${MARIADB_USERNAME}" != "x" ]; then
  MYSQLDUMP_OPTS="${MYSQLDUMP_OPTS} -u ${MARIADB_USERNAME}"
  if [ "x${MARIADB_PASSWORD}" != "x" ]; then
    MYSQLDUMP_OPTS="${MYSQLDUMP_OPTS} -p${MARIADB_PASSWORD}"
  fi
fi
if [ "x${MARIADB_DBNAME}" != "x" ]; then
  MYSQLDUMP_OPTS="${MYSQLDUMP_OPTS} ${MARIADB_DBNAME}"
else
  MYSQLDUMP_OPTS="${MYSQLDUMP_OPTS} --all-databases"
fi
echo "dump MariaDB..."
mysqldump -h ${MARIADB_HOST} ${MYSQLDUMP_OPTS} > ${TARGET}

# run bzip2 command
echo "backup ${TARGET}..."
time ${COMPRESS_CMD} ${COMPRESS_OPTS} ${TARGET}

if [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "s3" ]; then
  # transfer tarball to Amazon S3
  s3_copy_file ${COMPRESSED_FULLPATH} ${TARGET_BUCKET_URL}
elif [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "gs" ]; then
  gs_copy_file ${COMPRESSED_FULLPATH} ${TARGET_BUCKET_URL}
fi

# clean up working files if in cron mode
if ${CRONMODE} ; then
  rm -rf ${TARGET}
  rm -f ${COMPRESSED_FULLPATH}
fi
