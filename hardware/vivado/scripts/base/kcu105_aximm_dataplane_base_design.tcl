# VIVADO IPI Project Launch Script
set proj_name kcu105_aximm_dataplane
set design_top trd 
set device xcku040-ffva1156-2-e
set proj_dir runs_base_design
set source_dir ../../../sources
set constraints_dir ./${source_dir}/constraints
set hdl_dir ./${source_dir}/hdl
set runs ../../${proj_dir}
set ui_name bd_b0911ba6.ui

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
