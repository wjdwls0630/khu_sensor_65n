echo "------------------------------------------------------------------------"
echo "--                                                                    --"
echo "--                                                                    --"
echo "--                    khu_sensor_65n compile start                    --"
echo "--                                                                    --"
echo "--                                                                    --"
echo "------------------------------------------------------------------------"
##########################################################################################
##
## Create Operating_Conditions
##
##########################################################################################
#########################   DO NOT CHANGE BELOW THIS LINE   ##############################
##########################################################################################
# Samsung 65nm
# Dual Vth (Sign-off Corner, no need Multi-VDD)
# Logic Synthesis & Pre-STA (1st Sign-off)
# RVT: SS 1.08V 125c - WIRE Zero Wire Load Model
# HVT: SS 1.08V 125c - WIRE Zero Wire Load Model

remove_design -all
# source the common_setup & Common variables file
source -echo -v ./dc_scripts/user_scripts/user_design_setup.tcl
source -echo -v ./dc_scripts/common_lib_setup.tcl

set_svf $SVF_DIR/$TOP_MODULE.svf

source ./dc_scripts/00_read_global_reset.tcl
source ./dc_scripts/01_read_designs.tcl


# Apply constraints
source ./dc_scripts/02_constraints.tcl

# Define Group Paths
set ports_clock_root [get_ports [all_fanout -flat -clock_tree -level 0]]
group_path -name REGOUT -to [all_outputs]
group_path -name REGIN -from [remove_from_collection [all_inputs] $ports_clock_root]
group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] $ports_clock_root] -to [all_outputs]

source ./dc_scripts/03_compile_ultra.tcl
source ./dc_scripts/04_retime.tcl

source ./dc_scripts/05_gate_clock.tcl
source ./dc_scripts/06_design_finish.tcl
start_gui
#exit
