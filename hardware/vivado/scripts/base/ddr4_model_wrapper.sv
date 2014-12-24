`ifdef XILINX_SIMULATOR 
   `include "ddr4_model_xsim/arch_package.sv"
   `include "ddr4_model_xsim/proj_package.sv"
   `include "ddr4_model_xsim/interface.sv"
   `include "ddr4_model_xsim/ddr4_model.sv"
`else 
   `include "ddr4_model_vsim/arch_package.sv"
   `include "ddr4_model_vsim/proj_package.sv"
   `include "ddr4_model_vsim/interface.sv"
   `include "ddr4_model_vsim/ddr4_model.svp"
`endif
