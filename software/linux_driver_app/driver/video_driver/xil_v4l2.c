#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/vmalloc.h>
#include <linux/time.h>
#include <linux/slab.h>
#include <linux/pagemap.h>
#include <linux/videodev2.h> 
#include <media/videobuf2-vmalloc.h> 
#include <media/v4l2-device.h>
#include <media/v4l2-ioctl.h>
#include <media/v4l2-fh.h> 
#include <media/v4l2-event.h>
#include <media/v4l2-common.h>
#include "../include/xdma_user.h"
#include "../include/xpmon_be.h"
#include "xil_fb.h"

#define V4L2_BUFFER_MASK_FLAGS  (V4L2_BUF_FLAG_MAPPED | V4L2_BUF_FLAG_QUEUED | \
		V4L2_BUF_FLAG_DONE | V4L2_BUF_FLAG_ERROR | \
		V4L2_BUF_FLAG_PREPARED | V4L2_BUF_FLAG_TIMECODE)
#define CHUNK_SIZE 614400
#define GRABBER_BUF_SIZE FRAME_PIXEL_ROWS * FRAME_PIXEL_COLS * NUM_BYTES_PIXEL
#define LINE_BUF_SIZE (FRAME_PIXEL_COLS * NUM_BYTES_PIXEL)
#define MAX_WIDTH FRAME_PIXEL_COLS
//#define MAX_HEIGHT 1200
#define MAX_HEIGHT FRAME_PIXEL_ROWS
#define NUM_INPUTS 1
#define BUF_COUNT 3
#define MAX_QUEUE_SIZE 3
#define FPS_MAX 25
#define POLL_TIMEOUT 100

//#define ENABLE_DEBUG 1

#ifdef ENABLE_DEBUG
#define LOG_MSG printk
#else
#define LOG_MSG(...)
#endif

typedef struct {
	char     * buffer;
	int      buff_size;
	int      buff_count;
	int      pos;
	int      queued_pages;
	struct   list_head list; /* kernel's list structure */
} frame_grabber_buffer;

static const struct v4l2_fract
tpf_min     = {.numerator = 1,		.denominator = FPS_MAX},
	    tpf_max     = {.numerator = FPS_MAX,	.denominator = 1},
	    tpf_default = {.numerator = 1001,	.denominator = 30000};	/* NTSC */

struct grabber_fmt {
	const char *name;
	u32   fourcc;          /* v4l2 format id */
	u8    depth;
	bool  is_yuv;
};

struct queue {
	int queue[MAX_QUEUE_SIZE];
	int first;
	int count;
};

static int queue_full(struct queue *queue) {
	if (queue->count == MAX_QUEUE_SIZE)
		return 1;
	else
		return 0;
}
static int queue_empty(struct queue *queue) {
	if (queue->count == 0)
		return 1;
	else
		return 0;
}

static int queue_buffer (struct queue *queue, int index)
{
	int qindex = 0;
	LOG_MSG(KERN_INFO "queuing before , count %d first %d index %d\n ",\
			queue->count, queue->first, index);
	if (queue_full(queue)) {
		return -1;
	} else {
		qindex = ((queue->first + queue->count) >= MAX_QUEUE_SIZE) ?
			queue->first + queue->count - MAX_QUEUE_SIZE :
			queue->first + queue->count;
		LOG_MSG(KERN_INFO "Qindex is %d\n",qindex);
		queue->queue[qindex] = index;
		queue->count++;
		LOG_MSG(KERN_INFO "queuing after , count %d first %d\n",\
				queue->count, queue->first);
		LOG_MSG(KERN_INFO "QUEUE: %d %d %d\n",\
				queue->queue[0],\
				queue->queue[1],\
				queue->queue[2]);
		return 0;
	}
}

static int dqueue_buffer (struct queue *queue)
{
	int rc;
	LOG_MSG(KERN_INFO "dequeuing before, count %d first %d\n",\
			queue->count, queue->first);
	LOG_MSG(KERN_INFO "QUEUE: %d %d %d\n",\
			queue->queue[0],\
			queue->queue[1],\
			queue->queue[2]);
	if (queue_empty(queue)) {
		rc = -1;
	} else {
		rc = queue->queue[queue->first];
		if (queue->first == MAX_QUEUE_SIZE - 1)
			queue->first = 0;
		else
			queue->first++;
		queue->count--;
	}
	LOG_MSG(KERN_INFO "dequeuing after , count %d first %d, index %d\n",\
			queue->count, queue->first, rc);
	return rc;
}

