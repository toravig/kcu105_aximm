//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
//
// Project    : Ultrascale FPGA Gen3 Integrated Block for PCI Express
// File       : board.v
// Version    : 1.0 
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//
// Description: Top level testbench
//
//------------------------------------------------------------------------------

`timescale 1ps/1ps

`include "board_common.vh"

`define SIMULATION

module board;

  parameter          REF_CLK_FREQ       = 0 ;      // 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz

  localparam         REF_CLK_HALF_CYCLE = (REF_CLK_FREQ == 0) ? 5000 :
                                          (REF_CLK_FREQ == 1) ? 4000 :
                                          (REF_CLK_FREQ == 2) ? 2000 : 0;

  localparam   [2:0] PF0_DEV_CAP_MAX_PAYLOAD_SIZE = 3'b010;
  `ifdef LINKWIDTH
  localparam   [3:0] LINK_WIDTH = 4'h`LINKWIDTH;
  `else
  localparam   [3:0] LINK_WIDTH = 4'h8;
  `endif
  `ifdef LINKSPEED
  localparam   [2:0] LINK_SPEED = 3'h`LINKSPEED;
  `else
  localparam   [2:0] LINK_SPEED = 3'h4;
  `endif

  localparam MCB_CLK_HALF_CYCLE = 1667;
  localparam ADDR_WIDTH         = 17;
  localparam DQ_WIDTH           = 64;
  localparam DQS_WIDTH          = 2;
  localparam DM_WIDTH           = 2;
  localparam DRAM_WIDTH         = 16;
  localparam tCK                = 1250 ; //DDR4 interface clock period in ps
//  parameter SIMULATION          = "TRUE" ;


  localparam MRS                = 3'b000;
  localparam REF                = 3'b001;
  localparam PRE                = 3'b010;
  localparam ACT                = 3'b011;
  localparam WR                 = 3'b100;
  localparam RD                 = 3'b101;
  localparam ZQC                = 3'b110;
  localparam NOP                = 3'b111;

  // Input clock is assumed to be equal to the memory clock frequency
  // User should change the parameter as necessary if a different input
  // clock frequency is used
  localparam real CLKIN_PERIOD_NS = 12500 / 1000.0;


  //integer            i;

  // System-level clock and reset
  reg                sys_rst_n;

  reg                sys_clk;
  reg                mcb_clk;

  //
  // PCI-Express Serial Interconnect
  //

  wire  [(LINK_WIDTH-1):0]  ep_pci_exp_txn;
  wire  [(LINK_WIDTH-1):0]  ep_pci_exp_txp;
  wire  [(LINK_WIDTH-1):0]  rp_pci_exp_txn;
  wire  [(LINK_WIDTH-1):0]  rp_pci_exp_txp;

  wire  [25:0]  common_commands_in_ep;
  wire  [83:0]  pipe_rx_0_sigs_ep;
  wire  [83:0]  pipe_rx_1_sigs_ep;
  wire  [83:0]  pipe_rx_2_sigs_ep;
  wire  [83:0]  pipe_rx_3_sigs_ep;
  wire  [83:0]  pipe_rx_4_sigs_ep;
  wire  [83:0]  pipe_rx_5_sigs_ep;
  wire  [83:0]  pipe_rx_6_sigs_ep;
  wire  [83:0]  pipe_rx_7_sigs_ep;
  
  wire  [16:0]  common_commands_out_ep;
  wire  [69:0]  pipe_tx_0_sigs_ep;
  wire  [69:0]  pipe_tx_1_sigs_ep;
  wire  [69:0]  pipe_tx_2_sigs_ep;
  wire  [69:0]  pipe_tx_3_sigs_ep;
  wire  [69:0]  pipe_tx_4_sigs_ep;
  wire  [69:0]  pipe_tx_5_sigs_ep;
  wire  [69:0]  pipe_tx_6_sigs_ep;
  wire  [69:0]  pipe_tx_7_sigs_ep;

  wire  [25:0]  common_commands_in_rp;
  wire  [83:0]  pipe_rx_0_sigs_rp;
  wire  [83:0]  pipe_rx_1_sigs_rp;
  wire  [83:0]  pipe_rx_2_sigs_rp;
  wire  [83:0]  pipe_rx_3_sigs_rp;
  wire  [83:0]  pipe_rx_4_sigs_rp;
  wire  [83:0]  pipe_rx_5_sigs_rp;
  wire  [83:0]  pipe_rx_6_sigs_rp;
  wire  [83:0]  pipe_rx_7_sigs_rp;
  
  wire  [16:0]  common_commands_out_rp;
  wire  [69:0]  pipe_tx_0_sigs_rp;
  wire  [69:0]  pipe_tx_1_sigs_rp;
  wire  [69:0]  pipe_tx_2_sigs_rp;
  wire  [69:0]  pipe_tx_3_sigs_rp;
  wire  [69:0]  pipe_tx_4_sigs_rp;
  wire  [69:0]  pipe_tx_5_sigs_rp;
  wire  [69:0]  pipe_tx_6_sigs_rp;
  wire  [69:0]  pipe_tx_7_sigs_rp;

  wire          c0_ddr4_act_n;
  wire [16:0]   c0_ddr4_adr;
  wire [1:0]    c0_ddr4_ba;
  wire [0:0]    c0_ddr4_bg;
  wire          c0_ddr4_ck_c;
  wire [0:0]    c0_ddr4_cke;
  wire [0:0]    c0_ddr4_cs_n;
  wire [7:0]    c0_ddr4_dm_dbi_n;
  wire [63:0]   c0_ddr4_dq;
  wire [7:0]    c0_ddr4_dqs_c;
  wire [0:0]    c0_ddr4_odt;
 // wire          c0_ddr4_par;
  wire          c0_ddr4_reset_n;
  wire          C0_SYS_CLK_clk_n;
  wire          C0_SYS_CLK_clk_p;
  wire          c0_ddr4_ck_t;
  wire [7:0]    c0_ddr4_dqs_t;
  wire          c0_init_calib_complete;
  reg [ADDR_WIDTH:0] DDR4_ADRMOD;
  //[AAV]: Check the correct width from Pavan Marisetti
  //reg [ADDR_WIDTH-1:0] DDR4_ADRMOD;
  reg  [31:0] cmdName;
  tri        model_enable = 1'b1;


