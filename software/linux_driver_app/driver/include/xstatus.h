/*****************************************************************************/
/**
*
* @file xstatus.h
*
* This file contains Xilinx software status codes.  Status codes have their
* own data type called int.  These codes are used throughout the Xilinx
* device drivers.
*
* MODIFICATION HISTORY:
*
* Ver   Date     Changes
* ----- -------- -------------------------------------------------------
* 1.0   5/15/12 First release
*
*
******************************************************************************/

#ifndef XSTATUS_H   /* prevent circular inclusions */
#define XSTATUS_H   /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/

#include "xbasic_types.h"

/************************** Constant Definitions *****************************/

/*********************** Common status 0 - 500 *****************************/

#define XST_SUCCESS                     0L
#define XST_FAILURE                     1L
#define XST_DEVICE_IS_STARTED           5L
#define XST_DEVICE_IS_STOPPED           6L
#define XST_INVALID_PARAM               15L /* an invalid parameter was passed into the function */
#define XST_IS_STARTED                  23L /* used when part of device is already started i.e. sub channel */
#define XST_IS_STOPPED                  24L /* used when part of device is already stopped i.e. sub channel */

/************************** DMA status 511 - 530 ***************************/

#define XST_DMA_SG_LIST_EMPTY           513L  /* scatter gather list contains no buffer descriptors ready to be processed */
#define XST_DMA_SG_IS_STARTED           514L  /* scatter gather not stopped */
#define XST_DMA_SG_IS_STOPPED           515L  /* scatter gather not running */
#define XST_DMA_SG_LIST_FULL            517L  /* all the buffer desciptors of the scatter gather list are being used */
#define XST_DMA_SG_NO_LIST              523L  /* no scatter gather list has been created */
#define XST_DMA_SG_LIST_ERROR           526L  /* general purpose list access error */

/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

#ifdef __cplusplus
}
#endif

#endif /* end of protection macro */