static int queue_first (struct queue *queue)
{
	int rc;
	if (queue_empty(queue)) {
		rc = -1;
	} else {
		rc = queue->queue[queue->first];
	}
	LOG_MSG(KERN_INFO "dequeuing after , count %d first %d, index %d\n",\
			queue->count, queue->first, rc);
	return rc;
}





static const struct grabber_fmt formats[] = {

	{
		.name     = "RGB32 (BE)",
		.fourcc   = V4L2_PIX_FMT_BGR32, /* bgra */
		.depth    = 32,
	},
	{
		.name     = "RGB32 (LE)",
		.fourcc   = V4L2_PIX_FMT_RGB32, /* argb */
		.depth    = 32,
	},

};

static const struct grabber_fmt *__get_format(u32 pixelformat)
{
	const struct grabber_fmt *fmt;
	unsigned int k;

	for (k = 0; k < ARRAY_SIZE(formats); k++) {
		fmt = &formats[k];
		if (fmt->fourcc == pixelformat)
			break;
	}

	if (k == ARRAY_SIZE(formats))
		return NULL;

	return &formats[k];
}

static const struct grabber_fmt *get_format(struct v4l2_format *f)
{
	return __get_format(f->fmt.pix.pixelformat);
}

struct v4l2_grabber_priv {
	frame_grabber_buffer buf[BUF_COUNT];
	int index;
	struct queue inqueue;
	struct queue outqueue;
};

struct v4l2_grabber_device {
	struct v4l2_device v4l2_dev;
	struct video_device *vdev;
	/* pixel and stream format */
	struct v4l2_pix_format pix_format;
	struct v4l2_captureparm capture_param;
	unsigned long frame_jiffies;
	const struct grabber_fmt      *fmt;
	unsigned int               width, height;
	unsigned int                pixelsize;

	/* buffers stuff */
	u8 *image;         /* pointer to actual buffers data */
	unsigned long int imagesize;  /* size of buffers data */
	int buffers_number;  /* should not be big, 4 is a good choice */
	// struct v4l2l_buffer buffers[MAX_BUFFERS];	/* inner driver buffers */
	int used_buffers; /* number of the actually used buffers */
	int max_openers;  /* how many times can this device be opened */

	int write_position; /* number of last written frame + 1 */
	struct list_head outbufs_list; /* buffers in output DQBUF order */
	// int bufpos2index[MAX_BUFFERS]; /* mapping of (read/write_position % used_buffers)
	//* to inner buffer index */
	long buffer_size;

	/* sustain_framerate stuff */
	struct timer_list sustain_timer;
	unsigned int reread_count;

	/* timeout stuff */
	unsigned long timeout_jiffies; /* CID_TIMEOUT; 0 means disabled */
	int timeout_image_io; /* CID_TIMEOUT_IMAGE_IO; next opener will
			       * read/write to timeout_image */
	u8 *timeout_image; /* copy of it will be captured when timeout passes */

	/* sync stuff */
	atomic_t open_count;
	/* Input Number */
	int input;


	int ready_for_capture;/* set to true when at least one writer opened
			       * device and negotiated format */
	int ready_for_output; /* set to true when no writer is currently attached
			       * this differs slightly from !ready_for_capture,
			       * e.g. when using fallback images */
	int announce_all_caps;/* set to false, if device caps (OUTPUT/CAPTURE)
			       * should only be announced if the resp. "ready"
			       * flag is set; default=TRUE */
	struct v4l2_fract          timeperframe;

	wait_queue_head_t read_event;
	spinlock_t lock;
	struct  v4l2_grabber_priv priv;

};

struct v4l2_grabber_device *dev;

