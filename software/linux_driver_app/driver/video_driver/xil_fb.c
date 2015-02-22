/*******************************************************************************
 ** © Copyright 2012 - 2013 Xilinx, Inc. All rights reserved.
 ** This file contains confidential and proprietary information of Xilinx, Inc. and 
 ** is protected under U.S. and international copyright and other intellectual property laws.
 *******************************************************************************
 **   ____  ____ 
 **  /   /\/   / 
 ** /___/  \  /   Vendor: Xilinx 
 ** \   \   \/    
 **  \   \
 **  /   /          
 ** /___/   /\
 ** \   \  /  \   Zynq-7 PCIe Targeted Reference Design
 **  \___\/\___\
 ** 
 **  Device: zc7z045
 **  Reference: UG 
 *******************************************************************************
 **
 **  Disclaimer: 
 **
 **    This disclaimer is not a license and does not grant any rights to the materials 
 **    distributed herewith. Except as otherwise provided in a valid license issued to you 
 **    by Xilinx, and to the maximum extent permitted by applicable law: 
 **    (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
 **    AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
 **    INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
 **    FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
 **    or tort, including negligence, or under any other theory of liability) for any loss or damage 
 **    of any kind or nature related to, arising under or in connection with these materials, 
 **    including for any direct, or any indirect, special, incidental, or consequential loss 
 **    or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
 **    as a result of any action brought by a third party) even if such damage or loss was 
 **    reasonably foreseeable or Xilinx had been advised of the possibility of the same.


 **  Critical Applications:
 **
 **    Xilinx products are not designed or intended to be fail-safe, or for use in any application 
 **    requiring fail-safe performance, such as life-support or safety devices or systems, 
 **    Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
 **    or any other applications that could lead to death, personal injury, or severe property or 
 **    environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
 **    the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
 **    to applicable laws and regulations governing limitations on product liability.

 **  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

 *******************************************************************************/

/*****************************************************************************/
/**
 *
 * @file xil_fb.c
 *
 * This is the Application driver which registers with XDMA driver with private interface.
 * This Application driver creates an charracter driver interface with user Application.
 *
 * Author: Xilinx, Inc.; Missing Link Electronics, Inc
 *
 * 2011-2011 (c) Xilinx, Inc. This file is licensed uner the terms of the GNU
 * General Public License version 2.1. This program is licensed "as is" without
 * any warranty of any kind, whether express or implied.
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Date     Changes
 * ----- -------- -------------------------------------------------------
 * 1.0   05/15/12 First release 
 * 1.1   04/10/13 MLE: Changed driver to be framebuffer device
 *
 *****************************************************************************/

#include <linux/version.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/spinlock.h>
#include <linux/fs.h>
#include <linux/fb.h>
#include <linux/kdev_t.h>
#include <linux/cdev.h>
#include <linux/mm.h>		
#include <linux/spinlock.h>	
#include <linux/pagemap.h>	
#include <linux/slab.h>
#include <linux/list.h>
#include <asm/uaccess.h>
#include <linux/platform_device.h>
#include <linux/kthread.h>

#include "../include/xpmon_be.h"
#include "../include/xdma_user.h"
#include "../include/xdebug.h"
#include "../include/xio.h"

#include "xil_v4l2.h"

#include "../xdma/ps_pcie_dma_driver.h"
#include "../xdma/ps_pcie_pf.h"

/* Driver states */
#define UNINITIALIZED   0	/* Not yet come up */
#define INITIALIZED     1	/* But not yet set up for polling */
#define UNREGISTERED    2       /* Unregistering with DMA */
#define POLLING         3	/* But not yet registered with DMA */
#define REGISTERED      4	/* Registered with DMA */
#define CLOSED          5	/* Driver is being brought down */

/* DMA characteristics */
#define MYBAR           0


#define VIDEO_TX_CHANNEL_ID 0
#define VIDEO_RX_CHANNEL_ID 1


#ifdef XRAWDATA0
#define MYHANDLE  HANDLE_0
#else
#define MYHANDLE  HANDLE_1
#endif

#ifdef XRAWDATA0
#define MYNAME   "Raw Data 0"
#define DEV_NAME  "xraw_data0"
#else
#define MYNAME   "Raw Data 1"
#define DEV_NAME  "xraw_data1"
#endif

#define DESIGN_MODE_ADDRESS 0x9004		/* Used to configure HW for different modes */        

#define PERF_DESIGN_MODE   0x00000003

#ifdef XRAWDATA0

#define TX_CONFIG_ADDRESS       0x9108
#define RX_CONFIG_ADDRESS       0x9100
#define PKT_SIZE_ADDRESS        0x9104
#define STATUS_ADDRESS          0x910C
#define SEQNO_WRAP_REG          0x9110
/* Test start / stop conditions */
#define LOOPBACK            0x00000002	/* Enable TX data loopback onto RX */
#define SOBELCNTRL_OFFSET          0x9100
#define SOBELOFFLOAD_CNTRL_OFFSET  0x9104
#define DISPLAYCNTRL_OFFSET        0x9108
#define HOST_CNTRL_OFFSET          0x9300
#define HOST_STATUS_OFFSET         0x9304
#define ZYNQ_PS_REGISTER_OFFSET    0x9404
#define SOBEL_ON                    0x00000001
#define SOBEL_OFF                   0x00000000
#define SOBEL_INVERT                0x00000002
#define SOBEL_SW_PROCESSING         0x00000001
#define SOBEL_HW_PROCESSING         0x00000000
#define LOOPVIDEO_BACK              0x00000001
#define DISPLAY_ON_CVC              0x00000000
#define HOST_SOFTRESET_ASSERTED     0x00000001
#define HOST_SOFTRESET_NOT_ASSERTED 0x00000000
#define HOST_READY_MASK             0x00000001
#define HOST_NOT_READY_MASK         0xFFFFFFFE
#define ZYNQ_TEST_START_MASK        0x00000002
#define ZYNQ_TEST_STOP_MASK         0xFFFFFFFD
#define ZYNQ_READY_MASK             0x00000001
#define SOBEL_MIN_MASK              0x00FF0000
#define SOBEL_MAX_MASK              0xFF000000
#define SOBEL_MIN_COEF_START_BIT    16

#else

#define TX_CONFIG_ADDRESS   0x9208	/* Reg for controlling TX data */
#define RX_CONFIG_ADDRESS   0x9200	/* Reg for controlling RX pkt generator */
#define PKT_SIZE_ADDRESS    0x9204	/* Reg for programming packet size */
#define STATUS_ADDRESS      0x920C	/* Reg for checking TX pkt checker status */
#define SEQNO_WRAP_REG      0x9210  /* Reg for sequence number wrap around */
/* Test start / stop conditions */
#define LOOPBACK            0x00000002	/* Enable TX data loopback onto RX */
#endif

#ifdef ENABLE_DEBUG
#define LOG_MSG printk
#else
#define LOG_MSG(...)
#endif

/* Test start / stop conditions */
#define PKTCHKR             0x00000001	/* Enable TX packet checker */
#define PKTGENR             0x00000001	/* Enable RX packet generator */
#define CHKR_MISMATCH       0x00000001	/* TX checker reported data mismatch */

#ifdef XRAWDATA0
#define ENGINE_TX       0
#define ENGINE_RX       32
#else
#define ENGINE_TX       1
#define ENGINE_RX       33
#endif

/* Packet characteristics */
#ifdef XRAWDATA0
#define BUFSIZE         (PAGE_SIZE)
#define MAXPKTSIZE      (FRAME_PIXEL_COLS * NUM_BYTES_PIXEL ) 

#define MINPKTSIZE      (64)
#define NUM_BUFS        2000
#define BUFALIGN        8
#define BYTEMULTIPLE    8   /**< Lowest sub-multiple of memory path */
#else
#define BUFSIZE         (PAGE_SIZE)
#define MAXPKTSIZE      (8*PAGE_SIZE)

#define MINPKTSIZE      (64)
#define NUM_BUFS        2000
#define BUFALIGN        8
#define BYTEMULTIPLE    8   /**< Lowest sub-multiple of memory path */
#endif

#define NOBH 1
//#define WITHBH 1

#if defined (NOBH)
#define LOCK_DMA_CHANNEL(x) spin_lock(x)
#define UNLOCK_DMA_CHANNEL(x) spin_unlock(x)
#elif defined (WITHBH)
#define LOCK_DMA_CHANNEL(x) spin_lock_bh(x)
#define UNLOCK_DMA_CHANNEL(x) spin_unlock_bh(x)
#else
#define LOCK_DMA_CHANNEL(x) 
#define UNLOCK_DMA_CHANNEL(x) 
#endif


ps_pcie_dma_desc_t* ptr_dma_desc; 
//#define TX_RX_SYNC     1
#define MAX_TIMEOUT    60

#define TX_FRAME_SYNC_SIGNATURE 0xCA

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
#ifdef TX_RX_SYNC
#define RX_FRAME_SYNC_SIGNATURE 0xCB
#endif

#define MAXPKTSIZE      (FRAME_PIXEL_COLS * NUM_BYTES_PIXEL ) 
#define VIDEO_FRAME_SIZE ( MAXPKTSIZE * FRAME_PIXEL_ROWS )
#define NUM_FRAMES_IN_PLDDR 3 

//#define DMA_LOOPBACK 1
//#define PS_DDR_VDMA_TX_ADDR_BASE (0x00010000)
//#define PS_DDR_VDMA_RX_ADDR_BASE (PS_DDR_VDMA_TX_ADDR_BASE + (NUM_FRAMES_IN_PLDDR * VIDEO_FRAME_SIZE))
// Working offsets
#define PS_DDR_VDMA_TX_ADDR_BASE (0xC0000000)
//#define PS_DDR_VDMA_RX_ADDR_BASE (0xD0000000)
#define PS_DDR_VDMA_RX_ADDR_BASE (PS_DDR_VDMA_TX_ADDR_BASE + (NUM_FRAMES_IN_PLDDR * VIDEO_FRAME_SIZE))

struct task_struct* task = NULL;

typedef struct psddr_range
{
	u32 frame_start_address;
	u32 frame_end_address;
}psddr_range_t;

psddr_range_t psDstQsRangeTx[NUM_FRAMES_IN_PLDDR]; 
psddr_range_t psDstQsRangeRx[NUM_FRAMES_IN_PLDDR];

size_t TxDstDdrPhyAdrs;
size_t RxDstDdrPhyAdrs;


static void InitBridge_App (u64 bar0_addr, u32 bar0_addr_p, u64 bar2_addr, u32 bar2_addr_p);
static void InitVdma (u64 bar0_addr, u32 bar0_addr_p, u64 bar2_addr, u32 bar2_addr_p);
static void InitSobel (u64 bar0_addr, u32 bar0_addr_p, u64 bar2_addr, u32 bar2_addr_p);

static void c2s_processed_fr_tsmt (struct work_struct *work);
static void c2s_fr_tsmt_init_cbk(struct _ps_pcie_dma_chann_desc *p_chan,
		unsigned int *p_data, unsigned int count);

static void ResetDMAonStopTest(void);

static int index=0;
#endif


#define NUM_Q_ELEM 19440  

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
#define NUM_AUX_Q_ELEM ((FRAME_PIXEL_ROWS * NUM_FRAMES_IN_PLDDR) + 2) 
#ifdef  SINGLE_RX_AUX_DST_ELEMENT
#define RX_NUM_AUX_Q_ELEM (NUM_FRAMES_IN_PLDDR + 2) 
#else
#define RX_NUM_AUX_Q_ELEM ((FRAME_PIXEL_ROWS * NUM_FRAMES_IN_PLDDR) + 2) 
#endif

#endif

struct cdev *xrawCdev = NULL;
int xraw_DriverState = UNINITIALIZED;
int xraw_UserOpen = 0;

void *handle[4] = { NULL, NULL, NULL, NULL };
#ifdef X86_64
u64 TXbarbase, RXbarbase;
#else
u32 TXbarbase, RXbarbase;
#endif
u32 RawTestMode = TEST_STOP;
u32 RawMinPktSize = MINPKTSIZE, RawMaxPktSize = MAXPKTSIZE;
spinlock_t dma_lock;


#define NO_BP  1
#define YES_BP 2
#define MAX_QUEUE_THRESHOLD 12288
#define MIN_QUEUE_THRESHOLD 8192 
u8 impl_bp = NO_BP;/*back pressure implementation flag */


typedef struct
{
	int TotalNum;
	int AllocNum;
	int FirstBuf;
	int LastBuf;
	int FreePtr;
	int AllocPtr;
	unsigned char *origVA[NUM_BUFS];
} Buffer;

Buffer TxBufs;
Buffer RxBufs;
char xrawTrans[4096];

static unsigned int tx_channel_num_empty_bds = NUM_Q_ELEM - 2;
static unsigned int rx_channel_num_empty_bds = NUM_Q_ELEM - 2;
static ps_pcie_dma_desc_t *ptr_app_dma_desc = NULL;
static ps_pcie_dma_chann_desc_t *ptr_chan_s2c[PS_PCIE_NUM_DMA_CHANNELS] = {0};
static addr_type_t addr_typ_transfer[PS_PCIE_NUM_DMA_CHANNELS];
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
static ps_pcie_dma_chann_desc_t *ptr_chan_s2c_dst[PS_PCIE_NUM_DMA_CHANNELS] = {0};
static ps_pcie_dma_chann_desc_t *ptr_rxchan_s2c_dst[PS_PCIE_NUM_DMA_CHANNELS] = {0};
static addr_type_t addr_typ_aux_transfer[PS_PCIE_NUM_DMA_CHANNELS];

struct work_struct rx_dst_work;
struct workqueue_struct *rx_dst_workq; 
#endif
static ps_pcie_dma_chann_desc_t *ptr_rxchan_s2c[PS_PCIE_NUM_DMA_CHANNELS] = {0};

/* For exclusion */
spinlock_t RawLock;

/* For synchronization between Tx and Tx call back */
spinlock_t TxLock;
/* For synchronization between Rx and Rx call back */
spinlock_t RxLock;

#ifdef PFORM_USCALE_NO_EP_PROCESSOR

#ifdef RES_720P
#define H_SIZE             1280
#define V_SIZE             720 
#else
#define H_SIZE             1920
#define V_SIZE             1080
#endif

#define VDMA_OFFSET        0x00020000
#define SOBEL_OFFSET       0x00030000

#define MM2S_VDMACR            0x00000000
#define MM2S_VDMASR            0x00000004
#define MM2S_START_ADDR1       0x0000005C
#define MM2S_START_ADDR2       0x00000060
#define MM2S_START_ADDR3       0x00000064
#define MM2S_FRMDLY_STRIDE     0x00000058
#define MM2S_HSIZE             0x00000054
#define MM2S_VSIZE             0x00000050

#define S2MM_VDMACR            0x00000030
#define S2MM_VDMASR            0x00000034
#define S2MM_START_ADDR1       0x000000AC
#define S2MM_START_ADDR2       0x000000B0
#define S2MM_START_ADDR3       0x000000B4
#define S2MM_FRMDLY_STRIDE     0x000000A8
#define S2MM_HSIZE             0x000000A4
#define S2MM_VSIZE             0x000000A0

#define PARK_PTR_REG           0x00000028

//#define S2MM_VDMACR_VAL        0x000170C3   // RS=1; all others are default value, with genLock
#define MM2S_VDMACR_RESET_VAL  0x00000004 
#define S2MM_VDMACR_RESET_VAL  0x00000004
#define MM2S_VDMACR_RUN_VAL    0x00000000
#define S2MM_VDMACR_RUN_VAL    0x00000000
#define S2MM_VDMACR_VAL        0x00010003   // RS=1; all others are default value, with genLock
#ifdef RES_720P
#define S2MM_FRMDLY_STRIDE_VAL 0x00001400   //H_SIZE*4      //0x0000_1400   // Frame delay is set to zero + Stride is equal to Hsize = (1280*4)  => 0x1400
#define S2MM_HSIZE_VAL         0x00001400   //H_SIZE*4       //0x0000_1400   // (1280*4)  => 0x1400
#define S2MM_VSIZE_VAL         0x000002D0 //V_SIZE       //0x0000_02D0   // 720 lines => 0x000002D0
#else
#define S2MM_FRMDLY_STRIDE_VAL 0x00001E00   //H_SIZE*4      //0x0000_2000   // Frame delay is set to zero + Stride is equal to Hsize = (1920*4)  => 0x1E00
#define S2MM_HSIZE_VAL         0x00001E00   //H_SIZE*4       //0x0000_1E00   // (1920*4)  => 0x1E00
#define S2MM_VSIZE_VAL         0x00000438 //V_SIZE       //0x0000_0438   // 1080 lines => 0x00000438
#endif

//#define MM2S_VDMACR_VAL        0x000170C3   // RS=1; all others are default value
#define MM2S_VDMACR_VAL        0x00010003   // RS=1; all others are default value
#ifdef RES_720P
#define MM2S_FRMDLY_STRIDE_VAL  0x00001400  //H_SIZE*4       //0x0000_2000   // Frame delay is set to zero + Stride is equal to Hsize
#define MM2S_HSIZE_VAL          0x00001400  //H_SIZE*4  //0x0000_1E00;  // (1280pixel * 4Bytes)  => 0x1400
#define MM2S_VSIZE_VAL          0x000002D0  //V_SIZE  //0x0000_02D0;  // 720 lines => 0x02D0
#else
#define MM2S_FRMDLY_STRIDE_VAL 0x00001E00  //H_SIZE*4       //0x0000_2000   // Frame delay is set to zero + Stride is equal to Hsize
#define MM2S_HSIZE_VAL         0X00001E00  //H_SIZE*4  //0x0000_1E00;  // (1920pixel * 4Bytes)  => 5120 => 0x1E00
#define MM2S_VSIZE_VAL         0X00000438  //V_SIZE  //0x0000_0438;  // 1080 lines => 0x0438
#endif

