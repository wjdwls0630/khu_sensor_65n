#******************************************************************************
#**                           01_floorplan                                   **
#**                     floorplan and virtual placement                      **
#******************************************************************************

echo "***********************************************************************"
echo "                                                                       "
echo "                           01_floorplan.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "01_floorplan"

# source the user_design_setup & common_lib_setup
source -echo -v ./icc_scripts/user_scripts/user_design_setup.tcl
source -echo -v ./icc_scripts/common_lib_setup.tcl

# Clear existing mw library and re-make dir
set _mw_lib ./mw_db/${TOP_MODULE}_${step}
if {[file exist $_mw_lib]} {
	sh mv $_mw_lib ./mw_db/old/${TOP_MODULE}_${step}_${back}
}
copy_mw_lib -from ./mw_db/${TOP_MODULE}_00_read_design -to $_mw_lib

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
set_active_scenario $FLOORPLAN_SCN

# call pad place (.tdf)
source $ICC_IN_IO_CONST_FILE

create_floorplan -control_type boundary -start_first_row -flip_first_row \
-left_io2core $IO2L -bottom_io2core $IO2B -right_io2core $IO2R -top_io2core $IO2T \
-core_utilization $CORE_UTIL

# Add I/O Filler
insert_pad_filler -cell $IO_FILLER

# Define ignored layers
set_ignored_layers -max_routing_layer EA

#*******************************************************************************************
## NOTE for FloorPlan ######################################################################
#
##    ## IO adjustment using GUI
##    ##
##    ##
##
##    ## Fix analog IP / digital IP / memories placement in TOP.
##    ## You can use the command "set_dont_touch_placement" or GUI
##    ## Do not place and fix for block memories.
##    ##
##    ##
##
##    ## First, Do manual placement for hard macros excepting memories.
##    ## Then, Fix the hard macros after initial placement.
##
##    ## Then, Fix all memories.
##    if {[all_macro_cells] != "" } {
##         set_dont_touch_placement [all_macro_cells]
##    }
##
##    ## Physical Cells Placement
##    ## Add well edge cell
##    add_end_cap -respect_blockage -ignore_soft_blockage -lib_cell $WELL_EDGE_CELL
##
##    ## Add tap cell
##    add_tap_cell_array  -master_cell_name $TAP_CELL \
##              -pattern stagger_every_other_row \
##              -distance $TAP_DIST \
##              -ignore_soft_blockage true \
##              -skip_fixed_cells true
##
##    ## Save
##    sec_StartTimer saving
##    change_names -rule verilog -hier
##    set verilogout_no_tri true
##    save_mw_cel -as $TOP_MODULE
##    sec_ReportResourceUtil saving
##
##    ## Exit
##    sec_ReportResourceUtil total_$step
##    exit
#

# memory placement

#report_fp_strategy_ment
#set_fp_placement_strategy -sliver_size 10
#create_fp_placement -timing_driven -no_hierarchy_gravity
#report_congestion -grc_based -by_layer -routing_stage global

#Reducing cell density hotspots
#set_congestion_options -max_util 0.4 -cordinate {x1 y1 x2 y2}
#set_fp_placement_strategy \
#	-auto_grouping high \
#	-macros_on_edge on \
#	-sliver_size 10 \
#	-virtual_IPO on
#set_keepout_margin -type hard -all_macros -outer {10 10 10 10}
#create_fp_placement -timing_driven -no_hierarchy_gravity
#report_congestion -grc_based -by_layer -routing_stage global
#set_dont_touch_placement [all_macro_cells]
#set physopt_hard_keepout_distance 10
#*******************************************************************************************

# hard blockage for macro
# In case of hard, Any macro cannot place in an area of blockage.
# In case of soft, a few buffers can place in an area of blockage.
#create_placement_blockage -coordinate {{881.680 187.490} {1008.360 392.370}} \
   -name block_1 -type hard -no_snap

# Unplace all standard cells
remove_placement -object_type standard_cell

#*******************************************************************************************
# Physical Cells Placement
# Add well edge cell
add_end_cap -respect_blockage -ignore_soft_blockage -lib_cell $WELL_EDGE_CELL

#get_cells -all *cap*
#remove_cell [get_cells -all *cap*]

#Add tap cell
add_tap_cell_array  -master_cell_name $TAP_CELL \
	-pattern stagger_every_other_row \
  -distance $TAP_DIST \
	-ignore_soft_blockage true \
	-skip_fixed_cells true
#remove_stdcell_filler  -tap
#*******************************************************************************************

# Save
change_names -rule verilog -hier
set verilogout_no_tri true
save_mw_cel -as ${TOP_MODULE}

# close lib
close_mw_lib

#start_gui
exit