/* DMA Queue Helper function */
int dma_setup_receive_image(int index)
{
	int i;
	int pos_in_buf = 0;
	frame_grabber_buffer *grabber_buffer;
	struct list_head *pos;
	int transferred_pages = 0;

	//FIXME : Add error handling
	LOG_MSG(KERN_ERR"At %s() %d dma_setup_receive_image start",__FUNCTION__,__LINE__);
	grabber_buffer = &dev->priv.buf[index];
	pos = &grabber_buffer->list;
	get_dma_lock();
	for (i=0;i<MAX_HEIGHT;i++){
		if ((pos_in_buf + LINE_BUF_SIZE) > CHUNK_SIZE) {
			pos = pos->next;
			grabber_buffer = list_entry (pos,frame_grabber_buffer, list);
			pos_in_buf = 0;
		}
		transferred_pages += receive_packet(grabber_buffer->buffer + pos_in_buf,LINE_BUF_SIZE);
		pos_in_buf += LINE_BUF_SIZE;
	}
	release_dma_lock();
	LOG_MSG(KERN_ERR"At %s() %d dma_setup_receive_image end",__FUNCTION__,__LINE__);
	dev->priv.buf[index].queued_pages = transferred_pages;
	return transferred_pages;
}

/* ------------------------------------------------------------------
   IOCTL vidioc handling
   ------------------------------------------------------------------*/
static int vidioc_querycap(struct file *file, void  *priv,
		struct v4l2_capability *cap)
{
	strcpy(cap->driver, "ZC706 grabber");
	strcpy(cap->card, "ZC706 grabber");
	snprintf(cap->bus_info, sizeof(cap->bus_info),
			"platform:%s", dev->v4l2_dev.name);
#if LINUX_VERSION_CODE > KERNEL_VERSION(3,6,0)
	cap->device_caps = V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_STREAMING |
		V4L2_CAP_READWRITE;
	cap->capabilities = cap->device_caps | V4L2_CAP_DEVICE_CAPS;
#else
	cap->capabilities = V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_STREAMING | V4L2_CAP_READWRITE;
#endif

	return 0;
}

static int vidioc_enum_fmt_vid_cap(struct file *file, void  *priv,
		struct v4l2_fmtdesc *f)
{
	const struct grabber_fmt *fmt;

	LOG_MSG(KERN_INFO "IOCTL: Enum\n");
	if (f->index >= ARRAY_SIZE(formats))
		return -EINVAL;

	fmt = &formats[f->index];

	strlcpy(f->description, fmt->name, sizeof(f->description));
	f->pixelformat = fmt->fourcc;
	return 0;
}

static int vidioc_g_fmt_vid_cap(struct file *file, void *priv,
		struct v4l2_format *f)
{
	LOG_MSG("IOCTL: G_FMT_VID_CAP\n");
	f->fmt.pix.width        = dev->width;
	f->fmt.pix.height       = dev->height;
	f->fmt.pix.field        = V4L2_FIELD_INTERLACED;
	f->fmt.pix.pixelformat  = dev->fmt->fourcc;
	f->fmt.pix.bytesperline =
		(f->fmt.pix.width * dev->fmt->depth) >> 3;
	f->fmt.pix.sizeimage =
		f->fmt.pix.height * f->fmt.pix.bytesperline;
	if (dev->fmt->is_yuv)
		f->fmt.pix.colorspace = V4L2_COLORSPACE_SMPTE170M;
	else
		f->fmt.pix.colorspace = V4L2_COLORSPACE_SRGB;
	return 0;
}

static int vidioc_try_fmt_vid_cap(struct file *file, void *priv,
		struct v4l2_format *f)
{
	const struct grabber_fmt *fmt;

	fmt = get_format(f);
	if (!fmt) {
		LOG_MSG(KERN_INFO "Fourcc format (0x%08x) unknown.\n",\
				f->fmt.pix.pixelformat);
		f->fmt.pix.pixelformat = V4L2_PIX_FMT_BGR32;
		fmt = get_format(f);
	}

