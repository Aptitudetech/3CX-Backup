#!/bin/bash
# Upload files to AWS S3 bucket using curl
# Needs Python, PIP, AWS CLI and AWS Credentials in appropriate config files

FOLDER="/var/lib/3cxpbx/Instance1/Data/Backups"
BUCKET="//bkup-3cx/aptitudetech.net/"

for file in $FOLDER/*; do
        echo -n "Transferring $file..."
        aws s3 cp $file s3:$BUCKET
        echo "done."
done
