#******************************************************************************
#**                             06_design_finish                             **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                        06_design_finish.tcl                           "
echo "                                                                       "
echo "***********************************************************************"
#Samsung rule
#change_names -rules sec_verilog -hierarchy
change_names -rules verilog -hierarchy

write_file -format verilog -hierarchy -output ./outputs/$TOP_MODULE.vg


write_sdf ./outputs/$TOP_MODULE.sdf
write_sdc ./outputs/$TOP_MODULE.sdc
write_parasitics -output ./outputs/${TOP_MODULE}_parasitics

current_design khu_sensor_top
# write netlist without pad
write_file -format verilog -hierarchy -output ./outputs/khu_sensor_top.vg
