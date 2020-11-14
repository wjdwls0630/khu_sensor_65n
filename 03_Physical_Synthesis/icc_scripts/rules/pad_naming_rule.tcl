#******************************************************************************
#**                         pad_naming_rule.tcl                              **
#******************************************************************************
# This is a tcl file that changes pad names in logic library to in physical library. 
# The tcl file functions appending "_p" to a last character of the pad names. 
# (e.g. vssoh -> vssoh_p)

set lib_pads [filter_collection [get_lib_cells $STD_WST.db:$STD_WST/*] is_pad] 
foreach_in_collection lib_pad $lib_pads {
	set lib_pad_name [get_object_name $lib_pad]
	set pad_name_str [split "$lib_pad_name" '/']
	set pad_name_arr [regexp -all -inline  {\w+} $pad_name_str]
	foreach pad_name $pad_name_arr {
		if { $pad_name != $STD_WST } {
			sh sed -i 's/${pad_name} /${pad_name}_p /g' $ICC_IN_VERILOG_NETLIST_FILE
		}
	}
}
