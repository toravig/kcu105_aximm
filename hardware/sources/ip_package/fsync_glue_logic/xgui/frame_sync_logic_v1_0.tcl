# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set BASE_ADDR [ipgui::add_param $IPINST -parent $Page0 -name BASE_ADDR]
	set M_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name M_DATA_WIDTH]
	set M_LEN_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name M_LEN_WIDTH]
	set M_ADDR_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name M_ADDR_WIDTH]
	set M_ID_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name M_ID_WIDTH]
}

proc update_PARAM_VALUE.BASE_ADDR { PARAM_VALUE.BASE_ADDR } {
	# Procedure called to update BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BASE_ADDR { PARAM_VALUE.BASE_ADDR } {
	# Procedure called to validate BASE_ADDR
	return true
}

proc update_PARAM_VALUE.M_DATA_WIDTH { PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to update M_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_DATA_WIDTH { PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to validate M_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.M_LEN_WIDTH { PARAM_VALUE.M_LEN_WIDTH } {
	# Procedure called to update M_LEN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_LEN_WIDTH { PARAM_VALUE.M_LEN_WIDTH } {
	# Procedure called to validate M_LEN_WIDTH
	return true
}

proc update_PARAM_VALUE.M_ADDR_WIDTH { PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to update M_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_ADDR_WIDTH { PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to validate M_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.M_ID_WIDTH { PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to update M_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_ID_WIDTH { PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to validate M_ID_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.M_ID_WIDTH { MODELPARAM_VALUE.M_ID_WIDTH PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_ID_WIDTH}] ${MODELPARAM_VALUE.M_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.M_ADDR_WIDTH { MODELPARAM_VALUE.M_ADDR_WIDTH PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_ADDR_WIDTH}] ${MODELPARAM_VALUE.M_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.M_LEN_WIDTH { MODELPARAM_VALUE.M_LEN_WIDTH PARAM_VALUE.M_LEN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_LEN_WIDTH}] ${MODELPARAM_VALUE.M_LEN_WIDTH}
}

proc update_MODELPARAM_VALUE.M_DATA_WIDTH { MODELPARAM_VALUE.M_DATA_WIDTH PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_DATA_WIDTH}] ${MODELPARAM_VALUE.M_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BASE_ADDR { MODELPARAM_VALUE.BASE_ADDR PARAM_VALUE.BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BASE_ADDR}] ${MODELPARAM_VALUE.BASE_ADDR}
}

