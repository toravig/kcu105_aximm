# VIVADO IPI Project Launch Script
set proj_name kcu105_aximm_dataplane
set design_top trd 
set device xcku040-ffva1156-2-e
set proj_dir runs_mti
set source_dir ../../../sources
set constraints_dir ./${source_dir}/constraints
set hdl_dir ./${source_dir}/hdl
set runs ../../${proj_dir}
set ui_name bd_b0911ba6.ui

set sim_top board
# SIM_TOOL options- mti or xsim
#set SIM_TOOL  "mti"

create_project -name ${proj_name} -force -dir "../../${proj_dir}" -part ${device}

# Project Settings

add_files -fileset constrs_1 -norecurse ${constraints_dir}/kcu105_aximm_dataplane_base_design.xdc
set_property used_in_synthesis true [get_files ${constraints_dir}/kcu105_aximm_dataplane_base_design.xdc]

set_property ip_repo_paths ${source_dir}/ip_package [current_fileset]
update_ip_catalog

# BD for design
source base_design_bd.tcl 
# Source TCL for MIG IP settings and pin locs
source ../common/kcu105_mig_2400.tcl

make_wrapper -files [get_files ${runs}/${proj_name}.srcs/sources_1/bd/${design_top}/${design_top}.bd] -top
import_files -force -norecurse ${runs}/${proj_name}.srcs/sources_1/bd/${design_top}/hdl/${design_top}_wrapper.v
set_property top ${design_top}_wrapper [current_fileset]

add_files -norecurse -force ${hdl_dir}/kcu105_aximm_dataplane.v
set_property top kcu105_aximm_dataplane [current_fileset]
update_compile_order -fileset sources_1

#Setting Sythesis options
set_property flow {Vivado Synthesis 2014} [get_runs synth_1]
set_property flow {Vivado Implementation 2014} [get_runs impl_1]

set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

validate_bd_design
save_bd_design
close_bd_design ${design_top}

file mkdir ${runs}/${proj_name}.srcs/sources_1/bd/${design_top}/ui
# apply UI file
file copy -force ${ui_name} ${runs}/${proj_name}.srcs/sources_1/bd/${design_top}/ui/${ui_name}

open_bd_design ${runs}/${proj_name}.srcs/sources_1/bd/${design_top}/${design_top}.bd

#####################
## Set up Simulations
## Get the current working directory
#####################

set_property target_simulator ModelSim [current_project]
set_property -name modelsim.compile.vlog.more_options -value {-sv +incdir+./../../../../scripts/base/ddr4_model_vsim/. +define+DDR4_4G_X16 ./../../../../scripts/base/ddr4_model_wrapper.sv } -objects [get_filesets sim_1]
set_property -name modelsim.simulate.vsim.more_options -value {+notimingchecks +TESTNAME=smoke_test } -objects [get_filesets sim_1]
set_property verilog_define { {SIMULATION=1} } [get_filesets sim_1]

set_property include_dirs { ../../../sources/testbench ../../../sources/testbench/dsport ../../../sources/testbench/tests ../../../sources/testbench/include ./ddr4_model_vsim} [get_filesets sim_1]

read_verilog "../../../sources/testbench/board.sv"
read_verilog "../../../sources/testbench/dsport/xilinx_pcie_uscale_rp.v"
read_verilog "../../../sources/testbench/dsport/pcie3_uscale_rp_top.v"
read_verilog "../../../sources/testbench/dsport/pci_exp_usrapp_com.v"
read_verilog "../../../sources/testbench/dsport/pci_exp_usrapp_tx.v"
read_verilog "../../../sources/testbench/dsport/pci_exp_usrapp_cfg.v"
read_verilog "../../../sources/testbench/dsport/pci_exp_usrapp_rx.v"
read_verilog "../../../sources/testbench/dsport/pci_exp_usrapp_pl.v"
read_verilog "../../../sources/testbench/functional/pcie3_ultrascale_0_phy_sig_gen_clk.v"
read_verilog "../../../sources/testbench/functional/pcie3_ultrascale_0_phy_sig_gen.v"

set_property USED_IN simulation [get_files ../../../sources/testbench/board.sv] 
set_property USED_IN simulation [get_files ../../../sources/testbench/dsport/xilinx_pcie_uscale_rp.v] 
set_property USED_IN simulation [get_files ../../../sources/testbench/dsport/pcie3_uscale_rp_top.v] 
set_property USED_IN simulation [get_files ../../../sources/testbench/dsport/pci_exp_usrapp_com.v] 
set_property USED_IN simulation [get_files ../../../sources/testbench/dsport/pci_exp_usrapp_tx.v] 
set_property USED_IN simulation [get_files ../../../sources/testbench/dsport/pci_exp_usrapp_cfg.v] 
set_property USED_IN simulation [get_files ../../../sources/testbench/dsport/pci_exp_usrapp_rx.v] 
set_property USED_IN simulation [get_files ../../../sources/testbench/dsport/pci_exp_usrapp_pl.v] 
set_property USED_IN simulation [get_files ../../../sources/testbench/functional/pcie3_ultrascale_0_phy_sig_gen_clk.v]
set_property USED_IN simulation [get_files ../../../sources/testbench/functional/pcie3_ultrascale_0_phy_sig_gen.v]

update_compile_order -fileset sources_1
set_property top ${sim_top} [get_filesets sim_1]
update_compile_order -fileset sources_1

set_property include_dirs { ../../../sources/testbench ../../../sources/testbench/dsport ../../../sources/testbench/tests ../../../sources/testbench/include ./ddr4_model_vsim} [get_filesets sim_1]

generate_target all [get_files  ${runs}/${proj_name}.srcs/sources_1/bd/${design_top}/${design_top}.bd]
