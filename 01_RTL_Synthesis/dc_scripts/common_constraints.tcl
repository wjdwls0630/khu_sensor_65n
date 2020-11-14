echo "***********************************************************************"
echo "                                                                       "
echo "                      common_constraints.tcl                           "
echo "                                                                       "
echo "***********************************************************************"

#DRC
# Typically, a logic library specifies a default max_transition or max_capacitance,
# but not both. To achieve the best result, do not mix max_transition and max_capacitance
# set_max_fanout and set_max_transition
# set_max_fanout and set_max_capacitance
#set_max_transition 0.6 [all_designs]
#set_max_fanout 4 [all_designs]
#set_max_capacitance 2.1 [all_designs]

# we don't know input/output delay precisely
# However, excessive pessimistic condition usually becomes over constraints for practical design.
# In this design, we assume that external chips are close based on on-chip design.

## Inout optimization
if { !$INOUT_OPT } {
  set_false_path -from [all_inputs]
  set_false_path -to [all_outputs]
} else {
  set_input_delay -max 0.35 [remove_from_collection [all_inputs] [get_ports i_CLK]] -clock clk
  set_input_transition 0.12 [remove_from_collection [all_inputs] [get_ports i_CLK]]
  remove_input_delay [get_ports i_RSTN]
  remove_input_transition [get_ports i_RSTN]
  set_output_delay -max 0.5 [all_outputs] -clock clk
}
# Reset Constraints
echo "constraints i_RSTN"
set_ideal_network [get_ports i_RSTN]
set_false_path -from [get_ports i_RSTN]
set_disable_timing [get_ports i_RSTN]

#******************************************************************************
#Temporal solutions of reset tree
echo "constraints Reset Synchronizer"
echo "constraints async_rstn_synchronizer..."
# level 1
set_ideal_network [get_pins */async_rstn_synchronizer/o_RSTN_reg/Q]
set_false_path -from [get_pins */async_rstn_synchronizer/r_ff_reg/CK]
set_false_path -from [get_pins */async_rstn_synchronizer/o_RSTN_reg/CK]
set_false_path -to [get_pins */async_rstn_synchronizer/o_RSTN_reg/RN]
set_false_path -to [get_pins */async_rstn_synchronizer/r_ff_reg/RN]
set_disable_timing [get_cells */async_rstn_synchronizer]

# level 2
set_ideal_network [get_pins */*/async_rstn_synchronizer/o_RSTN_reg/Q]
set_false_path -from [get_pins */*/async_rstn_synchronizer/r_ff_reg/CK]
set_false_path -from [get_pins */*/async_rstn_synchronizer/o_RSTN_reg/CK]
set_false_path -to [get_pins */*/async_rstn_synchronizer/o_RSTN_reg/RN]
set_false_path -to [get_pins */*/async_rstn_synchronizer/r_ff_reg/RN]
set_disable_timing [get_cells */*/async_rstn_synchronizer]

# level 3
set_ideal_network [get_pins */*/*/async_rstn_synchronizer/o_RSTN_reg/Q]
set_false_path -from [get_pins */*/*/async_rstn_synchronizer/r_ff_reg/CK]
set_false_path -from [get_pins */*/*/async_rstn_synchronizer/o_RSTN_reg/CK]
set_false_path -to [get_pins */*/*/async_rstn_synchronizer/o_RSTN_reg/RN]
set_false_path -to [get_pins */*/*/async_rstn_synchronizer/r_ff_reg/RN]
set_disable_timing [get_cells */*/*/async_rstn_synchronizer]


echo "constraints async_rst_synchronizer..."
# level 2
set_ideal_network [get_pins */*/async_rst_synchronizer/o_RST_reg/Q]
set_false_path -from [get_pins */*/async_rst_synchronizer/r_ff_reg/CK]
set_false_path -from [get_pins */*/async_rst_synchronizer/o_RST_reg/CK]
set_false_path -to [get_pins */*/async_rst_synchronizer/o_RST_reg/SN]
set_false_path -to [get_pins */*/async_rst_synchronizer/r_ff_reg/SN]
set_disable_timing [get_cells */*/async_rst_synchronizer]

# level 3
set_ideal_network [get_pins */*/*/async_rst_synchronizer/o_RST_reg/Q]
set_false_path -from [get_pins */*/*/async_rst_synchronizer/r_ff_reg/CK]
set_false_path -from [get_pins */*/*/async_rst_synchronizer/o_RST_reg/CK]
set_false_path -to [get_pins */*/*/async_rst_synchronizer/o_RST_reg/SN]
set_false_path -to [get_pins */*/*/async_rst_synchronizer/r_ff_reg/SN]
set_disable_timing [get_cells */*/*/async_rst_synchronizer]

echo "constraints async_rstn_glitch_synchronizer..."
set_disable_timing [get_cells */async_rstn_glitch_synchronizer]
#******************************************************************************

set max_load 0.025
#set max_load 0.025
set_load $max_load [all_outputs]

# Turn on auto wire load selection
# Limitation of Statistical Wire Load Models(WLM)
# WLM are very subjective to variations due to P&R design style, tools, # of metal layers and so on.
# Zero-WLM style keep synthesis from wasting time on pointless buffering and sizing.
# Using a Zero-WLM with tightened timing constraints to engourage DC to produce a design
# that is more suitable for physical synthesis downstream
# Hence, a design should be synthesized without any wire load, that is with zero wire load.
# To make wire load zero, variable auto_wire_load_selection must be false.
# If you are going to use the synthesis result with Zero-WLM style, more timing margin is
# recommended.
# 1.2V Typical : 40% of clock cylce
set auto_wire_load_selection false

# fix multiple port for feedthrough
set_fix_multiple_port_nets -all -buffer_constants

# area
set_max_area 0

# power
if { $POWER_OPT } {
  set_leakage_optimization true
  set_dynamic_optimization true
} else {
  set_leakage_optimization false
  set_dynamic_optimization false
}

# These settings should be the default setting from Synopsys
# With these flags set correctly, and the distributed reset synchronizers, the clock tree
# like task of building a buffered reset tree is eliminated
set enable_recovery_removal_arcs false
set timing_disable_recovery_removal_checks false

# for default synthesizing style on async reset
set hdlin_ff_always_sync_set_reset false

# Set false path over 2ns path
if { $HOLD_FIX == "true" } {
  set_fix_hold [all_clocks]
} else {
  remove_attribute [all_clocks] fix_hold
}

# Interconnect net between PAD and virtual Port does not exist in reality. But DC calculates
# total capacitance of interconnect net and PAD's output for wire delay.
# Thus, For calculating accurate delay, we should constraint its resistance and load manually.
set port_nets [get_nets -of_object [get_ports *]]
foreach_in_collection each_net $port_nets {
	set net_name [get_object_name $each_net]
	set_load 0.0 [get_nets $net_name]
	set_resistance 0 [get_nets $net_name]
	set_dont_touch [get_nets $net_name]
	echo "Delete ${net_name} delay between PAD and virtual port!"
}
