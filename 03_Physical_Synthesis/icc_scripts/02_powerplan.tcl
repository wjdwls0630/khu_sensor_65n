#******************************************************************************
#**                           02_powerplan                                   **
#**              power planning, preroute and global route                   **
#******************************************************************************
# Power Network Synthesis (PNS)
# Creates macro power rings since all macro which needs to supply voltage cannot
# route to core power pad directly
# Creates the power grid

echo "***********************************************************************"
echo "                                                                       "
echo "                           02_powerplan.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "02_powerplan"

# source the user_design_setup & common_lib_setup
source -echo -v ./icc_scripts/user_scripts/user_design_setup.tcl
source -echo -v ./icc_scripts/common_lib_setup.tcl

# Clear existing mw library and re-make dir
set _mw_lib ./mw_db/${TOP_MODULE}_${step}
if {[file exist $_mw_lib]} {
	sh mv $_mw_lib ./mw_db/old/${TOP_MODULE}_${step}_${back}
}
copy_mw_lib -from ./mw_db/${TOP_MODULE}_01_floorplan -to $_mw_lib

# Open Library and Cell

set_mw_technology_file -technology $TECH_FILE $_mw_lib
set_mw_lib_reference $_mw_lib -mw_reference_library $MW_REF_LIB_DIRS
open_mw_lib $_mw_lib
remove_mw_cel \
	[remove_from_collection [get_mw_cel *] [get_mw_cel $TOP_MODULE]] \
	-all_versions -all_view -verbose
open_mw_cel $TOP_MODULE
link
current_design $TOP_MODULE


# Read scenario file
remove_sdc
remove_scenario -all
sh sed -i 's/ ${STD_WST}/ ${STD_WST}.db:${STD_WST}/' $FUNC1_SDC
#sh sed -i '/set_max_fanout/d' $FUNC1_SDC
source $ICC_MCMM_SCENARIOS_FILE
set_active_scenario $FP_SCN

#set_dont_touch_placement [all_macro_cells]

# Describe VDD and VSS used by the standard cell
derive_pg_connection \
	-power_net VDD \
	-power_pin VDD \
	-ground_net VSS \
	-ground_pin VSS

derive_pg_connection \
	-power_net VDD \
	-power_pin VDD12I \
	-ground_net VSS \
	-ground_pin VSSIP

derive_pg_connection \
	-power_net VDD_12I \
	-power_pin VDD_12I 
#******************************************************************************
# Memory P/G ring
#set_fp_rail_region_constraints \
#	-polygon {{533.180 700.495} {533.180 485.855} {627.370 485.855} {627.370 700.495}}

#create_fp_group_block_ring \
#	-nets  {$MW_R_POWER_NET $MW_R_GROUND_NET} \
#	-horizontal_ring_layer MET3
#	-horizontal_ring_offset 5
#	-horizontal_ring_width 5
#	-vertical_ring_layer MET4
#	-vertical_ring_offset 5
#	-vertical_ring_width 5
#	-horizontal_strap_layer MET3
#	-horizontal_strap_width 5
#	-vertical_strap_layer MET4
#	-vertical_strap_width 5
#	-output_directory ./pns_outputs

#commit_fp_group_block_ring
#preroute_instances  -ignore_pads -ignore_cover_cells -primary_routing_layer pin
#******************************************************************************
#******************************************************************************
# power rail (strap)
set_fp_rail_constraints \
	-add_layer -layer MET5 -direction horizontal \
	-max_strap 50 -min_strap 16 -max_width 3 -min_width 0.200 \
	-spacing minimum

set_fp_rail_constraints \
	-add_layer  -layer MET6 -direction vertical \
	-max_strap 50 -min_strap 16 -max_width 3 -min_width 0.440 \
	-spacing minimum

set_fp_rail_region_constraints \
	-polygon {{169.070 1035.925} {169.070 172.595} {1019.810 172.595} {1019.810 1035.925}}

set_fp_rail_constraints  -set_ring -nets {VDD VSS} \
	-horizontal_ring_layer { MET3 } -vertical_ring_layer { MET4 }

set_fp_rail_constraints -set_global -no_routing_over_hard_macros