	f->fmt.pix.field = V4L2_FIELD_INTERLACED;
	v4l_bound_align_image(&f->fmt.pix.width, 48, MAX_WIDTH, 2,
			&f->fmt.pix.height, 32, MAX_HEIGHT, 0, 0);
	f->fmt.pix.bytesperline =
		(f->fmt.pix.width * fmt->depth) >> 3;
	f->fmt.pix.sizeimage =
		f->fmt.pix.height * f->fmt.pix.bytesperline;
	if (fmt->is_yuv)
		f->fmt.pix.colorspace = V4L2_COLORSPACE_SMPTE170M;
	else
		f->fmt.pix.colorspace = V4L2_COLORSPACE_SRGB;
	f->fmt.pix.priv = 0;
	return 0;
}

static int vidioc_s_fmt_vid_cap(struct file *file, void *priv,
		struct v4l2_format *f)
{
	int ret = vidioc_try_fmt_vid_cap(file, priv, f);

	LOG_MSG(KERN_INFO "IOCTL: S_FMT_VID_CAP.\n");
	if (ret < 0)
		return ret;
	dev->fmt = get_format(f);
	dev->pixelsize = dev->fmt->depth / 8;
	dev->width = f->fmt.pix.width;
	dev->height = f->fmt.pix.height;
	return 0;
}

static int vidioc_enum_framesizes(struct file *file, void *fh,
		struct v4l2_frmsizeenum *fsize)
{
	static const struct v4l2_frmsize_stepwise sizes = {
		48, MAX_WIDTH, 4,
#ifdef RES_720P
		720, MAX_HEIGHT, 1
#else
			1080, MAX_HEIGHT, 1
#endif
	};
	int i;

	LOG_MSG(KERN_INFO "IOCTL: ENUM_FRAMESIZES.\n");
	if (fsize->index)
		return -EINVAL;
	for (i = 0; i < ARRAY_SIZE(formats); i++)
		if (formats[i].fourcc == fsize->pixel_format)
			break;
	if (i == ARRAY_SIZE(formats))
		return -EINVAL;
	fsize->type = V4L2_FRMSIZE_TYPE_STEPWISE;
	fsize->stepwise = sizes;
	return 0;
}

static int vidioc_reqbufs(struct file *file, void *fh,
		struct v4l2_requestbuffers *rb)
{
	LOG_MSG(KERN_INFO "Vidioc Reqbufs, requested %d bufs\n",
			rb->count);
	rb->count = BUF_COUNT;
	return 0;
}

static int vidioc_querybuf(struct file *file, void *fh,
		struct v4l2_buffer *buf)
{
	LOG_MSG(KERN_INFO "Querying buffer %d\n",buf->index);
	if ((buf->type != V4L2_BUF_TYPE_VIDEO_CAPTURE) | (buf->index >= BUF_COUNT))
		return -EINVAL;
	buf->length = GRABBER_BUF_SIZE;
	buf->m.offset = 0;
	dev->priv.index = buf->index;
	return 0;
}
static int vidioc_qbuf(struct file *file, void *fh, struct v4l2_buffer *b)
{
	struct v4l2_grabber_priv *priv = &dev->priv;

	LOG_MSG(KERN_INFO "QBUF start\n");
	queue_buffer (&priv->inqueue, b->index);
	dma_setup_receive_image(b->index);
	LOG_MSG(KERN_INFO "QBUF end\n");
	return 0;
}

static int vidioc_dqbuf(struct file *file, void *fh, struct v4l2_buffer *b)
{
	struct v4l2_grabber_priv *priv = &dev->priv;
	int index;
	struct timeval ts;

	if (queue_empty(&priv->outqueue)) {
		LOG_MSG(KERN_INFO "No new image\n");
		return -1;
	} else {
		index = dqueue_buffer (&priv->outqueue);
		b->field = V4L2_FIELD_NONE;
		b->flags &= ~V4L2_BUFFER_MASK_FLAGS;
		b->flags |=V4L2_BUF_FLAG_TIMECODE;
		b->bytesused = GRABBER_BUF_SIZE;
		do_gettimeofday(&ts);
		b->timestamp = ts;
		LOG_MSG(KERN_INFO "Dequeued Index %d\n", index);
		b->index = index;
		return 0;
	}
}


