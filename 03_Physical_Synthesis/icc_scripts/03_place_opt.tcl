#******************************************************************************
#**                           03_place_opt                                   **
#**                    Placement and Optimization                            **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                           03_place_opt.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "03_place_opt"

# source the user_design_setup & common_lib_setup
source -echo -v ./icc_scripts/user_scripts/user_design_setup.tcl
source -echo -v ./icc_scripts/common_lib_setup.tcl

# Clear existing mw library and re-make dir
set _mw_lib ./mw_db/${TOP_MODULE}_${step}
if {[file exist $_mw_lib]} {
	sh mv $_mw_lib ./mw_db/old/${TOP_MODULE}_${step}_${back}
}
copy_mw_lib -from ./mw_db/${TOP_MODULE}_02_powerplan -to $_mw_lib

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

source $ICC_MCMM_SCENARIOS_FILE
set_active_scenario $PLACE_OPT_SCN


#Fixing the locations of the hard macros
if { [all_macro_cells] != "" } {
  set_dont_touch_placement [all_macro_cells]
}

#Inout optimization
if { !$INOUT_OPT } {
	set_false_path -from [all_inputs]
	set_false_path -to [all_outputs]
}

# Optimization Common Session Options - set in all sessions
source ./icc_scripts/common_place_opt_env.tcl

source ./icc_scripts/rules/shield_65nm_rule.tcl

set_clock_tree_options -clock_trees [all_clocks] \
	-routing_rule shield_65nm_rule -layer_list "M3 B2"


# Unplace all standard cells except for tap and well_edge cells
remove_placement -object_type standard_cell

# Improved congestion analysis by using Global Route info
if { $GL_BASED_PLACE } {
	set placer_enable_enhanced_router true
	set placer_enable_high_effort_congestion true
} else {
	set placer_enable_enhanced_router false
	set placer_enable_high_effort_congestion false
}
# Placement Optimization
if {$LEAKAGE_POWER_PLACE} {
	#Optimize Power
	if {$ICC_STRATEGY == "ttr" } {
		place_opt -effort low -power
	}
	if {$ICC_STRATEGY == "qor" } {
    place_opt -congestion -area_recovery -effort $qor_effort -power
  }
} else {
	#Default place_opt
	if {$ICC_STRATEGY == "ttr" } {
		place_opt -effort low
	}
	if {$ICC_STRATEGY == "qor" } {
		place_opt -congestion -area_recovery -effort $qor_effort
  }
}

# Connect Power & Grounding in extraction and update timing
derive_pg_connection -power_net $MW_R_POWER_NET -power_pin  $MW_POWER_PORT
derive_pg_connection -ground_net $MW_R_GROUND_NET -ground_pin $MW_GROUND_PORT
derive_pg_connection -power_net $MW_R_POWER_NET -ground_net $MW_R_GROUND_NET -tie

# Generate global zroute based congestion map
if { $GEN_GL_CONG_MAP } {
	route_zrt_global -congestion_map_only true -effort ultra
}

# Running extraction and updating the timing
extract_rc
update_timing

# Report
set REPORTS_STEP_DIR $REPORTS_DIR/${step}
if {[file exist $REPORTS_STEP_DIR]} {
	sh rm -rf $REPORTS_STEP_DIR
}
sh mkdir $REPORTS_STEP_DIR

set legalize_support_phys_only_cell true
create_qor_snapshot -show_all -significant_digits 4 -name $step
redirect -file $REPORTS_STEP_DIR/snap.rpt \
	{ report_qor_snapshot -name $step -save_as snap.rpt }
redirect -file $REPORTS_STEP_DIR/hfn.rpt { report_net_fanout -threshold 100 }
redirect -file $REPORTS_STEP_DIR/qor.rpt -tee \
	{ report_qor -scenario [all_scenarios] -significant_digits 4 }
redirect -file $REPORTS_STEP_DIR/physical.sum -tee { report_design -physical -nosplit }
redirect -file $REPORTS_STEP_DIR/vth_use.rpt -tee { report_threshold_voltage_group }
redirect -file $REPORTS_STEP_DIR/check_legality { check_legality -verbose }
redirect -file $REPORTS_STEP_DIR/constraints.rpt { report_constraint \
	-scenario [all_scenarios] -all_violators -nosplit -significant_digits 4 }
redirect -file $REPORTS_STEP_DIR/max_timing.rpt {
	report_timing -significant_digits 4 \
	-delay max -transition_time  -capacitance \
	-max_paths 20 -nets -input_pins -slack_greater_than 0.0 \
	-physical -attributes -nosplit -derate
}
redirect -file $REPORTS_STEP_DIR/min_timing.rpt {
	report_timing -significant_digits 4 \
	-delay min -transition_time  -capacitance \
	-max_paths 20 -nets -input_pins \
	-physical -attributes -nosplit -crosstalk_delta -derate -path full_clock_expanded
}
report_clock_gating -style > $REPORTS_STEP_DIR/clock_gating.rpt
report_clock_gating_check -significant_digits 4 >> $REPORTS_STEP_DIR/clock_gating.rpt
report_clock_gating -structure >> $REPORTS_STEP_DIR/clock_gating.rpt
report_timing -max_paths 10 -to [get_pins -hierarchical "clk_gate*"] \
	> $REPORTS_STEP_DIR/clock_gating_max_paths.rpt
# delete "snapshot" directory called by create_qor_snapshot command
sh rm -rf snapshot/

# Save
change_names -rule verilog -hier
set verilogout_no_tri true
save_mw_cel -as ${TOP_MODULE}

# close lib
close_mw_lib

exit
