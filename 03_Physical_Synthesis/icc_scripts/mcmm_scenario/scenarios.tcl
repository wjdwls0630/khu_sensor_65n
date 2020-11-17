##########################################################################################
##
## Create Scenarios
##
#########################   DO NOT CHANGE BELOW THIS LINE   ##############################
##########################################################################################

foreach scenario $scenarios {

  create_scenario $scenario

  set mode   [lindex [split $scenario _] 0]
  set corner [lindex [split $scenario _] 1]

  set auto_link_disable true

  # Source SDC
  switch $mode {
    func1    { source $FUNC1_SDC }
    func2    { source $FUNC2_SDC }
    scan1    { source $SCAN1_SDC }
    scan2    { source $SCAN2_SDC }
    bist1    { source $BIST1_SDC }
    bist2    { source $BIST2_SDC }
    jtag     { source $JTAG_SDC  }
    funccts  { source $FUNCCTS_SDC }
    scancts  { source $SCANCTS_SDC }
    bistcts  { source $BISTCTS_SDC }
    jtagcts  { source $JTAGCTS_SDC }
  }

  # Set Tlup Model
  if { [string match "*wst*" $corner] == 1 } {
    set_tlu_plus_files -max_tluplus $TLUP_MAX_FILE -min_tluplus $TLUP_MAX_FILE -tech2itf_map $MAP_FILE
  } elseif { [string match "*bst*" $corner] == 1 } {
    set_tlu_plus_files -max_tluplus $TLUP_MIN_FILE -min_tluplus $TLUP_MIN_FILE -tech2itf_map $MAP_FILE
  }
  echo "***********************************************************************"
  echo "                                                                       "
  echo "    Check consistency between the Milkyway library and the TLUPlus     "
  echo "                                                                       "
  echo "***********************************************************************"
  check_tlu_plus_files

  # Set operating conditions
  if { $corner == "wst" } {
    set_operating_conditions -analysis_type on_chip_variation \
      -max_library $OPCOND_WST_LIB -max $OPCOND_WST \
      -min_library $OPCOND_WST_LIB -min $OPCOND_WST

    set user_opcond "./icc_scripts/user_scripts/user_operation_conditions.tcl"
    if {[file exist $user_opcond]} {
      source $user_opcond
    }

  } elseif { $corner == "wstti" } {
    set_operating_conditions -analysis_type on_chip_variation \
      -max_library $OPCOND_WST_LIB_TIV -max $OPCOND_WST_TIV \
      -min_library $OPCOND_WST_LIB_TIV -min $OPCOND_WST_TIV

    set user_opcond "./icc_scripts/user_scripts/user_operation_conditions.tcl"
    if {[file exist $user_opcond]} {
      source $user_opcond
    }
  } elseif { $corner == "bst" } {
    set_operating_conditions -analysis_type on_chip_variation \
      -max_library $OPCOND_BST_LIB -max $OPCOND_BST \
      -min_library $OPCOND_BST_LIB -min $OPCOND_BST

    set user_opcond "./icc_scripts/user_scripts/user_operation_conditions.tcl"
    if {[file exist $user_opcond]} {
      source $user_opcond
    }

  } elseif { $corner == "bstti" } {
    set_operating_conditions -analysis_type on_chip_variation \
      -max_library $OPCOND_BST_LIB_TIV -max $OPCOND_BST_TIV \
      -min_library $OPCOND_BST_LIB_TIV -min $OPCOND_BST_TIV

    set user_opcond "./icc_scripts/user_scripts/user_operation_conditions.tcl"
    if {[file exist $user_opcond]} {
      source $user_opcond
    }
  }

  ## For area recovery
  set_max_area 0

  ## Define Group Paths
  set ports_clock_root [get_ports [all_fanout -flat -clock_tree -level 0]]
  group_path -name REGOUT -to [all_outputs]
  group_path -name REGIN -from [remove_from_collection [all_inputs] $ports_clock_root]
  group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] $ports_clock_root] -to [all_outputs]

  ## Get clock information to apply additional margin
  set clock_info $REPORTS_DIR/${scenario}_report_clock.txt
  report_clock
  set rpt_clk_info [open $clock_info w]
  set rpt_clk_info [open $clock_info a]
  foreach_in_collection _clock [all_clocks] {
    set _period [get_attribute $_clock period]
    set _name   [get_attribute $_clock name]
    puts $rpt_clk_info "$_name $_period"
  }
  close $rpt_clk_info

  set auto_link_disable false
}
