#!/bin/bash

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
#DATA_IMAGE_DIR="${DATA_DIR}/image";
DATA_IMAGE_DIR="/u/dreuw/work/data/I6-Gesture";


# camera devices
WEBCAM=`grep "pwc Registered as" /var/log/dmesg | tail -1 | colrm 1 18 |colrm 12`
TVCAM=/dev/`grep "bttv.: registered device video" /var/log/dmesg | tail -1 |colrm 1 25`

######################################################################

# cmdline input variables
PERSON=$1;
START_RECORD=$2;
START_GESTURE=$3;

if [ -z "${PERSON}" ] || [ -z "${START_RECORD}" ]; then
  echo "usage: recordGestures.sh <PERSON_ID> <START_RECORD_ID> [<START_GESTURE_ID>]";
  exit;
else
  echo "creating record nr ${START_RECORD} for person nr ${PERSON}";
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

if [ -z "${START_GESTURE}" ]; then
  START_GESTURE=1;
elif [ "${START_GESTURE}" -gt "${NOF_GESTURES}" ]; then
  echo "start gesture nr ${START_GESTURE} > ${NOF_GESTURES} doesn't exist";
  exit;
else
  echo "continue creating records for person nr ${PERSON} at gesture nr ${START_GESTURE}";
fi




######################################################################
######################################################################

# general viewing options
VIDEO_PLAYER="mplayer";
IMAGE_VIEWER="xv";
IMAGE_FORMAT="png";


# general recording/converting options
VIDEO_ENCODER="mencoder";
VIDEO_IFPS="25";      #input fps
VIDEO_OFPS="25";      #output fps

VIDEO_OUTPUT_OPTIONS="-ovc lavc -ofps ${VIDEO_OFPS}";
VIDEO_OUTPUT_FORMAT="mpg";

VIDEO_TO_IMAGE_OUTPUT_DRIVER="png"; #also change IMAGE_FORMAT; Each file takes the frame number padded with leading zeros as name.
# gif89a       Output each frame into a GIF file in the current directory.  
# jpeg         Output each frame into a JPEG file in the current directory.  
# pgm          Output each frame into a PGM file in the current directory.  
# png          Output each frame into a PNG file in the current directory.  -- use -z <0-9> to enable png compression
# tga          Output each frame into a Targa file in the current directory.

VIDEO_TO_IMAGE_OUTPUT_DRIVER_OPTIONS="-z 9"; # png compression factor <0-9>
VIDEO_TO_IMAGE_OPTIONS="-vo ${VIDEO_TO_IMAGE_OUTPUT_DRIVER} ${VIDEO_TO_IMAGE_OUTPUT_DRIVER_OPTIONS}";


# webcam options
VIDEO_NAME_WEBCAM_="Philips ToUCam Pro II";
VIDEO_IDEVICE_WEBCAM=$WEBCAM; #input device for Philips ToUCam Pro II
VIDEO_WIDTH_WEBCAM="320";
VIDEO_HEIGHT_WEBCAM="240";
VIDEO_INPUT_OPTIONS_WEBCAM="-rawvideo on:fps=${VIDEO_IFPS}:w=${VIDEO_WIDTH_WEBCAM}:h=${VIDEO_HEIGHT_WEBCAM}";


# auxiliary camera options
VIDEO_NAME_AUX_="JVC GR-SX20EG";
VIDEO_IDEVICE_AUX=$TVCAM;    #input device for auxiliary camera 2
VIDEO_WIDTH_AUX="352";  #half PAL resolution
VIDEO_HEIGHT_AUX="288";
VIDEO_INPUT_OPTIONS_AUX="tv:// -tv device=${VIDEO_IDEVICE_AUX}:driver=v4l2:input=2:noaudio:width=${VIDEO_WIDTH_AUX}:height=${VIDEO_HEIGHT_AUX}:fps=${VIDEO_IFPS}:normid=0 "; #see 'man mplayer' for details

NOF_VIDEO_DEVICES=2; #set to 1, if you want to use only the webcam, else to 2


######################################################################
######################################################################



#
# echoes a question string wait until user answers this question with either y/Y or n/N
# default answer is always NO
# the variable $answer will be set to true or false then
#
function getAnswer() {
  answer=$1;
  question_string=$2;
   
  echo ${question_string};

  correctInput=false;
  while [ "${correctInput}" == "false" ] ; do
    read input;
    if [ "${input}" == "y" ] || [ "${input}" == "Y" ]; then 
      answer=true;
      correctInput=true;
    elif [ "${input}" == "n" ] || [ "${input}" == "N" ] || [ -z "${input}" ] ; then 
      answer=false;
      correctInput=true;
    else
      echo "Please answer (y)es or [n]o: ";
    fi;
  done;
}



