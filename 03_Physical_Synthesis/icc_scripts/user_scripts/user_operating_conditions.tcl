# Set operating conditions
#set_operating_conditions -analysis_type on_chip_variation \
#    -max SS45LP3P3V_SS_1045_165_N025_IO -max_library ss45lp3p3v_ss_1045_165_n025_io \
#    -min SS45LP3P3V_SS_1045_165_N025_IO -min_library ss45lp3p3v_ss_1045_165_n025_io \
#    -object_list [get_cells -all -hier -filter "ref_name =~ *_33_*"]

switch $corner {
    wst     { set_operating_conditions -analysis_type on_chip_variation \
	              -max SS65LP3P3V_WST_108_300_P125 -max_library ss65lp3p3v_wst_108_300_p125 \
                -min SS65LP3P3V_WST_108_300_P125 -min_library ss65lp3p3v_wst_108_300_p125 \
                -object_list [get_cells -all -hier -filter "ref_name =~ pvhbcu*"]
              echo "SEC_INFO: Define user operating condtions"
            }
    wstti   {
              echo "SEC_INFO: Define user operating condtions"
             }
    bst     { set_operating_conditions -analysis_type on_chip_variation \
                -max SS65LP3P3V_BST_132_360_N040 -max_library ss65lp3p3v_bst_132_360_n040 \
                -min SS65LP3P3V_BST_132_360_N040 -min_library ss65lp3p3v_bst_132_360_n040 \
                -object_list [get_cells -all -hier -filter "ref_name =~ pvhbcu*"]
              echo "SEC_INFO: Define user operating condtions"
}
    bstti   {
              echo "SEC_INFO: Define user operating condtions"
             }
    default {
              echo "SEC_INFO: No user operating condtions"
             }
}
