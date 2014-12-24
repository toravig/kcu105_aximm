
ifndef DRIVER_MODE
export DRIVER_MODE=PERFORMANCE
endif


export KDIR= /lib/modules/$(shell uname -r)/build
export XDMA_PATH=$(ROOTDIR)/xdma
export XRAWDATA0_PATH=$(ROOTDIR)/Appdriver
#export XRAWDATA1_PATH=$(ROOTDIR)/Rx_data
export VIDEO_PATH=$(ROOTDIR)/video_driver
#export XETHERNET0_PATH=$(ROOTDIR)/xxgbeth0
#export XETHERNET1_PATH=$(ROOTDIR)/xxgbeth1
export INSMOD=/sbin/insmod
export RMMOD=/sbin/rmmod
export RM=/bin/rm
export MKNOD_CMD=/bin/mknod
export MODPROBE_CMD=modprobe
export DMA_STATS_FILE=xdma_stats
export RAW0_FILE_NAME=xraw_data0
export RAW1_FILE_NAME=xraw_data1
export DMA_DRIVER_NAME=xdma_pcie.ko
export RAW0_DRIVER_NAME=XRawData.ko
export RAW1_DRIVER_NAME=rx_data_uscale.ko
export VIDEO_DRIVER_NAME=video_driver.ko
export DMA_DRIVER_REMOVE_NAME=xdma_pcie.ko
export RAW0_DRIVER_REMOVE_NAME=XRawData.ko
export RAW1_DRIVER_REMOVE_NAME=rx_data_uscale.ko
export XETHERNET0_DRIVER_NAME=xxgbeth0.ko
export XETHERNET1_DRIVER_NAME=xxgbeth1.ko
export SLEEP_TIME=1

MKNOD = `awk '/$(DMA_STATS_FILE)/ {print $$1}' /proc/devices`
MKNOD0 =`awk '/$(RAW0_FILE_NAME)/ {print $$1}' /proc/devices`
MKNOD1 =`awk '/$(RAW1_FILE_NAME)/ {print $$1}' /proc/devices`
MKNOD2 =`awk '/$(DMA_CTRL_FILE)/ {print $$1}' /proc/devices`
MKNODCTRL = `awk '/$(DMA_CTRL_FILE)/ {print $$1}' /proc/devices`

define compile_performance_driver
	echo Compiling Performance Driver
	$(MAKE) -C $(XDMA_PATH)
	$(MAKE) -C $(XRAWDATA0_PATH)
#	$(MAKE) -C $(XRAWDATA1_PATH)
endef

define compile_video_driver
	echo Compiling Video Driver
	$(MAKE) -C $(XDMA_PATH)
	$(MAKE) -C $(VIDEO_PATH)
endef

define insert_performance_driver
	echo Inserting Performance Driver
	$(INSMOD) $(XDMA_PATH)/$(DMA_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(MKNOD_CMD) /dev/$(DMA_STATS_FILE) c $(MKNOD) 0
	$(INSMOD) $(XRAWDATA0_PATH)/$(RAW0_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(MKNOD_CMD) /dev/$(RAW0_FILE_NAME) c $(MKNOD0) 0
#	$(INSMOD) $(XRAWDATA1_PATH)/$(RAW1_DRIVER_NAME)
#	$(MKNOD_CMD) /dev/$(RAW1_FILE_NAME) c $(MKNOD1) 0
endef

define insert_video_driver
	echo Inserting Video Driver
	$(INSMOD) $(XDMA_PATH)/$(DMA_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(MKNOD_CMD) /dev/$(DMA_STATS_FILE) c $(MKNOD) 0
	$(MODPROBE_CMD) v4l2-common 1>/dev/null 2>&1; sleep $(SLEEP_TIME)   
	$(MODPROBE_CMD) videodev 1>/dev/null 2>&1; sleep $(SLEEP_TIME)   
	$(INSMOD) $(VIDEO_PATH)/$(VIDEO_DRIVER_NAME); sleep $(SLEEP_TIME)
	chmod 777 /dev/fb1
	chmod 777 /dev/video0
endef

define clean_performance_driver
	echo Cleaning Performance Driver
	$(MAKE) -C $(XDMA_PATH) clean
	$(MAKE) -C $(XRAWDATA0_PATH) clean
#	$(MAKE) -C $(XRAWDATA1_PATH) clean
endef

define clean_video_driver
	echo Cleaning Video Driver
	$(MAKE) -C $(XDMA_PATH) clean
	$(MAKE) -C $(VIDEO_PATH) clean
endef

define remove_performance_driver
	echo Removing Performance Driver
#	$(RMMOD) $(RAW1_DRIVER_REMOVE_NAME); sleep $(SLEEP_TIME)
	$(RMMOD) $(RAW0_DRIVER_REMOVE_NAME); sleep $(SLEEP_TIME) 
	$(RM) -f /dev/$(DMA_STATS_FILE)
	$(RM) -f /dev/$(RAW0_FILE_NAME)
	$(RMMOD) $(DMA_DRIVER_REMOVE_NAME)
endef

define remove_video_driver
	echo Removing Video Driver
	$(RMMOD) $(VIDEO_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(RMMOD) $(DMA_DRIVER_REMOVE_NAME)
	$(RM) -f /dev/$(DMA_STATS_FILE)
endef