#define SOBEL_CNTL_STS_REG     0x00000000
#define SOBEL_NO_OF_ROWS       0x00000014
#define SOBEL_NO_OF_COLS       0x0000001C
#define SOBEL_XR0C0            0x00000024
#define SOBEL_XR0C1            0x0000002C
#define SOBEL_XR0C2            0x00000034
#define SOBEL_XR1C0            0x0000003C
#define SOBEL_XR1C1            0x00000044
#define SOBEL_XR1C2            0x0000004C
#define SOBEL_XR2C0            0x00000054
#define SOBEL_XR2C1            0x0000005C
#define SOBEL_XR2C2            0x00000064
#define SOBEL_YR0C0            0x0000006C
#define SOBEL_YR0C1            0x00000074
#define SOBEL_YR0C2            0x0000007C
#define SOBEL_YR1C0            0x00000084
#define SOBEL_YR1C1            0x0000008C
#define SOBEL_YR1C2            0x00000094
#define SOBEL_YR2C0            0x0000009C
#define SOBEL_YR2C1            0x000000A4
#define SOBEL_YR2C2            0x000000AC
#define SOBEL_HIGH_THRESHOLD   0x000000B4
#define SOBEL_LOW_THRESHOLD    0x000000BC
#define SOBEL_INVERT_REG       0x000000C4
#define SOBEL_CNTL_STS_REG_VAL 0x00000080
#define SOBEL_NO_OF_ROWS_VAL   V_SIZE
#define SOBEL_NO_OF_COLS_VAL   H_SIZE
#define SOBEL_XR0C0_VAL        0x00000001
#define SOBEL_XR0C1_VAL        0x00000000
#define SOBEL_XR0C2_VAL        0xFFFFFFFF
#define SOBEL_XR1C0_VAL        0x00000002
#define SOBEL_XR1C1_VAL        0x00000000
#define SOBEL_XR1C2_VAL        0xFFFFFFFE
#define SOBEL_XR2C0_VAL        0x00000001
#define SOBEL_XR2C1_VAL        0x00000000
#define SOBEL_XR2C2_VAL        0xFFFFFFFF
#define SOBEL_YR0C0_VAL        0x00000001
#define SOBEL_YR0C1_VAL        0x00000002
#define SOBEL_YR0C2_VAL        0x00000001
#define SOBEL_YR1C0_VAL        0x00000000
#define SOBEL_YR1C1_VAL        0x00000000
#define SOBEL_YR1C2_VAL        0x00000000
#define SOBEL_YR2C0_VAL        0xFFFFFFFF
#define SOBEL_YR2C1_VAL        0xFFFFFFFE
#define SOBEL_YR2C2_VAL        0xFFFFFFFF

#define SOBEL_HIGH_THRESHOLD_VAL 0x000000FF
#define SOBEL_LOW_THRESHOLD_VAL  0x00000000
#define SOBEL_INVERT_VAL         0x00000001
#define SOBEL_INVERT_OFF_VAL     0x00000000

#ifdef TX_RX_SYNC
u32 s2c_pushback_status;
u8 s2c_frame_cnt;
typedef enum
{
	BLOCK,
	PROGRESS,
	INITIALIZATION
}s2c_pushback_t;

spinlock_t sync_lock;
#endif

#endif

/* Framebuffer memory object and definitions */
#define FB_REAL_SIZE FRAME_PIXEL_ROWS * FRAME_PIXEL_COLS * NUM_BYTES_PIXEL
#define FB_VIRT_SIZE FB_REAL_SIZE * 2
#define FB_CHUNK_SIZE 614400

typedef struct {
	char     * buffer;
	int      buff_size;
	int      buff_count;
	int      pos;
	struct   list_head list; /* kernel's list structure */
} FrameBuffer;

FrameBuffer fb_data_0;
FrameBuffer fb_data_1;

//struct fb_info *info;
static struct fb_var_screeninfo xil_fb_default = {
	.xres =         FRAME_PIXEL_COLS,
	.yres =         FRAME_PIXEL_ROWS,
	.xres_virtual = FRAME_PIXEL_COLS,
	.yres_virtual = FRAME_PIXEL_ROWS * 2,
	.xoffset       = 0,
	.yoffset       = 0,
	.bits_per_pixel = 32,
	.red =          { 0, 8, 0 },
	.green =        { 0, 8, 0 },
	.blue =         { 0, 8, 0 },
	.activate =     FB_ACTIVATE_TEST,
	.height =       -1,
	.width =        -1,
	.pixclock =     20000,
	.left_margin =  64,
	.right_margin = 64,
	.upper_margin = 32,
	.lower_margin = 32,
	.hsync_len =    64,
	.vsync_len =    2,
	.vmode =        FB_VMODE_NONINTERLACED,
};

static struct fb_fix_screeninfo xil_fb_fix = {
	.id              = "Xil FB",
	.smem_len        = FB_VIRT_SIZE,
	.type            = FB_TYPE_PACKED_PIXELS,
	.visual          = FB_VISUAL_PSEUDOCOLOR,
	.xpanstep        = 1,
	.ypanstep        = 1,
	.ywrapstep       = 0,
	.accel           = FB_ACCEL_NONE,
	.line_length     = FRAME_PIXEL_COLS * NUM_BYTES_PIXEL,
};

int free_buffers = NUM_BUFS;

#ifdef XRAWDATA0
#define DRIVER_NAME         "xrawdata0_driver"
#define DRIVER_DESCRIPTION  "Xilinx Raw Data0 Driver "
#else
#define DRIVER_NAME         "xrawdata1_driver"
#define DRIVER_DESCRIPTION  "Xilinx Raw Data1 Driver"
#endif


/* bufferInfo queue implementation.
 *
 * the variables declared here are only used by either putBufferInfo or getBufferInfo.
 * These should always be guarded by QUpdateLock.
 *
 */


#define MAX_BUFF_INFO 16384

typedef struct BufferInfoQ
{
	spinlock_t iLock;		           /** < will be init to unlock by default  */
	BufferInfo iList[MAX_BUFF_INFO]; /** < Buffer Queue implimented in driver for storing incoming Pkts */
	unsigned int iPutIndex;          /** < Index to put the packets in Queue */
	unsigned int iGetIndex;          /** < Index to get the packets in Queue */ 
	unsigned int iPendingDone;       /** < Indicates number of packets to read */  
} BufferInfoQue;

BufferInfoQue TxDoneQ;		// assuming everything to be initialized to 0 as these are global
BufferInfoQue RxDoneQ;		// assuming everything to be initialized to 0 as these are global

// routines use for queue manipulation.
/* 
   putBuffInfo is used for adding an buffer element to the queue.
   it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/

int putBuffInfo (BufferInfoQue * bQue, BufferInfo buff);

/* 
   getBuffInfo is used for fetching the oldest buffer info from the queue.
   it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/
int getBuffInfo (BufferInfoQue * bQue, BufferInfo * buff);
#ifdef X86_64
int myInit (u64 barbase, unsigned int );
#else
int myInit (unsigned int, unsigned int);
#endif
int myFreePkt (void *, unsigned int *, int, unsigned int);  
int myGetRxPkt (void *, PktBuf *, unsigned int, int, unsigned int);
int myPutTxPkt (void *, PktBuf *, int, unsigned int);
int myPutRxPkt (void *, PktBuf *, int, unsigned int);
int mySetState (void *hndl, UserState * ustate, unsigned int privdata);
int myGetState (void *hndl, UserState * ustate, unsigned int privdata);

int fb_transferimage(struct fb_var_screeninfo *var);
int transfer_pixel_row(void * hndl, char * buffer, size_t length, char frame_delimiter, char frame_sync);
void cbk_transfer_video_row(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,\
		unsigned short uid, unsigned int num_frags);
void cbk_receive_video(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,\
		unsigned short uid, unsigned int num_frags);
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
void cbk_transfer_video_dst_row(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,\
		unsigned short uid, unsigned int num_frags);
void cbk_receive_video_dst(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,\
		unsigned short uid, unsigned int num_frags);
#endif

/* For checking data integrity */
unsigned int TxBufCnt = 0;
unsigned int RxBufCnt = 0;
unsigned int ErrCnt = 0;


	static inline void
PrintSummary (void)
{

}


#ifdef X86_64
	int
myInit (u64 barbase, unsigned int privdata)
{
#else
	int
		myInit (unsigned int barbase, unsigned int privdata)
		{
#endif
			int reg;
			log_normal ("Reached myInit with barbase %x and privdata %x\n",
					barbase, privdata);

			spin_lock_bh (&RawLock);
			if (privdata == 0x54545454)	// So that this is done only once
			{
				TXbarbase = barbase;
			}
			else if (privdata == 0x54545456)	// So that this is done only once
			{
				RXbarbase = barbase;
			}
			TxBufCnt = 0;
			RxBufCnt = 0;
			ErrCnt = 0;


			/* Stop any running tests. The driver could have been unloaded without
			 * stopping running tests the last time. Hence, good to reset everything.
			 */
			//  XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, 0);
			//  XIo_Out32 (TXbarbase + RX_CONFIG_ADDRESS, 0);
#ifdef HOSTCONTROL
			reg = XIo_In32 (TXbarbase + HOST_STATUS_OFFSET);

			reg = reg | HOST_READY_MASK;

			mdelay(10);
			log_verbose(KERN_ERR "Setting Host Ready\n");
			XIo_Out32 (TXbarbase +HOST_STATUS_OFFSET,reg);

			mdelay(10);

			reg = XIo_In32 (TXbarbase + HOST_STATUS_OFFSET);
			log_verbose(KERN_ERR"Register Val at Host Status Register is %x\n",reg);

			mdelay(10);
#endif
			spin_unlock_bh (&RawLock);

			return 0;
		}

	int
		myPutRxPkt (void *hndl, PktBuf * vaddr, int numpkts, unsigned int privdata)
		{
			int i;
			unsigned int flags;
			PktBuf *pbuf = vaddr;
			static int pktSize;
			unsigned char *usrAddr = NULL;
			BufferInfo tempBuffInfo;
			static  int noPages=0;
			int tusrLength;

			/* Check driver state */
			if (xraw_DriverState != REGISTERED)
			{
				LOG_MSG (KERN_ERR"Driver does not seem to be ready\n");
				return -1;
			}


			for (i = 0; i < numpkts; i++)
			{
				flags = vaddr->flags;

				pbuf = vaddr;
				dma_unmap_page(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]->ptr_dma_desc->dev,pbuf->bufPa,\
						pbuf->size,DMA_FROM_DEVICE);
				/*release the page lock*/
				page_cache_release( (struct page *)pbuf->pageAddr);
				pktSize = pktSize + pbuf->size;
				if (flags & PKT_SOP)
				{
					usrAddr = pbuf->bufInfo;
					pktSize = pbuf->size;
				}
				noPages++;
				if (flags & PKT_EOP)
				{
					tempBuffInfo.bufferAddress = usrAddr;
					tempBuffInfo.buffSize = pktSize;
					tempBuffInfo.noPages= noPages ;  
					tempBuffInfo.endAddress= pbuf->bufInfo;
					tempBuffInfo.endSize=pbuf->size;
					tusrLength = (pbuf->userInfo & 0x0000ffff);
					/* put the packet in driver queue*/
					putBuffInfo (&RxDoneQ, tempBuffInfo);
					pktSize = 0;
					noPages=0;
					usrAddr = NULL;
				}
				vaddr++;
			}
			/* Return packet buffers to free pool */

			return 0;
		}

	int
		myGetRxPkt (void *hndl, PktBuf * vaddr, unsigned int size, int numpkts,
				unsigned int privdata)
		{
#ifdef USE_LATER
			unsigned char *bufVA;
			PktBuf *pbuf;
			int i;

			log_verbose(KERN_INFO "myGetRxPkt: Came with handle %p size %d privdata %x\n",
					hndl, size, privdata);

			/* Check driver state */
			if (xraw_DriverState != REGISTERED)
			{
				LOG_MSG ("Driver does not seem to be ready\n");
				return 0;
			}

			/* Check handle value */
			if (hndl != handle[2])
			{
				LOG_MSG ("Came with wrong handle\n");
				return 0;
			}

			/* Check size value */
			if (size != BUFSIZE)
				LOG_MSG ("myGetRxPkt: Requested size %d does not match expected %d\n",
						size, (u32) BUFSIZE);

			spin_lock_bh (&RawLock);

			for (i = 0; i < numpkts; i++)
			{
				pbuf = &(vaddr[i]);
				/* Allocate a buffer. DMA driver will map to PCI space. */
				bufVA = AllocBuf (&RxBufs);
				log_verbose (KERN_INFO
						"myGetRxPkt: The buffer after alloc is at address %x size %d\n",
						(u32) bufVA, (u32) BUFSIZE);
				if (bufVA == NULL)
				{
					log_normal (KERN_ERR "RX: AllocBuf failed\n");
					break;
				}

				pbuf->pktBuf = bufVA;
				pbuf->bufInfo = bufVA;
				pbuf->size = BUFSIZE;
			}
			spin_unlock_bh (&RawLock);

			log_verbose (KERN_INFO "Requested %d, allocated %d buffers\n", numpkts, i);
			return i;
#endif  
			return 0; 
		}

	int
		myPutTxPkt (void *hndl, PktBuf * vaddr, int numpkts, unsigned int privdata)
		{
			int i;
			unsigned int flags;
			PktBuf *pbuf = vaddr;
			static int pktSize;
			unsigned char *usrAddr = NULL;
			BufferInfo tempBuffInfo;


			/* Check driver state */
			if (xraw_DriverState != REGISTERED)
			{
				LOG_MSG ("Driver does not seem to be ready\n");
				return -1;
			}
			//    LOG_MSG(KERN_ERR"At myPutTxPkt numpkts are %d\n",numpkts);
			/* Just check if we are on the way out */
			// spin_lock_bh(&RawLock);
			for (i = 0; i < numpkts; i++)
			{
				flags = vaddr->flags;

				pbuf = vaddr;
				if(pbuf->bufPa)
					dma_unmap_page(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]->ptr_dma_desc->dev,pbuf->bufPa,\
							pbuf->size,DMA_TO_DEVICE);
				if(pbuf->pageAddr)
					page_cache_release( (struct page *)pbuf->pageAddr);

				pktSize = pktSize + pbuf->size;

				if (flags & PKT_SOP)
				{
					usrAddr = pbuf->bufInfo;
					pktSize = pbuf->size;
				}

				if (flags & PKT_EOP)
				{
					tempBuffInfo.bufferAddress = usrAddr;
					tempBuffInfo.buffSize = pktSize;
					putBuffInfo (&TxDoneQ, tempBuffInfo);
					pktSize = 0;
					usrAddr = NULL;
				}

				vaddr++;

			}

			return 0;
		}

	int
		mySetState (void *hndl, UserState * ustate, unsigned int privdata)
		{
			int val;
			int seqno;
			int regval=0;

			static unsigned int testmode;

			log_verbose (KERN_INFO "Reached mySetState with privdata %x\n", privdata);

			/* Check driver state */
			if (xraw_DriverState != REGISTERED)
			{
				LOG_MSG (KERN_ERR"Driver does not seem to be ready\n");
				return EFAULT;
			}

			/* Check handle value */
			if ((hndl != handle[0]) && (hndl != handle[2]))
			{
				LOG_MSG (KERN_ERR"Came with wrong handle\n");
				return EBADF;
			}

			/* Valid only for TX engine */
			if (privdata == 0x54545454)
			{
				spin_lock_bh (&RawLock);

				/* Set up the value to be written into the register */
				RawTestMode = ustate->TestMode;
#ifdef HOSTCONTROL 
				val = XIo_In32 (TXbarbase + ZYNQ_PS_REGISTER_OFFSET);
				mdelay(10);

				log_verbose(KERN_ERR"ZYNQ_PS_REGISTER OFFSET value is %x\n",val);
				if((val & ZYNQ_READY_MASK) == 0 )
				{
					log_verbose("Zynq PS not ready. not able to start the test\n");
					spin_unlock_bh (&RawLock);
					return EFAULT;
				}
				else
				{
					log_verbose("Zynq PS ready. Starting the test %x val\n",val );
				}
#endif
				if (RawTestMode & TEST_START)
				{
					testmode = 0;
					if (RawTestMode & ENABLE_LOOPBACK)
						testmode |= LOOPBACK;
					if (RawTestMode & ENABLE_PKTCHK)
						testmode |= PKTCHKR;
					if (RawTestMode & ENABLE_PKTGEN)
						testmode |= PKTGENR;
				}
				else
				{
					/* Deliberately not clearing the loopback bit, incase a
					 * loopback test was going on - allows the loopback path
					 * to drain off packets. Just stopping the source of packets.
					 */
					if (RawTestMode & ENABLE_PKTCHK)
						testmode &= ~PKTCHKR;
					if (RawTestMode & ENABLE_PKTGEN)
						testmode &= ~PKTGENR;

					/* enable this if we need to Disable loop back also */ 
#ifdef USE_LATER
					if (RawTestMode & ENABLE_LOOPBACK)
						testmode &= ~LOOPBACK;
#endif		
				}

				log_verbose(KERN_ERR"SetState TX with RawTestMode %x, reg value %x\n",
						RawTestMode, testmode);

#ifdef HOSTCONTROL
				if(RawTestMode & ENABLE_SOBELFILTER)
				{
					log_verbose(KERN_ERR"%s Driver: Enabling Sobel Filter mode %x\n",MYNAME,\
							testmode); 
					log_verbose (KERN_ERR"========Reg %x = %x\n", TX_CONFIG_ADDRESS, testmode);
					regval = 0;
					regval |= SOBEL_ON;
					if(RawTestMode & ENABLE_SOBELFILTER_INVERT)
					{
						regval |= SOBEL_INVERT;
						log_verbose(KERN_INFO"Enabling sobel invert\n");
					}
					regval |= ((RawTestMode & SOBEL_MIN_COEF_MASK) << SOBEL_MIN_COEF_START_BIT);
					regval |= (RawTestMode & SOBEL_MAX_COEF_MASK);
					mdelay(10);
					log_verbose(KERN_ERR"%s Driver: Writing %X into SOBELCNTRL_OFFSET\n",MYNAME,regval);
					XIo_Out32(TXbarbase + SOBELCNTRL_OFFSET,regval);
					if(RawTestMode & ENABLE_SOBELFILTER_SW) 
					{
						mdelay(10);
						log_verbose(KERN_ERR"%s Driver: Enabling Sobel Filter software mode %x\n",MYNAME,\
								testmode); 
						XIo_Out32(TXbarbase + SOBELOFFLOAD_CNTRL_OFFSET,SOBEL_SW_PROCESSING);
						mdelay(10);
						val = XIo_In32 (TXbarbase + SOBELOFFLOAD_CNTRL_OFFSET);
						log_verbose(KERN_INFO"XXXX %s Driver:Enabling Sobel Filter Software mode %x val is %x\n",MYNAME,\
								testmode,val);         
					}
					else
					{
						mdelay(10);
						log_verbose(KERN_INFO"%s Driver: Enabling Sobel Filter Hardware mode %x\n",MYNAME,\
								testmode); 
						XIo_Out32(TXbarbase + SOBELOFFLOAD_CNTRL_OFFSET,SOBEL_HW_PROCESSING);
						mdelay(10);
						val = XIo_In32 (TXbarbase + SOBELOFFLOAD_CNTRL_OFFSET);
						log_verbose(KERN_INFO"XXXX %s Driver:Enabling Sobel Filter Hardware mode %x val is %x\n",MYNAME,\
								testmode,val);         
					}

				}
				else
				{
					log_verbose(KERN_INFO"%s Driver: Disabling Sobel Filter mode %x\n",MYNAME,\
							testmode); 
					mdelay(10);
					XIo_Out32(TXbarbase + SOBELCNTRL_OFFSET,SOBEL_OFF );         
				}
				if(RawTestMode & ENABLE_VIDEOLOOPBACK)
				{
					mdelay(10);
					log_verbose(KERN_INFO"%s Driver:Enabling VideoLoopback mode %x\n",MYNAME,\
							testmode);         
					XIo_Out32(TXbarbase + DISPLAYCNTRL_OFFSET,LOOPVIDEO_BACK);          
					mdelay(10);
					val = XIo_In32 (TXbarbase + DISPLAYCNTRL_OFFSET);
					log_verbose(KERN_INFO"XXXX %s Driver:Enabling VideoLoopback mode %x val is %x\n",MYNAME,\
							testmode,val);         
				} 
				else
				{
					mdelay(10);
					log_verbose(KERN_INFO"%s Driver:Displaying Video on CVC %x\n",MYNAME,\
							testmode);         

					XIo_Out32(TXbarbase + DISPLAYCNTRL_OFFSET,DISPLAY_ON_CVC);          
				}
				mdelay(10);
#endif
				/* Now write the registers */
				if (RawTestMode & TEST_START)
				{
					if (!
							(RawTestMode &
							 (ENABLE_PKTCHK | ENABLE_PKTGEN | ENABLE_LOOPBACK)))
					{
						LOG_MSG (KERN_ERR"%s Driver: TX Test Start called with wrong mode %x\n",
								MYNAME, testmode);
						RawTestMode = 0;
						spin_unlock_bh (&RawLock);
						return EBADRQC;
					}

					log_verbose(KERN_INFO"%s Driver: Starting the test - mode %x, reg %x\n",
							MYNAME, RawTestMode, testmode);

					/* Next, set packet sizes. Ensure they don't exceed PKTSIZEs */
					RawMinPktSize = ustate->MinPktSize;
					RawMaxPktSize = ustate->MaxPktSize;

					/* Set RX packet size for memory path */
					val = RawMaxPktSize;
					log_verbose(KERN_INFO"Reg %x = %x\n", PKT_SIZE_ADDRESS, val);
					RawMinPktSize = RawMaxPktSize = val;
					/* Now ensure the sizes remain within bounds */
					if (RawMaxPktSize > MAXPKTSIZE)
						RawMinPktSize = RawMaxPktSize = MAXPKTSIZE;
					if (RawMinPktSize < MINPKTSIZE)
						RawMinPktSize = RawMaxPktSize = MINPKTSIZE;
					if (RawMinPktSize > RawMaxPktSize)
						RawMinPktSize = RawMaxPktSize;
					val = RawMaxPktSize;
					log_verbose("========Reg %x = %d\n",DESIGN_MODE_ADDRESS, PERF_DESIGN_MODE);
					XIo_Out32 (TXbarbase + DESIGN_MODE_ADDRESS,PERF_DESIGN_MODE);
					log_verbose("DESIGN MODE %d\n",PERF_DESIGN_MODE );
					seqno= TX_CONFIG_SEQNO;
					log_verbose("========Reg %x = %d\n",SEQNO_WRAP_REG, seqno);
					XIo_Out32 (TXbarbase + SEQNO_WRAP_REG , seqno);
					log_verbose("SeqNo Wrap around %d\n", seqno);

					mdelay(1); 


					/* Incase the last test was a loopback test, that bit may not be cleared. */
					//XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, 0);
					if (RawTestMode & (ENABLE_PKTCHK | ENABLE_LOOPBACK))
					{

						log_verbose("========Reg %x = %x\n", TX_CONFIG_ADDRESS, testmode);
						//XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, testmode);
					}
					if (RawTestMode & ENABLE_PKTGEN)
					{
						log_verbose("========Reg %x = %x\n", RX_CONFIG_ADDRESS, testmode);
						//	      XIo_Out32 (TXbarbase + RX_CONFIG_ADDRESS, testmode);
					}
#ifdef HOSTCONTROL
					mdelay(10);
					val = XIo_In32 (TXbarbase + HOST_STATUS_OFFSET);
					mdelay(10);
					log_verbose(KERN_ERR"Obtained val %x at HOST_STATUS_OFFSET will be setting TEST START soon\n",val);
					val = val | ZYNQ_TEST_START_MASK; 
					mdelay(10);
					XIo_Out32 (TXbarbase +HOST_STATUS_OFFSET,val);
#endif
				}
				/* Else, stop the test. Do not remove any loopback here because
				 * the DMA queues and hardware FIFOs must drain first.
				 */
				else
				{
					log_verbose(KERN_ERR"%s Driver: Stopping the test, mode %x\n", MYNAME,
							testmode);
					log_verbose ("========Reg %x = %x\n", TX_CONFIG_ADDRESS, testmode);
					mdelay(50);   
					//XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, testmode);
					mdelay(10);
					//	  LOG_MSG ("========Reg %x = %x\n", RX_CONFIG_ADDRESS, testmode);
					//	  XIo_Out32 (TXbarbase + RX_CONFIG_ADDRESS, testmode);
					mdelay(10);
#ifdef HOSTCONTROL
					val = XIo_In32 (TXbarbase + HOST_STATUS_OFFSET);
					val = val & ZYNQ_TEST_STOP_MASK; 
					log_verbose(KERN_ERR"Obtained val %x at HOST_STATUS_OFFSET will be setting TEST STOP soon\n",val);
					mdelay(10);
					XIo_Out32 (TXbarbase +HOST_STATUS_OFFSET,val);
#endif


				}

				PrintSummary ();
				spin_unlock_bh (&RawLock);
			}
			return 0;
		}

	int
		myGetState (void *hndl, UserState * ustate, unsigned int privdata)
		{
			static int iter = 0;

			log_verbose ("Reached myGetState with privdata %x\n", privdata);

			/* Same state is being returned for both engines */

			ustate->LinkState = LINK_UP;
			ustate->DataMismatch= XIo_In32 (TXbarbase + STATUS_ADDRESS);
			ustate->MinPktSize = RawMinPktSize;
			ustate->MaxPktSize = RawMaxPktSize;
			ustate->TestMode = RawTestMode;
			if (privdata == 0x54545454)
				ustate->Buffers = TxBufs.TotalNum;
			else
				ustate->Buffers = RxBufs.TotalNum;

			if (iter++ >= 4)
			{
				PrintSummary ();

				iter = 0;
			}

			return 0;
		}


