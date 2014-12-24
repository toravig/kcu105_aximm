//--------------------------------------------------------------------------------------------------------------------------------
// The frame_sync_logic does the following:
//
// ***** S2C direction *****
// 1.	Driver is going to write into AXI_INTR_ASSERT register after three video frames 
//    are transferred into the DDR4 memory. This would result in the assertion of 'int_dma' port. 
// 2.	The rising edge of the 'int_dma' port is detected and given as 'mm2s_fsync' to AXI VDMA.
// 3.	VDMA will start reading the video frames from DDR4 and present the same on Sobel filter's stream interface.
// 4.	VDMA will assert 'axi_vdma_tstvec[1]' when all the lines in a frame buffer are transferred.
// 5.	Fsync logic detects the rising edge of the test vector from VDMA and gives it out as mm2s_fsync.
//    The same approach is followed for the third video frame.
// 6.	The first FSYNC is driven by software raised doorbell and every 2 subsequent FSYNCs use the tstvec[1]. 
//    This repeats for all frames.
// 7. 'int_dma' once asserted, needs clearing of interrupt status to go down.A mechanism is required 
//    to inform s/w to start writing next 3 frames.
// 
// ***** C2S direction *****
// 1.	VDMA indicates the transfer of video frame by asserting tstvec[32]
// 2.	The fsync logic detects the rising edge of the test vector and writes into the PCIE_INTERRUPT_ASSERT
//    register of the DMA. (By driving the Slave AXI interface)
// 3.	The PCIe_INTERRUPT_ASSERT register is written once in three frames.
//    The fsync logic has to mask the rising edge of the tstvec[32] for second and third video frames.
// 4. The PCIe doorbell interrupt should be raised on every third frame being written into DDR by VDMA so that software reads back all 3 frames.
//--------------------------------------------------------------------------------------------------------------------------------

module frame_sync_logic #(
    // AXI Master Interface Parameters
    parameter   M_ID_WIDTH        = 4,          
    parameter   M_ADDR_WIDTH      = 32,         
    parameter   M_LEN_WIDTH       = 4,          
    parameter   M_DATA_WIDTH      = 32,         
    parameter   BASE_ADDR         = 32'h80000000
  )(    
    input                                       m_clk,
    input                                       m_resetn,
    input                                       interrupt_in,
    input                                       mm2s_all_lines_xfred,
    input                                       s2mm_all_lines_xfred,
    input       [M_ADDR_WIDTH-1:0]              scratchpad_reg,
    input       [M_DATA_WIDTH-1:0]              scratchpad_val,

    // AXI Master Interface (clk clock domain)
    output                                      m1_awvalid,  // Write Address Channel
    input                                       m1_awready,  //
    output      [M_ID_WIDTH-1:0]                m1_awid,     //
    output      [M_ADDR_WIDTH-1:0]              m1_awaddr,   //
    output      [M_LEN_WIDTH-1:0]               m1_awlen,    //
    output      [2:0]                           m1_awsize,   //
    output      [1:0]                           m1_awburst,  //
    output      [2:0]                           m1_awprot,   //
    output      [3:0]                           m1_awcache,  //

    output                                      m1_wvalid,   // Write Data Channel
    input                                       m1_wready,   //
    output      [M_ID_WIDTH-1:0]                m1_wid,      //
    output      [M_DATA_WIDTH-1:0]              m1_wdata,    //
    output      [(M_DATA_WIDTH/8)-1:0]          m1_wstrb,    //
    output                                      m1_wlast,    //

    input                                       m1_bvalid,   // Write Response Channel
    output                                      m1_bready,   //
    input   [M_ID_WIDTH-1:0]                    m1_bid,      //
    input   [1:0]                               m1_bresp,    //

    output                                      m1_arvalid,  // Read Address Channel
    input                                       m1_arready,  //
    output   [M_ID_WIDTH-1:0]                   m1_arid,     //
    output   [M_ADDR_WIDTH-1:0]                 m1_araddr,   //
    output   [M_LEN_WIDTH-1:0]                  m1_arlen,    //
    output   [2:0]                              m1_arsize,   //
    output   [1:0]                              m1_arburst,  //
    output   [2:0]                              m1_arprot,   //
    output   [3:0]                              m1_arcache,  //

    input                                       m1_rvalid,   // Read Data Channel
    output                                      m1_rready,   //
    input   [M_ID_WIDTH-1:0]                    m1_rid,      //
    input   [M_DATA_WIDTH-1:0]                  m1_rdata,    //
    input   [1:0]                               m1_rresp,    //
    input                                       m1_rlast,    //

    // AXI Master Interface (clk clock domain)
    output                                      m2_awvalid,  // Write Address Channel
    input                                       m2_awready,  //
    output      [M_ID_WIDTH-1:0]                m2_awid,     //
    output      [M_ADDR_WIDTH-1:0]              m2_awaddr,   //
    output      [M_LEN_WIDTH-1:0]               m2_awlen,    //
    output      [2:0]                           m2_awsize,   //
    output      [1:0]                           m2_awburst,  //
    output      [2:0]                           m2_awprot,   //
    output      [3:0]                           m2_awcache,  //

    output                                      m2_wvalid,   // Write Data Channel
    input                                       m2_wready,   //
    output      [M_ID_WIDTH-1:0]                m2_wid,      //
    output      [M_DATA_WIDTH-1:0]              m2_wdata,    //
    output      [(M_DATA_WIDTH/8)-1:0]          m2_wstrb,    //
    output                                      m2_wlast,    //

    input                                       m2_bvalid,   // Write Response Channel
    output                                      m2_bready,   //
    input   [M_ID_WIDTH-1:0]                    m2_bid,      //
    input   [1:0]                               m2_bresp,    //

    output                                      m2_arvalid,  // Read Address Channel
    input                                       m2_arready,  //
    output   [M_ID_WIDTH-1:0]                   m2_arid,     //
    output   [M_ADDR_WIDTH-1:0]                 m2_araddr,   //
    output   [M_LEN_WIDTH-1:0]                  m2_arlen,    //
    output   [2:0]                              m2_arsize,   //
    output   [1:0]                              m2_arburst,  //
    output   [2:0]                              m2_arprot,   //
    output   [3:0]                              m2_arcache,  //

    input                                       m2_rvalid,   // Read Data Channel
    output                                      m2_rready,   //
    input   [M_ID_WIDTH-1:0]                    m2_rid,      //
    input   [M_DATA_WIDTH-1:0]                  m2_rdata,    //
    input   [1:0]                               m2_rresp,    //
    input                                       m2_rlast,    //

    output  reg                                 fsync_out
  );

