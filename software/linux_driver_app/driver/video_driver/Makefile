KBUILD_EXTRA_SYMBOLS += $(KDIR)/Module.symvers
KBUILD_EXTRA_SYMBOLS += $(XDMA_PATH)/Module.symvers

TARGET = video_driver
obj-m   := $(TARGET).o 

$(TARGET)-objs :=  xil_fb.o xil_v4l2.o

ifeq ($(OS_TYPE),64)
EXTRA_CFLAGS += -DX86_64
endif

ifeq ($(TEST_MODE),VIDEOACC)
EXTRA_CFLAGS += -DVIDEO_ACC_DESIGN
endif

EXTRA_CFLAGS += -DZynq_PCIeTRD -DX86_PC -DUSE_IO_MACROS -DNWLDMA -DXRAWDATA0 -DPM_SUPPORT -DHOSTCONTROL

all:
	$(MAKE) $(CFLAGS) -C $(KDIR) M=$(PWD)/video_driver modules 

$(TARGET).o:$(OBJS)
	$(LD) $(LD_FLAGS) -r -o $@ $(OBJS)

clean:
	rm -rf *.o *.ko *.mod.* .c* .t*  .*.cmd modules.order Module.symvers 