#define QSUCCESS 0
#define QFAILURE -1

	/* 
	   putBuffInfo is used for adding an buffer element to the queue.
	   it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/

	int
		putBuffInfo (BufferInfoQue * bQue, BufferInfo buff)
		{

			// assert (bQue != NULL)

			int currentIndex = 0;
			spin_lock_bh (&(bQue->iLock));

			currentIndex = (bQue->iPutIndex + 1) % MAX_BUFF_INFO;

			if (currentIndex == bQue->iGetIndex)
			{
				spin_unlock_bh (&(bQue->iLock));
				LOG_MSG (KERN_ERR "%s: BufferInfo Q is FULL in XRAW0 , drop the incoming buffers",
						__func__);
				return QFAILURE;		// array full
			}

			bQue->iPutIndex = currentIndex;

			bQue->iList[bQue->iPutIndex] = buff;
			bQue->iPendingDone++;

			if(bQue == &RxDoneQ)
			{
				if((impl_bp == NO_BP)&& ( bQue->iPendingDone > MAX_QUEUE_THRESHOLD))
				{
					impl_bp = YES_BP;
					LOG_MSG(KERN_ERR "XXXXXX Maximum Queue Threshold reached.Turning on BACK PRESSURE XRAW0 %d  \n",
							bQue->iPendingDone);
				} 
			}
			spin_unlock_bh (&(bQue->iLock));
			return QSUCCESS;
		}

	/*
	   getBuffInfo is used for fetching the oldest buffer info from the queue.
	   it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/
	int
		getBuffInfo (BufferInfoQue * bQue, BufferInfo * buff)
		{
			// assert if bQue is NULL
			if (!buff || !bQue)
			{
				LOG_MSG (KERN_ERR "%s: BAD BufferInfo pointer", __func__);
				return QFAILURE;
			}
			spin_lock_bh (&(bQue->iLock));

			// assuming we get the right buffer
			if (!bQue->iPendingDone)
			{
				spin_unlock_bh (&(bQue->iLock));
				log_verbose(KERN_ERR "%s: BufferInfo Q is Empty",__func__);
				return QFAILURE;
			}

			bQue->iGetIndex++;
			bQue->iGetIndex %= MAX_BUFF_INFO;
			*buff = bQue->iList[bQue->iGetIndex];
			bQue->iPendingDone--;

			if(bQue == &RxDoneQ) 
			{
				if((impl_bp == YES_BP) && (bQue->iPendingDone < MIN_QUEUE_THRESHOLD))
				{
					impl_bp = NO_BP;
					LOG_MSG(KERN_ERR "XXXXXXX Minimum Queue Threshold reached.Turning off Back Pressure at %d %s\n",
							__LINE__,__FILE__);
				}
			}

			spin_unlock_bh (&(bQue->iLock));

			return QSUCCESS;

		}

	void get_dma_lock(void)
	{
		//    spin_lock(&dma_lock);
	}
	void release_dma_lock(void)
	{
		//    spin_unlock(&dma_lock);
	}
#define WRITE_TO_CARD   0	
#define READ_FROM_CARD  1	

#ifdef PFORM_USCALE_NO_EP_PROCESSOR

	//- Function for Bridge initialization over PCIe for application logic
	static void InitBridge_App (u64 bar0_addr, u32 bar0_addr_p, u64 bar2_addr, u32 bar2_addr_p)
	{

		//LOG_MSG(KERN_ERR"bar0_addr_virtual = %lx bar0_physical_addr = %X bar2_virtual_address = %lx bar2_physical_adr = %X\n",bar0_addr,bar0_addr_p,bar2_addr,bar2_addr_p);
		InitVdma(bar0_addr,bar0_addr_p,bar2_addr,bar2_addr_p);
		InitSobel(bar0_addr,bar0_addr_p,bar2_addr,bar2_addr_p);
	}

	static void InitVdma (u64 bar0_addr, u32 bar0_addr_p, u64 bar2_addr, u32 bar2_addr_p)
	{
		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_VDMACR,MM2S_VDMACR_RESET_VAL);
		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_VDMACR,S2MM_VDMACR_RESET_VAL);


		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_VDMACR,MM2S_VDMACR_RUN_VAL);
		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_VDMACR,S2MM_VDMACR_RUN_VAL);

		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_VDMACR,S2MM_VDMACR_VAL);
		LOG_MSG(KERN_ERR"S2MM_VDMACR = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + S2MM_VDMACR));
		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_START_ADDR1,psDstQsRangeRx[0].frame_start_address);
		LOG_MSG(KERN_ERR"S2MM_START_ADDR1 = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + S2MM_START_ADDR1));
		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_START_ADDR2,psDstQsRangeRx[1].frame_start_address);
		LOG_MSG(KERN_ERR"S2MM_START_ADDR2 = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + S2MM_START_ADDR2));
		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_START_ADDR3,psDstQsRangeRx[2].frame_start_address);
		LOG_MSG(KERN_ERR"S2MM_START_ADDR3 = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + S2MM_START_ADDR3));

		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_FRMDLY_STRIDE,S2MM_FRMDLY_STRIDE_VAL);
		LOG_MSG(KERN_ERR"S2MM_FRMDLY_STRIDE = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + S2MM_FRMDLY_STRIDE));
		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_HSIZE,S2MM_HSIZE_VAL);
		LOG_MSG(KERN_ERR"S2MM_HSIZE = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + S2MM_HSIZE));
		XIo_Out32(bar2_addr + VDMA_OFFSET + S2MM_VSIZE,S2MM_VSIZE_VAL);
		LOG_MSG(KERN_ERR"S2MM_VSIZE = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + S2MM_VSIZE));


		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_VDMACR,MM2S_VDMACR_VAL);
		LOG_MSG(KERN_ERR"MM2S_VDMACR = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + MM2S_VDMACR));
		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_START_ADDR1,psDstQsRangeTx[0].frame_start_address);
		LOG_MSG(KERN_ERR"MM2S_START_ADDR1 = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + MM2S_START_ADDR1));
		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_START_ADDR2,psDstQsRangeTx[1].frame_start_address);
		LOG_MSG(KERN_ERR"MM2S_START_ADDR2 = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + MM2S_START_ADDR2));
		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_START_ADDR3,psDstQsRangeTx[2].frame_start_address);
		LOG_MSG(KERN_ERR"MM2S_START_ADDR3 = %x\n",  XIo_In32(bar2_addr + VDMA_OFFSET + MM2S_START_ADDR3));

		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_FRMDLY_STRIDE,MM2S_FRMDLY_STRIDE_VAL);
		LOG_MSG(KERN_ERR"MM2S_FRMDLY_STRIDE = %x\n", XIo_In32(bar2_addr + VDMA_OFFSET + MM2S_FRMDLY_STRIDE));
		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_HSIZE,MM2S_HSIZE_VAL);
		LOG_MSG(KERN_ERR"MM2S_HSIZE = %x\n", XIo_In32(bar2_addr + VDMA_OFFSET + MM2S_HSIZE));
		XIo_Out32(bar2_addr + VDMA_OFFSET + MM2S_VSIZE,MM2S_VSIZE_VAL);
		LOG_MSG(KERN_ERR"MM2S_VSIZE = %x\n", XIo_In32(bar2_addr + VDMA_OFFSET + MM2S_VSIZE));


	}

	static void InitSobel (u64 bar0_addr, u32 bar0_addr_p, u64 bar2_addr, u32 bar2_addr_p)
	{
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_CNTL_STS_REG,SOBEL_CNTL_STS_REG_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_NO_OF_ROWS,SOBEL_NO_OF_ROWS_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_NO_OF_COLS,SOBEL_NO_OF_COLS_VAL);

		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR0C0,SOBEL_XR0C0_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR0C1,SOBEL_XR0C1_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR0C2,SOBEL_XR0C2_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR1C0,SOBEL_XR1C0_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR1C1,SOBEL_XR1C1_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR1C2,SOBEL_XR1C2_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR2C0,SOBEL_XR2C0_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR2C1,SOBEL_XR2C1_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_XR2C2,SOBEL_XR2C2_VAL);

		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR0C0,SOBEL_YR0C0_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR0C1,SOBEL_YR0C1_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR0C2,SOBEL_YR0C2_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR1C0,SOBEL_YR1C0_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR1C1,SOBEL_YR1C1_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR1C2,SOBEL_YR1C2_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR2C0,SOBEL_YR2C0_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR2C1,SOBEL_YR2C1_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_YR2C2,SOBEL_YR2C2_VAL);


		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_HIGH_THRESHOLD,SOBEL_HIGH_THRESHOLD_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_LOW_THRESHOLD,SOBEL_LOW_THRESHOLD_VAL);
		XIo_Out32(bar2_addr + SOBEL_OFFSET + SOBEL_INVERT_REG,SOBEL_INVERT_VAL);

		LOG_MSG(KERN_ERR"SOBEL_CNTL_REG=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_CNTL_STS_REG));
		LOG_MSG(KERN_ERR"SOBEL_NO_OF_ROWS=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_NO_OF_ROWS));
		LOG_MSG(KERN_ERR"SOBEL_NO_OF_COLS=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_NO_OF_COLS));
		LOG_MSG(KERN_ERR"SOBEL_XR0C0=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR0C0));
		LOG_MSG(KERN_ERR"SOBEL_XR0C1=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR0C1));
		LOG_MSG(KERN_ERR"SOBEL_XR0C2=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR0C2));
		LOG_MSG(KERN_ERR"SOBEL_XR1C0=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR1C0));
		LOG_MSG(KERN_ERR"SOBEL_XR1C1=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR1C1));
		LOG_MSG(KERN_ERR"SOBEL_XR1C2=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR1C2));
		LOG_MSG(KERN_ERR"SOBEL_XR2C0=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR2C0));
		LOG_MSG(KERN_ERR"SOBEL_XR2C1=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR2C1));
		LOG_MSG(KERN_ERR"SOBEL_XR2C2=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_XR2C2));
		LOG_MSG(KERN_ERR"SOBEL_YR0C0=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR0C0));
		LOG_MSG(KERN_ERR"SOBEL_YR0C1=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR0C1));
		LOG_MSG(KERN_ERR"SOBEL_YR0C2=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR0C2));
		LOG_MSG(KERN_ERR"SOBEL_YR1C0=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR1C0));
		LOG_MSG(KERN_ERR"SOBEL_YR1C1=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR1C1));
		LOG_MSG(KERN_ERR"SOBEL_YR1C2=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR1C2));
		LOG_MSG(KERN_ERR"SOBEL_YR2C0=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR2C0));
		LOG_MSG(KERN_ERR"SOBEL_YR2C1=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR2C1));
		LOG_MSG(KERN_ERR"SOBEL_YR2C2=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_YR2C2));
		LOG_MSG(KERN_ERR"SOBEL_HIGH_THRESHOLD=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_HIGH_THRESHOLD));
		LOG_MSG(KERN_ERR"SOBEL_HIGH_THRESHOLD=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_LOW_THRESHOLD));
		LOG_MSG(KERN_ERR"SOBEL_INVERT_REG=%x\n",XIo_In32(bar2_addr + SOBEL_OFFSET + SOBEL_INVERT_REG));
	}


	static void c2s_processed_fr_tsmt (struct work_struct *work)
	{
		int retval = 0, state = 0,i=0;
		dma_addr_t paddr_buf;
		unsigned short uid = 1;

		index %= NUM_FRAMES_IN_PLDDR;

#ifdef DMA_LOOPBACK
		paddr_buf = psDstQsRangeTx[index].frame_start_address; 
#else
		paddr_buf = psDstQsRangeRx[index].frame_start_address; 
#endif

		LOCK_DMA_CHANNEL(&ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]->channel_lock);

#ifdef SINGLE_RX_AUX_DST_ELEMENT

#ifdef TX_RX_SYNC
		uid = RX_FRAME_SYNC_SIGNATURE;
#endif

		retval = xlnx_data_frag_io(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID],(unsigned char *)paddr_buf,addr_typ_aux_transfer[VIDEO_RX_CHANNEL_ID],\
				VIDEO_FRAME_SIZE,cbk_receive_video_dst, uid, true, (void *)paddr_buf);

		if(retval < XLNX_SUCCESS)
		{
			state = ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]->chann_state;

#ifdef PUMP_APP_DBG_PRNT
			LOG_MSG(KERN_ERR"\nFailed::::::Buffer allocated transmit %d\n", retval);
#endif
			if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED)
			{
#ifdef PUMP_APP_DBG_PRNT
				LOG_MSG(KERN_ERR"\n- Context Q saturated %d\n",state);
#endif
				ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]->chann_state = XLNX_DMA_CHANN_NO_ERR;
				//      set_task_state(current, TASK_INTERRUPTIBLE);
			}

		}
		else
		{
			//      LOG_MSG(KERN_ERR"Programmed %p for Rx Aux Channel\n",paddr_buf);
			paddr_buf += VIDEO_FRAME_SIZE;

		}
#else

		for(i=0; i < FRAME_PIXEL_ROWS; i++)
		{
#ifdef TX_RX_SYNC
			if(i == (FRAME_PIXEL_ROWS - 1))
			{
				uid = RX_FRAME_SYNC_SIGNATURE;
			}
#endif
			retval = xlnx_data_frag_io(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID],(unsigned char *)paddr_buf,addr_typ_aux_transfer[VIDEO_RX_CHANNEL_ID],\
					MAXPKTSIZE,cbk_receive_video_dst, uid, true, (void *)i);

			if(retval < XLNX_SUCCESS)
			{
				state = ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]->chann_state;

#ifdef PUMP_APP_DBG_PRNT
				LOG_MSG(KERN_ERR"\n- Failed::::::Buffer allocated transmit %d\n", retval);
#endif
				if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED)
				{
#ifdef PUMP_APP_DBG_PRNT
					LOG_MSG(KERN_ERR"\n- Context Q saturated %d\n",state);
#endif
					ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]->chann_state = XLNX_DMA_CHANN_NO_ERR;
					//      set_task_state(current, TASK_INTERRUPTIBLE);
				}

			}
			else
			{
				//      LOG_MSG(KERN_ERR"Programmed %p for Rx Aux Channel\n",paddr_buf);
				paddr_buf += MAXPKTSIZE;

			}

		}
#endif
		UNLOCK_DMA_CHANNEL(&ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]->channel_lock);

		index ++;

		return;
	}

	static void c2s_fr_tsmt_init_cbk(struct _ps_pcie_dma_chann_desc *p_chan,
			unsigned int *p_data, unsigned int count)
	{

		//    LOG_MSG(KERN_ERR"Rx Aux Doorbell interrupt received\n");
		if(xraw_DriverState != UNREGISTERED)			
			queue_work(rx_dst_workq, &(rx_dst_work));

		return;
	}

#endif

	int transfer_pixel_row(void * hndl, char * buffer, size_t length, char frame_delimiter, char frame_sync)   
	{
		int j;
		int total, result;
		int offset;                
		unsigned int allocPages;   
		unsigned long first, last; 
		int numFrags = 0;
		bool last_frag = false;
		void *ptr_ctx = NULL;
		unsigned short uid = 1;
		int retval;
		dma_addr_t paddr_buf;
		struct page** cachePages;  
		PktBuf *pbuf;
		PktBuf **pkts;

		total = 0;
		result = 0;

		//  LOG_MSG(KERN_ERR "Transferring 1 row of data\n");
		/****************************************************************/
		// SECTION 1: generate CACHE PAGES for USER BUFFER
		//
		offset = offset_in_page(buffer);
		first = ((unsigned long)buffer & PAGE_MASK) >> PAGE_SHIFT;
		last  = (((unsigned long)buffer + length-1) & PAGE_MASK) >> PAGE_SHIFT;
		allocPages = (last-first)+1;

		if(tx_channel_num_empty_bds < allocPages)
		{
			LOG_MSG(KERN_ERR"Transmit side bds %d Required bds are %d. Not initiating Tx transfer.\n",tx_channel_num_empty_bds,allocPages);
			return -1;
		}

		pkts = kzalloc( allocPages * (sizeof(PktBuf*)), GFP_ATOMIC);
		if(pkts == NULL)
		{
			LOG_MSG(KERN_ERR "Error: unable to allocate memory for pkts\n");
			return -1;
		}
		cachePages = kzalloc( (allocPages * (sizeof(struct page*))), GFP_ATOMIC);
		if( cachePages == NULL )
		{
			LOG_MSG(KERN_ERR "Error: unable to allocate memory for cachePages\n");
			kfree(pkts);
			return -1;
		}

		for (j=0; j<allocPages; j++) {
			pbuf = kzalloc( (sizeof(PktBuf)), GFP_ATOMIC);

			if(pbuf == NULL) {
				LOG_MSG(KERN_ERR "Insufficient Memory !!\n");
				for(j--; j>=0; j--)
					kfree(pkts[j]);
				for(j=0; j<allocPages; j++)
					page_cache_release(cachePages[j]);
				kfree(pkts);
				kfree(cachePages);
				return -1;
			}
			pkts[j] = pbuf;
			cachePages[j] = virt_to_page(buffer + (j * PAGE_SIZE));
			page_cache_get(cachePages[j]);
			if (0 == j) {
				pbuf->size = (PAGE_SIZE - offset);
			} else {
				if (j == (allocPages -1)) {
					pbuf->size = length - total; //TODO total
				} else {
					pbuf->size = (PAGE_SIZE);
				}
			}
			pbuf->pktBuf = (unsigned char*)cachePages[j];
			pbuf->pageOffset = (j == 0) ? offset : 0;
			pbuf->bufInfo = (unsigned char *) buffer + total;
			pbuf->pageAddr= (unsigned char*)cachePages[j];
			pbuf->userInfo = length;
			pbuf->flags = PKT_ALL;
			ptr_ctx = (void *)pkts;
			if(j == 0)
			{
				pbuf->flags |= PKT_SOP;
				if(frame_delimiter)
					pbuf->userInfo |= (1<<FRAME_DELITER_BIT);
				ptr_ctx = (void *)pkts;
			}
			if(j == (allocPages - 1) )
			{
				pbuf->flags |= PKT_EOP;
				last_frag = true;
				if(frame_sync == 1)
				{
					uid = TX_FRAME_SYNC_SIGNATURE;
				}
				ptr_ctx = (void *)pkts;
			}
			if(tx_channel_num_empty_bds)
			{
				paddr_buf = dma_map_page(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]->ptr_dma_desc->dev,cachePages[j],\
						pbuf->pageOffset, pbuf->size, DMA_TO_DEVICE);
				pbuf->bufPa = paddr_buf;
				LOCK_DMA_CHANNEL(&ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]->channel_lock);
				retval = xlnx_data_frag_io(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID],(unsigned char *)paddr_buf ,addr_typ_transfer[VIDEO_TX_CHANNEL_ID],\
						pbuf->size ,cbk_transfer_video_row ,uid, last_frag, ptr_ctx);

				if(retval < XLNX_SUCCESS) 
				{
					int state = ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]->chann_state;

					//spin_unlock_irqrestore(&chann->channel_lock, flags);
