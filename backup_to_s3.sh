#!/bin/bash
# Upload files to AWS S3 bucket using AWS CLI
# Needs Python, PIP, AWS CLI and AWS Credentials in appropriate config files

FOLDER="/var/lib/3cxpbx/Instance1/Data/Backups"
BUCKET="//bucket/folder/"

for file in $FOLDER/*; do
        echo -n "Transferring $file..."
        aws s3 cp $file s3:$BUCKET
        echo "done."
done
