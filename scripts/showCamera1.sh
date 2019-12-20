# camera devices
WEBCAM=`grep "pwc Registered as" /var/log/dmesg | tail -1 | colrm 1 18 |colrm 12`
TVCAM=/dev/`grep "bttv.: registered device video" /var/log/dmesg | tail -1 |colrm 1 25`

mplayer -geometry 75%:50% -rawvideo on:fps=25:w=320:h=240 ${WEBCAM}
