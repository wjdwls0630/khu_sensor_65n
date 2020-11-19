#******************************************************************************
#**                          common library settings                         **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                       common_lib_setup.tcl                            "
echo "                                                                       "
echo "***********************************************************************"
#******************************************************************************
#                       set basic parameter                                  **
#******************************************************************************
set designer "Man"
set company "KHU Room327"
# Define path directories for file locations
set ALIB_DIR "./alib"
set SVF_DIR "./svf"

#******************************************************************************
#**                         Set Library Parameter                            **
#******************************************************************************
set LIB_DIR /Tools/Library/samsung65_2016/CB_1502
set PRIMITIVE_LIB_DIR ${LIB_DIR}/PRIMITIVE
set IO_LIB_DIR ${LIB_DIR}/IO

#******************************************************************************
#**                Set 'search_path'                                         **
#******************************************************************************
set search_path ". $synopsys_root/libraries/syn \
		    					 $PRIMITIVE_LIB_DIR/sec100226_0026_SS65LP_PMK_RVT_PMK_FE_Common_N/synopsys  \
                   $PRIMITIVE_LIB_DIR/sec100226_0042_SS65LP_Normal_RVT_Normal_FE_Common_N/synopsys \
                   $IO_LIB_DIR/synopsys"

#******************************************************************************
#**                Set libraries                                             **
#******************************************************************************
# Samsung 65nm
# Dual Vth (Sign-off Corner, no need Multi-VDD)
# Logic Synthesis & Pre-STA (1st Sign-off)
# RVT: SS 1.08V 125c - WIRE Zero Wire Load Model
# HVT: SS 1.08V 125c - WIRE Zero Wire Load Model

# PMK (Power Management Kit)

# RVT
# SS (Worst)
set PMK_RVT_SS scmetropmk_cmos10lp_rvt_ss_1p08v_125c_sadhm

# HVT
# SS (Worst)
#set PMK_HVT_SS scmetropmk_cmos10lp_hvt_ss_1p08v_125c_sadhm

# Normal

# RVT
# SS (Worst)
set NOM_RVT_SS scmetro_cmos10lp_rvt_ss_1p08v_125c_sadhm

# HVT
# SS (Worst)
#set NOM_HVT_SS scmetro_cmos10lp_hvt_ss_1p08v_125c_sadhm

# IO

# SS (Worst)
set IO_SS ss65lp3p3v_wst_108_300_p125

set target_library [concat \
        $PMK_RVT_SS.db \
        $NOM_RVT_SS.db \
        $IO_SS.db
]

# * : all designs which are in dc_shell
#set synthetic_library dw_foundation.sldb
set link_library [concat \
        {*} \
				$PMK_RVT_SS.db \
        $NOM_RVT_SS.db \
        $IO_SS.db
]

set link_path $link_library

set_app_var alib_library_analysis_path $ALIB_DIR

set_host_options -max_cores $DC_NUM_CPUS

#******************************************************************************
#**                    Default Timing Environment Setting                   **
#******************************************************************************

set timing_enable_multiple_clocks_per_reg true
set timing_enable_non_sequential_checks true
set case_analysis_with_logic_constants true
set disable_auto_time_borrow false

#******************************************************************************

#******************************************************************************
#**                               ETC                                        **
#******************************************************************************

set sh_enable_page_mode false

setenv TMPDIR [sh pwd]/TMP
set back [sh date +%m%d_%H:%M:%S]

#******************************************************************************