reg   s2c_dma_intr_r1;
reg   s2mm_all_lines_xfred_r1;
wire  s2c_dma_intr;
wire  s2mm_fsync_rising_edge;
reg   s2c_dma_intr_latched;

always@(posedge m_clk)
begin
  s2c_dma_intr_r1         <= interrupt_in;
  s2mm_all_lines_xfred_r1 <= s2mm_all_lines_xfred;
end

assign s2c_dma_intr           = interrupt_in && !s2c_dma_intr_r1;
assign s2mm_fsync_rising_edge = s2mm_all_lines_xfred && !s2mm_all_lines_xfred_r1;

//Registering for better timing
always@(posedge m_clk)
  if(!m_resetn)
      fsync_out <= 1'b0;
  // When software generated interrupt is received, if VDMA has not finished reading the earlier frame, 
  // then hold on till VDMA finishes the current frame and then assert next fsync 
  else if(s2c_dma_intr_latched && mm2s_all_lines_xfred)
      fsync_out <= 1'b1;
  else
      fsync_out <= 1'b0;

//  If Software generates interrupt (writes frame into DDR4 while VDMA is fetching data from DDR4), hold onto the interrupt
//  before mm2s_all_lines_xfred gets asserted, and then give fsync to vdma
always@(posedge m_clk)
  if(~m_resetn)
     s2c_dma_intr_latched <= 1'b0;
  else if(s2c_dma_intr)
     s2c_dma_intr_latched <= 1'b1;
  else if(mm2s_all_lines_xfred)
     s2c_dma_intr_latched <= 1'b0;

  s2c_master_axi_mm #(
    .M_ID_WIDTH   (M_ID_WIDTH),
    .M_ADDR_WIDTH (M_ADDR_WIDTH),
    .M_LEN_WIDTH  (M_LEN_WIDTH),
    .M_DATA_WIDTH (M_DATA_WIDTH)
  )
 M1_AXI_MM (
    .m_clk(m_clk),
    .m_resetn(m_resetn),
    .interrupt_in(s2c_dma_intr),
    .mm2s_event(1'b0), // No need to generate interrupt in S2C direction /*mm2s_event),*/
    .axi_intr_assert_reg((BASE_ADDR + 32'h0000006C)),  // need to change the name of the reg, it is axi_intr_status at offset 0x6C
    .value_to_clr_intr(32'h00000008),
    .pcie_intr_assert_reg((BASE_ADDR + 32'h00000070)),
    .value_to_raise_pcie_intr(32'h00000008),

    .m_awid   (m1_awid   ),   
    .m_awvalid(m1_awvalid),
    .m_awready(m1_awready),
    .m_awaddr (m1_awaddr ), 
    .m_awlen  (m1_awlen  ),  
    .m_awsize (m1_awsize ), 
    .m_awburst(m1_awburst),
    .m_awprot (m1_awprot ), 
    .m_awcache(m1_awcache),

    .m_wid    (m1_wid    ),    
    .m_wvalid (m1_wvalid ), 
    .m_wready (m1_wready ),  
    .m_wdata  (m1_wdata  ),  
    .m_wstrb  (m1_wstrb  ),  
    .m_wlast  (m1_wlast  ),  

    .m_bid    (m1_bid    ),    
    .m_bvalid (m1_bvalid ), 
    .m_bready (m1_bready ), 
    .m_bresp  (m1_bresp  ),  

    .m_arid   (m1_arid   ),   
    .m_arvalid(m1_arvalid),
    .m_arready(m1_arready),
    .m_araddr (m1_araddr ), 
    .m_arlen  (m1_arlen  ),  
    .m_arsize (m1_arsize ), 
    .m_arburst(m1_arburst),
    .m_arprot (m1_arprot ), 
    .m_arcache(m1_arcache),

    .m_rid    (m1_rid    ),    
    .m_rvalid (m1_rvalid ), 
    .m_rready (m1_rready ), 
    .m_rdata  (m1_rdata  ),  
    .m_rresp  (m1_rresp  ),  
    .m_rlast  (m1_rlast  ) 

  );

  c2s_master_axi_mm #(
    .M_ID_WIDTH   (M_ID_WIDTH),
    .M_ADDR_WIDTH (M_ADDR_WIDTH),
    .M_LEN_WIDTH  (M_LEN_WIDTH),
    .M_DATA_WIDTH (M_DATA_WIDTH)
  )
 M2_AXI_MM (
    .m_clk(m_clk),
    .m_resetn(m_resetn),
    .interrupt_in(s2mm_fsync_rising_edge),
    .pcie_intr_assert_reg((BASE_ADDR + 32'h000000F0)),
    .value_to_raise_pcie_intr(32'h00000008),
    .scratchpad_reg((BASE_ADDR + scratchpad_reg)),
    .scratchpad_val(scratchpad_val),
    
    .m_awid   (m2_awid   ),   
    .m_awvalid(m2_awvalid),
    .m_awready(m2_awready),
    .m_awaddr (m2_awaddr ), 
    .m_awlen  (m2_awlen  ),  
    .m_awsize (m2_awsize ), 
    .m_awburst(m2_awburst),
    .m_awprot (m2_awprot ), 
    .m_awcache(m2_awcache),

    .m_wid    (m2_wid    ),    
    .m_wvalid (m2_wvalid ), 
    .m_wready (m2_wready ),  
    .m_wdata  (m2_wdata  ),  
    .m_wstrb  (m2_wstrb  ),  
    .m_wlast  (m2_wlast  ),  

    .m_bid    (m2_bid    ),    
    .m_bvalid (m2_bvalid ), 
    .m_bready (m2_bready ), 
    .m_bresp  (m2_bresp  ),  

    .m_arid   (m2_arid   ),   
    .m_arvalid(m2_arvalid),
    .m_arready(m2_arready),
    .m_araddr (m2_araddr ), 
    .m_arlen  (m2_arlen  ),  
    .m_arsize (m2_arsize ), 
    .m_arburst(m2_arburst),
    .m_arprot (m2_arprot ), 
    .m_arcache(m2_arcache),

    .m_rid    (m2_rid    ),    
    .m_rvalid (m2_rvalid ), 
    .m_rready (m2_rready ), 
    .m_rdata  (m2_rdata  ),  
    .m_rresp  (m2_rresp  ),  
    .m_rlast  (m2_rlast  ) 

  );

endmodule
