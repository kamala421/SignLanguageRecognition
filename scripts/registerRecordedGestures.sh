#!/bin/bash
#
# $Id: registerRecordedGestures.sh,v 1.8 2005/10/04 09:28:21 dreuw Exp $
#

# uncomment for debugging
#set -xv
START_GESTURE=1;
NOF_GESTURES=35;


PERSON_ID=$1;
SESSION_ID=$2;
if [ -z "${PERSON_ID}" ] || [ -z "${SESSION_ID}" ]; then
  echo "usage: registerRecordedGestures.sh <PERSON_ID> <SESSION_ID>";
  exit;
fi;

for ((gesture=${START_GESTURE}; gesture<=${NOF_GESTURES}; ++gesture)); do
    ./registerRecordedGesture.sh ${PERSON_ID} ${gesture} ${SESSION_ID};
done;
