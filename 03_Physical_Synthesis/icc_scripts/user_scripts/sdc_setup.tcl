#******************************************************************************
#**                              sdc_setup.tcl                              **
#******************************************************************************
# This is a tcl file that removes clock gating constraints, set_max_delay 0 from cg cells to gated registers

sh sed -i '/set_max_delay/ i \n' $FUNC1_SDC
sh sed -i '/set_max_delay/, +1 d' $FUNC1_SDC
sh sed -i '/^n$/d' $FUNC1_SDC