/* only one input in this sample driver */
static int vidioc_enum_input(struct file *file, void *priv,
		struct v4l2_input *inp)
{
	if (inp->index >= NUM_INPUTS)
		return -EINVAL;
	inp->type = V4L2_INPUT_TYPE_CAMERA;
	sprintf(inp->name, "Camera %u", inp->index);
	return 0;
}

static int vidioc_g_input(struct file *file, void *priv, unsigned int *i)
{
	*i = dev->input;
	return 0;
}

static int vidioc_s_input(struct file *file, void *priv, unsigned int i)
{
	if (i >= NUM_INPUTS)
		return -EINVAL;

	if (i == dev->input)
		return 0;
	dev->input = i;
	return 0;
}

/* timeperframe is arbitrary and continuous */
static int vidioc_enum_frameintervals(struct file *file, void *priv,
		struct v4l2_frmivalenum *fival)
{
	const struct grabber_fmt *fmt;

	if (fival->index)
		return -EINVAL;

	fmt = __get_format(fival->pixel_format);
	if (!fmt)
		return -EINVAL;

	/* regarding width & height - we support any */

	fival->type = V4L2_FRMIVAL_TYPE_CONTINUOUS;

	/* fill in stepwise (step=1.0 is required by V4L2 spec) */
	fival->stepwise.min  = tpf_min;
	fival->stepwise.max  = tpf_max;
	fival->stepwise.step = (struct v4l2_fract) {1, 1};

	return 0;
}

static int vidioc_g_parm(struct file *file, void *priv,
		struct v4l2_streamparm *parm)
{

	if (parm->type != V4L2_BUF_TYPE_VIDEO_CAPTURE)
		return -EINVAL;

	parm->parm.capture.capability   = V4L2_CAP_TIMEPERFRAME;
	parm->parm.capture.timeperframe = dev->timeperframe;
	parm->parm.capture.readbuffers  = 1;
	return 0;
}

#define FRACT_CMP(a, OP, b)	\
	((u64)(a).numerator * (b).denominator  OP  (u64)(b).numerator * (a).denominator)

static int vidioc_s_parm(struct file *file, void *priv,
		struct v4l2_streamparm *parm)
{
	struct v4l2_fract tpf;

	if (parm->type != V4L2_BUF_TYPE_VIDEO_CAPTURE)
		return -EINVAL;

	tpf = parm->parm.capture.timeperframe;

	/* tpf: {*, 0} resets timing; clip to [min, max]*/
	tpf = tpf.denominator ? tpf : tpf_default;
	tpf = FRACT_CMP(tpf, <, tpf_min) ? tpf_min : tpf;
	tpf = FRACT_CMP(tpf, >, tpf_max) ? tpf_max : tpf;

	dev->timeperframe = tpf;
	parm->parm.capture.timeperframe = tpf;
	parm->parm.capture.readbuffers  = 1;
	return 0;
}

static int vidioc_streamon(struct file *file, void *priv, enum v4l2_buf_type i)
{
	LOG_MSG(KERN_INFO "Stream On\n");
	return 0;
}

static int vidioc_streamoff(struct file *file, void *priv, enum v4l2_buf_type i)
{
	struct v4l2_grabber_priv *private = &dev->priv;

	LOG_MSG(KERN_INFO "Stream off\n");
	// FIXME FLushinqueue, FLUSH buffers
	private->inqueue.count = 0;
	private->outqueue.count = 0;
	msleep(100);
	LOG_MSG(KERN_INFO "RXDONE %d\n",rx_done_poll(3000));
	msleep(100);
	LOG_MSG(KERN_INFO "RXDONE %d\n",rx_done_poll(3000));
	return 0;
}


static int v4l2_grabber_open(struct file *file)
{
	LOG_MSG(KERN_INFO "Opening Video4 Linux device\n");
	return 0;
}

