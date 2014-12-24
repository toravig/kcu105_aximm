
################################################################
# This is a generated script based on design: trd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
#set scripts_vivado_version 2014.3
#set current_vivado_version [version -short]
#
#if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
#   puts ""
#   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."
#
#   return 1
#}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source trd_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xcku040-ffva1156-2-e


# CHANGE DESIGN NAME HERE
set design_name trd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: SLICER
proc create_hier_cell_SLICER { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_SLICER() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 63 -to 0 Din
  create_bd_pin -dir O -from 0 -to 0 Dout
  create_bd_pin -dir O -from 0 -to 0 Dout1
  create_bd_pin -dir I aclk
  create_bd_pin -dir I areset_n
  create_bd_pin -dir I din1
  create_bd_pin -dir O -from 0 -to 0 dout2

  # Create instance: synchronizer_0, and set properties
  set synchronizer_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:synchronizer:1.0 synchronizer_0 ]

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_TO {1} CONFIG.DIN_WIDTH {64}  ] $xlslice_0

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list CONFIG.DIN_FROM {32} CONFIG.DIN_TO {32} CONFIG.DIN_WIDTH {64}  ] $xlslice_1

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_pins aclk] [get_bd_pins synchronizer_0/aclk]
  connect_bd_net -net areset_n_1 [get_bd_pins areset_n] [get_bd_pins synchronizer_0/areset_n]
  connect_bd_net -net axi_vdma_0_axi_vdma_tstvec [get_bd_pins Din] [get_bd_pins xlslice_0/Din] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net din1_1 [get_bd_pins din1] [get_bd_pins synchronizer_0/din]
  connect_bd_net -net synchronizer_0_dout [get_bd_pins dout2] [get_bd_pins synchronizer_0/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins Dout] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins Dout1] [get_bd_pins xlslice_1/Dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: INTR_TRANSLATION_LOGIC
proc create_hier_cell_INTR_TRANSLATION_LOGIC { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_INTR_TRANSLATION_LOGIC() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir I -type rst ARESETN
  create_bd_pin -dir I -type clk M00_ACLK
  create_bd_pin -dir I -from 0 -to 0 -type rst M00_ARESETN
  create_bd_pin -dir O fsync_out
  create_bd_pin -dir I -from 0 -to 0 interrupt_in
  create_bd_pin -dir I -from 0 -to 0 mm2s_all_lines_xfred
  create_bd_pin -dir I -from 0 -to 0 s2mm_all_lines_xfred
  create_bd_pin -dir I -from 31 -to 0 scratchpad_reg
  create_bd_pin -dir I -from 31 -to 0 scratchpad_val

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list CONFIG.M00_HAS_REGSLICE {4} CONFIG.M01_HAS_REGSLICE {3} CONFIG.NUM_MI {1} CONFIG.NUM_SI {2} CONFIG.S00_HAS_DATA_FIFO {0} CONFIG.S00_HAS_REGSLICE {4} CONFIG.S01_HAS_DATA_FIFO {0} CONFIG.S01_HAS_REGSLICE {4} CONFIG.STRATEGY {0}  ] $axi_interconnect_0

  # Create instance: frame_sync_logic_0, and set properties
  set frame_sync_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:frame_sync_logic:1.0 frame_sync_logic_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net frame_sync_logic_0_m1 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins frame_sync_logic_0/m1]
  connect_bd_intf_net -intf_net frame_sync_logic_0_m2 [get_bd_intf_pins axi_interconnect_0/S01_AXI] [get_bd_intf_pins frame_sync_logic_0/m2]

  # Create port connections
  connect_bd_net -net frame_sync_logic_0_fsync_out [get_bd_pins fsync_out] [get_bd_pins frame_sync_logic_0/fsync_out]
  connect_bd_net -net mig_0_addn_ui_clkout1 [get_bd_pins ACLK] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins frame_sync_logic_0/m_clk]
  connect_bd_net -net mig_0_c0_init_calib_complete [get_bd_pins ARESETN] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins frame_sync_logic_0/m_resetn]
  connect_bd_net -net pcie3_ultrascale_0_user_clk [get_bd_pins M00_ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK]
  connect_bd_net -net pcie_dma_wrapper_x8g3_0_user_lnk_up [get_bd_pins M00_ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN]
  connect_bd_net -net synchronizer_0_dout [get_bd_pins interrupt_in] [get_bd_pins frame_sync_logic_0/interrupt_in]
  connect_bd_net -net user_axilite_control_0_spad_reg [get_bd_pins scratchpad_reg] [get_bd_pins frame_sync_logic_0/scratchpad_reg]
  connect_bd_net -net user_axilite_control_0_spad_val [get_bd_pins scratchpad_val] [get_bd_pins frame_sync_logic_0/scratchpad_val]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins mm2s_all_lines_xfred] [get_bd_pins frame_sync_logic_0/mm2s_all_lines_xfred]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins s2mm_all_lines_xfred] [get_bd_pins frame_sync_logic_0/s2mm_all_lines_xfred]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: VIDEO_PATH
