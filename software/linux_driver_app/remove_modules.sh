#!/bin/sh
DMA_MODULE_NAME="xdma_pcie"
RAW_MODULE="XRawData"
VIDEO_MODULE="video_driver"
STATSFILE="xdma_stats"
if [ -d /sys/module/$DMA_MODULE_NAME ]; then
	if [ -d /sys/module/$RAW_MODULE ]; then
		echo " Done "
		cd driver && sudo make remove
		rm -rf $STATSFILE
	elif [ -d /sys/module/$VIDEO_MODULE ]; then
		echo " Done "
		#/bin/sh kill_vlc.sh
		sleep 3
		cd driver && sudo make DRIVER_MODE=VIDEO remove
		rm -rf $STATSFILE
	elif [ -d /sys/module/$DMA_MODULE_NAME ]; then
		echo " Done "
		sleep 3
		rmmod $DMA_MODULE_NAME
		rm -rf $STATSFILE
	fi
fi
