#******************************************************************************
#**         common clock optimization in post-CTS stage settings             **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                 common_clock_opt_post_cts_env.tcl                     "
echo "                                                                       "
echo "***********************************************************************"

# Set Min/Max Routing Layers
set_ignored_layers -rc_congestion_ignored_layers {LB}

if { $MAX_ROUTING_LAYER != ""} {set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER}
if { $MIN_ROUTING_LAYER != ""} {set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER}

# Timing env setting
set timing_enable_multiple_clocks_per_reg true
set timing_enable_non_sequential_checks true
set case_analysis_with_logic_constants true
set disable_auto_time_borrow false
set_fix_multiple_port_nets -all -buffer_constants [all_designs]
set_auto_disable_drc_nets -constant false
set timing_input_port_default_clock true

# Congestion options
set_congestion_options -max_util 0.75

# MCMM capacity setting
set mcmm_enable_high_capacity_flow TRUE

# HFNS Options
set_ahfs_options -constant_nets true

# Handy Naming Convention for new cells added
set compile_instance_name_prefix icc_cpts

# Added
set timing_separate_clock_gating_group true
set timing_scgc_override_library_setup_hold false
set physopt_delete_unloaded_cells false
set_separate_process_options -placement false
set_separate_process_options -routing false
set_separate_process_options -extraction false

# Apply ocv margin
source ./icc_scripts/user_scripts/65nm_ocv_margin.pnr.tcl

# Delay calculation
# By default, ICC uses the Elmore delay model for both preroute and postroute delay calculation.
# Notwithstanding that the Elmore delay is faster, its result do not always
# correlate with PrimeTime. The Arnoldi model is more exact, but more runtime and memory.
# For best QoR, the Arnoldi model is better during CTS.
set_delay_calculation -arnoldi_effort high
