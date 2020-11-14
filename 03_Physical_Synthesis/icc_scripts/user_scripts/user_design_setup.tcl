#******************************************************************************
#**                          user design settings                           **
#******************************************************************************
echo "***********************************************************************"
echo "                                                                       "
echo "                      user_design_setup.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

#******************************************************************************
#**                         General ICC Varialbes                            **
#******************************************************************************


set TOP_MODULE                     "khu_sensor_pad"    ;# set design top module name
set ICC_STRATEGY                   "qor"              ;# ttr | qor
set LEAKAGE_POWER_PLACE            true              ;# set to true when enabling leakage Flow in place_opt step.
set LEAKAGE_POWER_POST_CTS             true              ;# set to true when enabling leakage Flow in clock_opt_post_cts step. runtime will be effected.
set ICC_NUM_CPUS                   "1"                ;# used during placement & routing
set qor_effort                     "high"           ;# low | medium | high. place optimization effort, default is medium.
set INOUT_OPT                      true               ;# set to true when optimizing i2r and r2o paths
set GL_BASED_PLACE                 true              ;# set to true when using high congested design

set GEN_GL_CONG_MAP                true              ;# set to true, to see global route based congestion map
set INTER_CLK_GROUPS               "clk clk_half"    ;# Define to balance clocks during CTS. "clkA clkB"
set TIECELL_INSERT                 true              ;# true | false, if true, ICC will insert TIE cells.
set SPARE_INSERT                   false              ;# true | false, if true, the followings must be defined.
set SPARE_PREFIX                   spares             ;# default is spares
set SPARE_CELL_n_NUM               ""                 ;# example) "BUF_X1M_A9TH 100 AOI22_X1M_A9TH 100 INV_X1M_A9TH 200"

set USER_DIE_SIZE                  false              ;# true | false, if you know chip size, define true.
                                                      ;# Then write bellow variables.
set DIE_WIDTH                      ""                 ;# If USER_DIE_SIZW is true, define this variable.
set DIE_HEIGHT                     ""                 ;# If USER_DIE_SIZW is true, define this variable.

set ICC_IN_IO_CONST_FILE           "./TECH/padplace_ICC_khu_sensor_L13_68um.tdf"  ;# This is tdf format.

# This is a tcl file that changes pad names in logic library to in physical library.
# The tcl file functions appending "_p" to a last character of the pad names.
# (e.g. vssoh -> vssoh_p)
set ICC_IO_NAMING_FILE             "./icc_scripts/rules/pad_naming_rule.tcl"

set CLOCK_MAX_TRAN    0.3; # clock path max transtion time.

set MAX_ROUTING_LAYER              "MET4"
set MIN_ROUTING_LAYER              ""
set CLK_MAX_ROUTING_LAYER          "MET4"
set CLK_MIN_ROUTING_LAYER          "MET3"

#######################################################
## For Power Definition
#######################################################

set MW_R_POWER_NET         "VDD"                 ;# This is real power net name.
set MW_R_GROUND_NET        "VSS"                 ;# This is real ground net name.

set mw_logic1_net          $MW_R_POWER_NET       ;# Default
set mw_logic0_net          $MW_R_GROUND_NET      ;# Default

set MW_POWER_PORT          "VDD"                 ;# This is standard cell power pin name.
set MW_GROUND_PORT         "VSS"                 ;# This is standard cell ground pin name.

#######################################################
## Input Files
#######################################################

set ICC_IN_VERILOG_NETLIST_FILE "../01_RTL_Synthesis/outputs/khu_sensor_pad.vg"

#######################################################
## Define Init Utilization
#######################################################

set CORE_UTIL                      "0.6"              ;# Define initial core utilization.
                                                      ;# example) 0.6 means 60% utilization.
set IO2L                           "50"               ;# This means space from IO to core boundary in left side.
set IO2B                           "50"               ;# This means space from IO to core boundary in bottom side.
set IO2R                           "50"               ;# This means space from IO to core boundary in right side.
set IO2T                           "50"               ;# This means space from IO to core boundary in top side.

#####################################################################################################
##
#
# scenario naming convention :  mode_corner
# - mode   : func1,func2,scan1,scan2,bist1,bist2,jtag
#            funccts,scancts,bistcts,jtagcts
# - corner : wst, wstti, bst, bstti
#
# (scenario example)
#  func1_wst func1_wstti func1_bst func1_bstti
#  func2_wst func2_wstti func2_bst func2_bstti
#  scan1_wst scan1_wstti scan1_bst scan1_bstti
#  scan2_wst scan2_wstti scan2_bst scan2_bstti
#  bist1_wst bist1_wstti bist1_bst bist1_bstti
#  bist2_wst bist2_wstti bist2_bst bist2_bstti
#  jtag_wst  jtag_wstti  jtag_bst  jtag_bstti
#  funccts_wstti scancts_wstti bistcts_wstti jtagcts_wstti
#
#####################################################################################################


