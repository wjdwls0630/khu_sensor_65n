#******************************************************************************
#**                             01_read_designs                              **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                         01_read_designs.tcl                           "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "01_read_designs"

read_file -format verilog -rtl $DC_IN_VERILOG_RTL_FILE

current_design $TOP_MODULE
# The link command locates the reference for each cell in the design.
link
uniquify
