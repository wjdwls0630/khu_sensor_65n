#******************************************************************************
#**                         00_read_global_reset                             **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                      00_read_global_reset.tcl                         "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "00_read_global_reset"

read_file -format verilog -rtl "./Source/Reset/async_rstn_synchronizer.v"
# To preserve or gate of glitch synchronizer
set_dont_touch [current_design]
set_false_path -from [get_cells o_RSTN_reg]
set_false_path -to [get_cells o_RSTN_reg]
set_disable_timing [get_cells *]
# To make reset buffer tree, set the ideal_network
set_ideal_network [get_pins o_RSTN_reg/Q]
echo "constraints i_RSTN"
set_ideal_network [get_ports i_RSTN]
set_false_path -from [get_ports i_RSTN]
set_disable_timing [get_ports i_RSTN]

compile_ultra -only_design_rule -incremental

read_file -format verilog -rtl "./Source/Reset/async_rst_synchronizer.v"
set_dont_touch [current_design]
set_false_path -from [get_cells o_RST_reg]
set_false_path -to [get_cells o_RST_reg]
set_disable_timing [get_cells *]
set_ideal_network [get_pins o_RST_reg/Q]
echo "constraints i_RSTN"
set_ideal_network [get_ports i_RSTN]
set_false_path -from [get_ports i_RSTN]
set_disable_timing [get_ports i_RSTN]

compile_ultra -only_design_rule -incremental
#propagate_constraints -design [current_design]

read_file -format verilog -rtl "./Source/Reset/async_rstn_glitch_synchronizer.v"

current_design "async_rstn_glitch_synchronizer"

echo "***********************************************************************"
echo "                                                                       "
echo "                    insert delay on or gate                            "
echo "                                                                       "
echo "***********************************************************************"
insert_buffer [get_pins __tmp100/A] $NOM_HVT_SS/DLY4X1MTH -no_of_cells 4

#set dont touch attribute
set_dont_touch [current_design]
set_disable_timing [get_cells *]
set_ideal_network [get_pins async_rstn_synchronizer/o_RSTN]
echo "constraints i_RSTN"
set_ideal_network [get_ports i_RSTN]
set_false_path -from [get_ports i_RSTN]
set_disable_timing [get_ports i_RSTN]

compile_ultra -only_design_rule -incremental
#propagate_constraints -design [current_design]
