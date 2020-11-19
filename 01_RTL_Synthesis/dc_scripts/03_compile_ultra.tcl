#******************************************************************************
#**                             03_compile_ultra                             **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                       03_compile_ultra.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "03_compile_ultra"

# Set operating conditions
#set user_opcond "./dc_scripts/user_scripts/user_operating_conditions.tcl"
#if {[file exist $user_opcond]} {
#	source $user_opcond
#}

compile_ultra -incremental

# Fix Violation
echo "***********************************************************************"
echo "                                                                       "
echo "                           fix violation                               "
echo "                                                                       "
echo "***********************************************************************"

source ./dc_scripts/common_reports.tcl

