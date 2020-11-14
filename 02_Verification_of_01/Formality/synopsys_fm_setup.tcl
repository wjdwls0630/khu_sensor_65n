echo "***********************************************************************"
echo "                                                                       "
echo "                     synopsys_fm_setup.tcl                             "
echo "                                                                       "
echo "***********************************************************************"

# Remove all libraries and containers before starting new verification
remove_library   -all
remove_container -all

#******************************************************************************
#                       set basic parameter                                  **
#******************************************************************************
set designer "Man"
set company "KHU Room327"
# Define path directories for file locations
set dc "../Design_Compiler/"
set src_path "${dc}src/"
set tcl_path "./tcl/"
set log_path "./log/"
set ddc_path "${dc}ddc/"
set netlist_path "${dc}netlist/"
set svf_path "${dc}svf/"
#******************************************************************************

#******************************************************************************
#**                         Set Library Parameter                            **
#******************************************************************************
# set env(SEC_SYNOPSYS)  <installed_synopsys_dk_path>
# set env(SEC_FM)       $env(SEC_SYNOPSYS)/formality
set env(SEC_SYNOPSYS) /Tools/Library/samsung013/sec050915_0050_STD150E_regular_DK_Synopsys_N/sec150e_synopsys
set env(SEC_FM) $env(SEC_SYNOPSYS)/formality
set env(synopsys_root) /Tools/Synopsys/DesignCompiler
#******************************************************************************
#**                Read technology library and udc files                     **
#******************************************************************************
set dk_home [getenv SEC_SYNOPSYS]
set sy_home [getenv synopsys_root]
# Reference/Front_End/samsung013/sec150e_synopsys/readme/SynopsysDKGuide.pdf p.14

# Typical (TT / 1.20V / 25 Celcius)
set STD_TYP std150e_typ_120_p025
set STD_TYP_MEM std150e_typ_120_p025_memory

# Worst (SS / 1.05V / 125 Celcius)
set STD_WST std150e_wst_105_p125

# Best (FF / 1.35V / -40 Celcius)
set STD_BST std150e_bst_135_n040

read_db -technology_library $dk_home/syn/STD150E/$STD_BST.db
read_db -technology_library $dk_home/syn/STD150E/$STD_WST.db
read_db -libname synthetic_library $sy_home/libraries/syn/dw_foundation.sldb
read_db -libname symbol_library $dk_home/syn/STD150E/std150e_veri.sdb

set sh_source_logging       false
set sh_new_variable_message false

proc count {} {
  if {[current_design] == "0"} {
    puts "The count function works on the current design"
    return 0
  } else {
    set orig_current_des [current_design]
    set cell_count [llength [find_cells]]

    foreach design [find_references -hierarchy] {
      if {[string first : $design] > 0} {
        current_design $design
        set cell_count [expr $cell_count + [llength [find_cells]]]
      }
    }
    current_design $orig_current_des
    puts "number of cells: $cell_count"
    return $cell_count
  }
}
proc make_time {start_t end_t} {
   val = [expr int($end_t - $start_t)]
   hor = [expr int($val / 3600)]
   val = [expr $val - $hor * 3600]
   min = [expr int($val / 60)]
   val = [expr $val - $min * 60]
   sec = $val
   return [format "%02i:%02i:%02i" $hor $min $sec]
}

if [catch {set env(SEC_SYNOPSYS)} msg] {
   puts "***"
   puts "*** Note :"
   puts "***"
   puts "***      You must set SEC_SYNOPSYS environment variables"
   puts "***      to a propriate direcotry path in which SEC Synopsys D/K was"
   puts "***      installed."
   puts "***"
   puts "***      And execute the following command"
   puts "***"
   puts "***      fm_shell> source \$env(SEC_SYNOPSYS)/formality/synopsys_fm.setup"
   puts "***"
} else {
   if [catch {set env(SEC_FM)} msg] {
      set env(SEC_FM) $env(SEC_SYNOPSYS)/formality
      source $env(SEC_FM)/utils/sec_read.tcl
      source $env(SEC_FM)/utils/sec_read_udc.tcl
      source $env(SEC_FM)/utils/sec_read_change_names_rpt.tcl
   } else {
      source $env(SEC_FM)/utils/sec_read.tcl
      source $env(SEC_FM)/utils/sec_read_udc.tcl
      source $env(SEC_FM)/utils/sec_read_change_names_rpt.tcl
   }
}

# Sets certain conservative Formality default variables to values that better conform to Design
# Compiler behavior. Certain guide commands are also accepted, instead of ignored. Set this
# variable before reading the automated setup file(.svf)
set synopsys_auto_setup true