#ifdef PUMP_APP_DBG_PRNT
					LOG_MSG(KERN_ERR"\n- Failed::::::Buffer allocated transmit %d\n", retval);
#endif
					if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
					{
#ifdef PUMP_APP_DBG_PRNT
						LOG_MSG(KERN_ERR"\n- Context Q saturated %d\n",state);
#endif
						ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]->chann_state = XLNX_DMA_CHANN_NO_ERR;
						//	set_task_state(current, TASK_INTERRUPTIBLE);  
						UNLOCK_DMA_CHANNEL(&ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]->channel_lock);
					}

				}
				else
				{
					total += pbuf->size;
					tx_channel_num_empty_bds--;
					UNLOCK_DMA_CHANNEL(&ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]->channel_lock);
					numFrags++;
				}
			}
		}
		kfree(cachePages);
		//  result = DmaSendPages_Tx (hndl, pkts, allocPages);
		return numFrags;
	}

	void cbk_transfer_video_row(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,\
			unsigned short uid, unsigned int num_frags)
	{

		int i;
		PktBuf **pkts = (PktBuf **)data;
		PktBuf *pbuf;
		unsigned int flags;
		BufferInfo tempBuffInfo;
		int pktSize = 0;
		unsigned char *usrAddr = NULL;


		//LOG_MSG(KERN_ERR"Received Callback with data = %p and num_frags = %d\n",data,num_frags);
		//LOG_MSG(KERN_ERR"*Tx%d\n",++count);
		//
		//count++;
		if(data == NULL)
		{
			LOG_MSG(KERN_ERR"Null data received in Tx callback number %d\n",count);
			tx_channel_num_empty_bds += num_frags;
			return ;
		}

		// spin_lock(&TxLock);
		tx_channel_num_empty_bds += num_frags;
		// spin_unlock(&TxLock);
		for(i=0; i<num_frags; i++)
		{
			pbuf = *(pkts + i);
			flags = pbuf->flags;
			// LOG_MSG(KERN_ERR"Received callback with physical_address = %p and ptr_data = %p\n",pbuf->bufPa,pkts);
			if(pbuf->bufPa)
				dma_unmap_page(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]->ptr_dma_desc->dev,pbuf->bufPa,\
						pbuf->size,DMA_TO_DEVICE);
			if(pbuf->pageAddr)
				page_cache_release((struct page *)pbuf->pageAddr);

			pktSize = pktSize + pbuf->size;

			if (flags & PKT_SOP)
			{
				usrAddr = pbuf->bufInfo;
				pktSize = pbuf->size;
			}

			if (flags & PKT_EOP)
			{
				tempBuffInfo.bufferAddress = usrAddr;
				tempBuffInfo.buffSize = pktSize;
				putBuffInfo (&TxDoneQ, tempBuffInfo);
			}
		}
		for(i=0; i<num_frags; i++) {
			kfree(pkts[i]);
		}
		kfree(pkts);

	}