set ICC_MCMM_SCENARIOS_FILE        "./icc_scripts/mcmm_scenario/scenarios.tcl"

####### Define scenarios

## This is example, modify this according to your scenarios.
##
## Generally, FP_SCN, PLACE_OPT_SNC and ROUTE_SCN uses worst function mode scenario such as func1_wstti.
## CLOCK_OPT_CTS_SCN uses all cts scenario such as funccts_wstti,scantcts_wstti,bistcts_wstti,jtagcts_wstti.
## CLOCK_OPT_PSYN_SCN, ROUTE_OPT_SCN and CHIP_FINISH_SCN uses all scenarios except for CLOCK_OPT_CTS_SCN.
## HOLD_ONLY_SCN optimizes only hold time and mttv.
## So, you uses best corner scenarios such as func1_bst,scan1_bst,bist1_bst and jtag_bst.
##
# Since the samsung013 Library is damaged, the worst operating condition is only applied.
#set scenarios                      "func1_wst func1_bst"
set scenarios                      "func1_wst funccts_wst"

set FP_SCN                         "func1_wst"
set PLACE_OPT_SCN                  "func1_wst"
set CLOCK_OPT_CTS_SCN              "funccts_wst"
#set CLOCK_OPT_PSYN_SCN             "func1_bst"
set CLOCK_OPT_PSYN_SCN             "func1_wst"
set ROUTE_SCN                      "func1_wst"
#set ROUTE_OPT_SCN                  "func1_bst"
set ROUTE_OPT_SCN                  "func1_wst"
#set CHIP_FINISH_SCN                "func1_bst"
set CHIP_FINISH_SCN                "func1_wst"

set CLOCK_OPT_CTS_SCN_READ_AGAIN   true              ;# If true, ICC will create scenario again.
set CLOCK_OPT_PSYN_SCN_READ_AGAIN  false              ;# If true, ICC will create scenario again.
set ROUTE_SCN_READ_AGAIN           false              ;# If true, ICC will create scenario again.
set ROUTE_OPT_SCN_READ_AGAIN       false              ;# If true, ICC will create scenario again.

set HOLD_FIX                       true		      ;# If you want to fix hold violation then set true.

####### Define SDC Files
## If you have only FUNC1_SDC, Write the sdc file in FUNC1_SDC field.
## If FUNC1_SDC and FUNCTS_SDC is same, Write the sdc file in FUNC1_SDC and FUNCCTS_SDC field.
## If you don't have BIST1_SDC, Remain with blank.

set FUNC1_SDC          "../01_RTL_Synthesis/outputs/khu_sensor_pad.sdc"
set FUNC2_SDC          ""
set SCAN1_SDC          ""
set SCAN2_SDC          ""
set BIST1_SDC          ""
set BIST2_SDC          ""
set JTAG_SDC           ""

set FUNCCTS_SDC        "../01_RTL_Synthesis/outputs/khu_sensor_pad.sdc"
set SCANCTS_SDC        ""
set BISTCTS_SDC        ""
set JTAGCTS_SDC        ""

####### Define Default Operating Conditions
##
## You have to write the default operation condition name and library name of standard cell.
## If some instances of your design have other operation condition (PVT) such as IO,
## You have to define the operation condition name and library name in user_opcond.tcl.
##

set OPCOND_WST          V105WTP1250
set OPCOND_WST_LIB      std150e_wst_105_p125 

set OPCOND_WST_TIV      ""
set OPCOND_WST_LIB_TIV  ""

set OPCOND_BST          V135BTN0400
set OPCOND_BST_LIB      std150e_bst_135_n040

set OPCOND_BST_TIV      ""
set OPCOND_BST_LIB_TIV  ""

#########################   DO NOT CHANGE BELOW THIS LINE   ##############################
##########################################################################################

set REPORTS_DIR                 "./reports"

## Avoiding too many messages
set_message_info -id PSYN-040   -limit 5
set_message_info -id PSYN-087   -limit 5
set_message_info -id LINT-8     -limit 5
set_message_info -id RT-104     -limit 5
set_message_info -id RT-065     -limit 5
set_message_info -id TIM-128    -limit 5
set_message_info -id TIM-141    -limit 5
set_message_info -id PSYN-267   -limit 5
set_message_info -id RT-104     -limit 5
set_message_info -id MWUI-040   -limit 5
set_message_info -id PSYN-024   -limit 5
set_message_info -id MWLIBP-300 -limit 5
set_message_info -id MWLIBP-314 -limit 5
set_message_info -id PSYN-058   -limit 5
set_message_info -id PSYN-025   -limit 5
set_message_info -id PSYN-086   -limit 1
set_message_info -id PSYN-039   -limit 5
set_message_info -id PSYN-523   -limit 5
set_message_info -id PSYN-900   -limit 1
set_message_info -id PSYN-850   -limit 1
set_message_info -id CTS-102    -limit 1
set_message_info -id OPT-170    -limit 1
set_message_info -id TIM-178    -limit 1
set_message_info -id TIM-179    -limit 1

