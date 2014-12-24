KBUILD_EXTRA_SYMBOL += $(KDIR)/Module.symvers
KBUILD_EXTRA_SYMBOLS += $(KDIR)/Module.symvers

TARGET = xdma_pcie
obj-m   := $(TARGET).o 

$(TARGET)-objs :=  ps_pcie_dma_driver.o

ifeq ($(TEST_MODE),VIDEOACC)
EXTRA_CFLAGS += -DVIDEO_ACC_DESIGN
endif

all:
	$(MAKE) $(CFLAGS) -C $(KDIR) M=$(PWD)/xdma modules

$(TARGET).o:$(OBJS)
	$(LD) $(LD_FLAGS) -r -o $@ $(OBJS)

clean:
	rm -rf *.o *.ko *.mod.* .c* .t*  .*.cmd modules.order Module.symvers 

