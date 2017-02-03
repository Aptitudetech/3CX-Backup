#!/bin/bash
# Upload files to AWS S3 bucket using curl

S3_KEY=
S3_SECRET=
S3_BUCKET=bkup-3cx-aptech
S3_PATH=

FILES="/var/lib/3cxpbx/Instance1/Data/Backups"

for file in $FILES; do
  echo -n "Transferring file $file..."

  export LC_ALL=C
  DATE=$(date +"%a, %d %b %Y %T %z")
  ACL="x-amz-acl:private"
  CONTENT_TYPE=$(file -b --mime-type $file)
  STRING="PUT\n\n$CONTENT_TYPE\n$DATE\n$ACL\n/$S3_BUCKET$S3_PATH$file"
  SIGNATURE=$(echo -en "${STRING}" | openssl sha1 -hmac "${S3_SECRET}" -binary | base64)

  curl -X PUT -T "$file" \
    -H "Host: $S3_BUCKET.s3.amazonaws.com" \
    -H "Date: $DATE" \
    -H "Content-Type: $CONTENT_TYPE" \
    -H "$ACL" \
    -H "Authorization: AWS ${S3_KEY}:$SIGNATURE" \
    "https://$S3_BUCKET.s3.amazonaws.com$S3_PATH$file"

  echo "done."
done
