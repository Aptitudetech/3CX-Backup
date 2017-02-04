#!/bin/bash
# Upload files to AWS S3 bucket using curl

HMAC-SHA256s(){
 KEY="$1"
 DATA="$2"
 shift 2
 printf "$DATA" | openssl dgst -binary -sha256 -hmac "$KEY" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//'
}

HMAC-SHA256h(){
 KEY="$1"
 DATA="$2"
 shift 2
 printf "$DATA" | openssl dgst -binary -sha256 -mac HMAC -macopt "hexkey:$KEY" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//'
}


AWS_SECRET_KEY=
AWS_ACCESS_KEY=

FILE_TO_UPLOAD="/var/lib/3cxpbx/Instance1/Data/Backups/3CXScheduledBackup.zip"
BUCKET="bucket"
STARTS_WITH="domaine.tld/3CXBackup.zip"

REQUEST_TIME=$(date +"%Y%m%dT%H%M%SZ")
REQUEST_REGION="ca-central-1"
REQUEST_SERVICE="s3"
REQUEST_DATE=$(printf "${REQUEST_TIME}" | cut -c 1-8)
AWS4SECRET="AWS4"$AWS_SECRET_KEY
ALGORITHM="AWS4-HMAC-SHA256"
EXPIRE="2017-03-03T00:00:00.000Z"
ACL="private"

POST_POLICY='{"expiration":"'$EXPIRE'","conditions": [{"bucket":"'$BUCKET'" },{"acl":"'$ACL'" },["starts-with", "$key", "'$STARTS_WITH'"],["eq", "$Content-Type", "application/octet-stream"],{"x-amz-credential":"'$AWS_ACCESS_KEY'/'$REQUEST_DATE'/'$REQUEST_REGION'/'$REQUEST_SERVICE'/aws4_request"},{"x-amz-algorithm":"'$ALGORITHM'"},{"x-amz-date":"'$REQUEST_TIME'"}]}'

UPLOAD_REQUEST=$(printf "$POST_POLICY" | openssl base64 )
UPLOAD_REQUEST=$(echo -en $UPLOAD_REQUEST |  sed "s/ //g")

SIGNATURE=$(HMAC-SHA256h $(HMAC-SHA256h $(HMAC-SHA256h $(HMAC-SHA256h $(HMAC-SHA256s $AWS4SECRET $REQUEST_DATE ) $REQUEST_REGION) $REQUEST_SERVICE) "aws4_request") $UPLOAD_REQUEST)

curl --silent \
	-F "key=""$STARTS_WITH" \
	-F "acl="$ACL"" \
	-F "Content-Type="application/octet-stream"" \
	-F "x-amz-algorithm="$ALGORITHM"" \
	-F "x-amz-credential="$AWS_ACCESS_KEY/$REQUEST_DATE/$REQUEST_REGION/$REQUEST_SERVICE/aws4_request"" \
	-F "x-amz-date="$REQUEST_TIME"" \
	-F "Policy="$UPLOAD_REQUEST"" \
	-F "X-Amz-Signature="$SIGNATURE"" \
	-F "file=@"$FILE_TO_UPLOAD https://$BUCKET.s3.$REQUEST_REGION.amazonaws.com/
