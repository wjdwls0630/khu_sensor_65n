# reset
set_fp_rail_constraints -remove_all_layers
remove_fp_virtual_pad -all              
set_fp_rail_strategy -reset             
set_fp_block_ring_constraints -remove_all
set_fp_rail_region_constraints  -remove 
# global constraints
set_fp_rail_constraints -set_global -no_routing_over_hard_macros 

# layer constraints
set_fp_rail_constraints -add_layer  -layer MET6 -direction vertical -max_strap 50 -min_strap 16 -max_width 3.000000 -min_width 0.440000 -spacing minimum 
set_fp_rail_constraints -add_layer  -layer MET5 -direction horizontal -max_strap 50 -min_strap 16 -max_width 3.000000 -min_width 0.200000 -spacing minimum 

# ring and strap constraints
set_fp_rail_constraints  -set_ring -nets { VDD VSS } -horizontal_ring_layer { MET3 } -vertical_ring_layer { MET4 } -extend_strap core_ring 

# strategies
set_fp_rail_strategy  -use_tluplus true 

# block ring constraints

# regions
set_fp_rail_region_constraints  -polygon { {169.070007 1035.920044} {169.070007 172.589996} {1019.809998 172.589996} {1019.809998 1035.920044} {169.070007 1035.920044} } 

# virtual pads

# synthesize_fp_rail 
synthesize_fp_rail -nets { VDD VSS } -voltage_supply 1.350000 -power_budget 350.000000   
