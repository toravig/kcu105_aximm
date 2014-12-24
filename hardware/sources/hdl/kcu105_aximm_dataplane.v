
`timescale 1ps / 1ps

module kcu105_aximm_dataplane #(parameter NUM_LANES = 8)
(
      // PCI Express slot PERST# reset signal
    input                          perst_n,      
      // PCIe differential reference clock input
    input                          pcie_ref_clk_p,   
    input                          pcie_ref_clk_n,   
      // PCIe differential transmit output
    output  [NUM_LANES-1:0]        pcie_tx_p,         
    output  [NUM_LANES-1:0]        pcie_tx_n,         
      // PCIe differential receive output
    input   [NUM_LANES-1:0]        pcie_rx_p,         
    input   [NUM_LANES-1:0]        pcie_rx_n,
   `ifdef SIMULATION
    input   [25:0]                 pipe_commands_in,
    output  [16:0]                 pipe_commands_out,
    input   [83:0]                 pipe_rx_0_sigs,
    input   [83:0]                 pipe_rx_1_sigs,
    input   [83:0]                 pipe_rx_2_sigs,
    input   [83:0]                 pipe_rx_3_sigs,
    input   [83:0]                 pipe_rx_4_sigs,
    input   [83:0]                 pipe_rx_5_sigs,
    input   [83:0]                 pipe_rx_6_sigs,
    input   [83:0]                 pipe_rx_7_sigs,
    output  [69:0]                 pipe_tx_0_sigs,
    output  [69:0]                 pipe_tx_1_sigs,
    output  [69:0]                 pipe_tx_2_sigs,
    output  [69:0]                 pipe_tx_3_sigs,
    output  [69:0]                 pipe_tx_4_sigs,
    output  [69:0]                 pipe_tx_5_sigs,
    output  [69:0]                 pipe_tx_6_sigs,
    output  [69:0]                 pipe_tx_7_sigs,
   `endif
    output                         C0_DDR4_act_n,
    output  [16:0]                 C0_DDR4_adr,
    output  [1:0]                  C0_DDR4_ba,
    output  [0:0]                  C0_DDR4_bg,
    output                         C0_DDR4_ck_c,
    output  [0:0]                  C0_DDR4_cke,
    output  [0:0]                  C0_DDR4_cs_n,
    inout   [7:0]                  C0_DDR4_dm_n,
    inout   [63:0]                 C0_DDR4_dq,
    inout   [7:0]                  C0_DDR4_dqs_c,
    output  [0:0]                  C0_DDR4_odt,
    output                         C0_DDR4_reset_n,
    input                          C0_SYS_CLK_clk_n,
    input                          C0_SYS_CLK_clk_p,
    output                         c0_DDR4_ck_t,
    inout   [7:0]                  c0_DDR4_dqs_t,
    output                         c0_init_calib_complete,
    input                          clk125_in,
    output  [2:0]                  muxaddr_out,
    input                          pmbus_alert,
    inout                          pmbus_clk,
    inout                          pmbus_data,
    input                          vauxn0,
    input                          vauxn2,
    input                          vauxn8,
    input                          vauxp0,
    input                          vauxp2,
    input                          vauxp8,
    output  [3:0]                  led 
);

localparam  LED_CTR_WIDTH               = 26;   
localparam  PL_LINK_CAP_MAX_LINK_SPEED  = 4;

  wire                      user_clk;
  wire                      user_lnk_up;
  reg                       lane_width_error;
  reg                       link_speed_error;  
  wire                      sys_clk;
  wire                      sys_clk_gt;
  wire                      sys_reset;
  wire [2:0]                cfg_current_speed;
  wire [3:0]                cfg_negotiated_width;
  reg  [LED_CTR_WIDTH-1:0]  led_ctr;


IBUFDS_GTE3 refclk_ibuf (.O(sys_clk_gt), .ODIV2(sys_clk), .I(pcie_ref_clk_p), .CEB(1'b0), .IB(pcie_ref_clk_n));

IBUF perst_n_ibuf (.I(perst_n), .O(sys_reset));

trd_wrapper u_trd
       (.pcie_7x_mgt_rxn     (pcie_rx_n      ),
        .pcie_7x_mgt_rxp     (pcie_rx_p      ),
        .pcie_7x_mgt_txn     (pcie_tx_n      ),
        .pcie_7x_mgt_txp     (pcie_tx_p      ),
        .cfg_current_speed   (cfg_current_speed),
        .cfg_negotiated_width(cfg_negotiated_width),
        .sys_clk             (sys_clk        ),
        .sys_clk_gt          (sys_clk_gt     ),
        .sys_reset           (sys_reset      ),
        .sys_rst             (~user_lnk_up   ),
        .user_clk            (user_clk       ),
        .user_lnk_up         (user_lnk_up    ),
   `ifdef SIMULATION
        .pcie3_ext_pipe_interface_commands_in (pipe_commands_in),
        .pcie3_ext_pipe_interface_commands_out(pipe_commands_out),
        .pcie3_ext_pipe_interface_rx_0_sigs   (pipe_rx_0_sigs),
        .pcie3_ext_pipe_interface_rx_1_sigs   (pipe_rx_1_sigs),
        .pcie3_ext_pipe_interface_rx_2_sigs   (pipe_rx_2_sigs),
        .pcie3_ext_pipe_interface_rx_3_sigs   (pipe_rx_3_sigs),
        .pcie3_ext_pipe_interface_rx_4_sigs   (pipe_rx_4_sigs),
        .pcie3_ext_pipe_interface_rx_5_sigs   (pipe_rx_5_sigs),
        .pcie3_ext_pipe_interface_rx_6_sigs   (pipe_rx_6_sigs),
        .pcie3_ext_pipe_interface_rx_7_sigs   (pipe_rx_7_sigs),
        .pcie3_ext_pipe_interface_tx_0_sigs   (pipe_tx_0_sigs),
        .pcie3_ext_pipe_interface_tx_1_sigs   (pipe_tx_1_sigs),
        .pcie3_ext_pipe_interface_tx_2_sigs   (pipe_tx_2_sigs),
        .pcie3_ext_pipe_interface_tx_3_sigs   (pipe_tx_3_sigs),
        .pcie3_ext_pipe_interface_tx_4_sigs   (pipe_tx_4_sigs),
        .pcie3_ext_pipe_interface_tx_5_sigs   (pipe_tx_5_sigs),
        .pcie3_ext_pipe_interface_tx_6_sigs   (pipe_tx_6_sigs),
        .pcie3_ext_pipe_interface_tx_7_sigs   (pipe_tx_7_sigs),
    `endif
        .C0_DDR4_act_n         (C0_DDR4_act_n   ),
        .C0_DDR4_adr           (C0_DDR4_adr     ),
        .C0_DDR4_ba            (C0_DDR4_ba      ),
        .C0_DDR4_bg            (C0_DDR4_bg      ),
        .C0_DDR4_ck_c          (C0_DDR4_ck_c    ),
        .c0_ddr4_ck_t          (c0_DDR4_ck_t    ),
        .C0_DDR4_cke           (C0_DDR4_cke     ),
        .C0_DDR4_cs_n          (C0_DDR4_cs_n    ),
        .C0_DDR4_dm_n          (C0_DDR4_dm_n    ),
        .C0_DDR4_dq            (C0_DDR4_dq      ),
        .C0_DDR4_dqs_c         (C0_DDR4_dqs_c   ),
        .c0_ddr4_dqs_t         (c0_DDR4_dqs_t   ),
        .C0_DDR4_odt           (C0_DDR4_odt     ),
        .C0_DDR4_reset_n       (C0_DDR4_reset_n ),
        .C0_SYS_CLK_clk_n      (C0_SYS_CLK_clk_n),
        .C0_SYS_CLK_clk_p      (C0_SYS_CLK_clk_p),
        .c0_init_calib_complete(c0_init_calib_complete),
        .clk125_in             (clk125_in       ),
        .muxaddr_out           (muxaddr_out     ),
        .pmbus_alert           (pmbus_alert     ),
        .pmbus_clk             (pmbus_clk       ),
        .pmbus_control         (pmbus_control   ),
        .pmbus_data            (pmbus_data      ),
        .vauxn0                (vauxn0          ),
        .vauxn2                (vauxn2          ),
        .vauxn8                (vauxn8          ),
        .vauxp0                (vauxp0          ),
        .vauxp2                (vauxp2          ),
        .vauxp8                (vauxp8          ));
       
// LEDs - Status
// ---------------
// Heart beat LED; flashes when primary PCIe core clock is present
always @(posedge user_clk)
begin
    led_ctr <= led_ctr + {{(LED_CTR_WIDTH-1){1'b0}}, 1'b1};
end

`ifdef SIMULATION
// Initialize for simulation
initial
begin
    led_ctr = {LED_CTR_WIDTH{1'b0}};
end
`endif

always @(posedge user_clk)
begin
   lane_width_error <= (cfg_negotiated_width != NUM_LANES); // Negotiated Link Width
   link_speed_error  <= (cfg_current_speed != PL_LINK_CAP_MAX_LINK_SPEED);
end

// led[1] lights up when PCIe core has trained
assign led[0] = user_lnk_up; 

// led[1] flashes to indicate PCIe clock is running
assign led[1] = led_ctr[LED_CTR_WIDTH-1];  // Flashes when user_clk is present

// led[2] lights up when the correct lane width is acheived
// If the link is not operating at full width, it flashes at twice the speed of the heartbeat on led[1]
assign led[2] = lane_width_error ? led_ctr[LED_CTR_WIDTH-2] : 1'b1;

assign led[3] = link_speed_error ? led_ctr[LED_CTR_WIDTH-2] : 1'b1;

endmodule
