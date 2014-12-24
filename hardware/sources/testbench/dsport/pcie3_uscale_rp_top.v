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
// File       : pcie3_uscale_rp_top.v
// Version    : 3.0 
//-----------------------------------------------------------------------------

/////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module pcie3_uscale_rp_top  (                                                                                                                                                           
  output wire   [7:0] pci_exp_txn,
  output wire   [7:0] pci_exp_txp,
  input  wire   [7:0] pci_exp_rxn,
  input  wire   [7:0] pci_exp_rxp,
  output wire         user_clk,
  output wire         user_reset,
  output wire         user_lnk_up,
  input  wire [255:0] s_axis_rq_tdata,
  input  wire   [7:0] s_axis_rq_tkeep,
  input  wire         s_axis_rq_tlast,
  output wire   [3:0] s_axis_rq_tready,
  input  wire  [59:0] s_axis_rq_tuser,
  input  wire         s_axis_rq_tvalid,
  output wire [255:0] m_axis_rc_tdata,
  output wire   [7:0] m_axis_rc_tkeep,
  output wire         m_axis_rc_tlast,
  input  wire  [21:0] m_axis_rc_tready,
  output wire  [74:0] m_axis_rc_tuser,
  output wire         m_axis_rc_tvalid,
  output wire [255:0] m_axis_cq_tdata,
  output wire   [7:0] m_axis_cq_tkeep,
  output wire         m_axis_cq_tlast,
  input  wire  [21:0] m_axis_cq_tready,
  output wire  [84:0] m_axis_cq_tuser,
  output wire         m_axis_cq_tvalid,
  input  wire [255:0] s_axis_cc_tdata,
  input  wire   [7:0] s_axis_cc_tkeep,
  input  wire         s_axis_cc_tlast,
  output wire   [3:0] s_axis_cc_tready,
  input  wire  [32:0] s_axis_cc_tuser,
  input  wire         s_axis_cc_tvalid,
  output wire   [1:0] pcie_tfc_nph_av,
  output wire   [1:0] pcie_tfc_npd_av,
  output wire   [3:0] pcie_rq_seq_num,
  output wire         pcie_rq_seq_num_vld,
  output wire   [5:0] pcie_rq_tag,
  output wire   [1:0] pcie_rq_tag_av,
  output wire         pcie_rq_tag_vld,
  input  wire         pcie_cq_np_req,
  output wire   [5:0] pcie_cq_np_req_count,
  output wire         cfg_phy_link_down,
  output wire   [1:0] cfg_phy_link_status,
  output wire   [3:0] cfg_negotiated_width,
  output wire   [2:0] cfg_current_speed,
  output wire   [2:0] cfg_max_payload,
  output wire   [2:0] cfg_max_read_req,
  output wire  [15:0] cfg_function_status,
  output wire  [11:0] cfg_function_power_state,
  output wire  [15:0] cfg_vf_status,
  output wire  [23:0] cfg_vf_power_state,
  output wire   [1:0] cfg_link_power_state,
  input  wire  [18:0] cfg_mgmt_addr,
  input  wire         cfg_mgmt_write,
  input  wire  [31:0] cfg_mgmt_write_data,
  input  wire   [3:0] cfg_mgmt_byte_enable,
  input  wire         cfg_mgmt_read,
  output wire  [31:0] cfg_mgmt_read_data,
  output wire         cfg_mgmt_read_write_done,
  input  wire         cfg_mgmt_type1_cfg_reg_access,
  output wire         cfg_err_cor_out,
  output wire         cfg_err_nonfatal_out,
  output wire         cfg_err_fatal_out,
  output wire         cfg_local_error,
  output wire         cfg_ltr_enable,
  output wire   [5:0] cfg_ltssm_state,
  output wire   [3:0] cfg_rcb_status,
  output wire   [3:0] cfg_dpa_substate_change,
  output wire   [1:0] cfg_obff_enable,
  output wire         cfg_pl_status_change,
  output wire   [3:0] cfg_tph_requester_enable,
  output wire  [11:0] cfg_tph_st_mode,
  output wire   [7:0] cfg_vf_tph_requester_enable,
  output wire  [23:0] cfg_vf_tph_st_mode,
  output wire         cfg_msg_received,
  output wire   [7:0] cfg_msg_received_data,
  output wire   [4:0] cfg_msg_received_type,
  input  wire         cfg_msg_transmit,
  input  wire   [2:0] cfg_msg_transmit_type,
  input  wire  [31:0] cfg_msg_transmit_data,
  output wire         cfg_msg_transmit_done,
  output wire   [7:0] cfg_fc_ph,
  output wire  [11:0] cfg_fc_pd,
  output wire   [7:0] cfg_fc_nph,
  output wire  [11:0] cfg_fc_npd,
  output wire   [7:0] cfg_fc_cplh,
  output wire  [11:0] cfg_fc_cpld,
  input  wire   [2:0] cfg_fc_sel,
  input  wire   [2:0] cfg_per_func_status_control,
  output wire  [15:0] cfg_per_func_status_data,
  input  wire   [3:0] cfg_per_function_number,
  input  wire         cfg_per_function_output_request,
  output wire         cfg_per_function_update_done,
  input  wire  [63:0] cfg_dsn,
  input  wire         cfg_power_state_change_ack,
  output wire         cfg_power_state_change_interrupt,
  input  wire         cfg_err_cor_in,
  input  wire         cfg_err_uncor_in,
  output wire   [3:0] cfg_flr_in_process,
  input  wire   [3:0] cfg_flr_done,
  output wire   [7:0] cfg_vf_flr_in_process,
  input  wire   [7:0] cfg_vf_flr_done,
  input  wire         cfg_link_training_enable,
  output wire         cfg_ext_read_received,
  output wire         cfg_ext_write_received,
  output wire   [9:0] cfg_ext_register_number,
  output wire   [7:0] cfg_ext_function_number,
  output wire  [31:0] cfg_ext_write_data,
  output wire   [3:0] cfg_ext_write_byte_enable,
  input  wire  [31:0] cfg_ext_read_data,
  input  wire         cfg_ext_read_data_valid,
  input  wire   [3:0] cfg_interrupt_int,
  input  wire   [3:0] cfg_interrupt_pending,
  output wire         cfg_interrupt_sent,
  output wire   [3:0] cfg_interrupt_msi_enable,
  output wire   [7:0] cfg_interrupt_msi_vf_enable,
  output wire  [11:0] cfg_interrupt_msi_mmenable,
  output wire         cfg_interrupt_msi_mask_update,
  output wire  [31:0] cfg_interrupt_msi_data,
  input  wire   [3:0] cfg_interrupt_msi_select,
  input  wire  [31:0] cfg_interrupt_msi_int,
  input  wire  [31:0] cfg_interrupt_msi_pending_status,
  input  wire         cfg_interrupt_msi_pending_status_data_enable,
  input  wire   [3:0] cfg_interrupt_msi_pending_status_function_num,
  output wire         cfg_interrupt_msi_sent,
  output wire         cfg_interrupt_msi_fail,
  input  wire   [2:0] cfg_interrupt_msi_attr,
  input  wire         cfg_interrupt_msi_tph_present,
  input  wire   [1:0] cfg_interrupt_msi_tph_type,
  input  wire   [8:0] cfg_interrupt_msi_tph_st_tag,
  input  wire   [3:0] cfg_interrupt_msi_function_number,
  output wire         cfg_hot_reset_out,
  input  wire         cfg_config_space_enable,
  input  wire         cfg_req_pm_transition_l23_ready,
  input  wire         cfg_hot_reset_in,
  input  wire   [7:0] cfg_ds_port_number,
  input  wire   [7:0] cfg_ds_bus_number,
  input  wire   [4:0] cfg_ds_device_number,
  input  wire   [2:0] cfg_ds_function_number,
  input   [25:0]      common_commands_in,
  input   [83:0]      pipe_rx_0_sigs,
  input   [83:0]      pipe_rx_1_sigs,
  input   [83:0]      pipe_rx_2_sigs,
  input   [83:0]      pipe_rx_3_sigs,
  input   [83:0]      pipe_rx_4_sigs,
  input   [83:0]      pipe_rx_5_sigs,
  input   [83:0]      pipe_rx_6_sigs,
  input   [83:0]      pipe_rx_7_sigs,
                      
  output  [16:0]      common_commands_out,
  output  [69:0]      pipe_tx_0_sigs,
  output  [69:0]      pipe_tx_1_sigs,
  output  [69:0]      pipe_tx_2_sigs,
  output  [69:0]      pipe_tx_3_sigs,
  output  [69:0]      pipe_tx_4_sigs,
  output  [69:0]      pipe_tx_5_sigs,
  output  [69:0]      pipe_tx_6_sigs,
  output  [69:0]      pipe_tx_7_sigs,
  input  wire         sys_clk,
  input  wire         sys_clk_gt,
  input  wire         sys_reset,
  output wire         pcie_perstn0_out,
  input  wire         pcie_perstn1_in,
  output wire         pcie_perstn1_out 
  );

  wire [15:0]  cfg_vend_id        = 16'H10EE;            //DEF_CFG_VEND_ID;
  wire [15:0]  cfg_subsys_vend_id = 16'H10EE;            //DEF_CFG_SUBSYS_VEND_ID;
  wire [15:0]  cfg_dev_id         = 16'H7038;            //DEF_PF0_DEVICE_ID;
  wire [15:0]  cfg_subsys_id      = 16'H0007;            //DEF_PF0_SUBSYSTEM_ID;
  wire [7:0]   cfg_rev_id         = 8'H00;              //DEF_PF0_REVISION_ID;

  trd_pcie3_ultrascale_0_0_pcie3_uscale_core_top
  #(
    .ARI_CAP_ENABLE ("FALSE"),   
    .DIS_GT_WIZARD   ("TRUE"),  
    .SHARED_LOGIC     ( 1 ),
    .AXISTEN_IF_CC_ALIGNMENT_MODE ( "FALSE" ),
    .AXISTEN_IF_CC_PARITY_CHK ("FALSE" ),
    .AXISTEN_IF_CQ_ALIGNMENT_MODE ("FALSE"),
    .AXISTEN_IF_ENABLE_CLIENT_TAG ("FALSE"),
    .AXISTEN_IF_ENABLE_MSG_ROUTE ('H0), 
    .AXISTEN_IF_ENABLE_RX_MSG_INTFC ("FALSE"),
    .AXISTEN_IF_RC_ALIGNMENT_MODE ("FALSE"),
    .AXISTEN_IF_RC_STRADDLE ("FALSE"),
    .AXISTEN_IF_RQ_ALIGNMENT_MODE ("FALSE"),
    .AXISTEN_IF_RQ_PARITY_CHK ("FALSE"),
    .COMPLETION_SPACE("8KB"),
    .C_DATA_WIDTH(256),
    .DEBUG_CFG_LOCAL_MGMT_REG_ACCESS_OVERRIDE ("FALSE"),
    .DEBUG_PL_DISABLE_EI_INFER_IN_L0 ("FALSE"),
    .DEBUG_TL_DISABLE_RX_TLP_ORDER_CHECKS ("FALSE"),
    .DNSTREAM_LINK_NUM ('H00),
    .INTERFACE_SPEED ("500MHZ" ),  
    .KEEP_WIDTH(8),
    .NO_DECODE_LOGIC ("FALSE"),
    .PCIE_CHAN_BOND (0),
    .PCIE_CHAN_BOND_EN ("FALSE"),
    .PCIE_EXT_CLK ("FALSE"),
    .PCIE_GT_DEVICE ("GTH"),
    .PCIE_LINK_SPEED(3),
    .PCIE_LPM_DFE ("LPM"),
    .PCIE_TXBUF_EN ("FALSE"),
    .PCIE_USE_MODE ("2.1"),
    .PF0_AER_CAP_ECRC_CHECK_CAPABLE ("FALSE"),
    .PF0_AER_CAP_ECRC_GEN_CAPABLE ("FALSE"),
    .PF0_AER_CAP_NEXTPTR ('H300),
    .PF0_ARI_CAP_NEXTPTR ('H000),
    .PF0_ARI_CAP_NEXT_FUNC ('H0),
    .PF0_ARI_CAP_VER ('H1),
    .PF0_BAR0_APERTURE_SIZE('B00100),
    .PF0_BAR0_CONTROL('B100),
    .PF0_BAR1_APERTURE_SIZE('B00000),
    .PF0_BAR1_CONTROL('B000),
    .PF0_BAR2_APERTURE_SIZE('B00000),
    .PF0_BAR2_CONTROL('B000),
    .PF0_BAR3_APERTURE_SIZE('B00000),
    .PF0_BAR3_CONTROL('B000),
    .PF0_BAR4_APERTURE_SIZE('B00000),
    .PF0_BAR4_CONTROL('B000),
    .PF0_BAR5_APERTURE_SIZE('B00000),
    .PF0_BAR5_CONTROL('B000),
    .PF0_BIST_REGISTER ('H0), 
    .PF0_CAPABILITY_POINTER('H80),
    .PF0_CLASS_CODE('H058000),
    .PF0_DEVICE_ID('H7031),
    .PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT("FALSE"),
    .PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT("FALSE"),
    .PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT("FALSE"), 
    .PF0_DEV_CAP2_ARI_FORWARD_ENABLE ("FALSE"), 
    .PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE ("TRUE"),
    .PF0_DEV_CAP2_LTR_SUPPORT("FALSE"),
    .PF0_DEV_CAP2_OBFF_SUPPORT('D0),
    .PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT("FALSE"),   
    .PF0_DEV_CAP_ENDPOINT_L0S_LATENCY ('D0),
    .PF0_DEV_CAP_ENDPOINT_L1_LATENCY ('D0),
    .PF0_DEV_CAP_EXT_TAG_SUPPORTED("FALSE"),
    .PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE("FALSE"),
    .PF0_DEV_CAP_MAX_PAYLOAD_SIZE('B010),
    .PF0_DPA_CAP_NEXTPTR('H300),
    .PF0_DPA_CAP_SUB_STATE_CONTROL ('H0), 
    .PF0_DPA_CAP_SUB_STATE_CONTROL_EN ("TRUE"),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7('H00),
    .PF0_DPA_CAP_VER ('H1),
    .PF0_DSN_CAP_NEXTPTR('H300),
    .PF0_EXPANSION_ROM_APERTURE_SIZE('B00000),
    .PF0_EXPANSION_ROM_ENABLE("FALSE"),
    .PF0_INTERRUPT_LINE ('H0),
    .PF0_INTERRUPT_PIN('H01),
    .PF0_LINK_CAP_ASPM_SUPPORT(0),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 ('D7),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 ('D7),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 ('D7),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 ('D7),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 ('D7),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 ('D7),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 ('D7),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 ('D7),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 ('D7),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 ('D7),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 ('D7),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 ('D7),
    .PF0_LINK_STATUS_SLOT_CLOCK_CONFIG ("FALSE"),
    .PF0_LTR_CAP_MAX_NOSNOOP_LAT ('H0),
    .PF0_LTR_CAP_MAX_SNOOP_LAT ('H0),
    .PF0_LTR_CAP_NEXTPTR ('H300),
    .PF0_LTR_CAP_VER ('H1),
    .PF0_MSIX_CAP_NEXTPTR('H00),
    .PF0_MSIX_CAP_PBA_BIR(0),
    .PF0_MSIX_CAP_PBA_OFFSET('H00000000),
    .PF0_MSIX_CAP_TABLE_BIR(0),
    .PF0_MSIX_CAP_TABLE_OFFSET('H00000000),
    .PF0_MSIX_CAP_TABLE_SIZE('H000),
    .PF0_MSI_CAP_MULTIMSGCAP(0),
    .PF0_MSI_CAP_NEXTPTR('HC0),
    .PF0_MSI_CAP_PERVECMASKCAP ("FALSE"),
    .PF0_PB_CAP_DATA_REG_D0 ('H0), 
    .PF0_PB_CAP_DATA_REG_D0_SUSTAINED ('H0), 
    .PF0_PB_CAP_DATA_REG_D1 ('H0), 
    .PF0_PB_CAP_DATA_REG_D3HOT ('H0), 
    .PF0_PB_CAP_NEXTPTR ('H274),
    .PF0_PB_CAP_SYSTEM_ALLOCATED ("FALSE"),
    .PF0_PB_CAP_VER ('H1),
    .PF0_PM_CAP_ID ('H1),
    .PF0_PM_CAP_NEXTPTR('H90),
    .PF0_PM_CAP_PMESUPPORT_D0("FALSE"),
    .PF0_PM_CAP_PMESUPPORT_D1("FALSE"),
    .PF0_PM_CAP_PMESUPPORT_D3HOT("FALSE"),
    .PF0_PM_CAP_SUPP_D1_STATE("FALSE"),
    .PF0_PM_CAP_VER_ID ('H3),
    .PF0_PM_CSR_NOSOFTRESET ("TRUE"),
    .PF0_RBAR_CAP_ENABLE("FALSE"),
    .PF0_RBAR_CAP_NEXTPTR('H300),
    .PF0_RBAR_CAP_SIZE0('H00000),
    .PF0_RBAR_CAP_SIZE1('H00000),
    .PF0_RBAR_CAP_SIZE2('H00000),
    .PF0_RBAR_CAP_VER ('H1),
    .PF0_RBAR_CONTROL_INDEX0 ('H0),
    .PF0_RBAR_CONTROL_INDEX1 ('H0),
    .PF0_RBAR_CONTROL_INDEX2 ('H0),
    .PF0_RBAR_CONTROL_SIZE0 ('H0),
    .PF0_RBAR_CONTROL_SIZE1 ('H0),
    .PF0_RBAR_CONTROL_SIZE2 ('H0),
    .PF0_RBAR_NUM ('H1),
    .PF0_REVISION_ID ('H00),
    .PF0_SECONDARY_PCIE_CAP_NEXTPTR ('H0),
    .PF0_SRIOV_BAR0_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR0_CONTROL('B000),
    .PF0_SRIOV_BAR1_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR1_CONTROL('B000),
    .PF0_SRIOV_BAR2_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR2_CONTROL('B000),
    .PF0_SRIOV_BAR3_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR3_CONTROL('B000),
    .PF0_SRIOV_BAR4_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR4_CONTROL('B000),
    .PF0_SRIOV_BAR5_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR5_CONTROL('B000),
    .PF0_SRIOV_CAP_INITIAL_VF('H0000),
    .PF0_SRIOV_CAP_NEXTPTR('H300),
    .PF0_SRIOV_CAP_TOTAL_VF('H0000),
    .PF0_SRIOV_CAP_VER('H0),
    .PF0_SRIOV_FIRST_VF_OFFSET('H0000),
    .PF0_SRIOV_FUNC_DEP_LINK('H0000),
    .PF0_SRIOV_SUPPORTED_PAGE_SIZE('H00000553),
    .PF0_SRIOV_VF_DEVICE_ID('H0000),
    .PF0_SUBSYSTEM_ID('H0007),
    .PF0_TPHR_CAP_DEV_SPECIFIC_MODE ("TRUE"),
    .PF0_TPHR_CAP_ENABLE ("FALSE"),
    .PF0_TPHR_CAP_INT_VEC_MODE ("TRUE"),
    .PF0_TPHR_CAP_NEXTPTR ('H300),
    .PF0_TPHR_CAP_ST_MODE_SEL ('H0),
    .PF0_TPHR_CAP_ST_TABLE_LOC ('H0),
    .PF0_TPHR_CAP_ST_TABLE_SIZE ('H0),
    .PF0_TPHR_CAP_VER ('H1),
    .PF0_VC_CAP_ENABLE ("FALSE"), 
    .PF0_VC_CAP_NEXTPTR ('H000),
    .PF0_VC_CAP_VER ('H1),
    .PF1_AER_CAP_ECRC_CHECK_CAPABLE("FALSE"),
    .PF1_AER_CAP_ECRC_GEN_CAPABLE("FALSE"),
    .PF1_AER_CAP_NEXTPTR('H000),
    .PF1_ARI_CAP_NEXTPTR('H000),
    .PF1_ARI_CAP_NEXT_FUNC ('H0),
    .PF1_BAR0_APERTURE_SIZE('B00000),
    .PF1_BAR0_CONTROL('B000),
    .PF1_BAR1_APERTURE_SIZE('B00000),
    .PF1_BAR1_CONTROL('B000),
    .PF1_BAR2_APERTURE_SIZE('B00000),
    .PF1_BAR2_CONTROL('B000),
    .PF1_BAR3_APERTURE_SIZE('B00000),
    .PF1_BAR3_CONTROL('B000),
    .PF1_BAR4_APERTURE_SIZE('B00000),
    .PF1_BAR4_CONTROL('B000),
    .PF1_BAR5_APERTURE_SIZE('B00000),
    .PF1_BAR5_CONTROL('B000),
    .PF1_BIST_REGISTER ('H0),
    .PF1_DPA_CAP_SUB_STATE_CONTROL ('H0),
    .PF1_DPA_CAP_SUB_STATE_CONTROL_EN ("TRUE"),
    .PF1_CAPABILITY_POINTER('H80),
    .PF1_CLASS_CODE('H058000),
    .PF1_DEVICE_ID('H7011),
    .PF1_DEV_CAP_MAX_PAYLOAD_SIZE('B010),
    .PF1_DPA_CAP_NEXTPTR('H000),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7('H00),    
    .PF1_DPA_CAP_VER ('H1),
    .PF1_DSN_CAP_NEXTPTR('H000),
    .PF1_EXPANSION_ROM_APERTURE_SIZE('B00000),
    .PF1_EXPANSION_ROM_ENABLE("FALSE"),
    .PF1_INTERRUPT_LINE ('H0),
    .PF1_INTERRUPT_PIN('H00),
    .PF1_MSIX_CAP_NEXTPTR('H00),
    .PF1_MSIX_CAP_PBA_BIR(0),
    .PF1_MSIX_CAP_PBA_OFFSET('H00000000),
    .PF1_MSIX_CAP_TABLE_BIR(0),
    .PF1_MSIX_CAP_TABLE_OFFSET('H00000000),
    .PF1_MSIX_CAP_TABLE_SIZE('H000),
    .PF1_MSI_CAP_MULTIMSGCAP(0),
    .PF1_MSI_CAP_NEXTPTR('H00),  
    .PF1_MSI_CAP_PERVECMASKCAP ("FALSE"), 
    .PF1_PB_CAP_DATA_REG_D0 ('H0),     
    .PF1_PB_CAP_DATA_REG_D0_SUSTAINED ('H0),
    .PF1_PB_CAP_DATA_REG_D1 ('H0),
    .PF1_PB_CAP_DATA_REG_D3HOT ('H0),
    .PF1_PB_CAP_NEXTPTR ('H000),
    .PF1_PB_CAP_SYSTEM_ALLOCATED ("FALSE"),
    .PF1_PB_CAP_VER ('H1),
    .PF1_PM_CAP_ID ('H1),
    .PF1_PM_CAP_NEXTPTR ('H00),
    .PF1_PM_CAP_VER_ID ('H3),
    .PF1_RBAR_CAP_ENABLE("FALSE"),
    .PF1_RBAR_CAP_NEXTPTR('H000),
    .PF1_RBAR_CAP_SIZE0('H00000),
    .PF1_RBAR_CAP_SIZE1('H00000),
    .PF1_RBAR_CAP_SIZE2('H00000),
    .PF1_RBAR_CAP_VER ('H1),
    .PF1_RBAR_CONTROL_INDEX0 ('H0),
    .PF1_RBAR_CONTROL_INDEX1 ('H0),
    .PF1_RBAR_CONTROL_INDEX2 ('H0),
    .PF1_RBAR_CONTROL_SIZE0 ('H0),
    .PF1_RBAR_CONTROL_SIZE1 ('H0),
    .PF1_RBAR_CONTROL_SIZE2 ('H0),
    .PF1_RBAR_NUM ('H1),
    .PF1_REVISION_ID('H00),
    .PF1_SRIOV_BAR0_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR0_CONTROL('B000),
    .PF1_SRIOV_BAR1_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR1_CONTROL('B000),
    .PF1_SRIOV_BAR2_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR2_CONTROL('B000),
    .PF1_SRIOV_BAR3_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR3_CONTROL('B000),
    .PF1_SRIOV_BAR4_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR4_CONTROL('B000),
    .PF1_SRIOV_BAR5_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR5_CONTROL('B000),
    .PF1_SRIOV_CAP_INITIAL_VF('H0000),
    .PF1_SRIOV_CAP_NEXTPTR('H000),
    .PF1_SRIOV_CAP_TOTAL_VF('H0000),
    .PF1_SRIOV_CAP_VER('H0),
    .PF1_SRIOV_FIRST_VF_OFFSET('H0000),
    .PF1_SRIOV_FUNC_DEP_LINK('H0001),
    .PF1_SRIOV_SUPPORTED_PAGE_SIZE('H00000553),
    .PF1_SRIOV_VF_DEVICE_ID('H0000),
    .PF1_SUBSYSTEM_ID('H0007),  
    .PF1_TPHR_CAP_DEV_SPECIFIC_MODE ("TRUE"),
    .PF1_TPHR_CAP_ENABLE ("FALSE"),
    .PF1_TPHR_CAP_INT_VEC_MODE ("TRUE"),
    .PF1_TPHR_CAP_NEXTPTR('H000),
    .PF1_TPHR_CAP_ST_MODE_SEL ('H0),
    .PF1_TPHR_CAP_ST_TABLE_LOC ('H0),
    .PF1_TPHR_CAP_ST_TABLE_SIZE ('H0),
    .PF1_TPHR_CAP_VER ('H1),
    .PIPE_PIPELINE_STAGES (0), // NOTE: not in defines, may need to be derived?
    .PL_DISABLE_AUTO_EQ_SPEED_CHANGE_TO_GEN3 ("FALSE"), 
    .PL_DISABLE_AUTO_SPEED_CHANGE_TO_GEN2 ("FALSE"), 
    .PL_DISABLE_EI_INFER_IN_L0 ("TRUE"),
    .PL_DISABLE_GEN3_DC_BALANCE ("FALSE"),
    .PL_DISABLE_GEN3_LFSR_UPDATE_ON_SKP ("TRUE"),
    .PL_DISABLE_RETRAIN_ON_FRAMING_ERROR ("FALSE"),
    .PL_DISABLE_SCRAMBLING ("FALSE"),
    .PL_DISABLE_SYNC_HEADER_FRAMING_ERROR ("FALSE"),
    .PL_DISABLE_UPCONFIG_CAPABLE ("FALSE"),
    .PL_EQ_ADAPT_DISABLE_COEFF_CHECK ("FALSE"),
    .PL_EQ_ADAPT_DISABLE_PRESET_CHECK ("FALSE"),
    .PL_EQ_ADAPT_ITER_COUNT ('H2),
    .PL_EQ_ADAPT_REJECT_RETRY_COUNT ('H1),
    .PL_EQ_BYPASS_PHASE23 ("FALSE"),
    .PL_EQ_DEFAULT_GEN3_RX_PRESET_HINT ('H3), 
    .PL_EQ_DEFAULT_GEN3_TX_PRESET ('H4), 
    .PL_EQ_PHASE01_RX_ADAPT ("FALSE"),
    .PL_EQ_SHORT_ADAPT_PHASE ("FALSE"),
    .PL_LANE0_EQ_CONTROL ('H3F00),
    .PL_LANE1_EQ_CONTROL ('H3F00 ),
    .PL_LANE2_EQ_CONTROL ('H3F00 ),
    .PL_LANE3_EQ_CONTROL ('H3F00 ),
    .PL_LANE4_EQ_CONTROL ('H3F00 ),
    .PL_LANE5_EQ_CONTROL ('H3F00 ),
    .PL_LANE6_EQ_CONTROL ('H3F00 ),
    .PL_LANE7_EQ_CONTROL ('H3F00 ),
    .PL_N_FTS_COMCLK_GEN1 ('D255),
    .PL_N_FTS_COMCLK_GEN2 ('D255),
    .PL_N_FTS_COMCLK_GEN3 ('D255),
    .PL_N_FTS_GEN1 ('D255),
    .PL_N_FTS_GEN2 ('D255),
    .PL_N_FTS_GEN3 ('D255),
    .PL_REPORT_ALL_PHY_ERRORS ("TRUE"),
    .PL_SIM_FAST_LINK_TRAINING ( "TRUE" ), 
    .PL_UPSTREAM_FACING ("FALSE"),
    .PM_ASPML0S_TIMEOUT ('H5DC),
    .PM_ASPML1_ENTRY_DELAY ('H0),
    .PM_ENABLE_L23_ENTRY ("FALSE"), 
    .PM_ENABLE_SLOT_POWER_CAPTURE ("TRUE"),
    .PM_L1_REENTRY_DELAY ('H0),
    .PM_PME_SERVICE_TIMEOUT_DELAY ('H18680),
    .PM_PME_TURNOFF_ACK_DELAY ('H64),
    .REF_CLK_FREQ (0),  
    .SIM_JTAG_IDCODE ('H0),
    .SRIOV_CAP_ENABLE ("FALSE"),
    .TL_COMPL_TIMEOUT_REG0 ( 'HBEBC20),
    .TL_COMPL_TIMEOUT_REG1 ( 'H2FAF080),
    .TL_CREDITS_CD('H000),
    .TL_CREDITS_CH('H00),
    .TL_CREDITS_NPD('H28),
    .TL_CREDITS_NPH('H20),
    .TL_CREDITS_PD('HCC),
    .TL_CREDITS_PH('H20),
    .TL_ENABLE_MESSAGE_RID_CHECK_ENABLE ("TRUE"),
    .TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE ("FALSE"),
    .TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE ("FALSE"),
    .TL_LEGACY_MODE_ENABLE ("FALSE"),
    .TL_PF_ENABLE_REG ("FALSE"),
    .TL_TX_MUX_STRICT_PRIORITY ("TRUE"),
    .TWO_LAYER_MODE_DLCMSM_ENABLE ("TRUE"), 
    .TWO_LAYER_MODE_ENABLE ("FALSE"),
    .TWO_LAYER_MODE_WIDTH_256 ("TRUE"),
    .USER_CLK_FREQ(3),
    .VF0_ARI_CAP_NEXTPTR('H000),
    .VF0_CAPABILITY_POINTER('H80),
    .VF0_MSIX_CAP_PBA_BIR(0),
    .VF0_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF0_MSIX_CAP_TABLE_BIR(0),
    .VF0_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF0_MSIX_CAP_TABLE_SIZE('H000),
    .VF0_MSI_CAP_MULTIMSGCAP(0),
    .VF0_PM_CAP_ID ('H1),
    .VF0_PM_CAP_NEXTPTR ('B00000000),
    .VF0_PM_CAP_VER_ID ('H3),
    .VF0_TPHR_CAP_DEV_SPECIFIC_MODE ("TRUE"),
    .VF0_TPHR_CAP_ENABLE ("FALSE"),
    .VF0_TPHR_CAP_INT_VEC_MODE ("TRUE"),
    .VF0_TPHR_CAP_NEXTPTR ('H000),
    .VF0_TPHR_CAP_ST_MODE_SEL ('H0),
    .VF0_TPHR_CAP_ST_TABLE_LOC ('H0),
    .VF0_TPHR_CAP_ST_TABLE_SIZE ('H0),
    .VF0_TPHR_CAP_VER ('H1),
    .VF1_ARI_CAP_NEXTPTR ('H000),
    .VF1_MSIX_CAP_PBA_BIR(0),
    .VF1_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF1_MSIX_CAP_TABLE_BIR(0),
    .VF1_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF1_MSIX_CAP_TABLE_SIZE('H000),
    .VF1_MSI_CAP_MULTIMSGCAP(0), 
    .VF1_PM_CAP_ID ('H1),
    .VF1_PM_CAP_NEXTPTR ('B00000000),
    .VF1_PM_CAP_VER_ID ('H3),
    .VF1_TPHR_CAP_DEV_SPECIFIC_MODE ("TRUE"),
    .VF1_TPHR_CAP_ENABLE ("FALSE"),
    .VF1_TPHR_CAP_INT_VEC_MODE ("TRUE"),
    .VF1_TPHR_CAP_NEXTPTR ('H000),
    .VF1_TPHR_CAP_ST_MODE_SEL ('H0),
    .VF1_TPHR_CAP_ST_TABLE_LOC ('H0),
    .VF1_TPHR_CAP_ST_TABLE_SIZE ('H0),
    .VF1_TPHR_CAP_VER ('H1),
    .VF2_ARI_CAP_NEXTPTR('H000),
    .VF2_MSIX_CAP_PBA_BIR(0),
    .VF2_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF2_MSIX_CAP_TABLE_BIR(0),
    .VF2_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF2_MSIX_CAP_TABLE_SIZE('H000),
    .VF2_MSI_CAP_MULTIMSGCAP(0),     
    .VF2_PM_CAP_ID ('H1), 
    .VF2_PM_CAP_NEXTPTR ('B00000000),
    .VF2_PM_CAP_VER_ID ('H3),
    .VF2_TPHR_CAP_DEV_SPECIFIC_MODE ("TRUE"),
    .VF2_TPHR_CAP_ENABLE ("FALSE"),
    .VF2_TPHR_CAP_INT_VEC_MODE ("TRUE"),
    .VF2_TPHR_CAP_NEXTPTR ('H000),
    .VF2_TPHR_CAP_ST_MODE_SEL ('H0),
    .VF2_TPHR_CAP_ST_TABLE_LOC ('H0),
    .VF2_TPHR_CAP_ST_TABLE_SIZE ('H0),
    .VF2_TPHR_CAP_VER ('H1),
    .VF3_ARI_CAP_NEXTPTR ('H000),
    .VF3_MSIX_CAP_PBA_BIR(0),
    .VF3_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF3_MSIX_CAP_TABLE_BIR(0),
    .VF3_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF3_MSIX_CAP_TABLE_SIZE('H000),
    .VF3_MSI_CAP_MULTIMSGCAP(0),
    .VF3_PM_CAP_ID ('H1),
    .VF3_PM_CAP_NEXTPTR ('B00000000),
    .VF3_PM_CAP_VER_ID ('H3),
    .VF3_TPHR_CAP_DEV_SPECIFIC_MODE ("TRUE"),
    .VF3_TPHR_CAP_ENABLE ("FALSE"),
    .VF3_TPHR_CAP_INT_VEC_MODE ("TRUE"),
    .VF3_TPHR_CAP_NEXTPTR ('H000),
    .VF3_TPHR_CAP_ST_MODE_SEL ('H0),
    .VF3_TPHR_CAP_ST_TABLE_LOC ('H0),
    .VF3_TPHR_CAP_ST_TABLE_SIZE ('H0),
    .VF3_TPHR_CAP_VER ('H1),
    .VF4_ARI_CAP_NEXTPTR('H000),
    .VF4_MSIX_CAP_PBA_BIR(0),
    .VF4_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF4_MSIX_CAP_TABLE_BIR(0),
    .VF4_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF4_MSIX_CAP_TABLE_SIZE('H000),
    .VF4_MSI_CAP_MULTIMSGCAP(0),
    .VF4_PM_CAP_ID ('H1),
    .VF4_PM_CAP_NEXTPTR ('B00000000),
    .VF4_PM_CAP_VER_ID ('H3),
    .VF4_TPHR_CAP_DEV_SPECIFIC_MODE ("TRUE"),
    .VF4_TPHR_CAP_ENABLE ("FALSE"),
    .VF4_TPHR_CAP_INT_VEC_MODE ("TRUE"),
    .VF4_TPHR_CAP_NEXTPTR ('H000),
    .VF4_TPHR_CAP_ST_MODE_SEL ('H0),
    .VF4_TPHR_CAP_ST_TABLE_LOC ('H0),
    .VF4_TPHR_CAP_ST_TABLE_SIZE ('H0),
    .VF4_TPHR_CAP_VER ('H1),
    .VF5_ARI_CAP_NEXTPTR('H000),
    .VF5_MSIX_CAP_PBA_BIR(0),
    .VF5_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF5_MSIX_CAP_TABLE_BIR(0),
    .VF5_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF5_MSIX_CAP_TABLE_SIZE('H000),
    .VF5_MSI_CAP_MULTIMSGCAP(0),
    .VF5_PM_CAP_ID ('H1),
    .VF5_PM_CAP_NEXTPTR ('B00000000),
    .VF5_PM_CAP_VER_ID ('H3),
    .VF5_TPHR_CAP_DEV_SPECIFIC_MODE ("TRUE"),
    .VF5_TPHR_CAP_ENABLE ("FALSE"),
    .VF5_TPHR_CAP_INT_VEC_MODE ("TRUE"),
    .VF5_TPHR_CAP_NEXTPTR ('H000),
    .VF5_TPHR_CAP_ST_MODE_SEL ('H0),
    .VF5_TPHR_CAP_ST_TABLE_LOC ('H0),
    .VF5_TPHR_CAP_ST_TABLE_SIZE ('H0),
    .VF5_TPHR_CAP_VER ('H1),
    .LL_ACK_TIMEOUT ('H0),
    .LL_ACK_TIMEOUT_EN ("FALSE"),
    .LL_ACK_TIMEOUT_FUNC ('D0),
    .LL_CPL_FC_UPDATE_TIMER ('H0),
    .LL_CPL_FC_UPDATE_TIMER_OVERRIDE ( "FALSE"),
    .LL_FC_UPDATE_TIMER ('H0),
    .LL_FC_UPDATE_TIMER_OVERRIDE ("FALSE"),
    .LL_NP_FC_UPDATE_TIMER ('H0),
    .LL_NP_FC_UPDATE_TIMER_OVERRIDE ("FALSE" ),
    .LL_P_FC_UPDATE_TIMER ('H0),
    .LL_P_FC_UPDATE_TIMER_OVERRIDE ("FALSE"),
    .LL_REPLAY_TIMEOUT ('H0),
    .LL_REPLAY_TIMEOUT_EN ( "FALSE" ),
    .LL_REPLAY_TIMEOUT_FUNC ('D0),
    .LTR_TX_MESSAGE_MINIMUM_INTERVAL ('HFA),
    .LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE ("FALSE"),
    .LTR_TX_MESSAGE_ON_LTR_ENABLE ("FALSE"),
    .MCAP_CAP_NEXTPTR ('H0),
    .MCAP_CONFIGURE_OVERRIDE ("FALSE" ),
    .MCAP_ENABLE ( "FALSE" ),
    .MCAP_EOS_DESIGN_SWITCH ("FALSE"),
    .MCAP_FPGA_BITSTREAM_VERSION ('H0),
    .MCAP_GATE_IO_ENABLE_DESIGN_SWITCH ("FALSE"),
    .MCAP_GATE_MEM_ENABLE_DESIGN_SWITCH ("FALSE"),
    .MCAP_INPUT_GATE_DESIGN_SWITCH ("FALSE"),
    .MCAP_INTERRUPT_ON_MCAP_EOS ("FALSE"),
    .MCAP_INTERRUPT_ON_MCAP_ERROR ("FALSE"),
    .MCAP_VSEC_ID ('H0 ),
    .MCAP_VSEC_LEN ('H2C),
    .MCAP_VSEC_REV ('H0),
    .PL_LINK_CAP_MAX_LINK_SPEED(4),    
    .PL_LINK_CAP_MAX_LINK_WIDTH(8),
    .TCQ (100)
)  pcie3_uscale_core_top_inst (
    .pci_exp_txn (pci_exp_txn),
    .pci_exp_txp (pci_exp_txp),
    .pci_exp_rxn (pci_exp_rxn),
    .pci_exp_rxp (pci_exp_rxp),
    .user_clk (user_clk),
    .user_reset (user_reset),
    .user_lnk_up (user_lnk_up),
    .s_axis_rq_tdata (s_axis_rq_tdata),
    .s_axis_rq_tkeep (s_axis_rq_tkeep),
    .s_axis_rq_tlast (s_axis_rq_tlast),
    .s_axis_rq_tready (s_axis_rq_tready),
    .s_axis_rq_tuser (s_axis_rq_tuser),
    .s_axis_rq_tvalid (s_axis_rq_tvalid),
    .m_axis_rc_tdata (m_axis_rc_tdata),
    .m_axis_rc_tkeep (m_axis_rc_tkeep),
    .m_axis_rc_tlast (m_axis_rc_tlast),
    .m_axis_rc_tready (m_axis_rc_tready),
    .m_axis_rc_tuser (m_axis_rc_tuser),
    .m_axis_rc_tvalid (m_axis_rc_tvalid),
    .m_axis_cq_tdata (m_axis_cq_tdata),
    .m_axis_cq_tkeep (m_axis_cq_tkeep),
    .m_axis_cq_tlast (m_axis_cq_tlast),
    .m_axis_cq_tready (m_axis_cq_tready),
    .m_axis_cq_tuser (m_axis_cq_tuser),
    .m_axis_cq_tvalid (m_axis_cq_tvalid),
    .s_axis_cc_tdata (s_axis_cc_tdata),
    .s_axis_cc_tkeep (s_axis_cc_tkeep),
    .s_axis_cc_tlast (s_axis_cc_tlast),
    .s_axis_cc_tready (s_axis_cc_tready),
    .s_axis_cc_tuser (s_axis_cc_tuser),
    .s_axis_cc_tvalid (s_axis_cc_tvalid),
    .pcie_tfc_nph_av (pcie_tfc_nph_av),
    .pcie_tfc_npd_av (pcie_tfc_npd_av),
    .pcie_rq_seq_num (pcie_rq_seq_num),
    .pcie_rq_seq_num_vld (pcie_rq_seq_num_vld),
    .pcie_rq_tag (pcie_rq_tag),
    .pcie_rq_tag_av (pcie_rq_tag_av),
    .pcie_rq_tag_vld (pcie_rq_tag_vld),
    .pcie_cq_np_req (pcie_cq_np_req),
    .pcie_cq_np_req_count (pcie_cq_np_req_count),
    .cfg_phy_link_down (cfg_phy_link_down),
    .cfg_phy_link_status (cfg_phy_link_status),
    .cfg_negotiated_width (cfg_negotiated_width),
    .cfg_current_speed (cfg_current_speed),
    .cfg_max_payload (cfg_max_payload),
    .cfg_max_read_req (cfg_max_read_req),
    .cfg_function_status (cfg_function_status),
    .cfg_function_power_state (cfg_function_power_state),
    .cfg_vf_status (cfg_vf_status),
    .cfg_vf_power_state (cfg_vf_power_state),
    .cfg_link_power_state (cfg_link_power_state),
    .cfg_mgmt_addr (cfg_mgmt_addr),
    .cfg_mgmt_write (cfg_mgmt_write),
    .cfg_mgmt_write_data (cfg_mgmt_write_data),
    .cfg_mgmt_byte_enable (cfg_mgmt_byte_enable),
    .cfg_mgmt_read (cfg_mgmt_read),
    .cfg_mgmt_read_data (cfg_mgmt_read_data),
    .cfg_mgmt_read_write_done (cfg_mgmt_read_write_done),
    .cfg_mgmt_type1_cfg_reg_access (cfg_mgmt_type1_cfg_reg_access),
    .cfg_err_cor_out (cfg_err_cor_out),
    .cfg_err_nonfatal_out (cfg_err_nonfatal_out),
    .cfg_err_fatal_out (cfg_err_fatal_out),
    .cfg_local_error (cfg_local_error),
    .cfg_ltr_enable (cfg_ltr_enable),
    .cfg_ltssm_state (cfg_ltssm_state),
    .cfg_rcb_status (cfg_rcb_status),
    .cfg_dpa_substate_change (cfg_dpa_substate_change),
    .cfg_obff_enable (cfg_obff_enable),
    .cfg_pl_status_change (cfg_pl_status_change),
    .cfg_tph_requester_enable (cfg_tph_requester_enable),
    .cfg_tph_st_mode (cfg_tph_st_mode),
    .cfg_vf_tph_requester_enable (cfg_vf_tph_requester_enable),
    .cfg_vf_tph_st_mode (cfg_vf_tph_st_mode),
    .cfg_msg_received (cfg_msg_received),
    .cfg_msg_received_data (cfg_msg_received_data),
    .cfg_msg_received_type (cfg_msg_received_type),
    .cfg_msg_transmit (cfg_msg_transmit),
    .cfg_msg_transmit_type (cfg_msg_transmit_type),
    .cfg_msg_transmit_data (cfg_msg_transmit_data),
    .cfg_msg_transmit_done (cfg_msg_transmit_done),
    .cfg_fc_ph (cfg_fc_ph),
    .cfg_fc_pd (cfg_fc_pd),
    .cfg_fc_nph (cfg_fc_nph),
    .cfg_fc_npd (cfg_fc_npd),
    .cfg_fc_cplh (cfg_fc_cplh),
    .cfg_fc_cpld (cfg_fc_cpld),
    .cfg_fc_sel (cfg_fc_sel),
    .cfg_per_func_status_control (cfg_per_func_status_control),
    .cfg_per_func_status_data (cfg_per_func_status_data),
    .cfg_per_function_number (cfg_per_function_number),
    .cfg_per_function_output_request (cfg_per_function_output_request),
    .cfg_per_function_update_done (cfg_per_function_update_done),
    .cfg_dsn (cfg_dsn),
    .cfg_power_state_change_ack (cfg_power_state_change_ack),
    .cfg_power_state_change_interrupt (cfg_power_state_change_interrupt),
    .cfg_err_cor_in (cfg_err_cor_in),
    .cfg_err_uncor_in (cfg_err_uncor_in),
    .cfg_flr_in_process (cfg_flr_in_process),
    .cfg_flr_done (cfg_flr_done),
    .cfg_vf_flr_in_process (cfg_vf_flr_in_process),
    .cfg_vf_flr_done (cfg_vf_flr_done),
    .cfg_link_training_enable (cfg_link_training_enable),
    .cfg_ext_read_received (cfg_ext_read_received),
    .cfg_ext_write_received (cfg_ext_write_received),
    .cfg_ext_register_number (cfg_ext_register_number),
    .cfg_ext_function_number (cfg_ext_function_number),
    .cfg_ext_write_data (cfg_ext_write_data),
    .cfg_ext_write_byte_enable (cfg_ext_write_byte_enable),
    .cfg_ext_read_data (cfg_ext_read_data),
    .cfg_ext_read_data_valid (cfg_ext_read_data_valid),
    .cfg_interrupt_int (cfg_interrupt_int),
    .cfg_interrupt_pending (cfg_interrupt_pending),
    .cfg_interrupt_sent (cfg_interrupt_sent),
    .cfg_interrupt_msi_enable (cfg_interrupt_msi_enable),
    .cfg_interrupt_msi_vf_enable (cfg_interrupt_msi_vf_enable),
    .cfg_interrupt_msi_mmenable (cfg_interrupt_msi_mmenable),
    .cfg_interrupt_msi_mask_update (cfg_interrupt_msi_mask_update),
    .cfg_interrupt_msi_data (cfg_interrupt_msi_data),
    .cfg_interrupt_msi_select (cfg_interrupt_msi_select),
    .cfg_interrupt_msi_int (cfg_interrupt_msi_int),
    .cfg_interrupt_msi_pending_status (cfg_interrupt_msi_pending_status),
    .cfg_interrupt_msi_pending_status_data_enable (cfg_interrupt_msi_pending_status_data_enable),
    .cfg_interrupt_msi_pending_status_function_num (cfg_interrupt_msi_pending_status_function_num),
    .cfg_interrupt_msi_sent (cfg_interrupt_msi_sent),
    .cfg_interrupt_msi_fail (cfg_interrupt_msi_fail),
    .cfg_interrupt_msi_attr (cfg_interrupt_msi_attr),
    .cfg_interrupt_msi_tph_present (cfg_interrupt_msi_tph_present),
    .cfg_interrupt_msi_tph_type (cfg_interrupt_msi_tph_type),
    .cfg_interrupt_msi_tph_st_tag (cfg_interrupt_msi_tph_st_tag),
    .cfg_interrupt_msi_function_number (cfg_interrupt_msi_function_number),
    .cfg_interrupt_msix_enable ( ),
    .cfg_interrupt_msix_mask ( ),
    .cfg_interrupt_msix_vf_enable ( ),
    .cfg_interrupt_msix_vf_mask ( ),
    .cfg_interrupt_msix_sent ( ),
    .cfg_interrupt_msix_fail ( ),
    .cfg_interrupt_msix_int                         ( 1'b0  ),
    .cfg_interrupt_msix_address                     ( 64'b0 ),
    .cfg_interrupt_msix_data                        ( 32'b0 ),
    .cfg_hot_reset_out (cfg_hot_reset_out),
    .cfg_config_space_enable (cfg_config_space_enable),
    .cfg_req_pm_transition_l23_ready (cfg_req_pm_transition_l23_ready),
    .cfg_hot_reset_in (cfg_hot_reset_in),
    .cfg_ds_port_number (cfg_ds_port_number),
    .cfg_ds_bus_number (cfg_ds_bus_number),
    .cfg_ds_device_number (cfg_ds_device_number),
    .cfg_ds_function_number (cfg_ds_function_number),
    .cfg_vend_id (cfg_vend_id),
    .cfg_dev_id (cfg_dev_id),
    .cfg_rev_id (cfg_rev_id),
    .cfg_subsys_vend_id (cfg_subsys_vend_id),
    .cfg_subsys_id (cfg_subsys_id),
    .drp_rdy ( ),
    .drp_do ( ),
    .drp_clk (1'b0),
    .drp_en (1'b0),
    .drp_we (1'b0),
    .drp_addr (10'b0),
    .drp_di (16'b0),
    .user_tph_stt_address ( 5'b0),
    .user_tph_function_num ( 4'b0),
    .user_tph_stt_read_data ( ),
    .user_tph_stt_read_data_valid ( ),
    .user_tph_stt_read_enable ( 1'b0),
    .sys_clk (sys_clk),
    .sys_clk_gt (sys_clk_gt),
    .sys_reset (sys_reset),
   .common_commands_in (common_commands_in ),
   .pipe_rx_0_sigs     (pipe_rx_0_sigs     ),
   .pipe_rx_1_sigs     (pipe_rx_1_sigs     ),
   .pipe_rx_2_sigs     (pipe_rx_2_sigs     ),
   .pipe_rx_3_sigs     (pipe_rx_3_sigs     ),
   .pipe_rx_4_sigs     (pipe_rx_4_sigs     ),
   .pipe_rx_5_sigs     (pipe_rx_5_sigs     ),
   .pipe_rx_6_sigs     (pipe_rx_6_sigs     ),
   .pipe_rx_7_sigs     (pipe_rx_7_sigs     ),
                                           
   .common_commands_out(common_commands_out),
   .pipe_tx_0_sigs     (pipe_tx_0_sigs     ),
   .pipe_tx_1_sigs     (pipe_tx_1_sigs     ),
   .pipe_tx_2_sigs     (pipe_tx_2_sigs     ),
   .pipe_tx_3_sigs     (pipe_tx_3_sigs     ),
   .pipe_tx_4_sigs     (pipe_tx_4_sigs     ),
   .pipe_tx_5_sigs     (pipe_tx_5_sigs     ),
   .pipe_tx_6_sigs     (pipe_tx_6_sigs     ),
   .pipe_tx_7_sigs     (pipe_tx_7_sigs     ),
  //---------- Shared Logic Internal -------------------------
   .int_qpll1lock_out      (),   
   .int_qpll1outrefclk_out (),
   .int_qpll1outclk_out    (), 
    //---------- External GT COMMON Ports ----------------------
   .ext_qpll1refclk        (),
   .ext_qpll1pd            (),
   .ext_qpll1rate          (), 
   .ext_qpll1reset         (),

   .ext_qpll1lock_out      (2'b0),
   .ext_qpll1outclk_out    (2'b0),
   .ext_qpll1outrefclk_out (2'b0),
    //--------------------------------------------------------------------------
    //  Transceiver Debug And Status Ports
    //--------------------------------------------------------------------------
    .gt_pcieuserratedone ({8{1'd0}}),
    .gt_loopback         ({8{3'd0}}),             
    .gt_txprbsforceerr   ({8{1'd0}}),            
    .gt_txprbssel        ({8{4'd0}}),            
    .gt_rxprbssel        ({8{4'd0}}),          
    .gt_rxprbscntreset   ({8{1'd0}}),             
    .gt_rxcdrlock        (),         
    .gt_pcierateidle     (),
    .gt_pcieuserratestart(),
    .gt_gtpowergood      (),  
    .gt_rxoutclk         (), 
    .gt_rxrecclkout      (), 
    .gt_txresetdone      (),    
    .gt_rxpmaresetdone   (),      
    .gt_rxresetdone      (),        
    .gt_rxbufstatus      (),            
    .gt_txphaligndone    (),            
    .gt_txphinitdone     (),         
    .gt_txdlysresetdone  (),         
    .gt_rxphaligndone    (),        
    .gt_rxdlysresetdone  (),          
    .gt_rxsyncdone       (),        
    .gt_cplllock         (),              
    .gt_qpll1lock        (),            
    .gt_eyescandataerror (),               
    .gt_rxprbserr        (),           
    .gt_dmonitorout      (),           
    .gt_rxcommadet       (),                   
    .gt_rxstatus         (),            
    .gt_txelecidle       (),             
    .gt_phystatus        (),                   
    .gt_rxvalid          (),              
    .gt_bufgtdiv         (),                 
    .phy_rrst_n          (),
    .phy_prst_n          (),
    .phy_txeq_ctrl       (),                  
    .phy_txeq_preset     (),                   
    .phy_rst_fsm         (),                 
    .phy_txeq_fsm        (),                  
    .phy_rxeq_fsm        (),                 
    .phy_rst_idle        (),                              

    .conf_req_type ( 2'b0 ),
    .conf_req_reg_num (4'b0 ),
    .conf_req_data ( 32'b0 ),
    .conf_req_valid ( 1'b0 ),
    .conf_req_ready ( ),
    .conf_resp_rdata ( ),
    .conf_resp_valid ( ),
 //   .conf_mcap_design_switch ( ),
 //   .conf_mcap_eos ( ),
 //   .conf_mcap_in_use_by_pcie ( ),
 //   .conf_mcap_request_by_conf ( 1'b0 ),
    .pl_eq_reset_eieos_count ( 1'b0 ),
    .pl_gen2_upstream_prefer_deemph ( 1'b0 ),
    .pl_eq_in_progress ( ),
    .pl_eq_phase ( ),
    .pcie_perstn0_out (pcie_perstn0_out),
    .pcie_perstn1_in  (pcie_perstn1_in),
    .pcie_perstn1_out (pcie_perstn1_out)
  );

endmodule
