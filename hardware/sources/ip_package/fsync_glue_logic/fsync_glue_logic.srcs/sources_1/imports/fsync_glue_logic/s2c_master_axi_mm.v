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

module s2c_master_axi_mm #(
    // AXI Master Interface Parameters
    parameter   M_ID_WIDTH        = 4,                        // AXI Master Port Widths
    parameter   M_ADDR_WIDTH      = 32,                       //   ..
    parameter   M_LEN_WIDTH       = 4,                        //   ..
    parameter   M_DATA_WIDTH      = 32                      //   ..
  )(    
    input                                       m_clk,
    input                                       m_resetn,
    input                                       interrupt_in,
    input                                       mm2s_event,
    input       [M_ADDR_WIDTH-1:0]              axi_intr_assert_reg,
    input       [M_DATA_WIDTH-1:0]              value_to_clr_intr,
    input       [M_ADDR_WIDTH-1:0]              pcie_intr_assert_reg,
    input       [M_DATA_WIDTH-1:0]              value_to_raise_pcie_intr,
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

localparam IDLE                = 3'h0;
localparam WAIT_FOR_INTR       = 3'h1;
localparam WRITE_REGISTER      = 3'h2;
localparam WAIT_FOR_AWREADY    = 3'h3;
localparam SEND_WDATA          = 3'h4;
localparam WAIT_FOR_WREADY     = 3'h5;
localparam WAIT_FOR_BRESP      = 3'h6;

reg [2:0]  state;
reg        intr_in_r1;
reg        mm2s_event_r1;

always@(posedge m_clk)
  if(~m_resetn)
  begin
      state <= IDLE;
      intr_in_r1 <= 1'b0;
      mm2s_event_r1 <= 1'b0;
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
              state <= WAIT_FOR_INTR;
              m_arid    <= {M_ID_WIDTH{1'b0}};   
              m_araddr  <= {M_ADDR_WIDTH{1'b0}}; 
              m_arlen   <= {M_LEN_WIDTH{1'b0}};  
            end
      WAIT_FOR_INTR: 
            begin
            if(interrupt_in || mm2s_event) begin
              // state <= WRITE_REGISTER;
               intr_in_r1 <= 1'b1;
               mm2s_event_r1 <= 1'b1;

               if(interrupt_in)
               m_awaddr  <= axi_intr_assert_reg;
               else if(mm2s_event)
               m_awaddr  <= pcie_intr_assert_reg;

               m_awvalid <= 1'b1;
               m_awlen   <= {M_LEN_WIDTH{1'b0}};
               m_awsize  <= 3'd2;  // 4 bytes
               m_awid    <= {M_ID_WIDTH{1'b0}};

              if(!m_awready)
              state <= WAIT_FOR_AWREADY;
              else
              state <= SEND_WDATA;

            end
            else begin
               state <= WAIT_FOR_INTR;
            end
            end
            /*
      WRITE_REGISTER:
            begin

              if(intr_in_r1)
              m_awaddr  <= axi_intr_assert_reg;
              else if(mm2s_event_r1)
              m_awaddr  <= pcie_intr_assert_reg;

              m_awvalid <= 1'b1;
              m_awlen   <= {M_LEN_WIDTH{1'b0}};
              m_awsize  <= 3'd2;  // 4 bytes
              // If AWREADY is already asserted, send WDATA, else wait for AWREADY
              if(!m_awready)
              state <= WAIT_FOR_AWREADY;
              else
              state <= SEND_WDATA;
            end
            */
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

              if(intr_in_r1)
              m_wdata  <= value_to_clr_intr;
              else if(mm2s_event_r1)
              m_wdata  <= value_to_raise_pcie_intr;

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
             // De-assert these signals, so that they can be latched onto the next intr/mm2s_event 
              intr_in_r1 <= 1'b0;
              mm2s_event_r1 <= 1'b0;

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
             // De-assert these signals, so that they can be latched onto the next intr/mm2s_event 
              intr_in_r1 <= 1'b0;
              mm2s_event_r1 <= 1'b0;

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
                 state <= WAIT_FOR_BRESP;
            end
     endcase
end

assign m_rready = 1'b1;
assign m_bready = 1'b1;

endmodule
