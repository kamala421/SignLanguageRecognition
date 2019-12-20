# camera devices
WEBCAM=`grep "pwc Registered as" /var/log/dmesg | tail -1 | colrm 1 18 |colrm 12`
TVCAM=/dev/`grep "bttv.: registered device video" /var/log/dmesg | tail -1 |colrm 1 25`

mplayer -geometry 25%:50% tv:// -tv device=${TVCAM}:driver=v4l2:input=2:noaudio:width=352:height=288:fps=25:normid=0