#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	void cbk_transfer_video_dst_row(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,\
			unsigned short uid, unsigned int num_frags)
	{
		dma_addr_t paddr_buf;
		int retval;
		int state;
		static int flag = 0;


		//LOG_MSG(KERN_ERR"*TxDst %d\n",++count);

		if(uid == TX_FRAME_SYNC_SIGNATURE)
		{
#ifdef DMA_LOOPBACK
			if(xraw_DriverState != UNREGISTERED)			
				queue_work(rx_dst_workq, &(rx_dst_work));
#else
			//LOG_MSG(KERN_ERR"Generating FSYNC\n");
			XIo_Out32(ptr_dma_desc->dma_reg_virt_base_addr + DMA_AXI_INTR_ASSRT_REG_OFFSET,0x08);
			//LOG_MSG(KERN_ERR"VDMA INTr register @(0x74) : %x \n", XIo_In32(ptr_dma_desc->dma_reg_virt_base_addr + DMA_AXI_INTR_ASSRT_REG_OFFSET));
			if(flag<1)
			{
				LOG_MSG("MM2S_VDMACR @(0x00) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + MM2S_VDMACR));
				LOG_MSG("MM2S_FRMDLY @(0x58) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + MM2S_FRMDLY_STRIDE));
				LOG_MSG("MM2S_HSIZE  @(0x54) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + MM2S_HSIZE));
				LOG_MSG("MM2S_VSIZE  @(0x50) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + MM2S_VSIZE));
				LOG_MSG("MM2S_ADDR1  @(0x5C) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + MM2S_START_ADDR1));
				LOG_MSG("MM2S_ADDR2  @(0x60) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + MM2S_START_ADDR2));
				LOG_MSG("MM2S_ADDR3  @(0x64) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + MM2S_START_ADDR3));

				LOG_MSG("S2MM_VDMACR @(0x30) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + S2MM_VDMACR));
				LOG_MSG("S2MM_FRMDLY @(0xA8) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + S2MM_FRMDLY_STRIDE));
				LOG_MSG("S2MM_HSIZE  @(0xA4) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + S2MM_HSIZE));
				LOG_MSG("S2MM_VSIZE  @(0xA0) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + S2MM_VSIZE));
				LOG_MSG("S2MM_ADDR1  @(0xAC) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + S2MM_START_ADDR1));
				LOG_MSG("S2MM_ADDR2  @(0xB0) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + S2MM_START_ADDR2));
				LOG_MSG("S2MM_ADDR3  @(0xB4) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + S2MM_START_ADDR3));
				flag++;
			}
# if 0
			LOG_MSG("MM2S_VDMASR @(0x04) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + MM2S_VDMASR));
			LOG_MSG("S2MM_VDMASR @(0x34) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + S2MM_VDMASR));
			LOG_MSG("PARK_PTR_REG @(0x28) : %x \n", XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + VDMA_OFFSET + PARK_PTR_REG));
#endif
#endif
		}
		// paddr_buf = (dma_addr_t)(psDstQsRangeTx[0].frame_start_address +  (val * MAXPKTSIZE));
		paddr_buf = (dma_addr_t)(data);
		retval = xlnx_data_frag_io(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID],(unsigned char *)paddr_buf,addr_typ_aux_transfer[VIDEO_TX_CHANNEL_ID],\
				MAXPKTSIZE,cbk_transfer_video_dst_row ,uid, true, data);

		if(retval < XLNX_SUCCESS) 
		{
			state = ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->chann_state;

#ifdef PUMP_APP_DBG_PRNT
			LOG_MSG(KERN_ERR"\n- Failed::::::Buffer allocated transmit %d\n", retval);
#endif
			if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
			{
#ifdef PUMP_APP_DBG_PRNT
				LOG_MSG(KERN_ERR"\n- Context Q saturated %d\n",state);
#endif
				ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->chann_state = XLNX_DMA_CHANN_NO_ERR;
				//	set_task_state(current, TASK_INTERRUPTIBLE);  
			}

		}
		else
		{
			// LOG_MSG(KERN_ERR"Programmed %p for Tx Aux Queue in the callback with data as %p.\n",paddr_buf,data);

		}
	}
#endif

	void cbk_receive_video(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,\
			unsigned short uid, unsigned int num_frags)
	{
		int i;
		PktBuf **pkts = (PktBuf **)data;
		PktBuf *pbuf;
		unsigned int flags;
		BufferInfo tempBuffInfo;
		int pktSize = 0;
		unsigned char *usrAddr = NULL;
		int noPages=0;


		//  LOG_MSG(KERN_ERR"Received %d Callback with data = %p , num_frags = %d and compl_bytes = %d\n",++count,data,num_frags,compl_bytes);
		//  LOG_MSG(KERN_ERR"#Rx%d\n",++count);
		if(data == NULL)
		{
			LOG_MSG(KERN_ERR"NULL data pointer received in Rx for callback number %d\n",count);
			rx_channel_num_empty_bds += num_frags;
			return;
		}
		//  spin_lock(&RxLock);
		rx_channel_num_empty_bds += num_frags;
		//  spin_unlock(&RxLock);

		//  myPutRxPkt (data, pkts[0], num_frags, 0);

		for(i=0; i<num_frags; i++)
		{
			pbuf = *(pkts + i);
			flags = pbuf->flags;
			// LOG_MSG(KERN_ERR"Received callback with physical_address = %p and ptr_data = %p\n",pbuf->bufPa,pkts);
			if(pbuf->bufPa)
				dma_unmap_page(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]->ptr_dma_desc->dev,pbuf->bufPa,\
						pbuf->size,DMA_FROM_DEVICE);
			if(pbuf->pageAddr)
				page_cache_release( (struct page *)pbuf->pageAddr);

			pktSize = pktSize + pbuf->size;

			if (flags & PKT_SOP)
			{
				usrAddr = pbuf->bufInfo;
				pktSize = pbuf->size;
			}

			noPages++;
			if (flags & PKT_EOP)
			{
				tempBuffInfo.bufferAddress = usrAddr;
				tempBuffInfo.buffSize = pktSize;
				tempBuffInfo.noPages= noPages ;  
				tempBuffInfo.endAddress= pbuf->bufInfo;
				tempBuffInfo.endSize=pbuf->size;
				putBuffInfo (&RxDoneQ, tempBuffInfo);
			}
		}
		for(i=0; i<num_frags; i++) {
			kfree(pkts[i]);
		}
		kfree(pkts);
	}

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	void cbk_receive_video_dst(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,\
			unsigned short uid, unsigned int num_frags)
	{

#ifdef TX_RX_SYNC
		if(uid == RX_FRAME_SYNC_SIGNATURE)
		{

			//       LOG_MSG(KERN_ERR"Setting pushback status to Progress");

			spin_lock(&sync_lock);
			s2c_pushback_status = PROGRESS; 
			spin_unlock(&sync_lock);
		}
#endif
		//LOG_MSG(KERN_ERR"#Rxdst%d\n",++count);

	}
#endif

	int DmaSetupReceive(const char __user * buffer, size_t length)
	{
		int j;
		int total, result = -1;
		PktBuf * pbuf;
		int status;
		int offset;
		unsigned int allocPages;
		unsigned long first, last;
		struct page** cachePages;
		PktBuf **pkts;

		/* Check driver state */
		if(xraw_DriverState != REGISTERED) {
			LOG_MSG("Driver does not seem to be ready\n");
			return 0;
		}
		total = 0;

		/****************************************************************/
		// SECTION 1: generate CACHE PAGES for USER BUFFER
		//
		offset = offset_in_page(buffer);
		first = ((unsigned long)buffer & PAGE_MASK) >> PAGE_SHIFT;
		last  = (((unsigned long)buffer + length-1) & PAGE_MASK) >> PAGE_SHIFT;
		allocPages = (last-first)+1;

		pkts = kzalloc( allocPages * (sizeof(PktBuf*)), GFP_ATOMIC);
		if(pkts == NULL)
		{
			LOG_MSG(KERN_ERR "Error: unable to allocate memory for pkts\n");
			return -1;
		}
		cachePages = kzalloc( (allocPages * (sizeof(struct page*))), GFP_ATOMIC);
		if( cachePages == NULL )
		{
			LOG_MSG(KERN_ERR "Error: unable to allocate memory for cachePages\n");
			kfree(pkts);
			return -1;
		}
		//  memset(cachePages, 0, sizeof(allocPages * sizeof(struct page*)) );
		down_read(&(current->mm->mmap_sem));
		status = get_user_pages(current,        // current process id
				current->mm,                // mm of current process
				(unsigned long)buffer,      // user buffer
				allocPages,
				READ_FROM_CARD,
				0,                          /* don't force */
				cachePages,
				NULL);
		up_read(&current->mm->mmap_sem);
		if( status < allocPages) {
			LOG_MSG(KERN_ERR ".... Error: requested pages=%d, granted pages=%d ....\n", allocPages, status);
			for(j=0; j<status; j++)
				page_cache_release(cachePages[j]);
			kfree(pkts);
			kfree(cachePages);
			return -1;
		}

		allocPages = status;	// actual number of pages system gave
		for(j=0; j< allocPages; j++)		/* Packet fragments loop */
		{
			pbuf = kzalloc( (sizeof(PktBuf)), GFP_ATOMIC);

			if(pbuf == NULL) {
				LOG_MSG(KERN_ERR "Insufficient Memory !!\n");
				for(j--; j>=0; j--)
					kfree(pkts[j]);
				for(j=0; j<allocPages; j++)
					page_cache_release(cachePages[j]);
				kfree(pkts);
				kfree(cachePages);
				return -1;
			}

			//spin_lock_bh(&RawLock);
			pkts[j] = pbuf;

			// first buffer would start at some offset, need not be on page boundary
			if(j==0) {
				pbuf->size = ((PAGE_SIZE)-offset);
				LOG_MSG (KERN_INFO "Pbuf Offset: %d\n", pbuf->pageOffset);
			}
			else {
				if(j == (allocPages-1)) {
					pbuf->size = length-total;
				}
				else pbuf->size = (PAGE_SIZE);
			}
			LOG_MSG (KERN_INFO "Pbuf Size: %d\n", pbuf->size);
			pbuf->pktBuf = (unsigned char*)cachePages[j];
			pbuf->pageOffset = (j == 0) ? offset : 0;
			pbuf->bufInfo = (unsigned char *) buffer + total;
			pbuf->pageAddr= (unsigned char*)cachePages[j];
			pbuf->flags = PKT_ALL;
			total += pbuf->size;
			//spin_unlock_bh(&RawLock);
		}
		/****************************************************************/

		allocPages = j;           // actually used pages
		//  LOG_MSG(KERN_INFO "Sendpages %d",allocPages);
		//	result = DmaSendPages(handle[2], pkts, allocPages);
		if(result == -1)
		{
			for(j=0; j<allocPages; j++) {
				page_cache_release(cachePages[j]);
			}
			total = 0;
		}
		kfree(cachePages);

		for(j=0; j<allocPages; j++) {
			kfree(pkts[j]);
		}
		kfree(pkts);

		return total;
	}

	int receive_packet(char * buffer, size_t length, int line)
	{
		int j;
		int total;
		PktBuf * pbuf;
		int offset;
		unsigned int allocPages;
		unsigned long first, last;
		struct page** cachePages;
		PktBuf **pkts;
		dma_addr_t paddr_buf;

		int numFrags = 0;
		bool last_frag = false;
		void *ptr_ctx = NULL;
		unsigned short uid = 0;
		int retval;
		int state;
		total = 0;

		/****************************************************************/
		// SECTION 1: generate CACHE PAGES for USER BUFFER
		//
		offset = offset_in_page(buffer);
		first = ((unsigned long)buffer & PAGE_MASK) >> PAGE_SHIFT;
		last  = (((unsigned long)buffer + length-1) & PAGE_MASK) >> PAGE_SHIFT;
		allocPages = (last-first)+1;

		if(rx_channel_num_empty_bds < allocPages)
		{
			LOG_MSG(KERN_ERR"Receive channel bds %d and required bds are %d, so not calling frag_io\n",rx_channel_num_empty_bds,allocPages);
			return -1;
		}

		pkts = kzalloc( allocPages * (sizeof(PktBuf*)), GFP_ATOMIC);
		if(pkts == NULL)
		{
			LOG_MSG(KERN_ERR "Error: unable to allocate memory for pkts\n");
			return -1;
		}
		cachePages = kzalloc( (allocPages * (sizeof(struct page*))), GFP_ATOMIC);
		if( cachePages == NULL )
		{
			LOG_MSG(KERN_ERR "Error: unable to allocate memory for cachePages\n");
			kfree(pkts);
			return -1;
		}


		for(j=0; j< allocPages; j++)		/* Packet fragments loop */
		{
			pbuf = kzalloc( (sizeof(PktBuf)), GFP_ATOMIC);

			if(pbuf == NULL) {
				LOG_MSG(KERN_ERR "Insufficient Memory !!\n");
				for(j--; j>=0; j--)
					kfree(pkts[j]);
				for(j=0; j<allocPages; j++)
					page_cache_release(cachePages[j]);
				kfree(pkts);
				kfree(cachePages);
				return -1;
			}

			//spin_lock_bh(&RawLock);
			pkts[j] = pbuf;
			pbuf->flags = PKT_ALL;
			cachePages[j] = virt_to_page(buffer + (j * PAGE_SIZE));
			page_cache_get(cachePages[j]);
			// first buffer would start at some offset, need not be on page boundary
			ptr_ctx = (void *)pkts;
			if(j==0) {
				pbuf->size = ((PAGE_SIZE)-offset);
				pbuf->flags |= PKT_SOP;
				ptr_ctx = (void *)pkts;
			}
			else {
				if(j == (allocPages-1)) {
					pbuf->size = length-total;
					pbuf->flags |= PKT_EOP;
					last_frag = true;
					ptr_ctx = (void *)pkts;
				}
				else pbuf->size = (PAGE_SIZE);
			}
			/* LOG_MSG (KERN_INFO "Pbuf Size: %d\n", pbuf->size); */
			pbuf->pktBuf = (unsigned char*)cachePages[j];
			pbuf->bufInfo = (unsigned char *) buffer + total;
			pbuf->pageAddr= (unsigned char*)cachePages[j];
			pbuf->pageOffset = (j == 0) ? offset : 0;

			if(line == 500){
				pbuf->userInfo |= (1<<FRAME_DELITER_BIT);
			}
			//spin_unlock_bh(&RawLock);
			//	 LOG_MSG(KERN_ERR "P%d\n",packetcount++);
			if(rx_channel_num_empty_bds)
			{
				paddr_buf = dma_map_page(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]->ptr_dma_desc->dev,cachePages[j],\
						pbuf->pageOffset, pbuf->size, DMA_FROM_DEVICE);
				pbuf->bufPa = paddr_buf;
				LOCK_DMA_CHANNEL(&ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]->channel_lock);
				retval = xlnx_data_frag_io(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID],(unsigned char *)paddr_buf,addr_typ_transfer[VIDEO_RX_CHANNEL_ID],\
						pbuf->size ,cbk_receive_video ,uid, last_frag, ptr_ctx);

				if(retval < XLNX_SUCCESS) 
				{
					state = ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]->chann_state;

					//spin_unlock_irqrestore(&chann->channel_lock, flags);
#ifdef PUMP_APP_DBG_PRNT
					LOG_MSG(KERN_ERR"\n- Failed::::::Buffer allocated transmit %d\n", retval);
#endif
					if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
					{
#ifdef PUMP_APP_DBG_PRNT
						LOG_MSG(KERN_ERR"\n- Context Q saturated %d\n",state);
#endif
						ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]->chann_state = XLNX_DMA_CHANN_NO_ERR;
						//	set_task_state(current, TASK_INTERRUPTIBLE);  
						UNLOCK_DMA_CHANNEL(&ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]->channel_lock);
					}

				}
				else
				{
					total += pbuf->size;
					//spin_lock(&RxLock);
					rx_channel_num_empty_bds--;
					//spin_unlock(&RxLock);
					UNLOCK_DMA_CHANNEL(&ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]->channel_lock);
					numFrags++;
				}
			}

		}
		/****************************************************************/

		allocPages = j;           // actually used pages
		kfree(cachePages);
		return allocPages;
	}

	static int
		xil_fb_open (struct fb_info *info, int user)
		{
			fb_data_0.pos = 0;
			LOG_MSG (KERN_ERR"Trying to open device\n");

			if (xraw_DriverState < INITIALIZED)
			{
				LOG_MSG (KERN_ERR"Driver not yet ready!\n");
				return -1;
			}

			//  if (xraw_UserOpen)
			//    {                                          /* To prevent more than one GUI */
			//      LOG_MSG ("Device already in use\n");
			//      return -EBUSY;
			//    }

			//spin_lock_bh(&DmaStatsLock);
			xraw_UserOpen++;		  
			//spin_unlock_bh(&DmaStatsLock);
			LOG_MSG (KERN_ERR"========>>>>> XDMA driver instance %d \n", xraw_UserOpen);

			return 0;
		}

	static int
		xil_fb_release (struct fb_info *info, int user)
		{
			LOG_MSG(KERN_ERR"Closing device\n");
			if (!xraw_UserOpen)
			{
				/* Should not come here */
				LOG_MSG (KERN_ERR"Device not in use\n");
				return -EFAULT;
			}

			//  spin_lock_bh(&DmaStatsLock);
			xraw_UserOpen--;
			//  spin_unlock_bh(&DmaStatsLock);

			return 0;
		}

	long xraw_dev_ioctl (struct file *filp,
			unsigned int cmd, unsigned long arg)
	{
		int retval = 0;
		if (xraw_DriverState < INITIALIZED) {
			/* Should not come here */
			LOG_MSG (KERN_ERR"Driver not yet ready!\n");
			return -1;
		}
		/* Check cmd type and value */
		if (_IOC_TYPE (cmd) != XPMON_MAGIC)
			return -ENOTTY;
		if (_IOC_NR (cmd) > XPMON_MAX_CMD)
			return -ENOTTY;
		/* Check read/write and corresponding argument */
		if (_IOC_DIR (cmd) & _IOC_READ)
			if (!access_ok (VERIFY_WRITE, (void *) arg, _IOC_SIZE (cmd)))
				return -EFAULT;
		if (_IOC_DIR (cmd) & _IOC_WRITE)
			if (!access_ok (VERIFY_READ, (void *) arg, _IOC_SIZE (cmd)))
				return -EFAULT;
		switch (cmd) {
			case IGET_TRN_TXUSRINFO:
				{
					int count = 0;
					int expect_count;
					if(copy_from_user(&expect_count,&(((FreeInfo *)arg)->expected),sizeof(int)) != 0) {
						LOG_MSG (KERN_ERR"##### ERROR in copy from usr #####");
						break;
					}
					while (count < expect_count) {
						BufferInfo buff;
						if (0 != getBuffInfo (&TxDoneQ, &buff)) {
							break;
						}
						if (copy_to_user
								(((BufferInfo *) (((FreeInfo *)arg)->buffList) + count), &buff,
								 sizeof (BufferInfo))) {
							LOG_MSG (KERN_ERR"##### ERROR in copy to usr #####");
						}
						// log_verbose(" %s:bufferAddr %x   PktSize %d", __func__, usrArgument->buffList[count].bufferAddress, usrArgument->buffList[count].buffSize);
						count++;
					}
					if(copy_to_user(&(((FreeInfo *)arg)->expected),&count,(sizeof(int))) != 0)
					{
						LOG_MSG (KERN_ERR"##### ERROR in copy to usr #####");
					}

					break;
				}
			case IGET_TRN_RXUSRINFO:
				{
					int count = 0;
					int expect_count;

					if(copy_from_user(&expect_count,&(((FreeInfo *)arg)->expected),sizeof(int)) != 0)
					{
						LOG_MSG (KERN_ERR"##### ERROR in copy from usr #####");
						break;
					}

					while (count < expect_count)
					{
						BufferInfo buff;
						if (0 != getBuffInfo (&RxDoneQ, &buff))
						{
							break;
						}
						if (copy_to_user
								(((BufferInfo *) (((FreeInfo *)arg)->buffList) + count), &buff,
								 sizeof (BufferInfo)))
						{
							LOG_MSG (KERN_ERR"##### ERROR in copy to usr #####");

						}
						log_verbose(" %s:bufferAddr %x   PktSize %d", __func__, usrArgument->buffList[count].bufferAddress, usrArgument->buffList[count].buffSize);
						count++;
					}
					if(copy_to_user(&(((FreeInfo *)arg)->expected),&count,(sizeof(int))) != 0)
					{
						LOG_MSG (KERN_ERR"##### ERROR in copy to usr #####");
					}

					break;
				}
			default:
				LOG_MSG (KERN_ERR"Invalid command %d\n", cmd);
				retval = -1;
				break;
		}

		return retval;
	}

	int rx_done_poll (int expect_count)
	{
		int count = 0;
		int pagecount = 0;

		while (count < expect_count) {
			BufferInfo buff;
			if (0 != getBuffInfo (&RxDoneQ, &buff)) {
				return pagecount;
			}
			count++;
			pagecount += buff.noPages;
		}
		return pagecount;
	}



	static int
		xraw_fb_ioctl (struct fb_info *info,
				unsigned int cmd, unsigned long arg)
		{
			int retval = 0;
			TestCmd tc;

			if (xraw_DriverState < INITIALIZED)
			{
				/* Should not come here */
				LOG_MSG (KERN_ERR"Driver not yet ready!\n");
				return -1;
			}

			/* Check cmd type and value */
			if (_IOC_TYPE (cmd) != XPMON_MAGIC)
				return -ENOTTY;
			if (_IOC_NR (cmd) > XPMON_MAX_CMD)
				return -ENOTTY;

			/* Check read/write and corresponding argument */
			if (_IOC_DIR (cmd) & _IOC_READ)
				if (!access_ok (VERIFY_WRITE, (void *) arg, _IOC_SIZE (cmd)))
					return -EFAULT;
			if (_IOC_DIR (cmd) & _IOC_WRITE)
				if (!access_ok (VERIFY_READ, (void *) arg, _IOC_SIZE (cmd)))
					return -EFAULT;

			switch (cmd)
			{

				case IGET_TRN_TXUSRINFO:
					{
						int count = 0;

						int expect_count;
						if(copy_from_user(&expect_count,&(((FreeInfo *)arg)->expected),sizeof(int)) != 0)
						{
							LOG_MSG (KERN_ERR"##### ERROR in copy from usr #####");
							break;
						}
						while (count < expect_count)
						{
							BufferInfo buff;
							if (0 != getBuffInfo (&TxDoneQ, &buff))
							{
								break;
							}
							if (copy_to_user
									(((BufferInfo *) (((FreeInfo *)arg)->buffList) + count), &buff,
									 sizeof (BufferInfo)))
							{
								LOG_MSG (KERN_ERR"##### ERROR in copy to usr #####");
							}
							// log_verbose(" %s:bufferAddr %x   PktSize %d", __func__, 
							//usrArgument->buffList[count].bufferAddress, usrArgument->buffList[count].buffSize);
							count++;
						}
						if(copy_to_user(&(((FreeInfo *)arg)->expected),&count,(sizeof(int))) != 0)
						{
							LOG_MSG (KERN_ERR"##### ERROR in copy to usr #####");
						}
						break;
					}

				case IGET_TRN_RXUSRINFO:
					{
						int count = 0;
						int expect_count;

						if(copy_from_user(&expect_count,&(((FreeInfo *)arg)->expected),sizeof(int)) != 0)
						{
							LOG_MSG (KERN_ERR"##### ERROR in copy from usr #####");
							break;
						}

						while (count < expect_count)
						{
							BufferInfo buff;
							if (0 != getBuffInfo (&RxDoneQ, &buff))
							{
								break;
							}
							if (copy_to_user
									(((BufferInfo *) (((FreeInfo *)arg)->buffList) + count), &buff,
									 sizeof (BufferInfo)))
							{
								LOG_MSG (KERN_ERR"##### ERROR in copy to usr #####");

							}
							log_verbose(" %s:bufferAddr %x   PktSize %d", __func__, 
									usrArgument->buffList[count].bufferAddress, usrArgument->buffList[count].buffSize);
							count++;
						}
						if(copy_to_user(&(((FreeInfo *)arg)->expected),&count,(sizeof(int))) != 0)
						{
							LOG_MSG (KERN_ERR"##### ERROR in copy to usr #####");
						}

						break;
					}
				case ISTART_TEST:
				case ISTOP_TEST:
					{
						u64 cntrl_fnc_base_addr;
						u32 sobel_min_threshold = 0;
						u32 sobel_max_threshold = 0;

						cntrl_fnc_base_addr =(u64)(ptr_dma_desc->cntrl_func_virt_base_addr); 

						if(copy_from_user(&tc, (TestCmd *)arg, sizeof(TestCmd)))
						{
							LOG_MSG(KERN_ERR"copy_from_user failed\n");
							retval = -EFAULT;
							break;
						}
						//LOG_MSG(KERN_ERR"####Engine %d Testmode %x Min %x Max %x #####\n ",tc.Engine,tc.TestMode,tc.MinPktSize,tc.MaxPktSize);
						RawTestMode = tc.TestMode;
						if (tc.TestMode & TEST_START)
						{
							LOG_MSG(KERN_ERR"####Video test started #####\n ");

							if (tc.TestMode & ENABLE_SOBELFILTER)
							{
								if(tc.TestMode & ENABLE_SOBELFILTER_INVERT)
								{
									XIo_Out32(cntrl_fnc_base_addr + SOBEL_OFFSET + SOBEL_INVERT_REG,SOBEL_INVERT_VAL);
									//LOG_MSG(KERN_ERR"####Sobel Invert enabled #####\n ");
								}
								else
								{
									XIo_Out32(cntrl_fnc_base_addr + SOBEL_OFFSET + SOBEL_INVERT_REG,SOBEL_INVERT_OFF_VAL);
									//LOG_MSG(KERN_ERR"####Sobel Invert disabled #####\n ");
								}
								sobel_min_threshold = (tc.TestMode & SOBEL_MIN_COEF_MASK);
								sobel_max_threshold = (tc.TestMode & SOBEL_MAX_COEF_MASK) >> 24;
								//              LOG_MSG(KERN_ERR"####Sobel min threshold %d Sobel Max threshold %d #####\n ",sobel_min_threshold,sobel_max_threshold);
								XIo_Out32(cntrl_fnc_base_addr + SOBEL_OFFSET + SOBEL_LOW_THRESHOLD,sobel_min_threshold);
								XIo_Out32(cntrl_fnc_base_addr + SOBEL_OFFSET + SOBEL_HIGH_THRESHOLD,sobel_max_threshold);
							}
							else
							{
								//LOG_MSG(KERN_ERR"#### Sobel filter disabled ###\n");
							}
						}
						else
						{
							//                 LOG_MSG(KERN_ERR"####Video test stopped BD free count Tx = %d Rx = %d #####\n ",tx_channel_num_empty_bds,rx_channel_num_empty_bds);
						}
						break;
					}
				case ISET_SOBEL_THRSLD:
					{
						u64 cntrl_fnc_base_addr;
						u32 sobel_min_threshold = 0;
						u32 sobel_max_threshold = 0;

						cntrl_fnc_base_addr =(u64)(ptr_dma_desc->cntrl_func_virt_base_addr); 

						if(copy_from_user(&tc, (TestCmd *)arg, sizeof(TestCmd)))
						{
							LOG_MSG(KERN_ERR"copy_from_user failed\n");
							retval = -EFAULT;
							break;
						}
						//LOG_MSG(KERN_ERR"####Engine %d Testmode %x Min %x Max %x #####\n ",tc.Engine,tc.TestMode,tc.MinPktSize,tc.MaxPktSize);
						if (RawTestMode & TEST_START)
						{
							//LOG_MSG(KERN_ERR"####Video test started #####\n ");

							if (tc.TestMode & ENABLE_SOBELFILTER)
							{
								if(tc.TestMode & ENABLE_SOBELFILTER_INVERT)
								{
									XIo_Out32(cntrl_fnc_base_addr + SOBEL_OFFSET + SOBEL_INVERT_REG,SOBEL_INVERT_VAL);
									//  LOG_MSG(KERN_ERR"####Sobel Invert enabled #####\n ");
								}
								else
								{
									XIo_Out32(cntrl_fnc_base_addr + SOBEL_OFFSET + SOBEL_INVERT_REG,SOBEL_INVERT_OFF_VAL);
									//    LOG_MSG(KERN_ERR"####Sobel Invert disabled #####\n ");
								}
								sobel_min_threshold = (tc.TestMode & SOBEL_MIN_COEF_MASK);
								sobel_max_threshold = (tc.TestMode & SOBEL_MAX_COEF_MASK) >> 24;
								//  LOG_MSG(KERN_ERR"####Sobel min threshold %d Sobel Max threshold %d #####\n ",sobel_min_threshold,sobel_max_threshold);
								XIo_Out32(cntrl_fnc_base_addr + SOBEL_OFFSET + SOBEL_LOW_THRESHOLD,sobel_min_threshold);
								XIo_Out32(cntrl_fnc_base_addr + SOBEL_OFFSET + SOBEL_HIGH_THRESHOLD,sobel_max_threshold);
							}
							else
							{
								//LOG_MSG(KERN_ERR"#### Sobel filter disabled ###\n");
							}
						}
						else
						{
							// LOG_MSG(KERN_ERR"####Video test stopped #####\n ");
						}
						break;
					}
				case ISET_RESET_VDMA:
					{

						if(copy_from_user(&tc, (TestCmd *)arg, sizeof(TestCmd)))
						{
							LOG_MSG(KERN_ERR"copy_from_user failed\n");
							retval = -EFAULT;
							break;
						}
						ResetDMAonStopTest();

						LOG_MSG(KERN_ERR"Resetting VDMA after stop test\n");
						/* Initialize the bridge with Application logic related mappings */
						InitBridge_App((u64) ptr_dma_desc->dma_reg_virt_base_addr, 
								(u32) ptr_dma_desc->dma_reg_phy_base_addr, 
								(u64) ptr_dma_desc->cntrl_func_virt_base_addr, 
								(u32) ptr_dma_desc->cntrl_func_phy_base_addr);

						LOG_MSG(KERN_ERR"#### BD free count Tx = %d Rx = %d #####\n",tx_channel_num_empty_bds,rx_channel_num_empty_bds);
						break;
					}

				default:
					LOG_MSG ("Invalid command %d\n", cmd);
					retval = -1;
					break;
			}

			return retval;
		}


	/**
	 * @name    fb_transferimage
	 *
	 * This function sends the whole image to thee zynq side.
	 *
	 * @param [fb_in] framebuffer object to be transmitted.
	 * @param [var] gives the offset of the image in the framebuffer.
	 *
	 */

	int
		fb_transferimage (struct fb_var_screeninfo *var)
		{
			int i;
			int ret_pack = 0;
			char frame_delim = 0;
			char frame_sync = 0;
			int pos_in_fb = 0;
			FrameBuffer *fb_s;
			FrameBuffer *fb_d;
			static int flag = 0;
			u32 reg_val;

			struct list_head *pos_s;
			struct list_head *pos_d;

			BufferInfo buff;
#ifdef TX_RX_SYNC
			if(s2c_pushback_status == BLOCK)
			{
				mdelay(MAX_TIMEOUT);
			}
			else if(s2c_pushback_status == INITIALIZATION)
			{
			}
			else if (s2c_pushback_status == PROGRESS)
			{
				// LOG_MSG(KERN_ERR"Setting pushback status to Block");
				spin_lock(&sync_lock);
				s2c_pushback_status = BLOCK; 
				spin_unlock(&sync_lock);
			}
#endif

			if ((RawTestMode & TEST_START) &&
					(RawTestMode & (ENABLE_PKTCHK | ENABLE_LOOPBACK))) {
				if (free_buffers < FRAME_PIXEL_ROWS) {
					while (free_buffers < FRAME_PIXEL_ROWS) {
						if (0 != getBuffInfo (&TxDoneQ, &buff)) {
							udelay(10);
						} else {
							free_buffers++;
						} } }

				// /* Find position in the framebuffer for yoffset */

				pos_s = &fb_data_0.list;
				fb_s = list_entry(pos_s, FrameBuffer, list);
				for (i=0; i<var->yoffset; i++) {
					pos_in_fb += MAXPKTSIZE;
					if (pos_in_fb >= fb_s->buff_size) {
						pos_s = pos_s->next;
						fb_s = list_entry(pos_s, FrameBuffer, list);
						pos_in_fb = 0;
					}
				}

				/* Copy fb_data to the framebuffer which will be transmitted */
				pos_d = &fb_data_1.list;
				fb_d = list_entry(pos_d, FrameBuffer, list);
				get_dma_lock();
				for (i=0; i< FRAME_PIXEL_ROWS; i++) {
					memcpy(fb_d->buffer + pos_in_fb , fb_s->buffer + pos_in_fb, (FRAME_PIXEL_COLS * NUM_BYTES_PIXEL));
					pos_in_fb += MAXPKTSIZE;
					if (pos_in_fb >= fb_d->buff_size) {
						pos_d = pos_d->next;
						fb_d = list_entry(pos_d, FrameBuffer, list);
						pos_s = pos_s->next;
						fb_s = list_entry(pos_s, FrameBuffer, list);
						pos_in_fb = 0;
					}
				}
				pos_in_fb = 0;

				pos_d = &fb_data_1.list;
				fb_d = list_entry(pos_d, FrameBuffer, list);
				free_buffers -= FRAME_PIXEL_ROWS;
				for (i=0; i<FRAME_PIXEL_ROWS; i++) 
				{
					if (i == 0 ) 
					{
						//mdelay(50);
						frame_delim = 1;
						frame_sync = 0;
					}
					else if(i == FRAME_PIXEL_ROWS - 1)
					{
						frame_delim = 0;
						frame_sync = 1;
					}
					else
					{
						frame_delim = 0;
						frame_sync = 0;
					}
					pos_in_fb += MAXPKTSIZE;
					if (pos_in_fb >= fb_d->buff_size) {
						pos_d = pos_d->next;
						fb_d = list_entry(pos_d, FrameBuffer, list);
						pos_in_fb = 0;
					}
					if( flag < 1 )
					{
						reg_val = XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + SOBEL_OFFSET + SOBEL_CNTL_STS_REG);
						reg_val |= 0x1;
						XIo_Out32(ptr_dma_desc->cntrl_func_virt_base_addr + SOBEL_OFFSET + SOBEL_CNTL_STS_REG,reg_val);
						reg_val = XIo_In32(ptr_dma_desc->cntrl_func_virt_base_addr + SOBEL_OFFSET + SOBEL_CNTL_STS_REG);
						LOG_MSG(KERN_ERR"Enabled Sobel filter value = %x\n",reg_val);
						flag++;
					}
					transfer_pixel_row(handle[0], fb_d->buffer + pos_in_fb, NUM_BYTES_PIXEL * FRAME_PIXEL_COLS, frame_delim, frame_sync);
				}
		}
	release_dma_lock();
	return ret_pack;
}

/* 
 * This function is called when somebody tries to
 * write into our device file. 
 */
	static ssize_t
xil_fb_write (struct fb_info *info,
		const char __user * buffer, size_t length, loff_t * offset)
{
	int ret_val;
	FrameBuffer *fb;
	struct list_head *pos;
	char *read_buffer;
	int remaining_length;
	int initial_offset;
	int read_pos = 0;
	struct fb_var_screeninfo var;
	read_buffer = vmalloc(length * sizeof(char));
	if (read_buffer == NULL) {
		return(-ENOMEM);
	}
	LOG_MSG(KERN_EMERG"In xil_fb_write\n");
	if(copy_from_user(read_buffer, buffer,length) != 0) {
		ret_val = -1; //todo;
		LOG_MSG(KERN_ERR "Error in copy_from_user\n");
		goto vmalloc_exit;
	}


	fb = &fb_data_0;
	pos = &fb->list;
	var.yoffset = 0;
	fb = list_entry(pos, FrameBuffer, list);
	initial_offset = (*offset + fb_data_0.pos);
	remaining_length = ((length + *offset + fb_data_0.pos) <= FB_REAL_SIZE) ? 
		length : (FB_REAL_SIZE - *offset - fb_data_0.pos);
	read_pos = 0;

	do {
		if (remaining_length < fb->buff_size) {
			memcpy(fb->buffer + initial_offset, read_buffer + read_pos, remaining_length);
			initial_offset = 0;
			read_pos += remaining_length;
			remaining_length = 0;

		} else {
			memcpy(fb->buffer + initial_offset, read_buffer + read_pos, fb->buff_size - initial_offset);
			read_pos += (fb->buff_size - initial_offset);
			initial_offset = 0;
			remaining_length -= fb->buff_size - initial_offset;
		}
		pos = pos->next;
		fb = list_entry(pos, FrameBuffer, list);
	} while (remaining_length != 0);

	ret_val = ((length + *offset + fb_data_0.pos) <= FB_REAL_SIZE) ? length : -ENOSPC;
	fb_data_0.pos += read_pos;
	if ((RawTestMode & TEST_START) &&
			(RawTestMode & (ENABLE_PKTCHK | ENABLE_LOOPBACK))) {
		fb_transferimage(&var); 
	}
vmalloc_exit:
	vfree(read_buffer);
	return ret_val;
}

static ssize_t
xil_fb_read (struct fb_info *info, char __user *buf, size_t count, loff_t *ppos) {

	int ret_val;
	FrameBuffer *fb;
	struct list_head *pos;
	char *write_buffer;
	int read_offset;
	int write_pos;


	write_buffer = vmalloc(count * sizeof(char));
	if (write_buffer == NULL) {
		ret_val = -ENOMEM;
		goto exit;
	}

	fb = &fb_data_0;
	pos = &fb->list;
	fb = list_entry(pos, FrameBuffer, list);
	write_pos = 0;
	read_offset = *ppos;
	do {
		if ((count - write_pos + read_offset)  < fb->buff_size) {
			memcpy(write_buffer + write_pos, fb->buffer + read_offset, (count - write_pos));
			write_pos = count;
			read_offset = 0;

		} else {
			memcpy(write_buffer + write_pos, fb->buffer, fb->buff_size);
			write_pos += fb->buff_size;
			read_offset = 0;
		}
		pos = pos->next;
		fb = list_entry(pos, FrameBuffer, list);


	} while (write_pos < (((count + *ppos) < FB_REAL_SIZE) ? count: FB_REAL_SIZE));

	ret_val = (count <= FB_REAL_SIZE) ? count : -ENOSPC;


	if(copy_to_user(buf, write_buffer,ret_val) != 0) {
		ret_val = -1; //todo;
		LOG_MSG(KERN_ERR "Error in copy_to_user\n");
		goto vmalloc_exit;
	}

vmalloc_exit:
	vfree(write_buffer);
exit:
	return ret_val;
}


void xil_fb_vma_open(struct vm_area_struct *vma)
{
	LOG_MSG(KERN_INFO "Opened VMA Device\n");
}

void xil_fb_vma_close(struct vm_area_struct *vma)
{
	LOG_MSG(KERN_INFO "Closed VMA Device\n");
}

/**
 * @name    xil_fb_vault
 *
 * returns the page wanted address or SIGBUS if outside range.
 *
 * @param [vma]
 * @param [vmf]
 *
 */

static int xil_fb_vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
{
	unsigned long offset;
	FrameBuffer *fb;
	struct list_head *pos;
	struct page *page = NULL;
	int read_pos = 0;
	void *pageptr = NULL; /* default to "missing" */
	int retval = VM_FAULT_SIGBUS;
	offset = (unsigned long)(vmf->virtual_address - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
	if (offset >= FB_VIRT_SIZE) {
		LOG_MSG(KERN_ERR"Offset out of  range %lu\n", offset);
		goto out; /* out of range */
	}

	// Now get the Framebuffer position
	fb = &fb_data_0;
	pos = &fb->list;
	fb = list_entry(pos, FrameBuffer, list);
	do {
		if ((offset - read_pos)  < fb->buff_size) {
			pageptr = fb->buffer + (offset - read_pos);
			break;
		} 
		read_pos += fb->buff_size;
		pos = pos->next;
		fb = list_entry(pos, FrameBuffer, list);
	} while (pageptr == NULL);

	page = virt_to_page(pageptr);
	/* got it, now increment the count */
	get_page(page);
	vmf->page = page;
	retval = 0;

out:
	return retval;
}

struct vm_operations_struct xil_fb_vm_ops = {
	.open =     xil_fb_vma_open,
	.close =    xil_fb_vma_close,
	.fault =    xil_fb_vma_fault,
};


/**
 * @name    xil_fb_mmap
 *
 * mmapping function, actual mapping done in the .fault method.
 *
 * @param [info]
 * @param [vma]
 *
 */

static int xil_fb_mmap(struct fb_info *info,
		struct vm_area_struct *vma)
{
	vma->vm_ops = &xil_fb_vm_ops;
#if (LINUX_VERSION_CODE > KERNEL_VERSION(3,6,11))
	vma->vm_flags |= (VM_DONTEXPAND | VM_DONTDUMP);
#else
	vma->vm_flags |= VM_RESERVED;
#endif
	xil_fb_vma_open(vma);
	return 0;
}

/**
 * @name    xil_fb_fillrect
 *
 * fills a rectangle in a specified color
 *
 * @param [info]
 * @param [rect]
 *
 */

static void xil_fb_fillrect(struct fb_info *info, const struct fb_fillrect *rect)
{
	int i;
	int j;
	int pos_in_fb = 0;
	FrameBuffer *fb;
	struct list_head *pos;
	char red;
	char blue;
	char green;


	red = (char) (rect->color >> 0) & 0xFF;
	green = (char) (rect->color >> 8) & 0xFF;
	blue = (char) (rect->color >> 16) & 0xFF;

	pos = &fb_data_0.list;
	fb = list_entry(pos, FrameBuffer, list);
	for (i=0; i<rect->dy; i++) {
		pos_in_fb += MAXPKTSIZE;
		if (pos_in_fb >= fb->buff_size) {
			pos = pos->next;
			fb = list_entry(pos, FrameBuffer, list);
			pos_in_fb = 0;
		}
	}
	for (i=0; i<rect->height; i++) {
		for (j=0; j<rect->width; j++){
			if ((j+rect->dx*4)< MAXPKTSIZE) {
				*(fb->buffer+ 0 + (i * MAXPKTSIZE) + ((j+rect->dx)*4)) = red;
				*(fb->buffer+ 1 + (i * MAXPKTSIZE) + ((j+rect->dx)*4)) = green;
				*(fb->buffer+ 2 + (i * MAXPKTSIZE) + ((j+rect->dx)*4)) = blue;
				*(fb->buffer+ 3 + (i * MAXPKTSIZE) + ((j+rect->dx)*4)) = 0x00;
			}
		}
		if (((i+ 1) * MAXPKTSIZE) > fb->buff_size) {
			pos = pos->next;
			fb = list_entry(pos, FrameBuffer, list);
		}
	}
	LOG_MSG(KERN_ERR "in the fillrect method \n");
}

/**
 * @name    xil_fb_copyarea
 *
 * copies aa rectangle to another area
 *
 * @param [info]
 * @param [area]
 *
 */

static void xil_fb_copyarea(struct fb_info *info, const struct fb_copyarea *area)
{
	int i;
	int pos_in_fb = 0;
	FrameBuffer *fb_d;
	FrameBuffer *fb_s;
	struct list_head *pos_d;
	struct list_head *pos_s;


	pos_s = &fb_data_0.list;
	fb_s = list_entry(pos_s, FrameBuffer, list);
	for (i=0; i<area->sy; i++) {
		pos_in_fb += MAXPKTSIZE;
		if (pos_in_fb >= fb_s->buff_size) {
			pos_s = pos_s->next;
			fb_s = list_entry(pos_s, FrameBuffer, list);
			pos_in_fb = 0;
		}
	}
	pos_in_fb = 0;
	pos_d = &fb_data_0.list;
	fb_d = list_entry(pos_d, FrameBuffer, list);
	for (i=0; i<area->dy; i++) {
		pos_in_fb += MAXPKTSIZE;
		if (pos_in_fb >= fb_d->buff_size) {
			pos_d = pos_d->next;
			fb_d = list_entry(pos_d, FrameBuffer, list);
			pos_in_fb = 0;
		}
	}
	for(i=0; i<area->height; i++) {
		if ((((area->dx * 4) + area->width * 4) < MAXPKTSIZE) && 
				(((area->sx * 4) + area->width * 4) < MAXPKTSIZE))
			memcpy(fb_d->buffer + (area->dx * 4), fb_s->buffer + (area->sx * 4),
					area->width * 4);
		if ((((i+ 1) * MAXPKTSIZE) > fb_s->buff_size) | 
				(((i+ 1) * MAXPKTSIZE) > fb_d->buff_size))
		{
			pos_s = pos_s->next;
			fb_s = list_entry(pos_s, FrameBuffer, list);
			pos_d = pos_d->next;
			fb_d = list_entry(pos_d, FrameBuffer, list);
		}
	}

	LOG_MSG(KERN_ERR "in the copyarea method \n");
}

/**
 * @name    xil_fb_imageblit
 *
 * copies a image to an area
 *
 * @param [info]
 * @param [image]
 *
 */

static void xil_fb_imageblit(struct fb_info *info, const struct fb_image *image)
{
	int i;
	int pos_in_fb = 0;
	FrameBuffer *fb_d;
	struct list_head *pos_d;

	pos_d = &fb_data_0.list;
	fb_d = list_entry(pos_d, FrameBuffer, list);
	for (i=0; i<image->dy; i++) {
		pos_in_fb += MAXPKTSIZE;
		if (pos_in_fb >= fb_d->buff_size) {
			pos_d = pos_d->next;
			fb_d = list_entry(pos_d, FrameBuffer, list);
			pos_in_fb = 0;
		}
	}

	for(i=0; i<image->height; i++) {
		if (((image->dx * 4) + image->width * 4) < MAXPKTSIZE) {
			memcpy(fb_d->buffer + (image->dx * 4), image->data + (i * image->width * 4),
					image->width * 4);
			if (((i+ 1) * MAXPKTSIZE) > fb_d->buff_size) {
				pos_d = pos_d->next;
				fb_d = list_entry(pos_d, FrameBuffer, list);
			}
		}
	}
	LOG_MSG(KERN_ERR "in the imageblit method \n");
}


/**
 * @name    xil_fb_pan_display
 *
 * does panning of the framebuffer.
 *
 * @param [var] screeninfo which holds the panning information
 * @param [info] fb_info struct
 *
 */

static int xil_fb_pan_display(struct fb_var_screeninfo *var,
		struct fb_info *info)
{
	fb_transferimage(var);
	//LOG_MSG(KERN_ERR "Now panning display to %u\n", var->yoffset);
	return 0;
}

/**
 * @name    free_framebuffer_memory
 *
 * frees the framebuffers memory.
 *
 * @param [fb_data] framebuffer to be freed
 *
 */

int free_framebuffer_memory(FrameBuffer *fb_data) {
	FrameBuffer *fb;
	struct list_head *pos;
	pos = &fb_data->list;
	while (pos != pos->next) {
		//LOG_MSG("Removing one entry\n");
		fb = list_entry(pos->next, FrameBuffer, list);
		list_del(pos->next);
		kfree(fb->buffer);
		kfree(fb);
	}
	kfree(fb_data->buffer);

	return 0;
}

/**
 * @name    allocate_framebuffer_memory
 *
 * allocates memory for the framebuffer 
 *
 * @param [fb_data] framebuffer to be allocated for
 *
 */

int allocate_framebuffer_memory(FrameBuffer *fb_data, int fb_size) {
	int fb_current_size;
	int fb_alloc_size;
	FrameBuffer *fb;
	fb_data->buff_count = 0;
	fb_current_size = 0;
	fb_alloc_size = FB_CHUNK_SIZE; //starting with an allocateable size;
	fb = fb_data;

	while (fb_current_size < fb_size) {
		LOG_MSG(KERN_ERR"Trying to allocate %d Bytes, currently allocated %d\n", fb_alloc_size, fb_current_size);
		fb->buffer = (char*) kmalloc(fb_alloc_size, GFP_KERNEL);
		if (NULL == fb->buffer) {
			LOG_MSG(KERN_ERR"Size %d did not work trying %d\n", fb_alloc_size, fb_alloc_size >> 1);
			fb_alloc_size = fb_alloc_size >> 1;
		} else {
			memset(fb->buffer,0, fb_alloc_size);
			fb->buff_size = fb_alloc_size;
			fb_current_size += fb_alloc_size;
			fb_data->buff_count++;
			if (fb_current_size < fb_size) {
				fb = (FrameBuffer*) kmalloc(sizeof(FrameBuffer), GFP_KERNEL);
				if (NULL == fb) {
					LOG_MSG(KERN_ERR"Allocation failed \n");
					goto error;
				} else {
					list_add(&fb->list, &fb_data->list);  
				}      
			}
		}
	}
	return 0;

error:
	free_framebuffer_memory(fb_data);
	return -1;
}

static struct fb_ops xil_fb_ops = {
	.owner          = THIS_MODULE,
	.fb_open        = xil_fb_open,
	.fb_read        = xil_fb_read,
	.fb_write       = xil_fb_write,
	.fb_release     = xil_fb_release,
	// .fb_check_var   = xxxfb_check_var,
	// .fb_set_par     = xxxfb_set_par,
	// .fb_setcolreg   = xxxfb_setcolreg,
	// .fb_blank       = xxxfb_blank,
	.fb_pan_display = xil_fb_pan_display,
	.fb_fillrect    = xil_fb_fillrect,       
	.fb_copyarea    = xil_fb_copyarea,      
	.fb_imageblit   = xil_fb_imageblit,      /* Needed !!! */
	// .fb_cursor      = xxxfb_cursor,         /* Optional !!! */
	// .fb_rotate      = xxxfb_rotate,
	// .fb_sync        = xxxfb_sync,
	.fb_ioctl       = xraw_fb_ioctl,
	.fb_mmap        = xil_fb_mmap,
};

static int xil_fb_probe(struct platform_device *dev)
{
	struct fb_info *info;
	int retval = -ENOMEM;
	info = framebuffer_alloc(sizeof(u32) * 256, &dev->dev);
	if (!info)
		goto err;
	info->screen_base = (char *) &fb_data_0; //FIXME 
	xil_fb_fix.smem_start = (unsigned long ) &fb_data_0;
	info->fbops = &xil_fb_ops;
	info->var = xil_fb_default;
	info->fix = xil_fb_fix;
	info->pseudo_palette = info->par;
	info->par = NULL;
	info->flags = FBINFO_FLAG_DEFAULT | FBINFO_VIRTFB;
	retval = fb_alloc_cmap(&info->cmap, 256, 0);
	if (retval < 0)
		goto err1;
	retval = register_framebuffer(info);
	if (retval < 0)
		goto err2;
	platform_set_drvdata(dev, info);
	return 0;
err2:
	fb_dealloc_cmap(&info->cmap);
err1:
	framebuffer_release(info);
err:
	return retval;
}

static int xil_fb_remove(struct platform_device *dev)
{
	struct fb_info *info = platform_get_drvdata(dev);
	if (info) {
		unregister_framebuffer(info);
		fb_dealloc_cmap(&info->cmap);
		framebuffer_release(info);
	}
	return 0;
}

static struct platform_driver xil_fb_driver = {
	.probe  = xil_fb_probe,
	.remove = xil_fb_remove,
	.driver = {
		.name   = "xil_fb",
	},
};

static struct platform_device *xil_fb_device;

	static int __init
rawdata_init (void)
{
	int ret;
	int i,j;
	// dev_t xrawDev;
	platform_t pfrom = HOST;

	unsigned int q_num_elements = NUM_Q_ELEM;
	unsigned int aux_q_num_elements = NUM_AUX_Q_ELEM;
	unsigned int rx_aux_q_num_elements = RX_NUM_AUX_Q_ELEM;
	unsigned int data_q_addr_hi;
	unsigned int data_q_addr_lo;
	unsigned int sta_q_addr_hi;
	unsigned int sta_q_addr_lo;
	direction_t dir;
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	char name_buf[50];
	dma_addr_t paddr_buf;
	dma_addr_t TxDsttemp, RxDsttemp;
	unsigned short uid = 1;
	int retval;
	int state;
#endif

	/* Just register the driver. No kernel boot options used. */
	LOG_MSG (KERN_INFO "%s Init: Inserting Xilinx driver in kernel.\n", MYNAME);

	xraw_DriverState = INITIALIZED;
	spin_lock_init (&RawLock);
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
#ifdef TX_RX_SYNC
	spin_lock_init(&sync_lock);
	s2c_pushback_status = INITIALIZATION;
	s2c_frame_cnt = 0;
#endif
#endif


	msleep (5);
	//char *option = NULL;

	// if (fb_get_options("vfb", &option))
	//         return -ENODEV;
	// vfb_setup(option);
	ret = platform_driver_register(&xil_fb_driver);
	if (!ret) {
		xil_fb_device = platform_device_alloc("xil_fb", 0);

		if (xil_fb_device)
			ret = platform_device_add(xil_fb_device);
		else
			ret = -ENOMEM;

		if (ret) {
			platform_device_put(xil_fb_device);
			platform_driver_unregister(&xil_fb_driver);
		}
	}


	xraw_DriverState = INITIALIZED;

	if (xraw_DriverState < POLLING)
	{
		ptr_dma_desc = xlnx_get_pform_dma_desc((void*)NULL, 0, 0);

		ret = xlnx_get_dma((void*)ptr_dma_desc->device , pfrom, &ptr_app_dma_desc);
		if(ptr_app_dma_desc == NULL) 
		{
			LOG_MSG(KERN_ERR"\n- Could not get valid dma descriptor %d\n", ret);
			goto error;
		}
		else
		{

			/* First Registering Tx channel */ 
			dir = OUT;
			ret = xlnx_get_dma_channel(ptr_app_dma_desc, VIDEO_TX_CHANNEL_ID, 
					dir, &ptr_chan_s2c[VIDEO_TX_CHANNEL_ID],NULL);

			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not get s2c %d channel error %d\n", VIDEO_TX_CHANNEL_ID,ret);
				goto error;
			}
			ret = xlnx_alloc_queues(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID], &data_q_addr_hi, //Physical address
					&data_q_addr_lo,//Physical address
					&sta_q_addr_hi,//Physical address
					&sta_q_addr_lo,//Physical address
					q_num_elements);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not allocate Qs for s2c %d channel %d\n",VIDEO_TX_CHANNEL_ID, ret);
				goto error;
			}
			ret = xlnx_activate_dma_channel(ptr_app_dma_desc, ptr_chan_s2c[VIDEO_TX_CHANNEL_ID],
					data_q_addr_hi,data_q_addr_lo,q_num_elements,
					sta_q_addr_hi,sta_q_addr_lo,q_num_elements , COALESE_CNT);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not activate s2c %d channel %d\n", VIDEO_TX_CHANNEL_ID,ret);
				goto error;
			}

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
			dir = IN;
			ret = xlnx_get_dma_channel(ptr_app_dma_desc, VIDEO_TX_CHANNEL_ID, 
					dir, &ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID],NULL);

			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not get s2c dst %d channel error %d\n", VIDEO_TX_CHANNEL_ID,ret);
				goto error;
			}
			ret = xlnx_alloc_queues(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID], &data_q_addr_hi, //Physical address
					&data_q_addr_lo,//Physical address
					&sta_q_addr_hi,//Physical address
					&sta_q_addr_lo,//Physical address
					aux_q_num_elements);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not allocate Qs for s2c dst %d channel %d\n",VIDEO_TX_CHANNEL_ID, ret);
				goto error;
			}
			ret = xlnx_activate_dma_channel(ptr_app_dma_desc, ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID],
					data_q_addr_hi,data_q_addr_lo,aux_q_num_elements,
					sta_q_addr_hi,sta_q_addr_lo,aux_q_num_elements, COALESE_CNT);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not activate s2c dst %d channel %d\n", VIDEO_TX_CHANNEL_ID,ret);
				goto error;
			}
