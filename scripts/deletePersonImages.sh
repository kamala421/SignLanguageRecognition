#!/bin/bash
#
# $Id: deletePersonImages.sh,v 1.2 2005/10/04 09:28:21 dreuw Exp $
#

# uncomment for debugging
#set -xv



# general info
NOF_PERSONS=25;
NOF_GESTURES=35;
NOF_RECORDS=2;

BASE_DIR="/u/image/I6-Gesture";
EXAMPLE_DIR="${BASE_DIR}/examples"
DATA_DIR="${BASE_DIR}/data";
DATA_VIDEO_DIR="${DATA_DIR}/video";
DATA_IMAGE_DIR="${DATA_DIR}/image";



######################################################################

# cmdline input variables
PERSON=$1;
START_RECORD=$2;

if [ -z "${PERSON}" ] || [ -z "${START_RECORD}" ]; then
  echo "usage: deletePersonImages.sh <PERSON_ID> <RECORD_ID>";
  exit;
else
  echo "deleting images of session ${START_RECORD} of person nr ${PERSON}";
fi

####### check input

if [ "${PERSON}" -gt "${NOF_PERSONS}" ]; then
  echo "start person nr ${PERSON} > ${NOF_PERSONS} doesn't exist. Please call the project guide.";
  exit;
fi

if [ "${START_RECORD}" -gt "${NOF_RECORDS}" ]; then
  echo "current record nr ${START_RECORD} > ${NOF_RECORDS} doesn't exist";
  exit;
fi

######################################################################

for i in `seq 1 35`; do  
  echo "deleting images for class $i and session ${START_RECORD}";
  rm /u/image/I6-Gesture/data/image/${i}/${PERSON}_${i}_${START_RECORD}*
done;