static int v4l2_grabber_close(struct file *file)
{
	LOG_MSG(KERN_INFO "Closing Video4 Linux device\n");
	return 0;
}
static ssize_t v4l2_grabber_read(struct file *file,
		char __user *buf, size_t count, loff_t *ppos)
{
	ssize_t transferred = 0;
	int transfer_size;
	frame_grabber_buffer *grabber_buffer;
	struct list_head *pos;

	LOG_MSG (KERN_INFO "READING Video4 Linux device\n");
	grabber_buffer = &dev->priv.buf[0];
	dma_setup_receive_image(0);
	LOG_MSG(KERN_INFO "queued pages: %d\n", grabber_buffer->queued_pages);
	msleep(100);
	LOG_MSG(KERN_INFO "RXDONE: %d\n",rx_done_poll(3000));

	/* Now transfer the data to userspace */
	transferred = 0;
	pos = &grabber_buffer->list;
	while (count > transferred) {
		transfer_size = (count  - transferred < CHUNK_SIZE) ?
			count - transferred : CHUNK_SIZE;
		if (0 != copy_to_user (buf+ transferred, grabber_buffer->buffer, transfer_size))
			return -1;
		LOG_MSG(KERN_INFO "Copying to Userspace device %d bytes\n",
				(int) transfer_size);
		pos = pos->next;
		grabber_buffer = list_entry (pos,frame_grabber_buffer, list);
		transferred += transfer_size;
	}
	return transferred;
}

static ssize_t v4l2_grabber_write(struct file *file, const char __user *buf,
		size_t count, loff_t *ppos)
{
	LOG_MSG (KERN_INFO "Writing Video4 Linux device\n");
	return 0;
}

static unsigned int v4l2_grabber_poll(struct file *file,
		struct poll_table_struct *pts)
{
	int done_pages;
	int buffer_index;
	int timeout_cnt = 0;
	frame_grabber_buffer *grabber_buffer;
	struct v4l2_grabber_priv *priv = &dev->priv;

	LOG_MSG (KERN_INFO "Polling Video4 Linux device\n");
	buffer_index = queue_first(&priv->inqueue);
	grabber_buffer = &priv->buf[buffer_index];

	while(queue_empty(&priv->outqueue)) {
		done_pages = rx_done_poll(2000);
		if (done_pages == 0) {
			if (timeout_cnt > POLL_TIMEOUT) {
				LOG_MSG(KERN_INFO "TIMEOUT \n");
				return POLLIN | POLLRDNORM;
			} else {
				timeout_cnt++;
				msleep(1);
			}
		} else {
			timeout_cnt = 0;
			if (done_pages >= grabber_buffer->queued_pages) {
				done_pages -= grabber_buffer->queued_pages;
				grabber_buffer->queued_pages = 0;
				dqueue_buffer(&priv->inqueue);
				LOG_MSG (KERN_INFO "New Frame : %d\n", buffer_index);
				queue_buffer(&priv->outqueue, buffer_index);
				if (done_pages > 0) {
					buffer_index = queue_first(&priv->inqueue);
					grabber_buffer = &dev->priv.buf[buffer_index];
					grabber_buffer->queued_pages -= done_pages;
				}
				return POLLIN | POLLRDNORM;
			} else {
				grabber_buffer->queued_pages -= done_pages;
			}
		}
	}
	return POLLIN | POLLRDNORM;
}


/**
 * @name    v4l2_grabber_mmap
 *
 * mmapping function
 *
 * @param [info]
 * @param [vma]
 *
 */

static int v4l2_grabber_mmap(struct file *filp,
		struct vm_area_struct *vma)
{
	unsigned long size = (unsigned long)(vma->vm_end-vma->vm_start);
	unsigned long mapped = 0;
	unsigned long map_size;
	char *buffer;
	struct list_head *pos;
	frame_grabber_buffer *grabber_buffer;

	LOG_MSG(KERN_INFO "mmap size: %lu\n", size);

	/* if userspace tries to mmap beyond end of our buffer, fail */
	if (size>GRABBER_BUF_SIZE)
		return -EINVAL;
	grabber_buffer = &dev->priv.buf[dev->priv.index];
	pos = &grabber_buffer->list;
	while (size > mapped) {
		/* start off at the start of the buffer */
		map_size = (size - mapped < CHUNK_SIZE) ? size - mapped : CHUNK_SIZE;
		buffer = grabber_buffer->buffer;
		memset (buffer, 0 ,map_size);
		if ((remap_pfn_range(vma,
						vma->vm_start+ mapped,
						virt_to_phys((void *)buffer) >> PAGE_SHIFT,
						map_size,
						vma->vm_page_prot)) < 0) {
			LOG_MSG(KERN_INFO "remap_pfn_range failed\n");
			return -EIO;
		} else {
			pos = pos->next;
			mapped += map_size;
			grabber_buffer = list_entry(pos, frame_grabber_buffer, list);
			LOG_MSG(KERN_INFO "Currently mapped : %lu get next buffer \n", mapped);
		}

		//next bufer
	}
	return 0;
}


