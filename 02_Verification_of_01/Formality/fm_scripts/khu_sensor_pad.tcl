# Remove containers before starting new verification
remove_container -all

# Script file for verifying ads1292_filter
set design "ads1292_filter"
set dir "ADS1292/ADS1292_Filter/ads1292_filter/"

echo "***********************************************************************"
echo "                                                                       "
echo "                             ${design}.tcl                             "
echo "                                                                       "
echo "***********************************************************************"

# read automated setup file where the retiming guidance commands are written
set_svf "${svf_path}${dir}${t_w_path}${design}.svf"

set design "float_adder"
set dir "ADS1292/ADS1292_Filter/float_adder/"
set_svf -append "${svf_path}${dir}${t_w_path}${design}.svf"

set design "float_multiplier"
set dir "ADS1292/ADS1292_Filter/float_multiplier/"
set_svf -append "${svf_path}${dir}${t_w_path}${design}.svf"

set design "iir_lpf"
set dir "ADS1292/ADS1292_Filter/iir_lpf/"
set_svf -append "${svf_path}${dir}${t_w_path}${design}.svf"

set design "iir_hpf"
set dir "ADS1292/ADS1292_Filter/iir_hpf/"
set_svf -append "${svf_path}${dir}${t_w_path}${design}.svf"

set design "iir_notch"
set dir "ADS1292/ADS1292_Filter/iir_notch/"
set_svf -append "${svf_path}${dir}${t_w_path}${design}.svf"

set design "converter_f2i"
set dir "ADS1292/ADS1292_Filter/converter_f2i/"
set_svf -append "${svf_path}${dir}${t_w_path}${design}.svf"

set design "converter_i2f"
set dir "ADS1292/ADS1292_Filter/converter_i2f/"
set_svf -append "${svf_path}${dir}${t_w_path}${design}.svf"

set design "ads1292_filter"
set dir "ADS1292/ADS1292_Filter/ads1292_filter/"

# when you use black-box,
# exec $env(SEC_FM)/utils/udc2bb <udc file address> -f udc_filename.v
# read_verilog -technology_library -container <ref/impl> udc_filename.v

# Create a container for the reference design(RTL)
# Read the reference design and set_top(link) it
create_container ref
read_verilog -container ref ${src_path}ADS1292/ADS1292_Filter/Float/float_adder.v
read_verilog -container ref ${src_path}ADS1292/ADS1292_Filter/Float/float_multiplier.v
read_verilog -container ref ${src_path}ADS1292/ADS1292_Filter/Float/converter_f2i.v
read_verilog -container ref ${src_path}ADS1292/ADS1292_Filter/Float/converter_i2f.v
read_verilog -container ref ${src_path}ADS1292/ADS1292_Filter/${design}.v


# link command is obsolete, using set_top instead
#link ref:/WORK/$design

set_top ref:/WORK/$design
set_reference_design ref:/WORK/$design

# Create a container for the implementation design(Gate-Level)
# Read the implementation design and set_top(link) it
create_container impl

read_verilog -container impl -netlist ${netlist_path}${dir}${t_w_path}${design}.vg

#link impl:/WORK/$design
set_top impl:/WORK/$design

set_implementation_design impl:/WORK/$design

set_compare_rule impl:/WORK/$design                          \
                 -from {\(.*\)_reg\([0-9]*\)_\([0-9][0-9]*\)A} \
                 -to   {\1_reg\2[\3]}
# set_compare_point commands for mapping the comparable design objects changes
# their instance name or flattened hierarchy path name

echo "***********************************************************************"
echo "                                                                       "
echo "                            verify  ${design}                          "
echo "                                                                       "
echo "***********************************************************************"

# verification
# Since we have already linked the design pairs,
# use -nolink option when performing verification
# However, for now, -nolink is obsolete, it is default
if {[verify] != 1} {
   diagnose
   report_failing_points
   source "${tcl_path}report_fail.tcl"
} else {
   source "${tcl_path}report_pass.tcl"
}
source "${tcl_path}report_default.tcl"
