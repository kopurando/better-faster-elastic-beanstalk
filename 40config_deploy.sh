#!/bin/bash
#==============================================================================
# Copyright 2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#       http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions
# and limitations under the License.
#==============================================================================


function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

SOURCE=/tmp/deployment/config
#remove default nginx configs so they dont overwrite our own!!
rm -rfv $SOURCE/#etc#nginx*
for i in $(ls $SOURCE); do
  FILE_NAME=$(echo $i | sed -e 's/#/\//g')
  /bin/cp "$SOURCE/$i" "$FILE_NAME" || error_exit "Failed to copy $FILE_NAME into place."
done
#if instance is not suited for phantom, remove phantom nginx snippets
if [[ $IO_LOG_NODE != *PHANTO* ]] ; then  rm -fv /etc/nginx/conf.d/phantomjs* ; fi ;