#
# shows a video example for a given gesture until user answers with NO
#
function showVideo() {
  video_path=$1;

  seeAgain=true;
  while [ "${seeAgain}" == "true" ] ; do
    echo "showing $video_path";
    $VIDEO_PLAYER $video_path  &>/dev/null
    getAnswer $seeAgain "Do you want to see this again? y/[n] ";
    seeAgain=${answer};
  done;
}



#
# shows a significant image example in background
#
function showImage() {
  image_path=$1;

  echo "showing ${image_path}";
  ${IMAGE_VIEWER} -expand 2 ${image_path} &
}



#
# records a video after pressing RETURN for a given gesture, person-id and record-iteration until user presses CTRL-C
#
function recordTemp() {
  gesture=$1;
  person=$2;
  record=$3;

  echo " ";
  echo "Press RETURN to start recording and press RETURN to stop recording camera 1 and camera 2.";
  read kbhit;


  # camera 1 - webcam
  ${VIDEO_ENCODER} ${VIDEO_INPUT_OPTIONS_WEBCAM} ${VIDEO_IDEVICE_WEBCAM} ${VIDEO_OUTPUT_OPTIONS} -o ${DATA_VIDEO_DIR}/${gesture}/${person}_${gesture}_${record}_cam1.${VIDEO_OUTPUT_FORMAT} &>/dev/null &

  # camera 2 - auxiliary
  ${VIDEO_ENCODER} ${VIDEO_INPUT_OPTIONS_AUX} ${VIDEO_OUTPUT_OPTIONS} -o ${DATA_VIDEO_DIR}/${gesture}/${person}_${gesture}_${record}_cam2.${VIDEO_OUTPUT_FORMAT} &>/dev/null &

  echo "Recording... press RETURN to stop"

  read kbhit;
  #stop recording camera 1 AND 2
  killall ${VIDEO_ENCODER}; #kill %1; kill %2;
  
  # show the just recorded video sequence of camera 1 and 2 beside the original example
  seeAgain=true;
  while [ ${seeAgain} == "true" ]; do
    #start example in bgnd
    $VIDEO_PLAYER -geometry 25%:15% ${EXAMPLE_DIR}/${gesture}.${VIDEO_OUTPUT_FORMAT} &>/dev/null & 
    #start camera 1 in bgnd
    $VIDEO_PLAYER -geometry 75%:15% ${DATA_VIDEO_DIR}/${gesture}/${person}_${gesture}_${record}_cam1.${VIDEO_OUTPUT_FORMAT} &>/dev/null & 
    #start camera 2 in fgnd -- wait until finished or use 'wait %1 %2'
    $VIDEO_PLAYER -geometry 75%:85% ${DATA_VIDEO_DIR}/${gesture}/${person}_${gesture}_${record}_cam2.${VIDEO_OUTPUT_FORMAT} &>/dev/null 

    getAnswer ${seeAgain} "Do you want to see your current record again? y/[n] ";
    seeAgain=${answer};   
  done;
}



#
# will call the record and registration functions
#
function recordGesture() {
  gesture=$1;
  person=$2;
  record=$3;

  echo "person nr ${person} / gesture nr ${gesture} / record nr ${record} will be recorded now";
  recordAgain=true;
  while [ ${recordAgain} == "true" ]; do
      recordTemp ${gesture} ${person} ${record};
      getAnswer ${recordAgain} "Do you want to record this again? y/[n] ";
      recordAgain=${answer};
  done;
}




## -------------- MAIN ----------------------

starttime=`date +%s`

#for((record=${START_RECORD}; record<=${NOF_RECORDS}; ++record)); do
record=${START_RECORD};
  for ((gesture=${START_GESTURE}; gesture<=${NOF_GESTURES}; ++gesture)); do

    clear

    echo Scene: $gesture / $NOF_GESTURES


    # 1. show video example for this gesture
    showVideo ${EXAMPLE_DIR}/${gesture}.${VIDEO_OUTPUT_FORMAT}

    # 2. show a significant image example in the background
    #showImage ${EXAMPLE_DIR}/${gesture}.${IMAGE_FORMAT}

    # 3. create folder structure
    mkdir -p ${DATA_IMAGE_DIR}/${gesture}/
    mkdir -p ${DATA_VIDEO_DIR}/${gesture}/

    # 4. record the gestures
    recordGesture ${gesture} ${PERSON} ${record};
  done;
#done;
stoptime=`date +%s`



echo "Thank you very much for your $(($stoptime-$starttime)) seconds :-))"