proc create_hier_cell_VIDEO_PATH { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_VIDEO_PATH() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_MM2S
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_S2MM
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CONTROL_BUS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE

  # Create pins
  create_bd_pin -dir I -type clk M00_ACLK
  create_bd_pin -dir I -from 0 -to 0 -type rst M00_ARESETN
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I din1
  create_bd_pin -dir I -type clk m_axi_mm2s_aclk
  create_bd_pin -dir I -from 31 -to 0 scratchpad_reg
  create_bd_pin -dir I -from 31 -to 0 scratchpad_val

  # Create instance: INTR_TRANSLATION_LOGIC
  create_hier_cell_INTR_TRANSLATION_LOGIC $hier_obj INTR_TRANSLATION_LOGIC

  # Create instance: SLICER
  create_hier_cell_SLICER $hier_obj SLICER

  # Create instance: axi_vdma_0, and set properties
  set axi_vdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 axi_vdma_0 ]
  set_property -dict [ list CONFIG.c_enable_debug_info_1 {0} CONFIG.c_enable_debug_info_4 {1} CONFIG.c_enable_debug_info_6 {0} CONFIG.c_enable_debug_info_7 {0} CONFIG.c_enable_debug_info_9 {0} CONFIG.c_enable_debug_info_14 {0} CONFIG.c_enable_debug_info_15 {0} CONFIG.c_include_mm2s_dre {1} CONFIG.c_include_s2mm_dre {1} CONFIG.c_m_axi_s2mm_data_width {64} CONFIG.c_mm2s_linebuffer_depth {4096} CONFIG.c_mm2s_max_burst_length {64} CONFIG.c_s2mm_linebuffer_depth {4096} CONFIG.c_s2mm_max_burst_length {64} CONFIG.c_use_mm2s_fsync {1}  ] $axi_vdma_0

  # Create instance: sobel_filter_0, and set properties
  set sobel_filter_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:sobel_filter:1.0 sobel_filter_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M00_AXI] [get_bd_intf_pins INTR_TRANSLATION_LOGIC/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_3_M03_AXI [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins axi_vdma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_interconnect_3_M04_AXI [get_bd_intf_pins S_AXI_CONTROL_BUS] [get_bd_intf_pins sobel_filter_0/S_AXI_CONTROL_BUS]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXIS_MM2S [get_bd_intf_pins axi_vdma_0/M_AXIS_MM2S] [get_bd_intf_pins sobel_filter_0/INPUT_STREAM]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_MM2S [get_bd_intf_pins M_AXI_MM2S] [get_bd_intf_pins axi_vdma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_S2MM [get_bd_intf_pins M_AXI_S2MM] [get_bd_intf_pins axi_vdma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net sobel_filter_0_OUTPUT_STREAM [get_bd_intf_pins axi_vdma_0/S_AXIS_S2MM] [get_bd_intf_pins sobel_filter_0/OUTPUT_STREAM]

  # Create port connections
  connect_bd_net -net INTR_TRANSLATION_LOGIC_fsync_out [get_bd_pins INTR_TRANSLATION_LOGIC/fsync_out] [get_bd_pins axi_vdma_0/mm2s_fsync]
  connect_bd_net -net M00_ACLK_1 [get_bd_pins M00_ACLK] [get_bd_pins INTR_TRANSLATION_LOGIC/M00_ACLK]
  connect_bd_net -net M00_ARESETN_1 [get_bd_pins M00_ARESETN] [get_bd_pins INTR_TRANSLATION_LOGIC/M00_ARESETN]
  connect_bd_net -net SLICER_Dout [get_bd_pins INTR_TRANSLATION_LOGIC/mm2s_all_lines_xfred] [get_bd_pins SLICER/Dout]
  connect_bd_net -net SLICER_Dout1 [get_bd_pins INTR_TRANSLATION_LOGIC/s2mm_all_lines_xfred] [get_bd_pins SLICER/Dout1]
  connect_bd_net -net SLICER_dout2 [get_bd_pins INTR_TRANSLATION_LOGIC/interrupt_in] [get_bd_pins SLICER/dout2]
  connect_bd_net -net axi_vdma_0_axi_vdma_tstvec [get_bd_pins SLICER/Din] [get_bd_pins axi_vdma_0/axi_vdma_tstvec]
  connect_bd_net -net din1_1 [get_bd_pins din1] [get_bd_pins SLICER/din1]
  connect_bd_net -net mig_0_addn_ui_clkout1 [get_bd_pins m_axi_mm2s_aclk] [get_bd_pins INTR_TRANSLATION_LOGIC/ACLK] [get_bd_pins SLICER/aclk] [get_bd_pins axi_vdma_0/m_axi_mm2s_aclk] [get_bd_pins axi_vdma_0/m_axi_s2mm_aclk] [get_bd_pins axi_vdma_0/m_axis_mm2s_aclk] [get_bd_pins axi_vdma_0/s_axi_lite_aclk] [get_bd_pins axi_vdma_0/s_axis_s2mm_aclk] [get_bd_pins sobel_filter_0/aclk]
  connect_bd_net -net mig_0_c0_init_calib_complete [get_bd_pins aresetn] [get_bd_pins INTR_TRANSLATION_LOGIC/ARESETN] [get_bd_pins SLICER/areset_n] [get_bd_pins axi_vdma_0/axi_resetn] [get_bd_pins sobel_filter_0/aresetn]
  connect_bd_net -net scratchpad_reg_1 [get_bd_pins scratchpad_reg] [get_bd_pins INTR_TRANSLATION_LOGIC/scratchpad_reg]
  connect_bd_net -net scratchpad_val_1 [get_bd_pins scratchpad_val] [get_bd_pins INTR_TRANSLATION_LOGIC/scratchpad_val]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: AXI_IC_BLOCKS
proc create_hier_cell_AXI_IC_BLOCKS { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_AXI_IC_BLOCKS() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI1
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M04_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S01_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S02_AXI

  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir I -from 0 -to 0 -type rst ARESETN
  create_bd_pin -dir I -type clk M00_ACLK
  create_bd_pin -dir I -type rst M00_ARESETN
  create_bd_pin -dir I -type clk S01_ACLK

  # Create instance: axi_Lite_IC, and set properties
  set axi_Lite_IC [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_Lite_IC ]
  set_property -dict [ list CONFIG.NUM_MI {5}  ] $axi_Lite_IC

  # Create instance: axi_ic_ExpDMA, and set properties
  set axi_ic_ExpDMA [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_ExpDMA ]
  set_property -dict [ list CONFIG.M00_HAS_REGSLICE {4} CONFIG.M01_HAS_REGSLICE {3} CONFIG.S00_HAS_REGSLICE {4} CONFIG.STRATEGY {2}  ] $axi_ic_ExpDMA

  # Create instance: axi_ic_mig, and set properties
  set axi_ic_mig [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_mig ]
  set_property -dict [ list CONFIG.M00_HAS_REGSLICE {4} CONFIG.NUM_MI {1} CONFIG.NUM_SI {3} CONFIG.S00_HAS_REGSLICE {4} CONFIG.S01_HAS_REGSLICE {4} CONFIG.S02_HAS_REGSLICE {4} CONFIG.STRATEGY {2}  ] $axi_ic_mig

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_ic_ExpDMA/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins axi_Lite_IC/S00_AXI] [get_bd_intf_pins axi_ic_ExpDMA/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins axi_Lite_IC/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins axi_Lite_IC/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins M02_AXI] [get_bd_intf_pins axi_Lite_IC/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins M03_AXI] [get_bd_intf_pins axi_Lite_IC/M03_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M04_AXI [get_bd_intf_pins M04_AXI] [get_bd_intf_pins axi_Lite_IC/M04_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_ic_ExpDMA/M00_AXI] [get_bd_intf_pins axi_ic_mig/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_2_M00_AXI [get_bd_intf_pins M00_AXI1] [get_bd_intf_pins axi_ic_mig/M00_AXI]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_MM2S [get_bd_intf_pins S01_AXI] [get_bd_intf_pins axi_ic_mig/S01_AXI]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_S2MM [get_bd_intf_pins S02_AXI] [get_bd_intf_pins axi_ic_mig/S02_AXI]

  # Create port connections
  connect_bd_net -net mig_0_addn_ui_clkout1 [get_bd_pins S01_ACLK] [get_bd_pins axi_Lite_IC/M03_ACLK] [get_bd_pins axi_Lite_IC/M04_ACLK] [get_bd_pins axi_ic_mig/S01_ACLK] [get_bd_pins axi_ic_mig/S02_ACLK]
  connect_bd_net -net mig_0_c0_ddr4_ui_clk [get_bd_pins M00_ACLK] [get_bd_pins axi_ic_mig/M00_ACLK]
  connect_bd_net -net mig_0_c0_init_calib_complete [get_bd_pins M00_ARESETN] [get_bd_pins axi_Lite_IC/M03_ARESETN] [get_bd_pins axi_Lite_IC/M04_ARESETN] [get_bd_pins axi_ic_mig/M00_ARESETN] [get_bd_pins axi_ic_mig/S01_ARESETN] [get_bd_pins axi_ic_mig/S02_ARESETN]
  connect_bd_net -net pcie3_ultrascale_0_user_clk [get_bd_pins ACLK] [get_bd_pins axi_Lite_IC/ACLK] [get_bd_pins axi_Lite_IC/M00_ACLK] [get_bd_pins axi_Lite_IC/M01_ACLK] [get_bd_pins axi_Lite_IC/M02_ACLK] [get_bd_pins axi_Lite_IC/S00_ACLK] [get_bd_pins axi_ic_ExpDMA/ACLK] [get_bd_pins axi_ic_ExpDMA/M00_ACLK] [get_bd_pins axi_ic_ExpDMA/M01_ACLK] [get_bd_pins axi_ic_ExpDMA/S00_ACLK] [get_bd_pins axi_ic_mig/ACLK] [get_bd_pins axi_ic_mig/S00_ACLK]
  connect_bd_net -net pcie_dma_wrapper_x8g3_0_user_lnk_up [get_bd_pins ARESETN] [get_bd_pins axi_Lite_IC/ARESETN] [get_bd_pins axi_Lite_IC/M00_ARESETN] [get_bd_pins axi_Lite_IC/M01_ARESETN] [get_bd_pins axi_Lite_IC/M02_ARESETN] [get_bd_pins axi_Lite_IC/S00_ARESETN] [get_bd_pins axi_ic_ExpDMA/ARESETN] [get_bd_pins axi_ic_ExpDMA/M00_ARESETN] [get_bd_pins axi_ic_ExpDMA/M01_ARESETN] [get_bd_pins axi_ic_ExpDMA/S00_ARESETN] [get_bd_pins axi_ic_mig/ARESETN] [get_bd_pins axi_ic_mig/S00_ARESETN]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set C0_DDR4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 C0_DDR4 ]
  set C0_SYS_CLK [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C0_SYS_CLK ]
  set pcie3_ext_pipe_interface [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_pcie3_ultrascale:ext_pipe_rtl:1.0 pcie3_ext_pipe_interface ]
  set pcie_7x_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt ]

  # Create ports
  set c0_init_calib_complete [ create_bd_port -dir O c0_init_calib_complete ]
  set cfg_current_speed [ create_bd_port -dir O -from 2 -to 0 cfg_current_speed ]
  set cfg_negotiated_width [ create_bd_port -dir O -from 3 -to 0 cfg_negotiated_width ]
  set clk125_in [ create_bd_port -dir I clk125_in ]
  set muxaddr_out [ create_bd_port -dir O -from 2 -to 0 muxaddr_out ]
  set pmbus_alert [ create_bd_port -dir I pmbus_alert ]
  set pmbus_clk [ create_bd_port -dir IO pmbus_clk ]
  set pmbus_control [ create_bd_port -dir O pmbus_control ]
  set pmbus_data [ create_bd_port -dir IO pmbus_data ]
  set sys_clk [ create_bd_port -dir I -type clk sys_clk ]
  set sys_clk_gt [ create_bd_port -dir I -type clk sys_clk_gt ]
  set sys_reset [ create_bd_port -dir I -type rst sys_reset ]
  set_property -dict [ list CONFIG.POLARITY {ACTIVE_LOW}  ] $sys_reset
  set sys_rst [ create_bd_port -dir I -type rst sys_rst ]
  set user_clk [ create_bd_port -dir O -type clk user_clk ]
  set user_lnk_up [ create_bd_port -dir O user_lnk_up ]
  set vauxn0 [ create_bd_port -dir I vauxn0 ]
  set vauxn2 [ create_bd_port -dir I vauxn2 ]
  set vauxn8 [ create_bd_port -dir I vauxn8 ]
  set vauxp0 [ create_bd_port -dir I vauxp0 ]
  set vauxp2 [ create_bd_port -dir I vauxp2 ]
  set vauxp8 [ create_bd_port -dir I vauxp8 ]

  # Create instance: AXI_IC_BLOCKS
  create_hier_cell_AXI_IC_BLOCKS [current_bd_instance .] AXI_IC_BLOCKS

  # Create instance: VIDEO_PATH
  create_hier_cell_VIDEO_PATH [current_bd_instance .] VIDEO_PATH

  # Create instance: axi_perf_mon_0, and set properties
  set axi_perf_mon_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_perf_mon:5.0 axi_perf_mon_0 ]
  set_property -dict [ list CONFIG.C_METRIC_COUNT_SCALE {2} CONFIG.C_NUM_MONITOR_SLOTS {2} CONFIG.C_NUM_OF_COUNTERS {4} CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI3}  ] $axi_perf_mon_0

  # Create instance: mig_0, and set properties
  set mig_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig:6.1 mig_0 ]
  set_property -dict [ list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {200} CONFIG.C0.ControllerType {DDR4_SDRAM} CONFIG.C0.DDR4_AxiDataWidth {512} CONFIG.C0.DDR4_AxiNarrowBurst {false} CONFIG.C0.DDR4_CasWriteLatency {12} CONFIG.C0.DDR4_DataWidth {64} CONFIG.C0.DDR4_InputClockPeriod {3332} CONFIG.C0.DDR4_Mem_Add_Map {ROW_COLUMN_BANK} CONFIG.C0.DDR4_MemoryPart {EDY4016AABG-DR-F} CONFIG.C0.DDR4_TimePeriod {833} CONFIG.c0_act_n {bank45.byte2.pin12} CONFIG.c0_adr_0 {bank45.byte3.pin8} CONFIG.c0_adr_1 {bank45.byte2.pin1} CONFIG.c0_adr_2 {bank45.byte3.pin4} CONFIG.c0_adr_3 {bank45.byte2.pin6} CONFIG.c0_adr_4 {bank45.byte2.pin5} CONFIG.c0_adr_5 {bank45.byte1.pin7} CONFIG.c0_adr_6 {bank45.byte1.pin9} CONFIG.c0_adr_7 {bank45.byte2.pin4} CONFIG.c0_adr_8 {bank45.byte3.pin5} CONFIG.c0_adr_9 {bank45.byte2.pin9} CONFIG.c0_adr_10 {bank45.byte3.pin2} CONFIG.c0_adr_11 {bank45.byte3.pin0} CONFIG.c0_adr_12 {bank45.byte2.pin7} CONFIG.c0_adr_13 {bank45.byte2.pin8} CONFIG.c0_adr_14 {bank45.byte3.pin10} CONFIG.c0_adr_15 {bank45.byte2.pin11} CONFIG.c0_adr_16 {bank45.byte3.pin3} CONFIG.c0_ba_0 {bank45.byte3.pin9} CONFIG.c0_ba_1 {bank45.byte1.pin5} CONFIG.c0_bg_0 {bank45.byte2.pin10} CONFIG.c0_ck_c_0 {bank45.byte3.pin7} CONFIG.c0_ck_t_0 {bank45.byte3.pin6} CONFIG.c0_cke_0 {bank45.byte3.pin11} CONFIG.c0_cs_n_0 {bank45.byte1.pin2} CONFIG.c0_data_compare_error {Unassigned} CONFIG.c0_dm_dbi_n_0 {bank44.byte0.pin0} CONFIG.c0_dm_dbi_n_1 {bank44.byte1.pin0} CONFIG.c0_dm_dbi_n_2 {bank44.byte2.pin0} CONFIG.c0_dm_dbi_n_3 {bank44.byte3.pin0} CONFIG.c0_dm_dbi_n_4 {bank46.byte0.pin0} CONFIG.c0_dm_dbi_n_5 {bank46.byte1.pin0} CONFIG.c0_dm_dbi_n_6 {bank46.byte2.pin0} CONFIG.c0_dm_dbi_n_7 {bank46.byte3.pin0} CONFIG.c0_dq_0 {bank44.byte0.pin9} CONFIG.c0_dq_1 {bank44.byte0.pin3} CONFIG.c0_dq_2 {bank44.byte0.pin10} CONFIG.c0_dq_3 {bank44.byte0.pin2} CONFIG.c0_dq_4 {bank44.byte0.pin8} CONFIG.c0_dq_5 {bank44.byte0.pin4} CONFIG.c0_dq_6 {bank44.byte0.pin11} CONFIG.c0_dq_7 {bank44.byte0.pin5} CONFIG.c0_dq_8 {bank44.byte1.pin9} CONFIG.c0_dq_9 {bank44.byte1.pin4} CONFIG.c0_dq_10 {bank44.byte1.pin8} CONFIG.c0_dq_11 {bank44.byte1.pin2} CONFIG.c0_dq_12 {bank44.byte1.pin11} CONFIG.c0_dq_13 {bank44.byte1.pin3} CONFIG.c0_dq_14 {bank44.byte1.pin10} CONFIG.c0_dq_15 {bank44.byte1.pin5} CONFIG.c0_dq_16 {bank44.byte2.pin8} CONFIG.c0_dq_17 {bank44.byte2.pin11} CONFIG.c0_dq_18 {bank44.byte2.pin5} CONFIG.c0_dq_19 {bank44.byte2.pin3} CONFIG.c0_dq_20 {bank44.byte2.pin2} CONFIG.c0_dq_21 {bank44.byte2.pin10} CONFIG.c0_dq_22 {bank44.byte2.pin4} CONFIG.c0_dq_23 {bank44.byte2.pin9} CONFIG.c0_dq_24 {bank44.byte3.pin4} CONFIG.c0_dq_25 {bank44.byte3.pin10} CONFIG.c0_dq_26 {bank44.byte3.pin5} CONFIG.c0_dq_27 {bank44.byte3.pin11} CONFIG.c0_dq_28 {bank44.byte3.pin9} CONFIG.c0_dq_29 {bank44.byte3.pin3} CONFIG.c0_dq_30 {bank44.byte3.pin8} CONFIG.c0_dq_31 {bank44.byte3.pin2} CONFIG.c0_dq_32 {bank46.byte0.pin9} CONFIG.c0_dq_33 {bank46.byte0.pin4} CONFIG.c0_dq_34 {bank46.byte0.pin11} CONFIG.c0_dq_35 {bank46.byte0.pin3} CONFIG.c0_dq_36 {bank46.byte0.pin10} CONFIG.c0_dq_37 {bank46.byte0.pin8} CONFIG.c0_dq_38 {bank46.byte0.pin5} CONFIG.c0_dq_39 {bank46.byte0.pin2} CONFIG.c0_dq_40 {bank46.byte1.pin10} CONFIG.c0_dq_41 {bank46.byte1.pin3} CONFIG.c0_dq_42 {bank46.byte1.pin11} CONFIG.c0_dq_43 {bank46.byte1.pin5} CONFIG.c0_dq_44 {bank46.byte1.pin8} CONFIG.c0_dq_45 {bank46.byte1.pin2} CONFIG.c0_dq_46 {bank46.byte1.pin9} CONFIG.c0_dq_47 {bank46.byte1.pin4} CONFIG.c0_dq_48 {bank46.byte2.pin8} CONFIG.c0_dq_49 {bank46.byte2.pin9} CONFIG.c0_dq_50 {bank46.byte2.pin11} CONFIG.c0_dq_51 {bank46.byte2.pin2} CONFIG.c0_dq_52 {bank46.byte2.pin5} CONFIG.c0_dq_53 {bank46.byte2.pin4} CONFIG.c0_dq_54 {bank46.byte2.pin10} CONFIG.c0_dq_55 {bank46.byte2.pin3} CONFIG.c0_dq_56 {bank46.byte3.pin2} CONFIG.c0_dq_57 {bank46.byte3.pin3} CONFIG.c0_dq_58 {bank46.byte3.pin11} CONFIG.c0_dq_59 {bank46.byte3.pin5} CONFIG.c0_dq_60 {bank46.byte3.pin8} CONFIG.c0_dq_61 {bank46.byte3.pin4} CONFIG.c0_dq_62 {bank46.byte3.pin10} CONFIG.c0_dq_63 {bank46.byte3.pin9} CONFIG.c0_dqs_c_0 {bank44.byte0.pin7} CONFIG.c0_dqs_c_1 {bank44.byte1.pin7} CONFIG.c0_dqs_c_2 {bank44.byte2.pin7} CONFIG.c0_dqs_c_3 {bank44.byte3.pin7} CONFIG.c0_dqs_c_4 {bank46.byte0.pin7} CONFIG.c0_dqs_c_5 {bank46.byte1.pin7} CONFIG.c0_dqs_c_6 {bank46.byte2.pin7} CONFIG.c0_dqs_c_7 {bank46.byte3.pin7} CONFIG.c0_dqs_t_0 {bank44.byte0.pin6} CONFIG.c0_dqs_t_1 {bank44.byte1.pin6} CONFIG.c0_dqs_t_2 {bank44.byte2.pin6} CONFIG.c0_dqs_t_3 {bank44.byte3.pin6} CONFIG.c0_dqs_t_4 {bank46.byte0.pin6} CONFIG.c0_dqs_t_5 {bank46.byte1.pin6} CONFIG.c0_dqs_t_6 {bank46.byte2.pin6} CONFIG.c0_dqs_t_7 {bank46.byte3.pin6} CONFIG.c0_init_calib_complete {Unassigned} CONFIG.c0_odt_0 {bank45.byte1.pin8} CONFIG.c0_reset_n {bank45.byte1.pin6} CONFIG.c0_sys_clk_n {bank45.byte1.pin11} CONFIG.c0_sys_clk_p {bank45.byte1.pin10} CONFIG.sys_rst {Unassigned}  ] $mig_0

  # Create instance: nwl_dma_x8g3_wrapper_0, and set properties
  set nwl_dma_x8g3_wrapper_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:nwl_dma_x8g3_wrapper:1.0 nwl_dma_x8g3_wrapper_0 ]
  set_property -dict [ list CONFIG.USE_AXI_SLAVE {true}  ] $nwl_dma_x8g3_wrapper_0

  # Create instance: pcie3_ultrascale_0, and set properties
  set pcie3_ultrascale_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie3_ultrascale:3.1 pcie3_ultrascale_0 ]
  set_property -dict [ list CONFIG.AXISTEN_IF_RC_STRADDLE {false} CONFIG.PF0_DEVICE_ID {8083} CONFIG.PF0_MSIX_CAP_PBA_OFFSET {00003000} CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {00002000} CONFIG.PF0_MSIX_CAP_TABLE_SIZE {003} CONFIG.PF0_Use_Class_Code_Lookup_Assistant {true} CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} CONFIG.cfg_ext_if {false} CONFIG.cfg_tx_msg_if {false} CONFIG.dedicate_perst {false} CONFIG.mode_selection {Advanced} CONFIG.per_func_status_if {false} CONFIG.pf0_bar0_64bit {true} CONFIG.pf0_bar0_scale {Megabytes} CONFIG.pf0_bar0_size {1} CONFIG.pf0_bar2_64bit {true} CONFIG.pf0_bar2_enabled {true} CONFIG.pf0_bar2_scale {Megabytes} CONFIG.pf0_bar2_size {1} CONFIG.pf0_bar4_64bit {true} CONFIG.pf0_bar4_enabled {true} CONFIG.pf0_bar4_scale {Megabytes} CONFIG.pf0_bar4_size {1} CONFIG.pf0_base_class_menu {Memory_controller} CONFIG.pf0_class_code_base {05} CONFIG.pf0_class_code_sub {80} CONFIG.pf0_msix_enabled {true} CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} CONFIG.pipe_sim {true} CONFIG.rcv_msg_if {false} CONFIG.tx_fc_if {false} CONFIG.xlnx_ref_board {KCU105}  ] $pcie3_ultrascale_0

  # Create instance: pcie_monitor_gen3_0, and set properties
  set pcie_monitor_gen3_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:pcie_monitor_gen3:1.0 pcie_monitor_gen3_0 ]

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
  set_property -dict [ list CONFIG.C_AUX_RST_WIDTH {1} CONFIG.C_EXT_RST_WIDTH {1}  ] $proc_sys_reset_0

  # Create instance: pvtmon_axi_slave_0, and set properties
  set pvtmon_axi_slave_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:pvtmon_axi_slave:1.0 pvtmon_axi_slave_0 ]

  # Create instance: user_axilite_control_0, and set properties
  set user_axilite_control_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:user_axilite_control:1.0 user_axilite_control_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net C0_SYS_CLK_1 [get_bd_intf_ports C0_SYS_CLK] [get_bd_intf_pins mig_0/C0_SYS_CLK]
  connect_bd_intf_net -intf_net VIDEO_PATH_M00_AXI [get_bd_intf_pins VIDEO_PATH/M00_AXI] [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/s]
  connect_bd_intf_net -intf_net axi_interconnect_2_M00_AXI [get_bd_intf_pins AXI_IC_BLOCKS/M00_AXI1] [get_bd_intf_pins mig_0/C0_DDR4_S_AXI]
