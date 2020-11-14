# Set operating conditions
switch $corner {
    wst     { set_operating_conditions -analysis_type on_chip_variation \
	            -max V105WTP1250 -max_library std150e_wst_105_p125 \
              -min V105WTP1250 -min_library std150e_wst_105_p125
               echo "SEC_INFO: Define user operating condtions"
             }
    bst     { set_operating_conditions -analysis_type on_chip_variation \
              -max V135BTN0400 -max_library std150e_bst_135_n040 \
              -min V135BTN0400 -min_library std150e_bst_135_n040
               echo "SEC_INFO: Define user operating condtions"
             }
    default {
               echo "SEC_INFO: No user operating condtions"
             }
}
