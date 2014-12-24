TARGET  = XRawData
KDIR= /lib/modules/$(shell uname -r)/build
KBUILD_EXTRA_SYMBOLS += $(KDIR)/Module.symvers
KBUILD_EXTRA_SYMBOLS += $(XDMA_PATH)/Module.symvers
obj-m   := $(TARGET).o 
$(TARGET)-objs :=  Appdriver.o


all:
	$(MAKE) $(CFLAGS) -C $(KDIR) M=$(PWD)/Appdriver modules

$(TARGET).o:$(OBJS)
	$(LD) $(LD_FLAGS) -r -o $@ $(OBJS)
clean:
	rm -rf *.o *.ko *.mod.* .c* .t*  .*.cmd modules.order Module.symvers 
