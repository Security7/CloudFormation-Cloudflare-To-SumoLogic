#!/bin/bash

#     _____  ______  _______  _______  _____  _   _   _____   _____
#    / ____||  ____||__   __||__   __||_   _|| \ | | / ____| / ____|
#   | (___  | |__      | |      | |     | |  |  \| || |  __ | (___
#    \___ \ |  __|     | |      | |     | |  | . ` || | |_ | \___ \
#    ____) || |____    | |      | |    _| |_ | |\  || |__| | ____) |
#   |_____/ |______|   |_|      |_|   |_____||_| \_| \_____||_____/
#

#
#   Get working dir.
#
LOCAL=$(pwd);

#
#   Create the CF file name to be copied
#
FILE=Cloudflare-to-SumoLogic.json;

#
#   This variable is used to extend the name of the bucket that holds the zipped
#   source code so it dose not colid with the production buckets. Since
#   S3 have global names.
#
BUCKET_ANTI_COLISION_NAME="";

#
#   If the stage is anything but production, we use the stage value for the
#   custom name of the bucket. This way if you want to deploy this
#   on another account, you can set your own name.
#
if [ $STAGE != "production" ]; then

    #
    #   Add the dot as section separation here so it is easier to manage
    #   when we have the empty string.
    #
    BUCKET_ANTI_COLISION_NAME=.$STAGE;

fi

#
#   Create the base name of the bucket that is then used across the script
#
BUCKET=net.security7.cloudformations$BUCKET_ANTI_COLISION_NAME;

#    __  __              _____   _   _
#   |  \/  |     /\     |_   _| | \ | |
#   | \  / |    /  \      | |   |  \| |
#   | |\/| |   / /\ \     | |   | . ` |
#   | |  | |  / ____ \   _| |_  | |\  |
#   |_|  |_| /_/    \_\ |_____| |_| \_|
#

#
#   <>> UI information.
#
echo "Starting by checking if $BUCKET exists.";

#
#   Check if the bucket dose not exists.
#
if ! aws s3 ls | tail -n +1 | grep -q "$BUCKET"; then

    #
    #   <>> UI information.
    #
    echo "  Creating bucket: $BUCKET.";

    #
    #   Create the bucket if is missing.
    #
    aws s3 mb s3://$BUCKET --region "us-east-2" > /dev/null;

    #
    #   Set read access to the bucket so if people want they can list
    #   the content of the bucket and see what zip files do we provide
    #
    aws s3api put-bucket-acl --acl public-read --bucket $BUCKET

fi

#
#   <>> UI information.
#
echo "";
echo "The S3 buckets is in place.";

#
#   <>> UI information.
#
echo "";
echo "Uploading: $FILE";
echo "";

#
#   Upload the CF file.
#
aws s3 cp $FILE s3://$BUCKET/$FILE;

#
#   Set the object to be publicly readeble and only that so people can
#   dowload it but can't change it.
#
aws s3api put-object-acl --key $FILE --acl public-read --bucket $BUCKET;

#
#   <>> UI information.
#
echo "";
echo "Done!";