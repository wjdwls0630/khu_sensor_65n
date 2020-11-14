#******************************************************************************
#**                  common route optimization settings                      **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                      common_route_opt_env.tcl                         "
echo "                                                                       "
echo "***********************************************************************"

# For zroute
set_route_mode_options -zroute true

# common options
set_route_zrt_common_options -connect_within_pins { {MET1 via_wire_standard_cell_pins} }
set_route_zrt_common_options -wide_macro_pin_as_fat_wire true
set_route_zrt_common_options -concurrent_redundant_via_mode reserve_space

# global options
set_route_zrt_global_options \
	-timing_driven true \
	-crosstalk_driven true

# track options
set_route_zrt_track_options  \
	-timing_driven true \
	-crosstalk_driven true

# detail options
set_route_zrt_detail_options \
	-use_default_width_for_min_area_min_len_stub true \
	-repair_shorts_over_macros_effort_level low \
	-antenna false \
	-timing_driven true

# Crosstalk options
set_route_opt_zrt_crosstalk_options -default true

# SI options
set_si_options -delta_delay true -static_noise true \
	-static_noise_threshold_above_low 0.35 \
	-static_noise_threshold_below_high 0.35 \
	-min_delta_delay true \
	-route_xtalk_prevention true \
	-route_xtalk_prevention_threshold 0.25 \
	-max_transition_mode total_slew

# Set Min/Max Routing Layers
set_ignored_layers -rc_congestion_ignored_layers {MET5 MET6}

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
set enable_recovery_removal_arcs true

# CRPR Clock Reconvergence Pessimism Removal
# In post-layout STA, clock reconvergence pessimism resulting
# from crosstalk delta delay is removed only if precisely the same clock
# edge drives both the launch and capture devices. (hold check)
# Setuput check which has 1 or more clock cycle will be done without
# CRPR induced by x-talk
set timing_remove_clock_reconvergence_pessimism true

# Congestion options
set_congestion_options -max_util 0.75

# MCMM capacity setting
set mcmm_enable_high_capacity_flow TRUE

# Route options
set psyn_onroute_disable_fanout_drc true
set route_opt_enable_blocked_region_buffer true

# Delay calculation
# By default, ICC uses the Elmore delay model for both preroute and postroute delay calculation.
# Notwithstanding that the Elmore delay is faster, its result do not always
# correlate with PrimeTime. The Arnoldi model is more exact, but more runtime and memory.
# For best QoR, the Arnoldi model is better during CTS.
set_delay_calculation -arnoldi_effort high 

# Handy Naming Convention for new cels added
set compile_instance_name_prefix icc_place

# Added
set timing_separate_clock_gating_group true
set timing_scgc_override_library_setup_hold false
set physopt_delete_unloaded_cells false
set_separate_process_options -placement false
set_separate_process_options -routing false
set_separate_process_options -extraction false

# Apply ocv margin
source ./icc_scripts/user_scripts/130nm_ocv_margin.pnr.tcl