#endif
			/* Registering the Rx channel */
			dir = IN;
			ret = xlnx_get_dma_channel(ptr_app_dma_desc, VIDEO_RX_CHANNEL_ID, 
					dir, &ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID],NULL);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not get s2c rx %d channel error %d\n", VIDEO_RX_CHANNEL_ID,ret);
				goto error;
			}

			ret = xlnx_alloc_queues(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID], &data_q_addr_hi, //Physical address
					&data_q_addr_lo,//Physical address
					&sta_q_addr_hi,//Physical address
					&sta_q_addr_lo,//Physical address
					q_num_elements);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not allocate Qs for s2c rx %d channel %d\n",VIDEO_RX_CHANNEL_ID, ret);
				goto error;
			}
			ret = xlnx_activate_dma_channel(ptr_app_dma_desc, ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID],
					data_q_addr_hi,data_q_addr_lo,q_num_elements,
					sta_q_addr_hi,sta_q_addr_lo,q_num_elements,COALESE_CNT);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not activate s2c rx %d channel %d\n", VIDEO_RX_CHANNEL_ID,ret);
				goto error;
			}
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
			dir = OUT;
			ret = xlnx_get_dma_channel(ptr_app_dma_desc, VIDEO_RX_CHANNEL_ID, 
					dir, &ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID],NULL);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not get rx s2c dst %d channel error %d\n", VIDEO_RX_CHANNEL_ID,ret);
				goto error;
			}

			ret = xlnx_alloc_queues(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID], &data_q_addr_hi, //Physical address
					&data_q_addr_lo,//Physical address
					&sta_q_addr_hi,//Physical address
					&sta_q_addr_lo,//Physical address
					rx_aux_q_num_elements);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not allocate Qs for rx s2c dst %d channel %d\n",VIDEO_RX_CHANNEL_ID, ret);
				goto error;
			}
			ret = xlnx_activate_dma_channel(ptr_app_dma_desc, ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID],
					data_q_addr_hi,data_q_addr_lo,rx_aux_q_num_elements,
					sta_q_addr_hi,sta_q_addr_lo,rx_aux_q_num_elements,COALESE_CNT);
			if(ret < XLNX_SUCCESS) 
			{
				LOG_MSG(KERN_ERR"\n- Could not activate rx s2c dst %d channel %d\n", VIDEO_RX_CHANNEL_ID,ret);
				goto error;
			}
