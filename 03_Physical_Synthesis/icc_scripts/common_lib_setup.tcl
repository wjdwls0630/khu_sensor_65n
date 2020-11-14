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

#******************************************************************************
#**                         Set Library Parameter                            **
#******************************************************************************
setenv SEC_SYNOPSYS /Tools/Library/samsung013/sec050915_0050_STD150E_regular_DK_Synopsys_N/sec150e_synopsys
setenv SEC_SYNOPSYS_AUX env(SEC_SYNOPSYS)/aux
#******************************************************************************
#**                Set New Variable for 'search_path'                        **
#******************************************************************************
set dk_home [getenv SEC_SYNOPSYS]
set dk_home_aux [getenv SEC_SYNOPSYS_AUX]
#******************************************************************************
#**                Set 'search_path'                                         **
#******************************************************************************

set search_path [list . [format "%s%s"  $synopsys_root /libraries/syn] \
    [format "%s%s"  $dk_home /syn/STD150E] $dk_home_aux]

#******************************************************************************
#**                Set libraries                                             **
#******************************************************************************
# Reference/Front_End/samsung013/sec150e_synopsys/readme/SynopsysDKGuide.pdf p.14

# Typical (TT / 1.20V / 25 Celcius)
set STD_TYP std150e_typ_120_p025
set STD_TYP_MEM std150e_typ_120_p025_memory

# Worst (SS / 1.05V / 125 Celcius)
set STD_WST std150e_wst_105_p125

# Best (FF / 1.35V / -40 Celcius)
set STD_BST std150e_bst_135_n040

set target_library [concat \
        $STD_WST.db \
        $STD_BST.db
]

# * : all designs which are in dc_shell 
set synthetic_library dw_foundation.sldb
set link_library [concat \
        {*} \
        $target_library \
	$synthetic_library
]

set link_path $link_library

set symbol_library [list std150e_veri.sdb]

#******************************************************************************
#**                         Common Setup File                                **
#******************************************************************************

set_host_options -max_cores $ICC_NUM_CPUS
set_route_mode_options -zroute true

#******************************************************************************

#******************************************************************************
#**                   Set Physical Library Parameter                         **
#******************************************************************************

setenv SEC_SYNOPSYS_ICC [sh pwd]/MilkyWay

#******************************************************************************

#******************************************************************************
#**                Set New Variable for 'MW_REF_LIB_DIRS'                   **
#******************************************************************************

set icc_home [getenv SEC_SYNOPSYS_ICC]

set all_milky [list \
		$icc_home/std150e_prim_050504 \
		$icc_home/std150e_60poi_power_6lm_070420 \
		$icc_home/std150e_60poi_io_6lm_071011
	      ]

set MW_REF_LIB_DIRS "$all_milky"

# Since I/O pad name is different between logical and physical, we should add
# LM cell db for ICC to search I/O pad cell properly
if { $step != "00_read_design" } {
	lappend link_library $icc_home/std150e_60poi_io_6lm_071011/LM/${STD_WST}_astro.db
	lappend link_library $icc_home/std150e_60poi_io_6lm_071011/LM/${STD_BST}_astro.db
}
#******************************************************************************

#******************************************************************************
#**                       Set TECH and TLUP Files                           **
#******************************************************************************

set TECH_FILE "./TECH/std150e_prim_6m.techgen.tf"
set TLUP_DIR [sh pwd]/TLUP/sec060328_0003_0.13um_L13G__InternalRule-set_PROC_Astro-TLUp_N/L13G
set MAP_FILE "${TLUP_DIR}/MAP/L13_CELL_6LM.map"
set TLUP_MAX_FILE "${TLUP_DIR}/TLUP/L13_CELL_WST_6LM_DUMMY_V8.0_R_vari_Hole_Rev3.0.tlup"
set TLUP_MIN_FILE "${TLUP_DIR}/TLUP/L13_CELL_BST_6LM_DUMMY_V8.0_R_vari_Hole_Rev3.0.tlup"

#******************************************************************************

#******************************************************************************
#**                        Set Stream Out Map File                           **
#******************************************************************************

set STREAM_OUT_MAP "./TECH/layer.map"

#******************************************************************************

#******************************************************************************
#**                           Set Antenna_Rule                               **
#******************************************************************************

# Reference/Back_End/KHU_ASTRO User Guide p.86 and samsung65 TECH antenna_rules
# IC User Guide p.457
# make antenna_rule.tcl
set ANTENNA_RULE "./TECH/std150e_prim713_antenna_200827.tcl"

#******************************************************************************

#******************************************************************************
#**                           Set IO FILLERS                                 **
#******************************************************************************
set IO_FILLER "iofillerh30_p iofillerh10_p iofillerh5_p iofiller1_p"
set IO_FILLER_OVERLAP ""

#******************************************************************************
#**                        Set Clock Tree Layers                             **
#******************************************************************************

# clock tree layers
set ICC_CTS_RULE_NAME "shield_130nm_rule"

#******************************************************************************
#**                    Default Timing Environment Setting                   **
#******************************************************************************

set timing_enable_multiple_clocks_per_reg true
set timing_enable_non_sequential_checks true
set case_analysis_with_logic_constants true
set disable_auto_time_borrow false
set legalize_support_phys_only_cell true

set_separate_process_options -placement false
set_separate_process_options -routing false
set_separate_process_options -extraction false

#******************************************************************************

#******************************************************************************
#**                               ETC                                        **
#******************************************************************************

set sh_enable_page_mode false

setenv TMPDIR [sh pwd]/TMP
set back [sh date +%m%d_%H:%M:%S]

#******************************************************************************