synthesize_fp_rail \
	-nets {VDD VSS} -voltage_supply 1.35 \
	-synthesize_power_plan -power_budget 350 -pad_masters {  vdd12ih_p vssiph_p  }

commit_fp_rail
#******************************************************************************

# creates power ring
# power rings help all macro cells to be supplied voltage.

create_rectangular_rings \
	-nets {VDD_12I} \
	-left_offset 25 -left_segment_layer MET5 -left_segment_width 1 \
	-right_offset 25 -right_segment_layer MET5 -right_segment_width 1 \
	-bottom_offset 25 -bottom_segment_layer MET6 -bottom_segment_width 1 \
	-top_offset 15 -top_segment_layer MET6 -top_segment_width 1 

# additional power net robustness
#******************************************************************************
# Note Voltage noise induced by inductance
#
# In Reality, current flows in loops. In this case, we only deal in terms of power,
# not fast-switching signal, such as clock. We use wide, thick, upper-level metal
# because of preventing IC Chip from IR-Drop. (The  wider and thicker metal, the less resistance)
# In addition, in order to minimize the effect of IR-Drop, Designers frequently
# draw power lines by shape of mesh. However, this shape make a plethora of loops which yield
# producing or changing magnetic fields.
# (If there is return path of currents, metals have inductance)
# Changing magnetic fields in turn current in other loops(mutual inductive coupling).
# Inductance take a toll on delay and power. (Even if resistance is 0,
# delay(edge rates) would not 0 since resonant factor(LC) is existed.)
# In power case, when turning on chips voltage will switch simultaneously and flow substantial
# currents.(A role of Power PAD is also impact on it since most of PADs tend to charge quickly)
# By following the formula of V_drop = L*di/dt, Simultaneously Switching leads to Voltage change
# which is often called 'Ground Bounce' or 'Inductive voltage noise'. Granted, most of PADs have
# preventing these phenomenons but we should care about it.
#
# Return to our design, we placed mesh power straps for the sake of effective supplying voltage.
# Moreover, given aforementioned risk, we placed straps at moderate intervals.
# (The effect of mutual inductive coupling is greatly increasing especially when the return path
# is far from conductor.)
#******************************************************************************
create_fp_placement -timing_driven -no_hierarchy_gravity

# route_guide
#create_route_guide \
	-name route_guide_0 \
	-no_signal_layers {MET4 MET5 MET6} \
	-preferred_direction_only_layers {MET1 MET2 MET3} \
	-coordinate {{1540.710 1820.910} {1640.710 2020.510}} -no_snap

# connect P/G (I/O STD)
set_preroute_drc_strategy  -treat_fat_blockage_as_fat_wire  -min_layer MET1  -max_layer MET6
preroute_instances  -ignore_macros -primary_routing_layer pin
preroute_standard_cells \
	-connect horizontal -skip_macro_pins -skip_pad_pins  -remove_floating_pieces \
	-do_not_route_over_macros \
	-port_filter_mode off \
	-cell_master_filter_mode off \
	-cell_instance_filter_mode off \
	-voltage_area_filter_mode off \
	-route_type {P/G Std. Cell Pin Conn}
preroute_instances  -ignore_macros -ignore_cover_cells \
	-select_net_by_type specified \
	-nets  {VDD_12I}
verify_pg_nets  -error_cell test

# short checking 
set_pnet_options -partial "MET2 MET3 MET4 MET5 MET6"

# legalize
# To resolve cell placement conflicts after doing initial placement, such as violating Standard(STD)
# cells away from the power straps, overlaps, legalize placement.
# command "legalize_fp_placement" is obsolete
legalize_placement


# Perform actual global routing to make sure the congestion
route_zrt_global
report_congestion -grc_based -by_layer -routing_stage global

# Perform global route congestion map analysis from the GUI (no need to "Reload)
# Perform timing analysis

# Save
change_names -rule verilog -hier
set verilogout_no_tri true
save_mw_cel -as ${TOP_MODULE}

# close lib
close_mw_lib

# Reset sdc file for applying sdc
sh rm -f $FUNC1_SDC
sh cp ${FUNC1_SDC}.bak ${FUNC1_SDC}

exit