`ifdef XILINX_SIMULATOR
module short(in1, in1);
inout in1;
endmodule
`endif
  //
  // PCI-Express Model Root Port Instance
  //

  defparam board.dut.u_trd.trd_i.pcie3_ultrascale_0.inst.EXT_PIPE_SIM = "TRUE"; 
  defparam board.RP.pcie3_uscale_rp_top_i.pcie3_uscale_core_top_inst.EXT_PIPE_SIM = "TRUE";

  xilinx_pcie3_uscale_rp
  #(
     .PL_LINK_CAP_MAX_LINK_SPEED(4),
     .PL_LINK_CAP_MAX_LINK_WIDTH(8),
     .PF0_DEV_CAP_MAX_PAYLOAD_SIZE(PF0_DEV_CAP_MAX_PAYLOAD_SIZE)
     //ONLY FOR RP
  ) RP (

    // SYS Inteface
    .sys_clk_n(~sys_clk),
    .sys_clk_p(sys_clk),
    .sys_rst_n(sys_rst_n),
    .common_commands_in (common_commands_in_rp ),
    .pipe_rx_0_sigs     (pipe_rx_0_sigs_rp     ),
    .pipe_rx_1_sigs     (pipe_rx_1_sigs_rp     ),
    .pipe_rx_2_sigs     (pipe_rx_2_sigs_rp     ),
    .pipe_rx_3_sigs     (pipe_rx_3_sigs_rp     ),
    .pipe_rx_4_sigs     (pipe_rx_4_sigs_rp     ),
    .pipe_rx_5_sigs     (pipe_rx_5_sigs_rp     ),
    .pipe_rx_6_sigs     (pipe_rx_6_sigs_rp     ),
    .pipe_rx_7_sigs     (pipe_rx_7_sigs_rp     ),
                                            
    .common_commands_out(common_commands_out_rp),
    .pipe_tx_0_sigs     (pipe_tx_0_sigs_rp     ),
    .pipe_tx_1_sigs     (pipe_tx_1_sigs_rp     ),
    .pipe_tx_2_sigs     (pipe_tx_2_sigs_rp     ),
    .pipe_tx_3_sigs     (pipe_tx_3_sigs_rp     ),
    .pipe_tx_4_sigs     (pipe_tx_4_sigs_rp     ),
    .pipe_tx_5_sigs     (pipe_tx_5_sigs_rp     ),
    .pipe_tx_6_sigs     (pipe_tx_6_sigs_rp     ),
    .pipe_tx_7_sigs     (pipe_tx_7_sigs_rp     ),

  
    // PCI-Express Interface
    .pci_exp_txn(rp_pci_exp_txn),
    .pci_exp_txp(rp_pci_exp_txp),
    .pci_exp_rxn(ep_pci_exp_txn),
    .pci_exp_rxp(ep_pci_exp_txp)
  );

  //------------------------------------------------------------------------------//
  // Simulation endpoint with PIO Slave
  //------------------------------------------------------------------------------//
  //
  // PCI-Express Endpoint Instance
  //
 kcu105_aximm_dataplane 
  dut (

  // SYS Inteface
  .perst_n          (sys_rst_n),
  .pcie_ref_clk_n   (~sys_clk),
  .pcie_ref_clk_p   ( sys_clk),
  .pipe_commands_in(common_commands_in_ep),
  .pipe_commands_out(common_commands_out_ep),
  .pipe_rx_0_sigs(pipe_rx_0_sigs_ep),
  .pipe_rx_1_sigs(pipe_rx_1_sigs_ep),
  .pipe_rx_2_sigs(pipe_rx_2_sigs_ep),
  .pipe_rx_3_sigs(pipe_rx_3_sigs_ep),
  .pipe_rx_4_sigs(pipe_rx_4_sigs_ep),
  .pipe_rx_5_sigs(pipe_rx_5_sigs_ep),
  .pipe_rx_6_sigs(pipe_rx_6_sigs_ep),
  .pipe_rx_7_sigs(pipe_rx_7_sigs_ep),
  .pipe_tx_0_sigs(pipe_tx_0_sigs_ep),
  .pipe_tx_1_sigs(pipe_tx_1_sigs_ep),
  .pipe_tx_2_sigs(pipe_tx_2_sigs_ep),
  .pipe_tx_3_sigs(pipe_tx_3_sigs_ep),
  .pipe_tx_4_sigs(pipe_tx_4_sigs_ep),
  .pipe_tx_5_sigs(pipe_tx_5_sigs_ep),
  .pipe_tx_6_sigs(pipe_tx_6_sigs_ep),
  .pipe_tx_7_sigs(pipe_tx_7_sigs_ep),
  // PCI-Express Interface
  .pcie_tx_n     (ep_pci_exp_txn),
  .pcie_tx_p     (ep_pci_exp_txp),
  .pcie_rx_n     (rp_pci_exp_txn),
  .pcie_rx_p     (rp_pci_exp_txp),
  .C0_DDR4_act_n (c0_ddr4_act_n),
  .C0_DDR4_adr   (c0_ddr4_adr),
  .C0_DDR4_ba    (c0_ddr4_ba),
  .C0_DDR4_bg    (c0_ddr4_bg),
  .C0_DDR4_ck_c  (c0_ddr4_ck_c),
  .c0_DDR4_ck_t  (c0_ddr4_ck_t),
  .C0_DDR4_cke   (c0_ddr4_cke),
  .C0_DDR4_cs_n  (c0_ddr4_cs_n),
  .C0_DDR4_dm_n  (c0_ddr4_dm_dbi_n),
  .C0_DDR4_dq    (c0_ddr4_dq),
  .C0_DDR4_dqs_c (c0_ddr4_dqs_c),
  .c0_DDR4_dqs_t (c0_ddr4_dqs_t),
  .C0_DDR4_odt   (c0_ddr4_odt),
 // .C0_DDR4_par   (c0_ddr4_par),
  .C0_DDR4_reset_n (c0_ddr4_reset_n),
  .C0_SYS_CLK_clk_n(~mcb_clk),
  .C0_SYS_CLK_clk_p( mcb_clk),
  .c0_init_calib_complete(c0_init_calib_complete),
  .led              ()
);

