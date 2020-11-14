#******************************************************************************
#**                         00_read_design                                   **
#**               create mw library and read verilog netlist                 **
#******************************************************************************

echo "***********************************************************************"
echo "                                                                       "
echo "                         00_read_design.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "00_read_design"

# source the user_design_setup & common_lib_setup
source -echo -v ./icc_scripts/user_scripts/user_design_setup.tcl
source -echo -v ./icc_scripts/common_lib_setup.tcl

# Clear existing mw library and re-make dir
set _mw_lib ./mw_db/${TOP_MODULE}_${step}
if {[file exist $_mw_lib]} {
	sh rm -rf $_mw_lib
}

# Create a Milkyway Design DB
echo "***********************************************************************"
echo "                                                                       "
echo "                   Creating a Milkyway Design DB                       "
echo "                                                                       "
echo "***********************************************************************"

create_mw_lib ./mw_db/${TOP_MODULE}_${step} \
	-technology $TECH_FILE \
	-mw_reference_library $MW_REF_LIB_DIRS \
	-bus_naming_style {[%d]} \
	-open

# If the "-open" option is not used, the library needs to be opened in order to import the design
# open_mw_lib ./mw_db/${TOP_MODULE}_${step}

# Apply pad naming rule in physical library
source $ICC_IO_NAMING_FILE

# Read verilog netlist
read_verilog -top ${TOP_MODULE} $ICC_IN_VERILOG_NETLIST_FILE
link
current_design $TOP_MODULE
uniquify_fp_mw_cel

# Can be replaced by
#import_designs $ICC_IN_VERILOG_NETLIST_FILE -format verilog -top ${TOP_MODULE}

# Save
change_names -rule verilog -hier
set verilogout_no_tri true
save_mw_cel -as ${TOP_MODULE}

# close lib
close_mw_lib

# Reset netlist file for applying naming rule
sh rm -f $ICC_IN_VERILOG_NETLIST_FILE
sh cp ${ICC_IN_VERILOG_NETLIST_FILE}.bak $ICC_IN_VERILOG_NETLIST_FILE
exit
