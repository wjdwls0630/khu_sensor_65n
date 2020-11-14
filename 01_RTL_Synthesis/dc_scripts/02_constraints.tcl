#******************************************************************************
#**                               02_constraints                             **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                         02_constraints.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# Set Step
set step "02_constraints"

## Read operating condition file
remove_sdc

source "./dc_scripts/common_clock_env.tcl"
source "./dc_scripts/common_constraints.tcl"