//
// Please refer text at the end of this file for PIPE Ports details. 
//
localparam integer USER_CLK_FREQ  = ((LINK_SPEED == 3'h4) ? 5 : 4);
localparam integer USER_CLK2_FREQ = ((3) + 1);
// USER_CLK2_FREQ = AXI Interface Frequency
//   0: Disable User Clock
//   1: 31.25 MHz
//   2: 62.50 MHz  (default)
//   3: 125.00 MHz
//   4: 250.00 MHz
//   5: 500.00 MHz
//
pcie3_ultrascale_0_phy_sig_gen #(
     .TCQ                        ( 1 ),
     .PL_LINK_CAP_MAX_LINK_WIDTH ( LINK_WIDTH ), // 1- GEN1, 2 - GEN2, 4 - GEN3
     .CLK_SHARING_EN             ( "FALSE" ),
     .PCIE_REFCLK_FREQ           ( REF_CLK_FREQ ), 
     .PCIE_USERCLK1_FREQ         ( USER_CLK_FREQ ), 
     .PCIE_USERCLK2_FREQ         ( USER_CLK2_FREQ ) 
  ) pcie3_ultrascale_0_phy_gen_rp_ep_i (
  //-----------------------------------------------------
  // SYS Inteface
    .sys_clk                    ( sys_clk ),
    .sys_rst_n                  ( sys_rst_n ),
  //---------------------- EP -------------------------------
    .common_commands_in_ep      ( common_commands_in_ep  ), 
    .pipe_rx_0_sigs_ep          ( pipe_rx_0_sigs_ep      ), 
    .pipe_rx_1_sigs_ep          ( pipe_rx_1_sigs_ep      ), 
    .pipe_rx_2_sigs_ep          ( pipe_rx_2_sigs_ep      ), 
    .pipe_rx_3_sigs_ep          ( pipe_rx_3_sigs_ep      ), 
    .pipe_rx_4_sigs_ep          ( pipe_rx_4_sigs_ep      ), 
    .pipe_rx_5_sigs_ep          ( pipe_rx_5_sigs_ep      ), 
    .pipe_rx_6_sigs_ep          ( pipe_rx_6_sigs_ep      ), 
    .pipe_rx_7_sigs_ep          ( pipe_rx_7_sigs_ep      ), 
                                                  
    .common_commands_out_ep     ( common_commands_out_ep ), 
    .pipe_tx_0_sigs_ep          ( pipe_tx_0_sigs_ep      ), 
    .pipe_tx_1_sigs_ep          ( pipe_tx_1_sigs_ep      ), 
    .pipe_tx_2_sigs_ep          ( pipe_tx_2_sigs_ep      ), 
    .pipe_tx_3_sigs_ep          ( pipe_tx_3_sigs_ep      ), 
    .pipe_tx_4_sigs_ep          ( pipe_tx_4_sigs_ep      ), 
    .pipe_tx_5_sigs_ep          ( pipe_tx_5_sigs_ep      ), 
    .pipe_tx_6_sigs_ep          ( pipe_tx_6_sigs_ep      ), 
    .pipe_tx_7_sigs_ep          ( pipe_tx_7_sigs_ep      ), 
  //---------------------- RP -------------------------------
    .common_commands_in_rp      ( common_commands_in_rp  ), 
    .pipe_rx_0_sigs_rp          ( pipe_rx_0_sigs_rp      ), 
    .pipe_rx_1_sigs_rp          ( pipe_rx_1_sigs_rp      ), 
    .pipe_rx_2_sigs_rp          ( pipe_rx_2_sigs_rp      ), 
    .pipe_rx_3_sigs_rp          ( pipe_rx_3_sigs_rp      ), 
    .pipe_rx_4_sigs_rp          ( pipe_rx_4_sigs_rp      ), 
    .pipe_rx_5_sigs_rp          ( pipe_rx_5_sigs_rp      ), 
    .pipe_rx_6_sigs_rp          ( pipe_rx_6_sigs_rp      ), 
    .pipe_rx_7_sigs_rp          ( pipe_rx_7_sigs_rp      ), 
                                                  
    .common_commands_out_rp     ( common_commands_out_rp ), 
    .pipe_tx_0_sigs_rp          ( pipe_tx_0_sigs_rp      ), 
    .pipe_tx_1_sigs_rp          ( pipe_tx_1_sigs_rp      ), 
    .pipe_tx_2_sigs_rp          ( pipe_tx_2_sigs_rp      ), 
    .pipe_tx_3_sigs_rp          ( pipe_tx_3_sigs_rp      ), 
    .pipe_tx_4_sigs_rp          ( pipe_tx_4_sigs_rp      ), 
    .pipe_tx_5_sigs_rp          ( pipe_tx_5_sigs_rp      ), 
    .pipe_tx_6_sigs_rp          ( pipe_tx_6_sigs_rp      ), 
    .pipe_tx_7_sigs_rp          ( pipe_tx_7_sigs_rp      ) 
  //-----------------------------------------------------
  );

  initial begin
    sys_clk = 0;
    forever #(REF_CLK_HALF_CYCLE) sys_clk = ~sys_clk;
  end

  initial
  begin
     mcb_clk = 1'b0;
     forever #(MCB_CLK_HALF_CYCLE) mcb_clk = ~mcb_clk;
   end

   always @(*)
      if (c0_ddr4_act_n)
        casez (c0_ddr4_adr[16:14])
        WR, RD: DDR4_ADRMOD = c0_ddr4_adr & 18'h1C7FF;
        default: DDR4_ADRMOD = c0_ddr4_adr;
        endcase
      else
        DDR4_ADRMOD = c0_ddr4_adr;
           
  genvar i;
  
    generate
      if (DRAM_WIDTH == 8)
      begin: mem_model_x8
           DDR4_if iDDR4[0:((2*8)/DRAM_WIDTH)-1]();
          
           for (i = 0; i < 2; i=i+1)
           begin:memModel
             ddr4_model u_ddr4_model(
                 .model_enable (model_enable),
                 .iDDR4        (iDDR4[i])
             );
           end
  
           for (i = 0; i < (2*8); i=i+1)
           begin:tranDQ
             //tran bidiDQ(iDDR4[i/8].DQ[i%8], c0_ddr4_dq[i]);
              `ifdef XILINX_SIMULATOR
                        short bidiDQ(iDDR4[i/8].DQ[i%8], c0_ddr4_dq[i]);
              `else 
                        tran bidiDQ(iDDR4[i/8].DQ[i%8], c0_ddr4_dq[i]);
              `endif
           end
  
           for (i = 0; i < 2; i=i+1)
           begin:tranDQS
            // tran bidiDQS(iDDR4[i].DQS_t, c0_ddr4_dqs_t[i]);
            // tran bidiDQS_(iDDR4[i].DQS_c, c0_ddr4_dqs_c[i]);
            // tran bidiDM(iDDR4[i].DM_n, c0_ddr4_dm_dbi_n[i]);
            
             `ifdef XILINX_SIMULATOR
                       short bidiDQS(iDDR4[i].DQS_t, c0_ddr4_dqs_t[i]);
                       short bidiDQS_(iDDR4[i].DQS_c, c0_ddr4_dqs_c[i]);
                      short bidiDM(iDDR4[i].DM_n, c0_ddr4_dm_dbi_n[i]);
             `else 
                       tran bidiDQS(iDDR4[i].DQS_t, c0_ddr4_dqs_t[i]);
                       tran bidiDQS_(iDDR4[i].DQS_c, c0_ddr4_dqs_c[i]);
                       tran bidiDM(iDDR4[i].DM_n, c0_ddr4_dm_dbi_n[i]);
             `endif
             assign iDDR4[i].CK = {c0_ddr4_ck_t, c0_ddr4_ck_c};
             assign iDDR4[i].ACT_n = c0_ddr4_act_n;
             assign iDDR4[i].RAS_n_A16 = DDR4_ADRMOD[16];
             assign iDDR4[i].CAS_n_A15 = DDR4_ADRMOD[15];
             assign iDDR4[i].WE_n_A14 = DDR4_ADRMOD[14];
            // assign iDDR4[i].PARITY = c0_ddr4_par;
             assign iDDR4[i].RESET_n = c0_ddr4_reset_n;
             assign iDDR4[i].CS_n = c0_ddr4_cs_n[0];
             assign iDDR4[i].CKE = c0_ddr4_cke[0];
             assign iDDR4[i].ODT = c0_ddr4_odt[0];
             assign iDDR4[i].BG = c0_ddr4_bg;
             assign iDDR4[i].BA = c0_ddr4_ba;
             assign iDDR4[i].ADDR_17 = DDR4_ADRMOD[17];
             assign iDDR4[i].ADDR = DDR4_ADRMOD[13:0];
           end
      end //mem_model_x8
      else
      begin: mem_model_x16
  
        if (DQ_WIDTH/16)
        begin: mem
  
             DDR4_if iDDR4[0:(DQ_WIDTH/DRAM_WIDTH)-1]();
  
             for (i = 0; i < DQ_WIDTH/DRAM_WIDTH; i=i+1)
             begin:memModel
                 ddr4_model u_ddr4_model(
                     .model_enable (model_enable),
                     .iDDR4        (iDDR4[i])
                 );
             end
  
             for (i = 0; i < ((DQ_WIDTH/DRAM_WIDTH)*16); i=i+1)
             begin:tranDQ
            //   tran bidiDQ(iDDR4[i/16].DQ[i%16], c0_ddr4_dq[i]);
            `ifdef XILINX_SIMULATOR
              short bidiDQ(iDDR4[i/16].DQ[i%16], c0_ddr4_dq[i]);
            `else
              tran bidiDQ(iDDR4[i/16].DQ[i%16], c0_ddr4_dq[i]);
            `endif
             end
  
             for (i = 0; i < DQ_WIDTH/DRAM_WIDTH; i=i+1)
             begin:tranDQS
            //   tran bidiDQS0(iDDR4[i].DQS_t[0], c0_ddr4_dqs_t[(2*i)]);
             //  tran bidiDQS0_(iDDR4[i].DQS_c[0], c0_ddr4_dqs_c[(2*i)]);
            //   tran bidiDM0(iDDR4[i].DM_n[0], c0_ddr4_dm_dbi_n[(2*i)]);
            //   tran bidiDQS1(iDDR4[i].DQS_t[1], c0_ddr4_dqs_t[((2*(i+1))-1)]);
           //    tran bidiDQS1_(iDDR4[i].DQS_c[1], c0_ddr4_dqs_c[((2*(i+1))-1)]);
           //    tran bidiDM1(iDDR4[i].DM_n[1], c0_ddr4_dm_dbi_n[((2*(i+1))-1)]);
            `ifdef XILINX_SIMULATOR
                    short bidiDQS0(iDDR4[i].DQS_t[0], c0_ddr4_dqs_t[(2*i)]);
                    short bidiDQS0_(iDDR4[i].DQS_c[0], c0_ddr4_dqs_c[(2*i)]);
                    short bidiDM0(iDDR4[i].DM_n[0], c0_ddr4_dm_dbi_n[(2*i)]);
                    short bidiDQS1(iDDR4[i].DQS_t[1], c0_ddr4_dqs_t[((2*(i+1))-1)]);
                    short bidiDQS1_(iDDR4[i].DQS_c[1], c0_ddr4_dqs_c[((2*(i+1))-1)]);
                    short bidiDM1(iDDR4[i].DM_n[1], c0_ddr4_dm_dbi_n[((2*(i+1))-1)]);
                  `else
                    tran bidiDQS0(iDDR4[i].DQS_t[0], c0_ddr4_dqs_t[(2*i)]);
                    tran bidiDQS0_(iDDR4[i].DQS_c[0], c0_ddr4_dqs_c[(2*i)]);
                    tran bidiDM0(iDDR4[i].DM_n[0], c0_ddr4_dm_dbi_n[(2*i)]);
                    tran bidiDQS1(iDDR4[i].DQS_t[1], c0_ddr4_dqs_t[((2*(i+1))-1)]);
                    tran bidiDQS1_(iDDR4[i].DQS_c[1], c0_ddr4_dqs_c[((2*(i+1))-1)]);
                    tran bidiDM1(iDDR4[i].DM_n[1], c0_ddr4_dm_dbi_n[((2*(i+1))-1)]);
                  `endif
           
               assign iDDR4[i].CK = { c0_ddr4_ck_t, c0_ddr4_ck_c };
               assign iDDR4[i].ACT_n = c0_ddr4_act_n;
               assign iDDR4[i].RAS_n_A16 = DDR4_ADRMOD[16];
               assign iDDR4[i].CAS_n_A15 = DDR4_ADRMOD[15];
               assign iDDR4[i].WE_n_A14 = DDR4_ADRMOD[14];
               //assign iDDR4[i].PARITY = c0_ddr4_par;
               assign iDDR4[i].RESET_n = c0_ddr4_reset_n;
               assign iDDR4[i].CS_n = c0_ddr4_cs_n[0];
               assign iDDR4[i].CKE = c0_ddr4_cke[0];
               assign iDDR4[i].ODT = c0_ddr4_odt[0];
               assign iDDR4[i].BG = c0_ddr4_bg;
               assign iDDR4[i].BA = c0_ddr4_ba;
               assign iDDR4[i].ADDR_17 = DDR4_ADRMOD[17];
               assign iDDR4[i].ADDR = DDR4_ADRMOD[13:0];
             end
        end //mem
  
        if (DQ_WIDTH%16) begin: mem_extra_bits
  
          DDR4_if iDDR4[(DQ_WIDTH/DRAM_WIDTH):(DQ_WIDTH/DRAM_WIDTH)]();
  
          ddr4_model u_ddr4_model(
              .model_enable (model_enable),
              .iDDR4        (iDDR4[(DQ_WIDTH/DRAM_WIDTH)])
          );
  
          for (i = (DQ_WIDTH/DRAM_WIDTH)*16; i < DQ_WIDTH; i=i+1) begin:tranDQ
          //  tran bidiDQ(iDDR4[i/16].DQ[i%16], c0_ddr4_dq[i]);
           // tran bidiDQ_msb(iDDR4[i/16].DQ[(i%16)+8], c0_ddr4_dq[i]);
           `ifdef XILINX_SIMULATOR
                     short bidiDQ(iDDR4[i/16].DQ[i%16], c0_ddr4_dq[i]);
                     short bidiDQ_msb(iDDR4[i/16].DQ[(i%16)+8], c0_ddr4_dq[i]);
                   `else
                     tran bidiDQ(iDDR4[i/16].DQ[i%16], c0_ddr4_dq[i]);
                     tran bidiDQ_msb(iDDR4[i/16].DQ[(i%16)+8], c0_ddr4_dq[i]);
                   `endif
          end
  
       //   tran bidiDQS0(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_t[0], c0_ddr4_dqs_t[DQS_WIDTH-1]);
       //   tran bidiDQS0_(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_c[0], c0_ddr4_dqs_c[DQS_WIDTH-1]);
       //   tran bidiDM0(iDDR4[DQ_WIDTH/DRAM_WIDTH].DM_n[0], c0_ddr4_dm_dbi_n[DM_WIDTH-1]);
       //   tran bidiDQS1(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_t[1], c0_ddr4_dqs_t[DQS_WIDTH-1]);
      //    tran bidiDQS1_(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_c[1], c0_ddr4_dqs_c[DQS_WIDTH-1]);
      //    tran bidiDM1(iDDR4[DQ_WIDTH/DRAM_WIDTH].DM_n[1], c0_ddr4_dm_dbi_n[DM_WIDTH-1]);
          
          `ifdef XILINX_SIMULATOR
                      short bidiDQS0(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_t[0], c0_ddr4_dqs_t[DQS_WIDTH-1]);
                      short bidiDQS0_(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_c[0], c0_ddr4_dqs_c[DQS_WIDTH-1]);
                      short bidiDM0(iDDR4[DQ_WIDTH/DRAM_WIDTH].DM_n[0], c0_ddr4_dm_dbi_n[DM_WIDTH-1]);
                      short bidiDQS1(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_t[1], c0_ddr4_dqs_t[DQS_WIDTH-1]);
                      short bidiDQS1_(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_c[1], c0_ddr4_dqs_c[DQS_WIDTH-1]);
                      short bidiDM1(iDDR4[DQ_WIDTH/DRAM_WIDTH].DM_n[1], c0_ddr4_dm_dbi_n[DM_WIDTH-1]);
                  `else
                      tran bidiDQS0(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_t[0], c0_ddr4_dqs_t[DQS_WIDTH-1]);
                      tran bidiDQS0_(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_c[0], c0_ddr4_dqs_c[DQS_WIDTH-1]);
                      tran bidiDM0(iDDR4[DQ_WIDTH/DRAM_WIDTH].DM_n[0], c0_ddr4_dm_dbi_n[DM_WIDTH-1]);
                      tran bidiDQS1(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_t[1], c0_ddr4_dqs_t[DQS_WIDTH-1]);
                      tran bidiDQS1_(iDDR4[DQ_WIDTH/DRAM_WIDTH].DQS_c[1], c0_ddr4_dqs_c[DQS_WIDTH-1]);
                      tran bidiDM1(iDDR4[DQ_WIDTH/DRAM_WIDTH].DM_n[1], c0_ddr4_dm_dbi_n[DM_WIDTH-1]);
                  `endif
  
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].CK = {c0_ddr4_ck_t, c0_ddr4_ck_c};
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].ACT_n = c0_ddr4_act_n;
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].RAS_n_A16 = DDR4_ADRMOD[16];
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].CAS_n_A15 = DDR4_ADRMOD[15];
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].WE_n_A14 = DDR4_ADRMOD[14];
       //   assign iDDR4[DQ_WIDTH/DRAM_WIDTH].PARITY = c0_ddr4_par;
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].RESET_n = c0_ddr4_reset_n;
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].CS_n = c0_ddr4_cs_n[0];
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].CKE = c0_ddr4_cke[0];
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].ODT = c0_ddr4_odt[0];
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].BG = c0_ddr4_bg;
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].BA = c0_ddr4_ba;
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].ADDR_17 = DDR4_ADRMOD[17];
          assign iDDR4[DQ_WIDTH/DRAM_WIDTH].ADDR = DDR4_ADRMOD[13:0];
        end //mem_extra_bits
        
      end // mem_model_x16
    endgenerate
//  assign net_gnd2[1:0] = 2'b00;
//  assign net_gnd = 1'b0;

  //------------------------------------------------------------------------------//
  // Generate system-level reset
  //------------------------------------------------------------------------------//
  initial begin
    $display("[%t] : System Reset Is Asserted...", $realtime);
    sys_rst_n = 1'b0;
    repeat (500) @(posedge sys_clk);
    $display("[%t] : System Reset Is De-asserted...", $realtime);
    sys_rst_n = 1'b1;
  end

  initial begin

    if ($test$plusargs ("dump_all")) begin

  `ifdef NCV // Cadence TRN dump

      $recordsetup("design=board",
                   "compress",
                   "wrapsize=100M",
                   "version=1",
                   "run=1");
      $recordvars();

  `elsif VCS //Synopsys VPD dump

      $vcdplusfile("board.vpd");
      $vcdpluson;
      $vcdplusglitchon;
      $vcdplusflush;

  `else

      // Verilog VC dump
      $dumpfile("board.vcd");
      $dumpvars(0, board);

  `endif

    end

  end


endmodule // BOARD
