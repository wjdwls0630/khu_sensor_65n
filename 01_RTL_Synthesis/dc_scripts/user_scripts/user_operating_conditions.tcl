#### Set operating conditions
# IO
set_operating_conditions -analysis_type on_chip_variation \
        -max SS65LP3P3V_WST_108_300_P125 -max_library ss65lp3p3v_wst_108_300_p125 \
        -min SS65LP3P3V_WST_108_300_P125 -min_library ss65lp3p3v_wst_108_300_p125 \
        -object_list [get_cells -hier -filter "ref_name =~ pvhbcu*"]
# PRIMITIVE
set_operating_conditions -analysis_type on_chip_variation \
        -max ss_1p08v_125c -max_library $NOM_RVT_SS \
        -min ss_1p08v_125c -min_library $NOM_RVT_SS  
echo "SEC_INFO: Define user operating condtions"
