# Vivado Batch mode script for implementation

source kcu105_aximm_dataplane_video_acc.tcl 

reset_run synth_1
launch_run [get_runs synth_1]

wait_on_run synth_1

reset_run impl_1
launch_run -to_step write_bitstream [get_runs impl_1]

wait_on_run impl_1
