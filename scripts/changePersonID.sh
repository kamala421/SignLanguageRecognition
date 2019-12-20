#!/bin/bash
#
# $Id: changePersonID.sh,v 1.2 2005/10/04 09:28:21 dreuw Exp $
#

#set -xv

# cmdline input variables
PERSON_ID=$1;
NEW_PERSON_ID=$2;

if [ -z "${PERSON_ID}" ] || [ -z "${NEW_PERSON_ID}" ]; then
  echo "usage: changePersonID.sh <PERSON_ID> <NEW_PERSON_ID>";
  exit;
else
  echo "changing ID of person nr ${PERSON_ID} into ${NEW_PERSON_ID}";
fi


for i in `seq 1 35`; do  
  echo "changing videos for class $i";
  for file in /u/image/I6-Gesture/data/video/${i}/${PERSON_ID}_${i}_*; do
    echo ${file} `echo ${file} | sed -e "s/\/${PERSON_ID}_/\/${NEW_PERSON_ID}_/"` 
    mv ${file} `echo ${file} | sed -e "s/\/${PERSON_ID}_/\/${NEW_PERSON_ID}_/"`
  done;
  
  echo "changing images for class $i";
  for file in /u/image/I6-Gesture/data/image/${i}/${PERSON_ID}_${i}_*; do
    echo ${file} `echo ${file} | sed -e "s/\/${PERSON_ID}_/\/${NEW_PERSON_ID}_/"` 
    mv ${file} `echo ${file} | sed -e "s/\/${PERSON_ID}_/\/${NEW_PERSON_ID}_/"`
  done;

  echo "changing paths in sequence file(s) for class $i";
  for file in /u/image/I6-Gesture/data/image/${i}/${NEW_PERSON_ID}_${i}_*.seq; do
    sed $file -e "s/\/${PERSON_ID}_/\/${NEW_PERSON_ID}_/" >> $file.tmp
  done;
  for file in /u/image/I6-Gesture/data/image/${i}/${NEW_PERSON_ID}_${i}_*.seq.tmp ; do 
    mv $file ${file//.tmp} ; 
  done

done;
