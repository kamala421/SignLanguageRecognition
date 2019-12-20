#!/bin/bash
#
# $Id: registerRecordedGesture.sh,v 1.2 2005/10/04 09:28:21 dreuw Exp $
#

# uncomment for debugging
#set -xv



# general info
NOF_PERSONS=20;                          # the number of recorded persons
NOF_GESTURES=35;                         # the number of gestures
NOF_SESSIONS=2;                          # the number of sessions

BASE_DIR="/Users/santoshkhatiwada/Desktop/ComputerVision/research/rwthGermanDataset";          # base dir, prefix which will be used for all other dirs
EXAMPLE_DIR="${BASE_DIR}/examples"       # a path where you can store some example videos and images
DATA_DIR="${BASE_DIR}/data";             # all videos and images will be stored here
DATA_VIDEO_DIR="${DATA_DIR}/video";      # all videos will be stored here
DATA_IMAGE_DIR="${DATA_DIR}/image";      # all images, converted from the videos using the scripts, will be stored here
TEMP_DIR="/tmp";                         # temporary directory to convert the videos into image sequences



######################################################################

# cmdline input variables
PERSON_ID=$1;
GESTURE_ID=$2;
SESSION_ID=$3;


if [ -z "${PERSON_ID}" ] || [ -z "${SESSION_ID}" ] || [ -z "${GESTURE_ID}" ]; then
  echo "usage: registerRecordedGestures.sh <PERSON_ID> <GESTURE_ID> <SESSION_ID>";
  exit;
else
  echo "creating session nr ${SESSION_ID} for person nr ${PERSON_ID} and gesture nr ${GESTURE_ID}";
fi

####### check input

if [ "${PERSON_ID}" -gt "${NOF_PERSONS}" ]; then
  echo "start person nr ${PERSON_ID} > ${NOF_PERSONS} doesn't exist. Please call the project guide.";
  exit;
fi

if [ "${SESSION_ID}" -gt "${NOF_SESSIONS}" ]; then
  echo "current session nr ${SESSION_ID} > ${NOF_SESSIONS} doesn't exist";
  exit;
fi

if [ "${GESTURE_ID}" -gt "${NOF_GESTURES}" ]; then
  echo "gesture nr ${GESTURE_ID} > ${NOF_GESTURES} doesn't exist";
  exit;
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

VIDEO_TO_IMAGE_OUTPUT_DRIVER_OPTIONS="z=9"; # png compression factor <0-9>
VIDEO_TO_IMAGE_OPTIONS="-vo ${VIDEO_TO_IMAGE_OUTPUT_DRIVER} ${VIDEO_TO_IMAGE_OUTPUT_DRIVER_OPTIONS}";


# webcam options
VIDEO_NAME_WEBCAM_="Philips ToUCam Pro II";
VIDEO_IDEVICE_WEBCAM="/dev/video0"; #input device for Philips ToUCam Pro II
VIDEO_WIDTH_WEBCAM="320";
VIDEO_HEIGHT_WEBCAM="240";
VIDEO_INPUT_OPTIONS_WEBCAM="-rawvideo on:fps=${VIDEO_IFPS}:w=${VIDEO_WIDTH_WEBCAM}:h=${VIDEO_HEIGHT_WEBCAM}";


# auxiliary camera options
VIDEO_NAME_AUX_="JVC GR-SX20EG";
VIDEO_IDEVICE_AUX="/dev/video1";    #input device for auxiliary camera 2
VIDEO_WIDTH_AUX="352";  #half PAL resolution
VIDEO_HEIGHT_AUX="288";
VIDEO_INPUT_OPTIONS_AUX="tv:// -tv device=${VIDEO_IDEVICE_AUX}:driver=v4l2:input=2:noaudio:width=${VIDEO_WIDTH_AUX}:height=${VIDEO_HEIGHT_AUX}:fps=${VIDEO_IFPS}:normid=0 "; #see 'man mplayer' for details

NOF_VIDEO_DEVICES=2; #set to 1, if you want to use only the webcam, else to 2


######################################################################
######################################################################



#
# registers a temporary video record for a given gesture, person-id and record-iteration
#
function registerRecordTemp() {
  person=$1;
  gesture=$2;
  session=$3;

  echo "person nr ${person} / gesture nr ${gesture} / session nr ${session} will be registered now ";

  for((camera=1; camera<=${NOF_VIDEO_DEVICES}; ++camera)); do

    # 1. convert video file into images -- files will be created in current directory
    echo "converting camera ${camera} video file into ${IMAGE_FORMAT}-images";
    echo "$VIDEO_PLAYER ${VIDEO_TO_IMAGE_OPTIONS} ${DATA_VIDEO_DIR}/${gesture}/${person}_${gesture}_${session}_cam${camera}.${VIDEO_OUTPUT_FORMAT}"	
    $VIDEO_PLAYER ${VIDEO_TO_IMAGE_OPTIONS} ${DATA_VIDEO_DIR}/${gesture}/${person}_${gesture}_${session}_cam${camera}.${VIDEO_OUTPUT_FORMAT} < /dev/null &>/dev/null

    # 2. change image file names in the current directory
    echo "changing image filenames";
    for currentImage in *.${IMAGE_FORMAT}; do
      mv ${currentImage} ${person}_${gesture}_${session}_cam${camera}_${currentImage}
    done;  
    	
        
    # 3. create sequence file with full path destination names for images in the current directory
    echo "creating sequence file";
    for currentImage in *.${IMAGE_FORMAT}; do
     echo ${DATA_IMAGE_DIR}/${gesture}/${currentImage} >> ${TEMP_DIR}/${person}_${gesture}_${session}_cam${camera}.seq
    done;  
    
    # 4. move images and sequence file to database directory
    echo "moving images and sequence file to ${DATA_IMAGE_DIR}/${gesture}/";
    for currentImage in *.${IMAGE_FORMAT}; do
      mv $currentImage ${DATA_IMAGE_DIR}/${gesture}/
    done;
    mv  ${TEMP_DIR}/${person}_${gesture}_${session}_cam${camera}.seq ${DATA_IMAGE_DIR}/${gesture}/
    rm *.png
 done;   

}




## -------------- MAIN ----------------------

clear
echo "Scene: ${GESTURE_ID} / ${NOF_GESTURES}";

# register the recorded data
mkdir -p ${DATA_IMAGE_DIR}/${GESTURE_ID}/
registerRecordTemp ${PERSON_ID} ${GESTURE_ID} ${SESSION_ID};
