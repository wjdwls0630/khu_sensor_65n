#******************************************************************************
#**                            08_chip_finish                                **
#**                       additional decap/filler                            **
#**                            DRC & LVS                                     **
#**            Extract Delay(.sdf) & Parasitic Output(.dspf)                 **
#**                      Extract Netlist(.v) & GDSII                         **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                       08_chip_finish.tcl                              "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "08_chip_finish"

# source the user_design_setup & common_lib_setup
source -echo -v ./icc_scripts/user_scripts/user_design_setup.tcl
source -echo -v ./icc_scripts/common_lib_setup.tcl

# Clear existing mw library and re-make dir
set _mw_lib ./mw_db/${TOP_MODULE}_${step}
if {[file exist $_mw_lib]} {
	sh mv $_mw_lib ./mw_db/old/${TOP_MODULE}_${step}_${back}
}
copy_mw_lib -from ./mw_db/${TOP_MODULE}_07_route_opt -to $_mw_lib

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

# After placement, delete max_delay constraints. It is only for placing
# clock gating cell and gated register in proximity.
source $ICC_SDC_SETUP_FILE

source $ICC_MCMM_SCENARIOS_FILE
set_active_scenario $CHIP_FINISH_SCN

# Optimization Common Session Options - set in all sessions
source ./icc_scripts/common_route_opt_env.tcl

#Source antenna rule
source $ANTENNA_RULE
report_antenna_rules

set_route_zrt_detail_options -antenna true

# Search & Repair
verify_zrt_route
route_zrt_detail -inc true -initial_drc_from_input true

# Error handle
# After P&R, please check an errors by Error Browser.
# In the Error Browser, check "Detail Route", and check errors.
# For antenna violation fixing, set renewed detail route option and routing again.
# Below lines, it is command for it.
# In some case, antenna violation cannot be fixed completely.
# If this is the case, the errors should be fixed manually by hop-up technique(in virtuoso)
#
# For short circuit, check detail one by one, if errors by a pin connection with custom modules or 
# a limitation of the library, the errors can be ignored. 
#
# For diff net spacing, check the pins connection, if errors by a pin connection with custom modules
# or a limitation of the library, the errors can be ignored. If not, the errors should be fixed by
# re-routing or handling manually(in virtuoso)

set_route_zrt_detail_options \
	-diode_libcell_names diode_cell_hd \
	-antenna_fixing_preference use_diodes

# Search & Repair
verify_zrt_route
route_zrt_detail -inc true -initial_drc_from_input true

# Connect Power & Grounding in extraction and update timing
derive_pg_connection -power_net $MW_R_POWER_NET -power_pin  $MW_POWER_PORT
derive_pg_connection -ground_net $MW_R_GROUND_NET -ground_pin $MW_GROUND_PORT
derive_pg_connection -power_net $MW_R_POWER_NET -ground_net $MW_R_GROUND_NET -tie

## Read scenario file
set_active_scenarios [lminus [all_scenarios] $CLOCK_OPT_CTS_SCN]

# Intermediate Save
# Use timing driven SnR.
set_route_zrt_global_options -timing_driven true
set_route_zrt_track_options  -timing_driven true
set_route_zrt_detail_options -timing_driven true
save_mw_cel
puts "SEC_INFO: CEL was saved. You can open CEL with read_only !!"

# Running extraction and updating the timing
extract_rc -coupling_cap
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
	-max_paths 20 -nets -input_pins \
	-physical -attributes -nosplit -derate -crosstalk_delta -derate -path full_clock_expanded
}
redirect -file $REPORTS_STEP_DIR/min_timing.rpt {
	report_timing -significant_digits 4 \
	-delay min -transition_time  -capacitance \
	-max_paths 20 -nets -input_pins \
	-physical -attributes -nosplit -crosstalk_delta -derate -path full_clock_expanded
}        
report_zrt_shield -with_ground $MW_R_GROUND_NET -output $REPORTS_STEP_DIR/shield_ratio.rpt 
report_clock_gating -style > $REPORTS_STEP_DIR/clock_gating.rpt
report_clock_gating_check -significant_digits 4 >> $REPORTS_STEP_DIR/clock_gating.rpt
report_clock_gating -structure >> $REPORTS_STEP_DIR/clock_gating.rpt
report_timing -max_paths 10 -to [get_pins -hierarchical "clk_gate*"] \
	> $REPORTS_STEP_DIR/clock_gating_max_paths.rpt
redirect -file $REPORTS_STEP_DIR/power.rpt {
 	report_power -verbose -analysis_effort high
}
# To verify CRPR
#redirect -file $REPORTS_DIR/${step}/crpr.rpt { report_crpr }
# delete "snapshot" directory called by create_qor_snapshot command
sh rm -rf snapshot/
# Save
change_names -rule verilog -hier
set verilogout_no_tri true
save_mw_cel -as ${TOP_MODULE}

# Check LVS
verify_lvs -max_error 500

# Write outputs

# insert extra cell (I/O Filler, STD Filler, decap)
# Decap
insert_stdcell_filler \
	-cell_with_metal $DECAP_FILLER \
	-ignore_soft_placement_blockage \
	-between_std_cells_only \
	-connect_to_power {VDD} -connect_to_ground {VSS}

# STD Filler
insert_stdcell_filler \
	-cell_without_metal $RVT_FILLER \
	-ignore_soft_placement_blockage \
	-between_std_cells_only \
	-connect_to_power {VDD} -connect_to_ground {VSS}

# I/O Filler
insert_pad_filler -cell $IO_FILLER

save_mw_cel -as ${TOP_MODULE}_Insert_Filler

write_verilog ./outputs/${TOP_MODULE}.vg \
	-no_corner_pad_cells -no_pad_filler_cells -diode_ports \
	-no_core_filler_cells -no_flip_chip_bump_cells -wire_declaration

write_verilog ./outputs/${TOP_MODULE}.sim.v \
	-no_corner_pad_cells -no_pad_filler_cells -diode_ports \
	-no_core_filler_cells -no_flip_chip_bump_cells -wire_declaration \
	-no_tap_cells -no_unconnected_cells

set_write_stream_options -child_depth 0 -map_layer $STREAM_OUT_MAP \
	-output_pin {geometry text} \
	-keep_data_type -max_name_length 128

write_stream -format gds -cells $TOP_MODULE ./outputs/${TOP_MODULE}.gds_depth0

set_write_stream_options -child_depth 30 -map_layer $STREAM_OUT_MAP \
	-output_pin {geometry text} \
	-keep_data_type -max_name_length 128

write_stream -format gds -cells $TOP_MODULE ./outputs/${TOP_MODULE}.gds_depth30

write_def -nondefault_rule -rows_tracks_gcells -vias -all_vias -components -pins -blockages \
	-regions_groups -specialnets -nets -diode_pins -output ./outputs/${TOP_MODULE}.def

write_sdf ./outputs/$TOP_MODULE.sdf
write_sdc ./outputs/$TOP_MODULE.sdc

extract_rc -coupling_cap 
write_parasitics -format SPEF -output ./outputs/${TOP_MODULE}.spef

remove_power_domain -all
ungroup -all -flatten -force
set_app_var verilogout_no_tri true
write_verilog -no_corner_pad_cells -no_pad_filler_cells -no_core_filler_cells \
	-no_flip_chip_bump_cells -no_cover_cells -diode_ports -output_net_name_for_tie \
	-pg_ports -no_tap_cells -no_chip_cells \
	-split_bus ./outputs/${TOP_MODULE}.lvs.v
start_gui
#exit
