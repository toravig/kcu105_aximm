//============================================================================================
// AXI-MM rules to be followed:
// The master must not wait for the slave to assert AWREADY or WREADY before asserting AWVALID or WVALID
// The slave can wait for AWVALID or WVALID, or both, before asserting AWREADY
// The slave can wait for AWVALID or WVALID, or both, before asserting WREADY
// The slave must wait for both AWVALID and AWREADY to be asserted before asserting BVALID
// The slave must wait for WVALID, WREADY, and WLAST to be asserted before asserting BVALID
// The slave must not wait for the master to assert BREADY before asserting BVALID
// The master can wait for BVALID before asserting BREADY.
//============================================================================================
module c2s_master_axi_mm #(
    // AXI Master Interface Parameters
    parameter   M_ID_WIDTH        = 4,                        // AXI Master Port Widths
    parameter   M_ADDR_WIDTH      = 32,                       //   ..
    parameter   M_LEN_WIDTH       = 4,                        //   ..
    parameter   M_DATA_WIDTH      = 32                      //   ..

  )(    
    input                                       m_clk,
    input                                       m_resetn,
    input                                       interrupt_in,
    input       [M_ADDR_WIDTH-1:0]              pcie_intr_assert_reg,
    input       [M_DATA_WIDTH-1:0]              value_to_raise_pcie_intr,
    input       [M_ADDR_WIDTH-1:0]              scratchpad_reg,
    input       [M_DATA_WIDTH-1:0]              scratchpad_val,

    // AXI Master Interface (m_clk clock domain)
    output  reg                                 m_awvalid,      // Write Address Channel
    input                                       m_awready,      //
    output  reg [M_ID_WIDTH-1:0]                m_awid,         //
    output  reg [M_ADDR_WIDTH-1:0]              m_awaddr,       //
    output  reg [M_LEN_WIDTH-1:0]               m_awlen,        //
    output  reg [2:0]                           m_awsize,       //
    output  reg [1:0]                           m_awburst,      //
    output  reg [2:0]                           m_awprot,       //
    output  reg [3:0]                           m_awcache,      //

    output  reg                                 m_wvalid,       // Write Data Channel
    input                                       m_wready,       //
    output  reg [M_ID_WIDTH-1:0]                m_wid,          //
    output  reg [M_DATA_WIDTH-1:0]              m_wdata,        //
    output  reg [(M_DATA_WIDTH/8)-1:0]          m_wstrb,        //
    output  reg                                 m_wlast,        //

    input                                       m_bvalid,       // Write Response Channel
    output                                      m_bready,       //
    input   [M_ID_WIDTH-1:0]                    m_bid,          //
    input   [1:0]                               m_bresp,        //

    output  reg                                 m_arvalid,      // Read Address Channel
    input                                       m_arready,      //
    output  reg [M_ID_WIDTH-1:0]                m_arid,         //
    output  reg [M_ADDR_WIDTH-1:0]              m_araddr,       //
    output  reg [M_LEN_WIDTH-1:0]               m_arlen,        //
    output  reg [2:0]                           m_arsize,       //
    output  reg [1:0]                           m_arburst,      //
    output  reg [2:0]                           m_arprot,       //
    output  reg [3:0]                           m_arcache,      //

    input                                       m_rvalid,       // Read Data Channel
    output                                      m_rready,       //
    input   [M_ID_WIDTH-1:0]                    m_rid,          //
    input   [M_DATA_WIDTH-1:0]                  m_rdata,        //
    input   [1:0]                               m_rresp,        //
    input                                       m_rlast        //

  );

localparam IDLE                = 4'h0;
localparam WAIT_FOR_INTR       = 4'h1;
localparam WAIT_FOR_AWREADY    = 4'h2;
localparam SEND_WDATA          = 4'h3;
localparam WAIT_FOR_WREADY     = 4'h4;
localparam WAIT_FOR_BRESP      = 4'h5;
localparam AW_NEXT_ACCESS      = 4'h6;
localparam WAIT_FOR_AWREADY1   = 4'h7;
localparam SEND_WDATA1         = 4'h8;
localparam WAIT_FOR_WREADY1    = 4'h9;
localparam WAIT_FOR_BRESP1     = 4'hA;