#endif
			addr_typ_transfer[VIDEO_TX_CHANNEL_ID] = PHYS_ADDR;
			addr_typ_transfer[VIDEO_RX_CHANNEL_ID] = PHYS_ADDR;
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
			addr_typ_aux_transfer[VIDEO_TX_CHANNEL_ID] = EP_PHYS_ADDR;
			addr_typ_aux_transfer[VIDEO_RX_CHANNEL_ID] = EP_PHYS_ADDR;
			for(i=0;i<NUM_FRAMES_IN_PLDDR;i++)
			{
				psDstQsRangeTx[i].frame_start_address = PS_DDR_VDMA_TX_ADDR_BASE + (i * VIDEO_FRAME_SIZE);
				//LOG_MSG(KERN_ERR"Tx Frame %d start address %X\n",i + 1,psDstQsRangeTx[i].frame_start_address);
				psDstQsRangeTx[i].frame_end_address = psDstQsRangeTx[i].frame_start_address + VIDEO_FRAME_SIZE;
				psDstQsRangeRx[i].frame_start_address = PS_DDR_VDMA_RX_ADDR_BASE + (i * VIDEO_FRAME_SIZE); 
				//LOG_MSG(KERN_ERR"Rx Frame %d start address %X\n",i + 1, psDstQsRangeRx[i].frame_start_address);
				psDstQsRangeRx[i].frame_end_address = psDstQsRangeRx[i].frame_start_address + VIDEO_FRAME_SIZE;
			}

			TxDstDdrPhyAdrs = psDstQsRangeTx[0].frame_start_address;
			RxDstDdrPhyAdrs = psDstQsRangeRx[0].frame_start_address;
			TxDsttemp = TxDstDdrPhyAdrs;
			RxDsttemp = RxDstDdrPhyAdrs;
			for(i=0;i<(NUM_FRAMES_IN_PLDDR);i++)
			{
				for(j=0; j<FRAME_PIXEL_ROWS;j++)
				{
					paddr_buf = (dma_addr_t)(psDstQsRangeTx[i].frame_start_address + (j * (MAXPKTSIZE)));
					//LOCK_DMA_CHANNEL(&ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->channel_lock);
					retval = xlnx_data_frag_io(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID],(unsigned char *)paddr_buf,addr_typ_aux_transfer[VIDEO_TX_CHANNEL_ID],\
							MAXPKTSIZE,cbk_transfer_video_dst_row ,uid, true, (void *)paddr_buf);

					if(retval < XLNX_SUCCESS) 
					{
						state = ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->chann_state;

#ifdef PUMP_APP_DBG_PRNT
						LOG_MSG(KERN_ERR"\n- Failed::::::Buffer allocated transmit %d\n", retval);
#endif
						if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
						{
#ifdef PUMP_APP_DBG_PRNT
							LOG_MSG(KERN_ERR"\n- Context Q saturated %d\n",state);
#endif
							ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->chann_state = XLNX_DMA_CHANN_NO_ERR;
							//	set_task_state(current, TASK_INTERRUPTIBLE);  
							//	UNLOCK_DMA_CHANNEL(&ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->channel_lock);
						}

					}
					else
					{
						// LOG_MSG(KERN_ERR"Programmed %p for Tx Aux Queue\n",paddr_buf);
						//					       TxDsttemp += MAXPKTSIZE;
						//	UNLOCK_DMA_CHANNEL(&ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->channel_lock);

					}
				}
			}
			sprintf(name_buf,"Rx Dst WorkQueue");
			rx_dst_workq = create_singlethread_workqueue((const char*)name_buf); 
			if(rx_dst_workq != NULL)
			{
				//LOG_MSG(KERN_ERR"Rx Dst Work Queue created successfully\n");
			}
			INIT_WORK(&(rx_dst_work), c2s_processed_fr_tsmt);

			xlnx_register_doorbell_cbk(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID], c2s_fr_tsmt_init_cbk);
			//LOG_MSG(KERN_ERR"Rx Aux Doorbell callback registered\n");
			xlnx_register_doorbell_cbk(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID], c2s_fr_tsmt_init_cbk);
			//LOG_MSG(KERN_ERR"Tx Aux Doorbell callback registered\n");

			xlnx_register_doorbell_cbk(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID], c2s_fr_tsmt_init_cbk);

			//LOG_MSG(KERN_ERR"Tx Doorbell callback registered\n");
			xlnx_register_doorbell_cbk(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID], c2s_fr_tsmt_init_cbk);
			//LOG_MSG(KERN_ERR"Rx  Doorbell callback registered\n");
