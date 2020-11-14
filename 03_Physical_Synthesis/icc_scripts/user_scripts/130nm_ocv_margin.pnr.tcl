#******************************************************************************
#**                     130nm_ocv_margin.pnr.tcl                             **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                   130nm_ocv_margin.pnr.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# Start of user specification
# Define setup/hold margin

set JITTER_MARGIN         "0.03"  ;# Define the value as %.
                                   ;# example) CS6 has 3% (0.03) for jitter margin.
                                   ;# If clock period is 5ns, margin is 150ps.
set PRE_CTS_SETUP_MARGIN  "0.02"   ;# Define the value as %.
                                   ;# example) 0.02 means 2% of clock period.
                                   ;# If clock period is 5ns, margin is 100ps.
                                   ;# During implementation, this value is added in jitter margin.
                                   ;# Therefore, total margin will be 5% (250ps) in this example.
set POST_CTS_SETUP_MARGIN "0.01"   ;# Define the value as %.
                                   ;# example) 0.01 means 1% of clock period.
                                   ;# If clock period is 5ns, margin is 50ps.
                                   ;# During implementation, this value is added in jitter margin.
                                   ;# Therefore, total margin will be 4% (200ps) in this example.
set USER_HOLD_MARGIN      "0.05"   ;# Define the value as ns.
                                   ;# example) 0.05 means 50ps margin.
set CoreIP_HOLD_MARGIN		  "0.125"
set	FF_WST_HOLD_MARGIN      "0.240"
set FF_BST_HOLD_MARGIN      "0.090"

# Define max transition time
# In real case, actual input slopes do not reach maximum slew rate almost case.
# Thus, we should circumscribe max transition time that is shorter than library max transition time
set WST_MAX_TRAN        "1.0"    ;# library value is 2.250
set BST_MAX_TRAN        "0.8"    ;# library value is 1.131

####### Define max length

set MAX_LENGTH    "800"            ;# value | none, define max length for signal

# derating factors @ WST/WSTTI corners
#
# The followings are Sign-Off OCV margin.
# You must confirm bellow OCV values with designer.
# Refer to example value below : Without powergating, WC PVT - SS/1.05V/125
#                                BC PVT - FF/1.35V/-40, Peak IR-Drop : 50mV

set _derate(wst,late,data)          1.144
set _derate(wst,late,clock)	        1.065
set _derate(wst,early)   			    0.990


#
### The followings are PnR OCV margin. This is automatically generated by above values.
#
set _derate_pnr(wst,late,data)      [expr $_derate(wst,late,data) ]
set _derate_pnr(wst,late,clock)     [expr $_derate(wst,late,clock)]
set _derate_pnr(wst,early)   			[expr $_derate(wst,early)  - 0.065]

# derating factors @ BST/BSTTI corners
#
# The followings are Sign-Off OCV margin.
# You must confirm bellow OCV values with designer.
#

set _derate(bst,late)          1.075

#
# The followings are PnR OCV margin. This is automatically generated by above values.
#
set _derate_pnr(bst,late)     [expr $_derate(bst,late)   + 0.065]
###########################################################################

