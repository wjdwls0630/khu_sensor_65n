#******************************************************************************
#**                           04_clock_opt_cts                               **
#**                          Clock Tree Synthesis                            **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                       04_clock_opt_cts.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "04_clock_opt_cts"

# source the user_design_setup & common_lib_setup
source -echo -v ./icc_scripts/user_scripts/user_design_setup.tcl
source -echo -v ./icc_scripts/common_lib_setup.tcl

# Clear existing mw library and re-make dir
set _mw_lib ./mw_db/${TOP_MODULE}_${step}
if {[file exist $_mw_lib]} {
	sh mv $_mw_lib ./mw_db/old/${TOP_MODULE}_${step}_${back}
}
copy_mw_lib -from ./mw_db/${TOP_MODULE}_03_place_opt -to $_mw_lib

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

## Read scenario file
#sh sed -i '/set_max_fanout/d' $FUNC1_SDC
sh sed -i 's/ ${STD_WST}/ ${STD_WST}.db:${STD_WST}/' $FUNC1_SDC
if { $CLOCK_OPT_CTS_SCN_READ_AGAIN } {
	remove_sdc
	remove_scenario -all
	source $ICC_MCMM_SCENARIOS_FILE
}
set_active_scenario $CLOCK_OPT_CTS_SCN

#******************************************************************************
# Note Checklist prior to CTS
# 1. Placement must be finished clearly.
# 2. Verify P/G nets are prerouted properly.
# 3. Verify Congestion value. Congestion value must be lower than 4.
# 4. After placement, the ideal situaltion is that there is no timing violation.
# If it has, it may be okay, but not recommend.
# 5. Check your high fan out nets (hfn)
#******************************************************************************

# Optimization Common Session Options - set in all sessions
source ./icc_scripts/common_clock_opt_cts_env.tcl

# Improved congestion analysis by using Global Route info
if { $GL_BASED_PLACE } {
	set placer_enable_enhanced_router true
	set placer_enable_high_effort_congestion true
} else {
	set placer_enable_enhanced_router false
	set placer_enable_high_effort_congestion false
}

# CTS
foreach cts_mode_scenario $CLOCK_OPT_CTS_SCN {
	# Set CTS scenario
	current_scenario    $cts_mode_scenario
	set_scenario_options -cts_mode true -cts_corner max -scenario $cts_mode_scenario

	# Naming prefix
	set cts_instance_name_prefix CTS_${cts_mode_scenario}_

	# Variables
	set cts_fix_drc_beyond_exceptions true
	set cts_fix_drc_on_data true
	set cts_upsize_for_drc_beyond_exception true
	set cts_remove_buffers_inserted_by_fixing_drc false

	# Source shielding rule
	source ./icc_scripts/rules/shield_130nm_rule.tcl

	# CTS options
	set_clock_tree_options \
		-max_transition $CLOCK_MAX_TRAN \
		-ocv_clustering true \
		-gate_sizing true \
		-routing_rule $ICC_CTS_RULE_NAME \
		-use_default_routing_for_sinks 1

	# Run CTS
	clock_opt -only_cts -no_clock_route

	# To do inter clock balancing
	if { $INTER_CLK_GROUPS != "" } {
		foreach balance_clock $INTER_CLK_GROUPS {
			balance_inter_clock_delay -clock_trees "$balance_clock"
		}
	}
	# set dont touch on clock tree
	set_clock_tree_exception \
		-dont_touch_subtrees [remove_from_collection [all_fanout -flat -clock_tree] [get_ports [all_outputs]]]

	# Source shielding rule
	mark_clock_tree -clock_synthesized -fix_sinks \
		-routing_rule $ICC_CTS_RULE_NAME -use_default_routing_for_sinks 1

	# Report
	set REPORTS_STEP_DIR $REPORTS_DIR/${step}
	if { ![file exist $REPORTS_STEP_DIR] } {
		sh mkdir $REPORTS_STEP_DIR
	}
	if {[file exist $REPORTS_DIR/${step}/${cts_mode_scenario}]} {
		sh rm -rf $REPORTS_DIR/${step}/${cts_mode_scenario}
	}
	sh mkdir $REPORTS_DIR/${step}/${cts_mode_scenario}
	
	redirect -file $REPORTS_DIR/${step}/${cts_mode_scenario}/clock_tree_settings   {report_clock_tree -settings}
	redirect -file $REPORTS_DIR/${step}/${cts_mode_scenario}/clock_tree_exceptions {report_clock_tree -exceptions}
	redirect -file $REPORTS_DIR/${step}/${cts_mode_scenario}/skew                  {report_clock_tree}
	redirect -file $REPORTS_DIR/${step}/${cts_mode_scenario}/skew.summary          {report_clock_tree -summary}
	redirect -file $REPORTS_DIR/${step}/${cts_mode_scenario}/clock_structure       {report_clock_tree -structure}

	# save cell after each mode CTS
	save_mw_cel -as ${cts_mode_scenario}_cts_fin

	set_scenario_options -cts_mode false -cts_corner max -scenario $cts_mode_scenario
}

# Connect Power & Grounding in extraction and update timing
derive_pg_connection -power_net  $MW_R_POWER_NET    -power_pin  $MW_POWER_PORT
derive_pg_connection -ground_net $MW_R_GROUND_NET   -ground_pin $MW_GROUND_PORT
derive_pg_connection -power_net  $MW_R_POWER_NET    -ground_net $MW_R_GROUND_NET -tie

# Running extraction and updating the timing
extract_rc
update_timing

# Final reporting after all CTS
foreach cts_mode_scenario $CLOCK_OPT_CTS_SCN {
	# Set CTS scenario
	current_scenario    $cts_mode_scenario
	set_scenario_options -cts_mode true -cts_corner max

	# Report
	redirect -file $REPORTS_DIR/${step}/${cts_mode_scenario}/skew.final          {report_clock_tree}
	redirect -file $REPORTS_DIR/${step}/${cts_mode_scenario}/skew.summary.final  {report_clock_tree -summary}
}

# Remove all clock tree exceptions after CTS
remove_clock_tree_exceptions -all

# dump shieldin net list
report_net_routing_rules [get_flat_nets *] -output $REPORTS_DIR/shielding_nets.dump

# Report

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
	-max_paths 100 -nets -input_pins -slack_greater_than 0.0 \
	-physical -attributes -nosplit -derate -crosstalk_delta -derate -path full_clock_expanded
}
redirect -file $REPORTS_STEP_DIR/min_timing.rpt {
	report_timing -significant_digits 4 \
	-delay min -transition_time  -capacitance \
	-max_paths 100 -nets -input_pins \
	-physical -attributes -nosplit -crosstalk_delta -derate -path full_clock_expanded
}
# delete "snapshot" directory called by create_qor_snapshot command
sh rm -rf snapshot/



#******************************************************************************
# Note Checklist after CTS
# 1. Check Timing Violation.
# 2. Verify Congestion value. Congestion value must be lower than 4.
# 3. View Clock Tree.
# 4. Check report file of cts.
#******************************************************************************

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
