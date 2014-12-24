#ifndef XIL_FB_H
#define XIL_FB_H
void get_dma_lock(void);
void release_dma_lock(void);
int receive_packet(char * buffer, size_t length);
int DmaSetupReceive(const char __user * buffer,size_t length);
int rx_done_poll (int expect_count);
long xraw_dev_ioctl (struct file *filp,
                     unsigned int cmd, unsigned long arg);
#endif /* XIL_FB_H */