foreach scenario [all_active_scenarios] {

  current_scenario $scenario
  #******************************************************************************# -----------------------------------------------------------------------
  # Apply additional setup/hold margin

  set clock_info ./reports/report_clock.txt

  if { [file exist $clock_info] } {

    set min_period 999999
    set rpt_clk_info [open $clock_info r]
    set clk_list [split [read $rpt_clk_info] "\n"]
    set current_step [get_object_name [current_mw_lib]]

  } else {
    set clock_info $REPORTS_DIR/report_clock.txt
    report_clock
    set rpt_clk_info [open $clock_info w]
    set rpt_clk_info [open $clock_info a]
    foreach_in_collection _clock [all_clocks] {
        set _period [get_attribute $_clock period]
        set _name   [get_attribute $_clock name]
        puts $rpt_clk_info "$_name $_period"
    }
    close $rpt_clk_info

    set min_period 999999
    set rpt_clk_info [open $clock_info r]
    set clk_list [split [read $rpt_clk_info] "\n"]
    set current_step [get_object_name [current_mw_lib]]

  }

  if { [regexp _clock_  $current_step] || \
       [regexp _route_  $current_step] || \
       [regexp _shield_ $current_step] || \
       [regexp _chip_   $current_step] || \
       [regexp eco      $current_step] } {

    foreach clk $clk_list {
      if { $clk != "" } {
        set clock  [lindex $clk 0]
        set period [lindex $clk 1]
        set jitter_m [expr $period * $JITTER_MARGIN ]
        set user_m   [expr $period * $POST_CTS_SETUP_MARGIN ]
        set uncert [expr $jitter_m + $user_m ]
        if { $uncert > 2.0 } {
          set uncert 2.0
        }
        set_clock_uncertainty -setup $uncert $clock
      # Default hold margin : $CoreIP_HOLD_MARGIN(from EC.JUN)
      set hold_m	[expr $USER_HOLD_MARGIN + $CoreIP_HOLD_MARGIN]
        set_clock_uncertainty -hold $hold_m $clock
        if { $period < $min_period } {
          set min_period $period
        }
      }
    }

  } else {

    foreach clk $clk_list {
      if { $clk != "" } {
        set clock  [lindex $clk 0]
        set period [lindex $clk 1]
        set jitter_m [expr $period * $JITTER_MARGIN ]
        set user_m   [expr $period * $PRE_CTS_SETUP_MARGIN ]
        set uncert [expr $jitter_m + $user_m ]
        if { $uncert > 2.0 } {
          set uncert 2.0
        }
        set_clock_uncertainty -setup $uncert $clock
        # Default hold margin : $CoreIP_HOLD_MARGIN
        set hold_m	[expr $USER_HOLD_MARGIN + $CoreIP_HOLD_MARGIN]
        set_clock_uncertainty -hold $hold_m $clock
        if { $period < $min_period } {
          set min_period $period
        }
      }
     }
  }

  # OCV margin and MAX_TRAN
  set corner [lindex [split $scenario _] 1]

  if { [string match "*wst*" $corner] == 1 } {
    set_max_transition $WST_MAX_TRAN [current_design]

    set_timing_derate -late  -data  $_derate_pnr(wst,late,data)
    set_timing_derate -late  -clock $_derate_pnr(wst,late,clock)
    set_timing_derate -early 		$_derate_pnr(wst,early)

    set wst_lib      [get_libs -quiet ${STD_WST}.db:${STD_WST}]
    if {[sizeof $wst_lib] > 0 } {
      foreach wstlib [get_object_name $wst_lib] {
        if { [string match "*wst*" $wstlib] == 1 } {
          set_timing_derate -late  -data -cell_delay $_derate_pnr(wst,late,data)  $wstlib/*
          set_timing_derate -late  -clock -cell_delay $_derate_pnr(wst,late,clock)  $wstlib/*
          set_timing_derate -early -cell_delay $_derate_pnr(wst,early)  $wstlib/*
        }
      }
    }

    # CP F/F Fixed Hold Margin
    set FF [filter_collection [all_register] "ref_name =~ f*_hd"]
    if {[sizeof $FF] > 0} {
      foreach ff_cell [get_object_name $FF] {
        set_clock_uncertainty -hold $FF_WST_HOLD_MARGIN [get_pins -of $ff_cell -filter "lib_pin_name =~ *CK* || lib_pin_name =~ G*"]
      }
    }

    set hm_cells  [get_cells -quiet -hier -filter "is_hard_macro == true"]
    if {[sizeof $hm_cells] > 0 } {
      set_clock_uncertainty -hold $CoreIP_HOLD_MARGIN [get_pins -of $hm_cells -filter "lib_pin_name =~ *CK* || lib_pin_name =~ *CLK*"]
    }

  } elseif { [string match "*bst*" $corner] == 1 } {
    set_max_transition $bST_MAX_TRAN [current_design]

    set_timing_derate -late  $_derate_pnr(bst,late)
    set bst_lib      [get_libs -quiet ${STD_BST}]
    if {[sizeof $bst_lib] > 0 } {
      foreach bstlib [get_object_name $bst_lib] {
        if { [string match "*bst*" $bstlib] == 1 } {
          set_timing_derate -late -cell_delay $_derate_pnr(bst,late)  $bstlib/*

        }
      }
    }
    # CP F/F Fixed Hold Margin
    set FF [filter_collection [all_register] "ref_name =~ f*_hd"]
    if {[sizeof $FF] > 0} {
      foreach ff_cell [get_object_name $FF] {
        set_clock_uncertainty -hold $FF_BST_HOLD_MARGIN [get_pins -of $ff_cell -filter "lib_pin_name =~ *CK* || lib_pin_name =~ G*"]
      }
    }

    set hm_cells  [get_cells -quiet -hier -filter "is_hard_macro == true"]
    if {[sizeof $hm_cells] > 0 } {
      set_clock_uncertainty -hold $CoreIP_HOLD_MARGIN [get_pins -of $hm_cells -filter "lib_pin_name =~ *CK* || lib_pin_name =~ *CLK*"]
    }
  }
  # Max Length

  if { $MAX_LENGTH != "none" } {
        set_max_net_length $MAX_LENGTH [current_design]
  }
}
