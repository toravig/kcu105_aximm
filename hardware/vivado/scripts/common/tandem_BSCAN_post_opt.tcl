## Add the BSCAN primitive to the Config PBLOCK and add it to Stage1
## This must be done becaus the Config Site primitves cannot be reconfigured
#set myBscan_primitive [get_cells dbg_hub/inst/bscan_inst/SERIES7_BSCAN.bscan_inst]
#set_property HD.TANDEM 1 $myBscan_primitive
#add_cells_to_pblock [get_pblocks u_trd_x8g3_trd_i_pcie3_ultrascale_0_inst_tandem_cfg_pblock] $myBscan_primitive

set_property HD.TANDEM 1 [get_cells dbg_hub/inst/bscan_inst/SERIES7_BSCAN.bscan_inst]
add_cells_to_pblock [get_pblocks -of_object [get_sites CONFIG_SITE_X0Y0]] [get_cells dbg_hub/inst/bscan_inst/SERIES7_BSCAN.bscan_inst]