/* LINUX V4L2 Interface */
static const struct v4l2_file_operations v4l2_grabber_fops = {
	.owner           = THIS_MODULE,
	.open            = v4l2_grabber_open,
	.release         = v4l2_grabber_close,
	.read            = v4l2_grabber_read,
	.write           = v4l2_grabber_write,
	.poll            = v4l2_grabber_poll,
	.mmap            = v4l2_grabber_mmap,
	.unlocked_ioctl  = video_ioctl2,
};

static const struct v4l2_ioctl_ops v4l2_grabber_ioctl_ops = {
	.vidioc_querycap          = vidioc_querycap,
	.vidioc_enum_fmt_vid_cap  = vidioc_enum_fmt_vid_cap,
	.vidioc_g_fmt_vid_cap     = vidioc_g_fmt_vid_cap,
	.vidioc_try_fmt_vid_cap   = vidioc_try_fmt_vid_cap,
	.vidioc_s_fmt_vid_cap     = vidioc_s_fmt_vid_cap,
	.vidioc_enum_framesizes   = vidioc_enum_framesizes,
	.vidioc_reqbufs           = vidioc_reqbufs,
	/* .vidioc_create_bufs   = vb2_ioctl_create_bufs, */
	/* .vidioc_prepare_buf   = vb2_ioctl_prepare_buf, */
	.vidioc_querybuf         = vidioc_querybuf,
	.vidioc_qbuf             = vidioc_qbuf,
	.vidioc_dqbuf            = vidioc_dqbuf,
	.vidioc_enum_input       = vidioc_enum_input,
	.vidioc_g_input          = vidioc_g_input,
	.vidioc_s_input          = vidioc_s_input,
	.vidioc_enum_frameintervals = vidioc_enum_frameintervals,
	.vidioc_g_parm           = vidioc_g_parm,
	.vidioc_s_parm           = vidioc_s_parm,
	.vidioc_streamon         = vidioc_streamon,
	.vidioc_streamoff        = vidioc_streamoff,
	/* .vidioc_log_status    = v4l2_ctrl_log_status, */
	/* .vidioc_subscribe_event = v4l2_ctrl_subscribe_event, */
	/* .vidioc_unsubscribe_event = v4l2_event_unsubscribe, */
};

int free_framegrabber_memory(frame_grabber_buffer *grabber_data) {
	frame_grabber_buffer *grabber_buffer;
	struct list_head *pos;
	pos = &grabber_data->list;
	while (pos != pos->next) {
		LOG_MSG(KERN_INFO "Removing one entry\n");
		grabber_buffer = list_entry(pos->next, frame_grabber_buffer, list);
		list_del(pos->next);
		kfree(grabber_buffer->buffer);
		kfree(grabber_buffer);
	}
	kfree(grabber_data->buffer);

	return 0;
}

