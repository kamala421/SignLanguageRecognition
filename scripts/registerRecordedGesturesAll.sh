#!/bin/bash
#
# $Id: registerRecordedGesturesAll.sh,v 1.2 2005/10/04 09:28:21 dreuw Exp $
#

# uncomment for debugging
#set -xv
START_PERSON=1;
NOF_PERSONS=20;


SESSION_ID=$1
if [ -z "${SESSION_ID}" ]; then
    echo "usage: registerRecordedGesturesAll.sh <SESSION_ID>";
    exit;
fi

for ((person_id=${START_PERSON}; person_id<=${NOF_PERSONS}; ++person_id)); do
    ./registerRecordedGestures.sh ${person_id} ${SESSION_ID};
done;
