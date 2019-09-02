#!/bin/bash -e

# settings
MARIADB_HOST=${MARIADB_HOST:-mariadb}
TARGET_FILE=${TARGET_FILE}
MYSQL_OPTS=${MYSQL_OPTS:-}

# start script
CWD=`/usr/bin/dirname $0`
cd $CWD
. ./functions.sh

echo "=== $0 started at `/bin/date "+%Y/%m/%d %H:%M:%S"` ==="

TMPDIR="/tmp"
TARGET="${TMPDIR}/${TARGET_FILE}"
COMPRESS_CMD="bzip2"
COMPRESSED_FULLURL=${TARGET_BUCKET_URL}${TARGET_FILE}


# check parameters
if [ "x${TARGET_BUCKET_URL}" == "x" ]; then
  echo "ERROR: The environment variable TARGET_BUCKET_URL must be specified." 1>&2
  exit 1
fi
if [ "x${TARGET_FILE}" == "x" ]; then
  echo "ERROR: The environment variable TARGET_FILE must be specified." 1>&2
  exit 1
fi

if [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "s3" ]; then
  # download tarball from Amazon S3
  s3_copy_file ${COMPRESSED_FULLURL} ${TARGET}
elif [ `echo $TARGET_BUCKET_URL | cut -f1 -d":"` == "gs" ]; then
  gs_copy_file ${COMPRESSED_FULLURL} ${TARGET}
fi

# run bzip2 command/restore database
if [ "x${MARIADB_USERNAME}" != "x" ]; then
  MYSQL_OPTS="${MYSQL_OPTS} -u ${MARIADB_USERNAME}"
  if [ "x${MARIADB_PASSWORD}" != "x" ]; then
    MYSQL_OPTS="${MYSQL_OPTS} -p${MARIADB_PASSWORD}"
  fi
fi

echo "expand ${TARGET} and restore..."
time ${COMPRESS_CMD} -dc ${TARGET} | mysql -h ${MARIADB_HOST} ${MYSQL_OPTS}
