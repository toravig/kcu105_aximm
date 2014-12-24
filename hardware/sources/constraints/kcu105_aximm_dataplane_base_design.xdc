## The constraint 'NODELAY' is not supported in this version of software. Hence not converted.
#set_property PACKAGE_PIN K22 [get_ports perst_n]
set_property LOC [get_package_pins -of_objects [get_sites IOB_X1Y103]] [get_ports perst_n]
set_false_path -from [get_ports perst_n]
set_property IOSTANDARD LVCMOS18 [get_ports perst_n]
set_property PULLUP true [get_ports perst_n]

##### REFCLK_IBUF###########
set_property LOC GTHE3_COMMON_X0Y1 [get_cells refclk_ibuf]

create_clock -period 10.000 -name sys_clk [get_pins refclk_ibuf/ODIV2]
create_clock -period 10.000 -name sys_clk_gt [get_pins refclk_ibuf/O]
create_generated_clock -name sys_clk_bufg -source [get_pins refclk_ibuf/ODIV2] -divide_by 1 [get_pins u_trd/trd_i/pcie3_ultrascale_0/inst/bufg_gt_sysclk/O]

set_clock_groups -name async1 -asynchronous -group [get_clocks {sys_clk sys_clk_gt sys_clk_bufg}] -group [get_clocks {txout_clk user_clk pipe_clk core_clk mcap_clk}]

set_false_path -from [get_pins {u_trd/trd_i/proc_sys_reset_0/U0/ACTIVE_LOW_BSR_OUT_DFF[0].interconnect_aresetn_reg[0]/C}]

set_clock_groups -name userclk2_to_mcbclk0 -asynchronous -group [get_clocks mmcm_clkout0] -group [get_clocks user_clk]
# Shd be part of IP xdc
set_clock_groups -name userclk_to_pipeclk -asynchronous -group [get_clocks pipe_clk] -group [get_clocks user_clk]

#set_clock_groups -name userclk2_to_mcbclk1 -asynchronous -group [get_clocks mmcm_clkout1] -group [get_clocks user_clk]
#set_clock_groups -name mcb_clk0_to_mcbclk1 -asynchronous -group [get_clocks mmcm_clkout1] -group [get_clocks mmcm_clkout0]

##-------------------------------------
## LED Status Pinout   (bottom to top)
##-------------------------------------

set_property PACKAGE_PIN AP8 [get_ports {led[0]}]
set_property PACKAGE_PIN H23 [get_ports {led[1]}]
set_property PACKAGE_PIN P20 [get_ports {led[2]}]
set_property PACKAGE_PIN P21 [get_ports {led[3]}]
set_property PACKAGE_PIN N22 [get_ports c0_init_calib_complete]
#set_property PACKAGE_PIN M22 [get_ports {led[5]}]
#set_property PACKAGE_PIN R23 [get_ports {led[6]}]
#set_property PACKAGE_PIN P23 [get_ports {led[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports c0_init_calib_complete]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[5]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[6]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {led[7]}]

#set_property SLEW SLOW [get_ports {led[7]}]
#set_property SLEW SLOW [get_ports {led[6]}]
#set_property SLEW SLOW [get_ports {led[5]}]
set_property SLEW SLOW [get_ports c0_init_calib_complete]
set_property SLEW SLOW [get_ports {led[3]}]
set_property SLEW SLOW [get_ports {led[2]}]
set_property SLEW SLOW [get_ports {led[1]}]
set_property SLEW SLOW [get_ports {led[0]}]

#set_property DRIVE 4 [get_ports {led[7]}]
#set_property DRIVE 4 [get_ports {led[6]}]
#set_property DRIVE 4 [get_ports {led[5]}]
set_property DRIVE 4 [get_ports c0_init_calib_complete]
set_property DRIVE 4 [get_ports {led[3]}]
set_property DRIVE 4 [get_ports {led[2]}]
set_property DRIVE 4 [get_ports {led[1]}]
set_property DRIVE 4 [get_ports {led[0]}]

set_false_path -from [get_pins u_trd/trd_i/nwl_dma_x8g3_wrapper_0/inst/p_rst_reg/C]
set_false_path -from [get_pins u_trd/trd_i/pcie3_ultrascale_0/inst/reg_user_lnk_up_reg/C]

#MIG DDR4 Related
#set_property PACKAGE_PIN AK16 [get_ports C0_SYS_CLK_clk_n]
#set_property IOSTANDARD DIFF_SSTL12 [get_ports C0_SYS_CLK_clk_n]