#endif

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
			/* Initialize the bridge with Application logic related mappings */
			InitBridge_App((u64) ptr_dma_desc->dma_reg_virt_base_addr, 
					(u32) ptr_dma_desc->dma_reg_phy_base_addr, 
					(u64) ptr_dma_desc->cntrl_func_virt_base_addr, 
					(u32) ptr_dma_desc->cntrl_func_phy_base_addr);
#endif

			xraw_DriverState = REGISTERED;
			//LOG_MSG(KERN_ERR"\n Successfully registered with Tx and Rx channels of Expresso DMA\n");

		}
	}
	RawTestMode |=TEST_START;
	RawTestMode |= ENABLE_LOOPBACK;

	/* Now allocating Memory for For FrameBuffer */
	INIT_LIST_HEAD(&fb_data_0.list);
	if (0 != allocate_framebuffer_memory(&fb_data_0, FB_VIRT_SIZE))
		goto error;
	//LOG_MSG(KERN_ERR"Framebuffer0: size: %d, count: %d \n", fb_data_0.buff_size, fb_data_0.buff_count);
	fb_data_0.pos = 0;

	INIT_LIST_HEAD(&fb_data_1.list);
	if (0 != allocate_framebuffer_memory(&fb_data_1, FB_VIRT_SIZE))
		goto error;
	//LOG_MSG(KERN_ERR"Framebuffer0: size: %d, count: %d \n", fb_data_1.buff_size, fb_data_1.buff_count);
	fb_data_1.pos = 0;
#ifdef V4L2_DEVICE
	init_v4l2();
#endif
	/* now enabling the output */

	//ustate.TestMode = TEST_START | ENABLE_MOVINGVIDEO | ENABLE_LOOPBACK | ENABLE_SOBELFILTER; 
	// ustate.MinPktSize = 0;
	//ustate.MaxPktSize = 8294400;
	// mySetState (handle[0], &ustate, 0x54545454);
	return 0;

error: 
	spin_lock_bh (&RawLock);
	xraw_DriverState = UNREGISTERED;
	spin_unlock_bh (&RawLock);
	platform_device_put(xil_fb_device);
	platform_driver_unregister(&xil_fb_driver);
	// cdev_del(xrawCdev);
	// unregister_chrdev_region (xrawDev, 1);

	return -1;      
}

	static void __exit
rawdata_cleanup (void)
{

	/* Stop any running tests, else the hardware's packet checker &
	 * generator will continue to run.
	 */
	//  XIo_Out32 (TXbarbase + TX_CONFIG_ADDRESS, 0);

	//  XIo_Out32 (TXbarbase + RX_CONFIG_ADDRESS, 0);
	/* Set stop test bit */

	//ustate.TestMode = ENABLE_LOOPBACK;
	//ustate.MinPktSize = 0U;
	//ustate.MaxPktSize = 0;
	//mySetState (handle[0], &ustate, 0x54545454);


	LOG_MSG (KERN_INFO "%s: Unregistering Xilinx driver from kernel.\n", MYNAME);
	xraw_DriverState = UNREGISTERED;

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	/* Flush workqueue */
	flush_workqueue(rx_dst_workq);
	mdelay (2000);
	/* Destroy Work Queue */
	destroy_workqueue(rx_dst_workq);
	//Tx cHannel
	/* Stop the IOs over channel */
	xlnx_deactivate_dma_channel(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]);
	//xlnx_stop_channel_IO(ptr_chan_s2c, true);
	xlnx_dealloc_queues(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]);
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	//TxAux Channel
	xlnx_deactivate_dma_channel(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]);
	//	xlnx_stop_channel_IO(ptr_TxAuxapp_dma_desc, true);
	xlnx_dealloc_queues(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]);
#endif

	//Rx Channel

	xlnx_deactivate_dma_channel(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]);
	//	xlnx_stop_channel_IO(ptr_rxapp_dma_desc, true);
	xlnx_dealloc_queues(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]);

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	//Rx Aux Channel	
	xlnx_deactivate_dma_channel(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]);
	//	xlnx_stop_channel_IO(ptr_rxauxapp_dma_desc, true);
	xlnx_dealloc_queues(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]);
#endif
	/* Freeing Kernel Memory of Framebuffer*/
#ifdef V4L2_DEVICE
	cleanup_v4l2();
#endif
	free_framebuffer_memory(&fb_data_0);
	free_framebuffer_memory(&fb_data_1);
	platform_device_unregister(xil_fb_device);
	platform_driver_unregister(&xil_fb_driver);

}

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
static void ResetDMAonStopTest(void)
{
	int ret;
	int i,j;

	//platform_t pfrom = HOST;

	unsigned int q_num_elements = NUM_Q_ELEM;
	unsigned int aux_q_num_elements = NUM_AUX_Q_ELEM;
	unsigned int rx_aux_q_num_elements = RX_NUM_AUX_Q_ELEM;
	unsigned int data_q_addr_hi;
	unsigned int data_q_addr_lo;
	unsigned int sta_q_addr_hi;
	unsigned int sta_q_addr_lo;
	//	direction_t dir;
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	char name_buf[50];
	dma_addr_t paddr_buf;
	dma_addr_t TxDsttemp, RxDsttemp;
	unsigned short uid = 1;
	int retval;
	int state;
#endif

	/* Flush workqueue */
	flush_workqueue(rx_dst_workq);
	mdelay (2000);
	/* Destroy Work Queue */
	destroy_workqueue(rx_dst_workq);
	//Tx cHannel
	/* Stop the IOs over channel */
	xlnx_deactivate_dma_channel(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]);
	//xlnx_stop_channel_IO(ptr_chan_s2c, true);
	xlnx_dealloc_queues(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID]);
	//TxAux Channel
	xlnx_deactivate_dma_channel(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]);
	//	xlnx_stop_channel_IO(ptr_TxAuxapp_dma_desc, true);
	xlnx_dealloc_queues(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]);

	//Rx Channel

	xlnx_deactivate_dma_channel(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]);
	//	xlnx_stop_channel_IO(ptr_rxapp_dma_desc, true);
	xlnx_dealloc_queues(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID]);

	//Rx Aux Channel	
	xlnx_deactivate_dma_channel(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]);
	//	xlnx_stop_channel_IO(ptr_rxauxapp_dma_desc, true);
	xlnx_dealloc_queues(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID]);
	ret = xlnx_alloc_queues(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID], &data_q_addr_hi, //Physical address
			&data_q_addr_lo,//Physical address
			&sta_q_addr_hi,//Physical address
			&sta_q_addr_lo,//Physical address
			q_num_elements);
	if(ret < XLNX_SUCCESS) 
	{
		LOG_MSG(KERN_ERR"\n- Could not allocate Qs for s2c %d channel %d\n",VIDEO_TX_CHANNEL_ID, ret);
		goto error;
	}
	ret = xlnx_activate_dma_channel(ptr_app_dma_desc, ptr_chan_s2c[VIDEO_TX_CHANNEL_ID],
			data_q_addr_hi,data_q_addr_lo,q_num_elements,
			sta_q_addr_hi,sta_q_addr_lo,q_num_elements , COALESE_CNT);
	if(ret < XLNX_SUCCESS) 
	{
		LOG_MSG(KERN_ERR"\n- Could not activate s2c %d channel %d\n", VIDEO_TX_CHANNEL_ID,ret);
		goto error;
	}

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	ret = xlnx_alloc_queues(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID], &data_q_addr_hi, //Physical address
			&data_q_addr_lo,//Physical address
			&sta_q_addr_hi,//Physical address
			&sta_q_addr_lo,//Physical address
			aux_q_num_elements);
	if(ret < XLNX_SUCCESS) 
	{
		LOG_MSG(KERN_ERR"\n- Could not allocate Qs for s2c dst %d channel %d\n",VIDEO_TX_CHANNEL_ID, ret);
		goto error;
	}
	ret = xlnx_activate_dma_channel(ptr_app_dma_desc, ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID],
			data_q_addr_hi,data_q_addr_lo,aux_q_num_elements,
			sta_q_addr_hi,sta_q_addr_lo,aux_q_num_elements, COALESE_CNT);
	if(ret < XLNX_SUCCESS) 
	{
		LOG_MSG(KERN_ERR"\n- Could not activate s2c dst %d channel %d\n", VIDEO_TX_CHANNEL_ID,ret);
		goto error;
	}
#endif
#endif
	/* Registering the Rx channel */
	ret = xlnx_alloc_queues(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID], &data_q_addr_hi, //Physical address
			&data_q_addr_lo,//Physical address
			&sta_q_addr_hi,//Physical address
			&sta_q_addr_lo,//Physical address
			q_num_elements);
	if(ret < XLNX_SUCCESS) 
	{
		LOG_MSG(KERN_ERR"\n- Could not allocate Qs for s2c rx %d channel %d\n",VIDEO_RX_CHANNEL_ID, ret);
		goto error;
	}
	ret = xlnx_activate_dma_channel(ptr_app_dma_desc, ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID],
			data_q_addr_hi,data_q_addr_lo,q_num_elements,
			sta_q_addr_hi,sta_q_addr_lo,q_num_elements,COALESE_CNT);
	if(ret < XLNX_SUCCESS) 
	{
		LOG_MSG(KERN_ERR"\n- Could not activate s2c rx %d channel %d\n", VIDEO_RX_CHANNEL_ID,ret);
		goto error;
	}
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	ret = xlnx_alloc_queues(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID], &data_q_addr_hi, //Physical address
			&data_q_addr_lo,//Physical address
			&sta_q_addr_hi,//Physical address
			&sta_q_addr_lo,//Physical address
			rx_aux_q_num_elements);
	if(ret < XLNX_SUCCESS) 
	{
		LOG_MSG(KERN_ERR"\n- Could not allocate Qs for rx s2c dst %d channel %d\n",VIDEO_RX_CHANNEL_ID, ret);
		goto error;
	}
	ret = xlnx_activate_dma_channel(ptr_app_dma_desc, ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID],
			data_q_addr_hi,data_q_addr_lo,rx_aux_q_num_elements,
			sta_q_addr_hi,sta_q_addr_lo,rx_aux_q_num_elements,COALESE_CNT);
	if(ret < XLNX_SUCCESS) 
	{
		LOG_MSG(KERN_ERR"\n- Could not activate rx s2c dst %d channel %d\n", VIDEO_RX_CHANNEL_ID,ret);
		goto error;
	}
#endif

	LOG_MSG(KERN_ERR"\n- Activated both channels along with aux");

	addr_typ_transfer[VIDEO_TX_CHANNEL_ID] = PHYS_ADDR;
	addr_typ_transfer[VIDEO_RX_CHANNEL_ID] = PHYS_ADDR;
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	addr_typ_aux_transfer[VIDEO_TX_CHANNEL_ID] = EP_PHYS_ADDR;
	addr_typ_aux_transfer[VIDEO_RX_CHANNEL_ID] = EP_PHYS_ADDR;
	for(i=0;i<NUM_FRAMES_IN_PLDDR;i++)
	{
		psDstQsRangeTx[i].frame_start_address = PS_DDR_VDMA_TX_ADDR_BASE + (i * VIDEO_FRAME_SIZE);
		//LOG_MSG(KERN_ERR"Tx Frame %d start address %X\n",i + 1,psDstQsRangeTx[i].frame_start_address);
		psDstQsRangeTx[i].frame_end_address = psDstQsRangeTx[i].frame_start_address + VIDEO_FRAME_SIZE;
		psDstQsRangeRx[i].frame_start_address = PS_DDR_VDMA_RX_ADDR_BASE + (i * VIDEO_FRAME_SIZE); 
		//LOG_MSG(KERN_ERR"Rx Frame %d start address %X\n",i + 1, psDstQsRangeRx[i].frame_start_address);
		psDstQsRangeRx[i].frame_end_address = psDstQsRangeRx[i].frame_start_address + VIDEO_FRAME_SIZE;
	}

	TxDstDdrPhyAdrs = psDstQsRangeTx[0].frame_start_address;
	RxDstDdrPhyAdrs = psDstQsRangeRx[0].frame_start_address;
	TxDsttemp = TxDstDdrPhyAdrs;
	RxDsttemp = RxDstDdrPhyAdrs;
	LOG_MSG(KERN_ERR"\n--> About to populate Rx destination queue with DDR addresses");
	for(i=0;i<(NUM_FRAMES_IN_PLDDR);i++)
	{
		for(j=0; j<FRAME_PIXEL_ROWS;j++)
		{
			paddr_buf = (dma_addr_t)(psDstQsRangeTx[i].frame_start_address + (j * (MAXPKTSIZE)));
			//LOCK_DMA_CHANNEL(&ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->channel_lock);
			retval = xlnx_data_frag_io(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID],(unsigned char *)paddr_buf,addr_typ_aux_transfer[VIDEO_TX_CHANNEL_ID],\
					MAXPKTSIZE,cbk_transfer_video_dst_row ,uid, true, (void *)paddr_buf);

			if(retval < XLNX_SUCCESS) 
			{
				state = ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->chann_state;

#ifdef PUMP_APP_DBG_PRNT
				LOG_MSG(KERN_ERR"\n- Failed::::::Buffer allocated transmit %d\n", retval);
#endif
				if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
				{
#ifdef PUMP_APP_DBG_PRNT
					LOG_MSG(KERN_ERR"\n- Context Q saturated %d\n",state);
#endif
					ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->chann_state = XLNX_DMA_CHANN_NO_ERR;
					//	set_task_state(current, TASK_INTERRUPTIBLE);  
					//	UNLOCK_DMA_CHANNEL(&ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->channel_lock);
				}

			}
			else
			{
				// LOG_MSG(KERN_ERR"Programmed %p for Tx Aux Queue\n",paddr_buf);
				//					       TxDsttemp += MAXPKTSIZE;
				//	UNLOCK_DMA_CHANNEL(&ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID]->channel_lock);

			}
		}
	}
	sprintf(name_buf,"Rx Dst WorkQueue");
	rx_dst_workq = create_singlethread_workqueue((const char*)name_buf); 
	if(rx_dst_workq != NULL)
	{
		//LOG_MSG(KERN_ERR"Rx Dst Work Queue created successfully\n");
	}
	INIT_WORK(&(rx_dst_work), c2s_processed_fr_tsmt);
	LOG_MSG(KERN_ERR"\n--> Created Rx Work Queue");

	xlnx_register_doorbell_cbk(ptr_rxchan_s2c_dst[VIDEO_RX_CHANNEL_ID], c2s_fr_tsmt_init_cbk);
	LOG_MSG(KERN_ERR"\n--> Registering Call back at %d ",__LINE__);
	LOG_MSG(KERN_ERR"Rx Aux Doorbell callback registered\n");
	xlnx_register_doorbell_cbk(ptr_chan_s2c_dst[VIDEO_TX_CHANNEL_ID], c2s_fr_tsmt_init_cbk);
	LOG_MSG(KERN_ERR"\n--> Registering Call back at %d ",__LINE__);
	LOG_MSG(KERN_ERR"Tx Aux Doorbell callback registered\n");

	xlnx_register_doorbell_cbk(ptr_chan_s2c[VIDEO_TX_CHANNEL_ID], c2s_fr_tsmt_init_cbk);
	LOG_MSG(KERN_ERR"\n--> Registering Call back at %d ",__LINE__);	
	LOG_MSG(KERN_ERR"Tx Doorbell callback registered\n");

	xlnx_register_doorbell_cbk(ptr_rxchan_s2c[VIDEO_RX_CHANNEL_ID], c2s_fr_tsmt_init_cbk);
	LOG_MSG(KERN_ERR"\n--> Registering Call back at %d ",__LINE__);	
	LOG_MSG(KERN_ERR"Rx  Doorbell callback registered\n");
#endif
	tx_channel_num_empty_bds = NUM_Q_ELEM - 2;
	rx_channel_num_empty_bds = NUM_Q_ELEM - 2;
	index = 0;
	xraw_DriverState = REGISTERED;
	//LOG_MSG(KERN_ERR"\n Successfully registered with Tx and Rx channels of Expresso DMA\n");
	return;


error: 
	spin_lock_bh (&RawLock);
	xraw_DriverState = UNREGISTERED;
	spin_unlock_bh (&RawLock);
	platform_device_put(xil_fb_device);
	platform_driver_unregister(&xil_fb_driver);
}
#endif

module_init (rawdata_init);
module_exit (rawdata_cleanup);

MODULE_AUTHOR ("Xilinx, Inc.");
MODULE_DESCRIPTION (DRIVER_DESCRIPTION);
MODULE_LICENSE ("GPL");
