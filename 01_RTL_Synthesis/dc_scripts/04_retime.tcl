#******************************************************************************
#**                                04_retime                                 **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                             04_retime.tcl                             "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "04_retime"

# Set operating conditions
#set user_opcond "./dc_scripts/user_scripts/user_operating_conditions.tcl"
#if {[file exist $user_opcond]} {
#	source $user_opcond
#}
compile_ultra -incremental -retime

source ./dc_scripts/common_reports.tcl