reg [3:0]  state;

always@(posedge m_clk)
  if(~m_resetn)
  begin
      state <= IDLE;
      m_awvalid <= 1'b0;
      m_awsize  <= 3'd2;  // 4 bytes
      m_awcache <= 4'd0;
      m_awprot  <= 3'd0;
      m_awburst <= 2'd1;
      m_wvalid  <= 1'b0;
      m_wlast   <= 1'b0;

      m_arvalid <= 1'b0;
      m_arsize  <= 3'b000; 
      m_arburst <= 2'b00;
      m_arprot  <= 3'b000; 
      m_arcache <= 4'h0;
  end
  else
  begin
    case(state)
      IDLE: begin
              state     <= WAIT_FOR_INTR;
              m_arid    <= {M_ID_WIDTH{1'b0}};   
              m_araddr  <= {M_ADDR_WIDTH{1'b0}}; 
              m_arlen   <= {M_LEN_WIDTH{1'b0}};  
            end
      WAIT_FOR_INTR: 
            begin
              //[AAV]: whether to look for interrupt or rising edge of the interrupt
            if(interrupt_in) begin
              m_awaddr  <= scratchpad_reg;
              m_awvalid <= 1'b1;
              m_awlen   <= {M_LEN_WIDTH{1'b0}};
              m_awsize  <= 3'd2;  // 4 bytes
              m_awid    <= {M_ID_WIDTH{1'b0}};
              // If AWREADY is already asserted, send WDATA, else wait for AWREADY
              if(!m_awready)
              state <= WAIT_FOR_AWREADY;
              else
              state <= SEND_WDATA;
            end
            else begin
               state <= WAIT_FOR_INTR;
            end
            end
      WAIT_FOR_AWREADY:
            begin
              if(m_awready) begin
                 m_awvalid <= 1'b0;
                 state <= SEND_WDATA;
              end
              // Hold AWVALID until AWREADY is asserted
              else begin
                m_awvalid <= m_awvalid;
                state <= WAIT_FOR_AWREADY;
              end
            end
      SEND_WDATA:
            begin
              if(m_awready) begin
                 m_awvalid <= 1'b0;
              end
              // Hold AWVALID until AWREADY is asserted
              else begin
                m_awvalid <= m_awvalid;
              end
              // bit[3] is the interrupt bit, all other bits are reserved and read only
              // No need to follow read-modify-write approach
              m_wdata  <= scratchpad_val;
              m_wvalid <= 1'b1;
              m_wstrb  <= 'hF; // The interrupt register is 32-bit, so 4 bytes are valid
              m_wlast  <= 1'b1;
              m_wid    <= 'd0;
              // If WREADY is already asserted, wait for BRESP, else wait for WREADY
              if(!m_wready)
              state <= WAIT_FOR_WREADY;
              else
              state <= WAIT_FOR_BRESP;
            end
      WAIT_FOR_WREADY:
            begin
              if(m_wready) begin
                 m_wvalid <= 1'b0;
                 m_wlast  <= 1'b0;
                 // Write succesful, wait for mm2s event
                 if(m_bvalid && (m_bresp == 2'b00))
                 state <= WAIT_FOR_INTR;
                 // ERROR case, move to IDLE and wait for next interrupt from DMA
                 else if(m_bvalid && (m_bresp != 2'b00))
                 state <= IDLE;
                 else
                 state <= WAIT_FOR_BRESP;
              end
              else begin
                 m_wvalid <= m_wvalid;
                 m_wlast  <= m_wlast;
                 state    <= WAIT_FOR_WREADY;
              end
            end
      WAIT_FOR_BRESP:
            begin
              if(m_wready) begin
                 m_wvalid <= 1'b0;
                 m_wlast  <= 1'b0;
              end
              else begin
                 m_wvalid <= m_wvalid;
                 m_wlast  <= m_wlast;
              end
                 // Write succesful, wait for mm2s event 
                 if(m_bvalid && (m_bresp == 2'b00))
                 state <= AW_NEXT_ACCESS;
                 // ERROR case, move to IDLE and wait for next interrupt from DMA
                 else if(m_bvalid && (m_bresp != 2'b00))
                 state <= IDLE;
                 else
                 state <= WAIT_FOR_BRESP;
            end
      AW_NEXT_ACCESS: 
            begin
              m_awaddr  <= pcie_intr_assert_reg;
              m_awvalid <= 1'b1;
              m_awlen   <= {M_LEN_WIDTH{1'b0}};
              m_awsize  <= 3'd2;  // 4 bytes
              m_awid    <= {M_ID_WIDTH{1'b0}};
              // If AWREADY is already asserted, send WDATA, else wait for AWREADY
              if(!m_awready)
              state <= WAIT_FOR_AWREADY1;
              else
              state <= SEND_WDATA1;
            end
      WAIT_FOR_AWREADY1:
            begin
              if(m_awready) begin
                 m_awvalid <= 1'b0;
                 state <= SEND_WDATA1;
              end
              // Hold AWVALID until AWREADY is asserted
              else begin
                m_awvalid <= m_awvalid;
                state <= WAIT_FOR_AWREADY1;
              end
            end
      SEND_WDATA1:
            begin
              if(m_awready) begin
                 m_awvalid <= 1'b0;
              end
              // Hold AWVALID until AWREADY is asserted
              else begin
                m_awvalid <= m_awvalid;
              end
              // bit[3] is the interrupt bit, all other bits are reserved and read only
              // No need to follow read-modify-write approach
              m_wdata  <= value_to_raise_pcie_intr;
              m_wvalid <= 1'b1;
              m_wstrb  <= 'hF; // The interrupt register is 32-bit, so 4 bytes are valid
              m_wlast  <= 1'b1;
              m_wid    <= 'd0;
              // If WREADY is already asserted, wait for BRESP, else wait for WREADY
              if(!m_wready)
              state <= WAIT_FOR_WREADY1;
              else
              state <= WAIT_FOR_BRESP1;
            end
      WAIT_FOR_WREADY1:
            begin
              if(m_wready) begin
                 m_wvalid <= 1'b0;
                 m_wlast  <= 1'b0;
                 // Write succesful, wait for mm2s event
                 if(m_bvalid && (m_bresp == 2'b00))
                 state <= WAIT_FOR_INTR;
                 // ERROR case, move to IDLE and wait for next interrupt from DMA
                 else if(m_bvalid && (m_bresp != 2'b00))
                 state <= IDLE;
                 else
                 state <= WAIT_FOR_BRESP1;
              end
              else begin
                 m_wvalid <= m_wvalid;
                 m_wlast  <= m_wlast;
                 state    <= WAIT_FOR_WREADY1;
              end
            end
      WAIT_FOR_BRESP1:
            begin
              if(m_wready) begin
                 m_wvalid <= 1'b0;
                 m_wlast  <= 1'b0;
              end
              else begin
                 m_wvalid <= m_wvalid;
                 m_wlast  <= m_wlast;
              end
                 // Write succesful, wait for mm2s event 
                 if(m_bvalid && (m_bresp == 2'b00))
                 state <= WAIT_FOR_INTR;
                 // ERROR case, move to IDLE and wait for next interrupt from DMA
                 else if(m_bvalid && (m_bresp != 2'b00))
                 state <= IDLE;
                 else
                 state <= WAIT_FOR_BRESP1;
            end
     endcase
end

assign m_rready = 1'b1;
assign m_bready = 1'b1;

endmodule
