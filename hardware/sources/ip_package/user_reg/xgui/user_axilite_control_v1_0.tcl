# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set C_TOTAL_NUM_CE [ipgui::add_param $IPINST -parent $Page0 -name C_TOTAL_NUM_CE]
	set C_S_AXI_MIN_SIZE [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_MIN_SIZE]
	set C_NUM_ADDRESS_RANGES [ipgui::add_param $IPINST -parent $Page0 -name C_NUM_ADDRESS_RANGES]
	set C_S_AXI_HIGHADDR [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_HIGHADDR]
	set C_S_AXI_BASEADDR [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_BASEADDR]
	set C_S_AXI_BUF_HIGHADDR [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_BUF_HIGHADDR]
	set C_S_AXI_BUF_BASEADDR [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_BUF_BASEADDR]
}

proc update_PARAM_VALUE.C_TOTAL_NUM_CE { PARAM_VALUE.C_TOTAL_NUM_CE } {
	# Procedure called to update C_TOTAL_NUM_CE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TOTAL_NUM_CE { PARAM_VALUE.C_TOTAL_NUM_CE } {
	# Procedure called to validate C_TOTAL_NUM_CE
	return true
}

proc update_PARAM_VALUE.C_S_AXI_MIN_SIZE { PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to update C_S_AXI_MIN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_MIN_SIZE { PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to validate C_S_AXI_MIN_SIZE
	return true
}

proc update_PARAM_VALUE.C_NUM_ADDRESS_RANGES { PARAM_VALUE.C_NUM_ADDRESS_RANGES } {
	# Procedure called to update C_NUM_ADDRESS_RANGES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_NUM_ADDRESS_RANGES { PARAM_VALUE.C_NUM_ADDRESS_RANGES } {
	# Procedure called to validate C_NUM_ADDRESS_RANGES
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BUF_HIGHADDR { PARAM_VALUE.C_S_AXI_BUF_HIGHADDR } {
	# Procedure called to update C_S_AXI_BUF_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BUF_HIGHADDR { PARAM_VALUE.C_S_AXI_BUF_HIGHADDR } {
	# Procedure called to validate C_S_AXI_BUF_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BUF_BASEADDR { PARAM_VALUE.C_S_AXI_BUF_BASEADDR } {
	# Procedure called to update C_S_AXI_BUF_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BUF_BASEADDR { PARAM_VALUE.C_S_AXI_BUF_BASEADDR } {
	# Procedure called to validate C_S_AXI_BUF_BASEADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_BUF_BASEADDR { MODELPARAM_VALUE.C_S_AXI_BUF_BASEADDR PARAM_VALUE.C_S_AXI_BUF_BASEADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_BUF_BASEADDR}] ${MODELPARAM_VALUE.C_S_AXI_BUF_BASEADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_BUF_HIGHADDR { MODELPARAM_VALUE.C_S_AXI_BUF_HIGHADDR PARAM_VALUE.C_S_AXI_BUF_HIGHADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_BUF_HIGHADDR}] ${MODELPARAM_VALUE.C_S_AXI_BUF_HIGHADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_BASEADDR { MODELPARAM_VALUE.C_S_AXI_BASEADDR PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_BASEADDR}] ${MODELPARAM_VALUE.C_S_AXI_BASEADDR}
}

proc update_MODELPARAM_VALUE.C_S_AXI_HIGHADDR { MODELPARAM_VALUE.C_S_AXI_HIGHADDR PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_HIGHADDR}] ${MODELPARAM_VALUE.C_S_AXI_HIGHADDR}
}

proc update_MODELPARAM_VALUE.C_NUM_ADDRESS_RANGES { MODELPARAM_VALUE.C_NUM_ADDRESS_RANGES PARAM_VALUE.C_NUM_ADDRESS_RANGES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_NUM_ADDRESS_RANGES}] ${MODELPARAM_VALUE.C_NUM_ADDRESS_RANGES}
}

proc update_MODELPARAM_VALUE.C_S_AXI_MIN_SIZE { MODELPARAM_VALUE.C_S_AXI_MIN_SIZE PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_MIN_SIZE}] ${MODELPARAM_VALUE.C_S_AXI_MIN_SIZE}
}

proc update_MODELPARAM_VALUE.C_TOTAL_NUM_CE { MODELPARAM_VALUE.C_TOTAL_NUM_CE PARAM_VALUE.C_TOTAL_NUM_CE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TOTAL_NUM_CE}] ${MODELPARAM_VALUE.C_TOTAL_NUM_CE}
}

