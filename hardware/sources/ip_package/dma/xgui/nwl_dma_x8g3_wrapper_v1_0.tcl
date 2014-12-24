# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set USE_AXI_SLAVE [ipgui::add_param $IPINST -parent $Page0 -name USE_AXI_SLAVE]
	set M_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name M_DATA_WIDTH]
	set M_LEN_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name M_LEN_WIDTH]
	set M_ADDR_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name M_ADDR_WIDTH]
	set M_ID_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name M_ID_WIDTH]
	set S_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name S_DATA_WIDTH]
	set S_LEN_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name S_LEN_WIDTH]
	set S_ADDR_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name S_ADDR_WIDTH]
	set S_ID_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name S_ID_WIDTH]
	set P_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name P_DATA_WIDTH]
	set DMA_CHANNEL_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name DMA_CHANNEL_WIDTH]
	set NUM_LANES [ipgui::add_param $IPINST -parent $Page0 -name NUM_LANES]
}

proc update_PARAM_VALUE.USE_AXI_SLAVE { PARAM_VALUE.USE_AXI_SLAVE } {
	# Procedure called to update USE_AXI_SLAVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_AXI_SLAVE { PARAM_VALUE.USE_AXI_SLAVE } {
	# Procedure called to validate USE_AXI_SLAVE
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

proc update_PARAM_VALUE.S_DATA_WIDTH { PARAM_VALUE.S_DATA_WIDTH } {
	# Procedure called to update S_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_DATA_WIDTH { PARAM_VALUE.S_DATA_WIDTH } {
	# Procedure called to validate S_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.S_LEN_WIDTH { PARAM_VALUE.S_LEN_WIDTH } {
	# Procedure called to update S_LEN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_LEN_WIDTH { PARAM_VALUE.S_LEN_WIDTH } {
	# Procedure called to validate S_LEN_WIDTH
	return true
}

proc update_PARAM_VALUE.S_ADDR_WIDTH { PARAM_VALUE.S_ADDR_WIDTH } {
	# Procedure called to update S_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_ADDR_WIDTH { PARAM_VALUE.S_ADDR_WIDTH } {
	# Procedure called to validate S_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.S_ID_WIDTH { PARAM_VALUE.S_ID_WIDTH } {
	# Procedure called to update S_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_ID_WIDTH { PARAM_VALUE.S_ID_WIDTH } {
	# Procedure called to validate S_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.P_DATA_WIDTH { PARAM_VALUE.P_DATA_WIDTH } {
	# Procedure called to update P_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.P_DATA_WIDTH { PARAM_VALUE.P_DATA_WIDTH } {
	# Procedure called to validate P_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DMA_CHANNEL_WIDTH { PARAM_VALUE.DMA_CHANNEL_WIDTH } {
	# Procedure called to update DMA_CHANNEL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DMA_CHANNEL_WIDTH { PARAM_VALUE.DMA_CHANNEL_WIDTH } {
	# Procedure called to validate DMA_CHANNEL_WIDTH
	return true
}

proc update_PARAM_VALUE.NUM_LANES { PARAM_VALUE.NUM_LANES } {
	# Procedure called to update NUM_LANES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_LANES { PARAM_VALUE.NUM_LANES } {
	# Procedure called to validate NUM_LANES
	return true
}


proc update_MODELPARAM_VALUE.NUM_LANES { MODELPARAM_VALUE.NUM_LANES PARAM_VALUE.NUM_LANES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_LANES}] ${MODELPARAM_VALUE.NUM_LANES}
}

proc update_MODELPARAM_VALUE.DMA_CHANNEL_WIDTH { MODELPARAM_VALUE.DMA_CHANNEL_WIDTH PARAM_VALUE.DMA_CHANNEL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DMA_CHANNEL_WIDTH}] ${MODELPARAM_VALUE.DMA_CHANNEL_WIDTH}
}

proc update_MODELPARAM_VALUE.P_DATA_WIDTH { MODELPARAM_VALUE.P_DATA_WIDTH PARAM_VALUE.P_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.P_DATA_WIDTH}] ${MODELPARAM_VALUE.P_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.S_ID_WIDTH { MODELPARAM_VALUE.S_ID_WIDTH PARAM_VALUE.S_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_ID_WIDTH}] ${MODELPARAM_VALUE.S_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.S_ADDR_WIDTH { MODELPARAM_VALUE.S_ADDR_WIDTH PARAM_VALUE.S_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_ADDR_WIDTH}] ${MODELPARAM_VALUE.S_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.S_LEN_WIDTH { MODELPARAM_VALUE.S_LEN_WIDTH PARAM_VALUE.S_LEN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_LEN_WIDTH}] ${MODELPARAM_VALUE.S_LEN_WIDTH}
}

proc update_MODELPARAM_VALUE.S_DATA_WIDTH { MODELPARAM_VALUE.S_DATA_WIDTH PARAM_VALUE.S_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_DATA_WIDTH}] ${MODELPARAM_VALUE.S_DATA_WIDTH}
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