int allocate_framegrabber_memory(frame_grabber_buffer *grabber_data, int size) {
	int grabber_current_size;
	int grabber_alloc_size;
	frame_grabber_buffer *grabber_buffer;

	grabber_data->buff_count = 0;
	grabber_current_size = 0;
	grabber_data->queued_pages = 0;
	grabber_alloc_size = CHUNK_SIZE; //starting with an allocateable size;
	grabber_buffer = grabber_data;
	while (grabber_current_size < size) {
		LOG_MSG(KERN_INFO "Trying to allocate %d Bytes, currently allocated %d\n",\
				grabber_alloc_size, grabber_current_size);
		grabber_buffer->buffer = (char*) kmalloc(grabber_alloc_size, GFP_KERNEL);
		if (NULL == grabber_buffer->buffer) {
			LOG_MSG("Size %d did not work trying %d\n", grabber_alloc_size,
					grabber_alloc_size >> 1);
			grabber_alloc_size = grabber_alloc_size >> 1;
		} else {
			memset(grabber_buffer->buffer,0, grabber_alloc_size);
			grabber_buffer->buff_size = grabber_alloc_size;
			grabber_current_size += grabber_alloc_size;
			grabber_data->buff_count++;
			if (grabber_current_size < size) {
				grabber_buffer = (frame_grabber_buffer*)
					kmalloc(sizeof(frame_grabber_buffer), GFP_KERNEL);
				if (NULL == grabber_buffer) {
					LOG_MSG(KERN_INFO "Allocation failed \n");
					goto error;
				} else {
					list_add(&grabber_buffer->list, &grabber_data->list);
				}
			}
		}
	}
	return 0;

error:
	free_framegrabber_memory(grabber_data);
	return -1;
}

int init_v4l2(void)
{
	int retval = 0;
	int i,j;

	LOG_MSG(KERN_INFO "Initializing Video4 Linux 2 device\n");
	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
	if (dev == NULL) {
		return -ENOMEM;
	}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,10)
	snprintf(dev->v4l2_dev.name, sizeof(dev->v4l2_dev.name),
			"xv4l2-dev-%03d", 0);
	retval = v4l2_device_register(NULL, &dev->v4l2_dev);

	if (retval)
		goto error_grabber_buf;
#endif

	for (i=0;i<BUF_COUNT; i++) {
		INIT_LIST_HEAD(&dev->priv.buf[i].list);
		if (0 != allocate_framegrabber_memory(&dev->priv.buf[i], GRABBER_BUF_SIZE)) {
			for (j=0;j<i;j++)
				free_framegrabber_memory(&dev->priv.buf[j]);
			goto error_grabber_buf;
		}
		LOG_MSG(KERN_ERR"Framegrabber buffer %i: size: %d, count: %d \n", i, dev->priv.buf[i].buff_size,\
				dev->priv.buf[i].buff_count);
		dev->priv.buf[i].pos = 0;
	}
	dev->vdev = video_device_alloc();
	if (dev->vdev == NULL) {
		LOG_MSG(KERN_ERR"video_device_alloc failed");
		retval = ENOMEM;
		goto error_vdev;
	}
	dev->vdev->tvnorms      = V4L2_STD_ALL;
#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,10)
	dev->vdev->current_norm = V4L2_STD_ALL;
#endif
#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,10)
	dev->vdev->v4l2_dev = &dev->v4l2_dev;
#endif
	dev->vdev->vfl_type     = VFL_TYPE_GRABBER;
	dev->vdev->fops         = &v4l2_grabber_fops;
	dev->vdev->ioctl_ops    = &v4l2_grabber_ioctl_ops;
	dev->vdev->release      = &video_device_release;
	dev->vdev->minor        = -1;
	dev->fmt = &formats[0];
	dev->width = 640;
	dev->height = 480;
	dev->pixelsize = dev->fmt->depth / 8;
	if (video_register_device(dev->vdev, VFL_TYPE_GRABBER, -1) < 0 ) {

		LOG_MSG(KERN_ERR"video_register_device failed");
		retval = ENOMEM;
		goto error_reg;
	}
	return retval;
error_reg:
	video_device_release(dev->vdev);
error_vdev:
#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,10)
	v4l2_device_unregister(&dev->v4l2_dev);
#endif
	for (i=0;i<BUF_COUNT; i++)
		free_framegrabber_memory(&dev->priv.buf[i]);
error_grabber_buf:
	kfree(dev);
	return -retval;
}


int cleanup_v4l2(void)
{
	int i;

	LOG_MSG(KERN_INFO "Removing Video4 Linux 2 device\n");
	for (i=0;i<BUF_COUNT; i++)
		free_framegrabber_memory(&dev->priv.buf[i]);
	kfree(video_get_drvdata(dev->vdev));
	video_unregister_device(dev->vdev);
#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,10)
	v4l2_device_unregister(&dev->v4l2_dev);
#endif
	kfree(dev);
	dev = NULL;
	return 0;
}