#set_property PACKAGE_PIN AK17 [get_ports C0_SYS_CLK_clk_p]
#set_property IOSTANDARD DIFF_SSTL12 [get_ports C0_SYS_CLK_clk_p]

#create_clock -name c0_sys_clk -period 3.333 [get_ports C0_SYS_CLK_CLK_P]

#set_property PACKAGE_PIN AN16 [get_ports sys_rst]
#set_property IOSTANDARD LVCMOS12 [get_ports sys_rst]

##-------------------------------------
## PMBus Pinout
##-------------------------------------
create_clock -period 8.000 -name sysclk -waveform {0.000 4.000} [get_ports clk125_in]

set_property IOSTANDARD LVCMOS18 [get_ports clk125_in]
set_property PACKAGE_PIN G10 [get_ports clk125_in]

set_property PACKAGE_PIN J24 [get_ports pmbus_clk]
set_property PACKAGE_PIN J25 [get_ports pmbus_data]
set_property PACKAGE_PIN AK10 [get_ports pmbus_alert]
#set_property PACKAGE_PIN AP10 [get_ports iic_mux_reset_n]
set_property IOSTANDARD LVCMOS18 [get_ports pmbus_clk]
set_property IOSTANDARD LVCMOS18 [get_ports pmbus_data]
set_property IOSTANDARD LVCMOS18 [get_ports pmbus_alert]
#set_property IOSTANDARD LVCMOS18 [get_ports iic_mux_reset_n]

set_clock_groups -name userclk2_to_clk125 -asynchronous -group [get_clocks sysclk] -group [get_clocks user_clk]
# Shd be pderived from above constraint
set_clock_groups -name userclk_to_pvtmonclk -asynchronous -group [get_clocks clk_out2_clk_wiz_0] -group [get_clocks user_clk]
# Shd be part of IP xdc
set_clock_groups -name mmcmclk0_to_riuclk -asynchronous -group [get_clocks mmcm_clkout0] -group [get_clocks riu_clk]
##--------------------------------------
## SYSMON
##--------------------------------------
set_property IOSTANDARD ANALOG [get_ports vauxp0]
#set_property IO_TYPE SYSMON_AUX [get_ports  vauxp0]
set_property PACKAGE_PIN E13 [get_ports vauxn0]
set_property IOSTANDARD ANALOG [get_ports vauxn0]
#set_property IO_TYPE SYSMON_AUX [get_ports  vauxn0]
set_property IOSTANDARD ANALOG [get_ports vauxp8]
#set_property IO_TYPE SYSMON_AUX [get_ports  vauxp8]
set_property PACKAGE_PIN B11 [get_ports vauxn8]
set_property IOSTANDARD ANALOG [get_ports vauxn8]
#set_property IO_TYPE SYSMON_AUX [get_ports  vauxn8]
set_property IOSTANDARD ANALOG [get_ports vauxp2]
#set_property IO_TYPE SYSMON_AUX [get_ports  vauxp2]
set_property PACKAGE_PIN H13 [get_ports vauxn2]
set_property IOSTANDARD ANALOG [get_ports vauxn2]
#set_property IO_TYPE SYSMON_AUX [get_ports  vauxn2]
set_property PACKAGE_PIN T27 [get_ports {muxaddr_out[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {muxaddr_out[0]}]
set_property PACKAGE_PIN R27 [get_ports {muxaddr_out[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {muxaddr_out[1]}]
set_property PACKAGE_PIN N27 [get_ports {muxaddr_out[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {muxaddr_out[2]}]

#create_pblock pblock_nwl
#add_cells_to_pblock pblock_nwl [get_cells u_trd/trd_i/nwl_dma_x8g3_wrapper_0]
#resize_pblock pblock_nwl -add {CLOCKREGION_X0Y0:CLOCKREGION_X1Y0}
#resize_pblock pblock_nwl -add {CLOCKREGION_X2Y0:CLOCKREGION_X3Y4}

#set_property CLOCK_ROOT X0Y1 [get_nets u_trd/trd_i/mig_0/inst/u_ddr4_mem_intfc/u_ddr4_phy/u_infrastructure/O1]
#set_property CLOCK_ROOT X0Y1 [get_nets u_trd/trd_i/mig_0/inst/u_ddr4_mem_intfc/u_ddr4_phy/u_infrastructure/riu_clk]