connect_bd_intf_net -intf_net axi_interconnect_2_M00_AXI [get_bd_intf_pins axi_perf_mon_0/SLOT_1_AXI] [get_bd_intf_pins mig_0/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_3_M00_AXI [get_bd_intf_pins AXI_IC_BLOCKS/M00_AXI] [get_bd_intf_pins user_axilite_control_0/s_axi]
  connect_bd_intf_net -intf_net axi_interconnect_3_M01_AXI [get_bd_intf_pins AXI_IC_BLOCKS/M01_AXI] [get_bd_intf_pins pvtmon_axi_slave_0/s_axi]
  connect_bd_intf_net -intf_net axi_interconnect_3_M02_AXI [get_bd_intf_pins AXI_IC_BLOCKS/M02_AXI] [get_bd_intf_pins axi_perf_mon_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_3_M03_AXI [get_bd_intf_pins AXI_IC_BLOCKS/M03_AXI] [get_bd_intf_pins VIDEO_PATH/S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_interconnect_3_M04_AXI [get_bd_intf_pins AXI_IC_BLOCKS/M04_AXI] [get_bd_intf_pins VIDEO_PATH/S_AXI_CONTROL_BUS]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_MM2S [get_bd_intf_pins AXI_IC_BLOCKS/S01_AXI] [get_bd_intf_pins VIDEO_PATH/M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_vdma_0_M_AXI_S2MM [get_bd_intf_pins AXI_IC_BLOCKS/S02_AXI] [get_bd_intf_pins VIDEO_PATH/M_AXI_S2MM]
  connect_bd_intf_net -intf_net mig_0_C0_DDR4 [get_bd_intf_ports C0_DDR4] [get_bd_intf_pins mig_0/C0_DDR4]
  connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_cfg_mgmt [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/cfg_mgmt] [get_bd_intf_pins pcie3_ultrascale_0/pcie_cfg_mgmt]
  connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_m [get_bd_intf_pins AXI_IC_BLOCKS/S00_AXI] [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/m]
connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_m [get_bd_intf_pins AXI_IC_BLOCKS/S00_AXI] [get_bd_intf_pins axi_perf_mon_0/SLOT_0_AXI]
  connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_pcie3_cfg_control [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/pcie3_cfg_control] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_control]
  connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_pcie3_cfg_interrupt [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/pcie3_cfg_interrupt] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_interrupt]
  connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_pcie3_cfg_msi [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/pcie3_cfg_msi] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_msi]
  connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_pcie3_cfg_msix [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/pcie3_cfg_msix] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_msix]
  connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_s_axis_cc [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/s_axis_cc] [get_bd_intf_pins pcie3_ultrascale_0/s_axis_cc]
connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_s_axis_cc [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/s_axis_cc] [get_bd_intf_pins pcie_monitor_gen3_0/s_axis_cc]
  connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_s_axis_rq [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/s_axis_rq] [get_bd_intf_pins pcie3_ultrascale_0/s_axis_rq]
connect_bd_intf_net -intf_net nwl_dma_x8g3_wrapper_0_s_axis_rq [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/s_axis_rq] [get_bd_intf_pins pcie_monitor_gen3_0/s_axis_rq]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_m_axis_cq [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/m_axis_cq] [get_bd_intf_pins pcie3_ultrascale_0/m_axis_cq]
connect_bd_intf_net -intf_net pcie3_ultrascale_0_m_axis_cq [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/m_axis_cq] [get_bd_intf_pins pcie_monitor_gen3_0/m_axis_cq]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_m_axis_rc [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/m_axis_rc] [get_bd_intf_pins pcie3_ultrascale_0/m_axis_rc]
connect_bd_intf_net -intf_net pcie3_ultrascale_0_m_axis_rc [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/m_axis_rc] [get_bd_intf_pins pcie_monitor_gen3_0/m_axis_rc]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie3_cfg_status [get_bd_intf_pins nwl_dma_x8g3_wrapper_0/pcie3_cfg_status] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_status]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie3_ext_pipe_interface [get_bd_intf_ports pcie3_ext_pipe_interface] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_ext_pipe_interface]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie_7x_mgt [get_bd_intf_ports pcie_7x_mgt] [get_bd_intf_pins pcie3_ultrascale_0/pcie_7x_mgt]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie_cfg_fc [get_bd_intf_pins pcie3_ultrascale_0/pcie_cfg_fc] [get_bd_intf_pins pcie_monitor_gen3_0/fc]
  connect_bd_intf_net -intf_net pcie_monitor_gen3_0_init_fc [get_bd_intf_pins pcie_monitor_gen3_0/init_fc] [get_bd_intf_pins user_axilite_control_0/init_fc]

  # Create port connections
  connect_bd_net -net Net [get_bd_ports pmbus_clk] [get_bd_pins pvtmon_axi_slave_0/pmbus_clk]
  connect_bd_net -net Net1 [get_bd_ports pmbus_data] [get_bd_pins pvtmon_axi_slave_0/pmbus_data]
  connect_bd_net -net clk125_in_1 [get_bd_ports clk125_in] [get_bd_pins pvtmon_axi_slave_0/clk125_in]
  connect_bd_net -net mig_0_addn_ui_clkout1 [get_bd_pins AXI_IC_BLOCKS/S01_ACLK] [get_bd_pins VIDEO_PATH/m_axi_mm2s_aclk] [get_bd_pins mig_0/addn_ui_clkout1]
  connect_bd_net -net mig_0_c0_ddr4_ui_clk [get_bd_pins AXI_IC_BLOCKS/M00_ACLK] [get_bd_pins axi_perf_mon_0/core_aclk] [get_bd_pins axi_perf_mon_0/slot_1_axi_aclk] [get_bd_pins mig_0/c0_ddr4_ui_clk]
  connect_bd_net -net mig_0_c0_init_calib_complete [get_bd_ports c0_init_calib_complete] [get_bd_pins AXI_IC_BLOCKS/M00_ARESETN] [get_bd_pins VIDEO_PATH/aresetn] [get_bd_pins axi_perf_mon_0/core_aresetn] [get_bd_pins axi_perf_mon_0/slot_1_axi_aresetn] [get_bd_pins mig_0/c0_ddr4_aresetn] [get_bd_pins mig_0/c0_init_calib_complete] [get_bd_pins user_axilite_control_0/ddr4_calib_done]
  connect_bd_net -net nwl_dma_x8g3_wrapper_0_int_dma [get_bd_pins VIDEO_PATH/din1] [get_bd_pins nwl_dma_x8g3_wrapper_0/int_dma]
  connect_bd_net -net pcie3_ultrascale_0_cfg_current_speed [get_bd_ports cfg_current_speed] [get_bd_pins pcie3_ultrascale_0/cfg_current_speed]
  connect_bd_net -net pcie3_ultrascale_0_cfg_negotiated_width [get_bd_ports cfg_negotiated_width] [get_bd_pins pcie3_ultrascale_0/cfg_negotiated_width]
  connect_bd_net -net pcie3_ultrascale_0_user_clk [get_bd_ports user_clk] [get_bd_pins AXI_IC_BLOCKS/ACLK] [get_bd_pins VIDEO_PATH/M00_ACLK] [get_bd_pins axi_perf_mon_0/s_axi_aclk] [get_bd_pins axi_perf_mon_0/slot_0_axi_aclk] [get_bd_pins nwl_dma_x8g3_wrapper_0/user_clk] [get_bd_pins pcie3_ultrascale_0/user_clk] [get_bd_pins pcie_monitor_gen3_0/clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins pvtmon_axi_slave_0/s_axi_clk] [get_bd_pins user_axilite_control_0/s_axi_aclk]
  connect_bd_net -net pcie3_ultrascale_0_user_lnk_up [get_bd_ports user_lnk_up] [get_bd_pins pcie3_ultrascale_0/user_lnk_up] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net pcie3_ultrascale_0_user_reset [get_bd_pins nwl_dma_x8g3_wrapper_0/user_reset] [get_bd_pins pcie3_ultrascale_0/user_reset]
  connect_bd_net -net pcie_dma_wrapper_x8g3_0_user_lnk_up [get_bd_pins AXI_IC_BLOCKS/ARESETN] [get_bd_pins VIDEO_PATH/M00_ARESETN] [get_bd_pins axi_perf_mon_0/s_axi_aresetn] [get_bd_pins axi_perf_mon_0/slot_0_axi_aresetn] [get_bd_pins nwl_dma_x8g3_wrapper_0/user_lnk_up] [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins pvtmon_axi_slave_0/s_axi_areset_n] [get_bd_pins user_axilite_control_0/s_axi_areset_n]
  connect_bd_net -net pcie_monitor_gen3_0_rx_byte_count [get_bd_pins pcie_monitor_gen3_0/rx_byte_count] [get_bd_pins user_axilite_control_0/rx_pcie_bc]
  connect_bd_net -net pcie_monitor_gen3_0_tx_byte_count [get_bd_pins pcie_monitor_gen3_0/tx_byte_count] [get_bd_pins user_axilite_control_0/tx_pcie_bc]
  connect_bd_net -net pmbus_alert_1 [get_bd_ports pmbus_alert] [get_bd_pins pvtmon_axi_slave_0/pmbus_alert]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins pcie_monitor_gen3_0/reset] [get_bd_pins proc_sys_reset_0/peripheral_reset]
  connect_bd_net -net pvtmon_axi_slave_0_muxaddr_out [get_bd_ports muxaddr_out] [get_bd_pins pvtmon_axi_slave_0/muxaddr_out]
  connect_bd_net -net pvtmon_axi_slave_0_pmbus_control [get_bd_ports pmbus_control] [get_bd_pins pvtmon_axi_slave_0/pmbus_control]
  connect_bd_net -net sys_clk_1 [get_bd_ports sys_clk] [get_bd_pins pcie3_ultrascale_0/sys_clk]
  connect_bd_net -net sys_clk_gt_1 [get_bd_ports sys_clk_gt] [get_bd_pins pcie3_ultrascale_0/sys_clk_gt]
  connect_bd_net -net sys_reset_1 [get_bd_ports sys_reset] [get_bd_pins pcie3_ultrascale_0/sys_reset]
  connect_bd_net -net sys_rst_1 [get_bd_ports sys_rst] [get_bd_pins mig_0/sys_rst]
  connect_bd_net -net user_axilite_control_0_clk_period [get_bd_pins pcie_monitor_gen3_0/one_second_cnt] [get_bd_pins user_axilite_control_0/clk_period]
  connect_bd_net -net user_axilite_control_0_scaling_factor [get_bd_pins pcie_monitor_gen3_0/scaling_factor] [get_bd_pins user_axilite_control_0/scaling_factor]
  connect_bd_net -net user_axilite_control_0_spad_reg [get_bd_pins VIDEO_PATH/scratchpad_reg] [get_bd_pins user_axilite_control_0/spad_reg]
  connect_bd_net -net user_axilite_control_0_spad_val [get_bd_pins VIDEO_PATH/scratchpad_val] [get_bd_pins user_axilite_control_0/spad_val]
  connect_bd_net -net vauxn0_1 [get_bd_ports vauxn0] [get_bd_pins pvtmon_axi_slave_0/vauxn0]
  connect_bd_net -net vauxn2_1 [get_bd_ports vauxn2] [get_bd_pins pvtmon_axi_slave_0/vauxn2]
  connect_bd_net -net vauxn8_1 [get_bd_ports vauxn8] [get_bd_pins pvtmon_axi_slave_0/vauxn8]
  connect_bd_net -net vauxp0_1 [get_bd_ports vauxp0] [get_bd_pins pvtmon_axi_slave_0/vauxp0]
  connect_bd_net -net vauxp2_1 [get_bd_ports vauxp2] [get_bd_pins pvtmon_axi_slave_0/vauxp2]
  connect_bd_net -net vauxp8_1 [get_bd_ports vauxp8] [get_bd_pins pvtmon_axi_slave_0/vauxp8]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x44A10000 [get_bd_addr_spaces nwl_dma_x8g3_wrapper_0/m] [get_bd_addr_segs axi_perf_mon_0/S_AXI/Reg] SEG_axi_perf_mon_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A20000 [get_bd_addr_spaces nwl_dma_x8g3_wrapper_0/m] [get_bd_addr_segs VIDEO_PATH/axi_vdma_0/S_AXI_LITE/Reg] SEG_axi_vdma_0_Reg
  create_bd_addr_seg -range 0x40000000 -offset 0xC0000000 [get_bd_addr_spaces nwl_dma_x8g3_wrapper_0/m] [get_bd_addr_segs mig_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_mig_0_C0_DDR4_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x1000 -offset 0x44A02000 [get_bd_addr_spaces nwl_dma_x8g3_wrapper_0/m] [get_bd_addr_segs pvtmon_axi_slave_0/s_axi/reg0] SEG_pvtmon_axi_slave_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x44A30000 [get_bd_addr_spaces nwl_dma_x8g3_wrapper_0/m] [get_bd_addr_segs VIDEO_PATH/sobel_filter_0/S_AXI_CONTROL_BUS/Reg] SEG_sobel_filter_0_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x44A01000 [get_bd_addr_spaces nwl_dma_x8g3_wrapper_0/m] [get_bd_addr_segs user_axilite_control_0/s_axi/reg0] SEG_user_axilite_control_0_reg0
  create_bd_addr_seg -range 0x40000000 -offset 0xC0000000 [get_bd_addr_spaces VIDEO_PATH/axi_vdma_0/Data_MM2S] [get_bd_addr_segs mig_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_mig_0_C0_DDR4_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x40000000 -offset 0xC0000000 [get_bd_addr_spaces VIDEO_PATH/axi_vdma_0/Data_S2MM] [get_bd_addr_segs mig_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_mig_0_C0_DDR4_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x100000000 -offset 0x0 [get_bd_addr_spaces VIDEO_PATH/INTR_TRANSLATION_LOGIC/frame_sync_logic_0/m1] [get_bd_addr_segs nwl_dma_x8g3_wrapper_0/s/reg0] SEG_nwl_dma_x8g3_wrapper_0_reg0
  create_bd_addr_seg -range 0x100000000 -offset 0x0 [get_bd_addr_spaces VIDEO_PATH/INTR_TRANSLATION_LOGIC/frame_sync_logic_0/m2] [get_bd_addr_segs nwl_dma_x8g3_wrapper_0/s/reg0] SEG_nwl_dma_x8g3_wrapper_0_reg0
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


