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
set LIB_DIR /Tools/Library/samsung65_2016/CB_1502
set PRIMITIVE_LIB_DIR ${LIB_DIR}/PRIMITIVE
set IO_LIB_DIR ${LIB_DIR}/IO

#******************************************************************************
#**                Set 'search_path'                                         **
#******************************************************************************
#set search_path ". $synopsys_root/libraries/syn \
		               $PRIMITIVE_LIB_DIR/sec100226_0026_SS65LP_PMK_RVT_PMK_FE_Common_N/synopsys  \
                   $PRIMITIVE_LIB_DIR/sec100226_0028_SS65LP_PMK_HVT_PMK_FE_Common_N/synopsys  \
                   $PRIMITIVE_LIB_DIR/sec100226_0042_SS65LP_Normal_RVT_Normal_FE_Common_N/synopsys \
                   $PRIMITIVE_LIB_DIR/sec100226_0043_SS65LP_Normal_HVT_Normal_FE_Common_N/synopsys \
                   $IO_LIB_DIR/synopsys"
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
# The used corner and threshold are different by each stage in P&R.
# Please refer to each stages' description

# PMK (Power Management Kit)

# RVT
# SS (Worst)
set PMK_RVT_SS scmetropmk_cmos10lp_rvt_ss_1p08v_125c_sadhm

# FF (Best)
set PMK_RVT_FF scmetropmk_cmos10lp_rvt_ff_1p32v_m40c_sadhm

# HVT
# SS (Worst)
#set PMK_HVT_SS scmetropmk_cmos10lp_hvt_ss_1p08v_125c_sadhm

# FF (Best)
#set PMK_HVT_FF scmetropmk_cmos10lp_hvt_ff_1p32v_m40c_sadhm

# Normal

# RVT
# SS (Worst)
set NOM_RVT_SS scmetro_cmos10lp_rvt_ss_1p08v_125c_sadhm

# FF (Best)
set NOM_RVT_FF scmetro_cmos10lp_rvt_ff_1p32v_m40c_sadhm

# HVT
# SS (Worst)
#set NOM_HVT_SS scmetro_cmos10lp_hvt_ss_1p08v_125c_sadhm

# FF (Best)
#set NOM_HVT_FF scmetro_cmos10lp_hvt_ff_1p32v_m40c_sadhm

# IO

# SS (Worst)
set IO_SS ss65lp3p3v_wst_108_300_p125

# FF (Best)
set IO_FF ss65lp3p3v_bst_132_360_n040

#set target_library [concat \
        $PMK_RVT_SS.db \
        $PMK_RVT_FF.db \
        $PMK_HVT_SS.db \
        $PMK_HVT_FF.db \
        $NOM_RVT_SS.db \
        $NOM_RVT_FF.db \
        $NOM_HVT_SS.db \
        $NOM_HVT_FF.db \
        $IO_SS.db \
        $IO_FF.db \
]
set target_library [concat \
        $PMK_RVT_SS.db \
        $PMK_RVT_FF.db \
        $NOM_RVT_SS.db \
        $NOM_RVT_FF.db \
        $IO_SS.db \
        $IO_FF.db \
]

# * : all designs which are in dc_shell
#set synthetic_library dw_foundation.sldb
#set link_library [concat \
        {*} \
        $PMK_RVT_SS.db \
        $PMK_RVT_FF.db \
        $PMK_HVT_SS.db \
        $PMK_HVT_FF.db \
        $NOM_RVT_SS.db \
        $NOM_RVT_FF.db \
        $NOM_HVT_SS.db \
        $NOM_HVT_FF.db \
        $IO_SS.db \
        $IO_FF.db \
]

set link_library [concat \
        {*} \
        $PMK_RVT_SS.db \
        $PMK_RVT_FF.db \
        $NOM_RVT_SS.db \
        $NOM_RVT_FF.db \
        $IO_SS.db \
        $IO_FF.db \
]

#******************************************************************************
#**                   Set Physical Library Parameter                         **
#******************************************************************************

set MILKY_DIR ${LIB_DIR}/MilkyWay/ICC

#******************************************************************************

#******************************************************************************
#**                Set New Variable for 'MW_REF_LIB_DIRS'                   **
#******************************************************************************

set all_milky [list \
    ${MILKY_DIR}/cmos10lprvt_m \
    ${MILKY_DIR}/Power_IO \
    ${MILKY_DIR}/RVT_PMK
]

set MW_REF_LIB_DIRS "$all_milky"

#******************************************************************************
#**                         Common Setup File                                **
#******************************************************************************

set_host_options -max_cores $ICC_NUM_CPUS
set_route_mode_options -zroute true

#******************************************************************************

#******************************************************************************
#**                       Set TECH and TLUP Files                           **
#******************************************************************************

set TECH_AND_TLUP_DIR           "${LIB_DIR}/LAYOUT/ICC/65nm_TECH_TLUP_20120423"

set TECH_FILE                   "${TECH_AND_TLUP_DIR}/TECH/ICC/LR6LP/cmos10lp_4_20_01_3.tf"
set MAP_FILE                    "${TECH_AND_TLUP_DIR}/TLUP/LR6LP.4_20_01_3um.map"
set TLUP_MAX_FILE               "${TECH_AND_TLUP_DIR}/TLUP/LR6LP_SigCmax_4_20_01_00_3um_effective.tlup"
set TLUP_MIN_FILE               "${TECH_AND_TLUP_DIR}/TLUP/LR6LP_SigCmin_4_20_01_00_3um_effective.tlup"

#******************************************************************************

#******************************************************************************
#**                        Set Stream Out Map File                           **
#******************************************************************************
# In order to export layout(ICC) to GDSII(Virtuoso), set stream option
set STREAM_OUT_MAP              "${TECH_AND_TLUP_DIR}/TECH/ICC/LR6LP/gds2OutLayer_4_20_01_3.map"

# On the contrary, stream-in is converting GDSII to layout.
# The layermap file can be found in the same directory that contains stream out mapping file dir.
# (gds2InLayer_4_20_01_3.map)

#******************************************************************************

#******************************************************************************
#**                           Set Antenna_Rule                               **
#******************************************************************************

set ANTENNA_RULE                "${TECH_AND_TLUP_DIR}/TECH/ICC/LR6LP/antenna_rules_4_20_01_3.tcl"

#******************************************************************************

#******************************************************************************
#**           Set decap cells, STD Fillers and IO Fillers                    **
#******************************************************************************
# Decap cells
# The cells is used for reducing dynamic voltage drop/rise(usually called ground bounce in power grids).
# (It is okay to consider it energy reservoir or high pass filter)
# (Decap cells are usually considered as thick gate NMOS decoupling cap)
# The cells are always posed VDD on the gate, but gate leakage power can be ignored due to the thick gate.
# After placement, the tools fill the cells empty space
set DECAP_FILLER                "FILLDGCAP56MTR FILLDGCAP31MTR FILLDGCAP19MTR FILLDGCAP13MTR FILLDGCAP9MTR"

# Filler cell contain dummy RX(diffusion) and PC(poly) patterns which make RX and PC
# density not to be low on a chip. Of course, The Filler cells are cells with no logical functionality.
# The reason why the Filler cells are used is that they fill gaps left in the layout where the area is unfilled.
# (Filler cells in the layout connect power and ground rails across an area containing no cells.)
# If you do DRC without Filler cells, you can easily expect to see spacing violation like "NWell minimum spacing not met."
# This is where the Filler cells are needed.
# In brief, the Filler cells is analogous to the standard cells, it has the VDD/VSS pins,
# but they only have the base layer like NWell, which does not have function.

set LVT_FILLER                  ""
set RVT_FILLER                  "FILL64MTR FILL32MTR FILL16MTR FILL8MTR FILL4MTR FILL2MTR FILL1MTR"
set HVT_FILLER                  ""
set LVTLIB                      ""
set RVTLIB                      "$LIB_DIR/MilkyWay/ICC/cmos10lprvt_m"
set HVTLIB                      ""

# Add I/O Filler
# Power Ring (internal to external, in order)
# VDDI: 1.2V I/O power ring
# VSSIP: 1.2V I/O ground ring
# VDDP: 1.8V/2.5V/3.3V I/O power ring
# VDDO: 1.8V/2.5V/3.3V I/O power ring
# VSSO: 1.8V/2.5V/3.3V I/O ground ring
# For Samsung Library, Voltage of Pre-Driver and Output-Driver is connected automatically(PAD_Ring)
# when PAD Filler is inserted, consider only VDD and VSS which are core voltage in this process.
# Insert Filler in order from big to small for the sake of reducing the number of fillers.
# Especially, iofillerv30 has two internal power ports which are connected to internal VDD and VSS rings.
# Due to this cell, EM and IR-drop of internal power ring can be mitigated.

set IO_FILLER                   "iofillerv30 iofillerv1 iofillerv_1 iofillerv_005"
set IO_FILLER_OVERLAP           ""

#******************************************************************************
#**                    Set well edge cell and tap cell                       **
#******************************************************************************
# Well Tap Cells,  (Fill tie cells)
# Library cell(Bulk CMOS) usually have well taps which are traditionally used so that NWell
# is connected to VDD and substrate is connected to GND.
# However, each and every CMOS device do not need to have these taps.
# Theoretically, the only one VDD tap per NWell(one row) and the only one GND tap per substrate
# is needed. Actually, the significant area reduction can be achieved by removing these well ties from the layout.
# Thus, most foundry companies chose to have "tap-less" libraries like samsung 65nm.
# However, as we all know, if the device does not have taps, the Latch-up can easily occur.
# Hence, the companies set the design rule or manual relating to a distance between tap cells
# for preventing the latchup.
# Following the design rule, ICC pre-place these Fill tie cells periodically in every row.

set WELL_EDGE_CELL              "FILLTIEMTR"       ;# FILLTIEMT(H/R/L)
set TAP_CELL                    "FILLTIEMTR"       ;# FILLTIEMT(H/R/L)
set TAP_DIST                    "118.8"

#******************************************************************************
#**                               Set TIE cell                               **
#******************************************************************************
# In aggressive scaling down technology, the gate oxide is so thin and sensitive that
# the transistor, which connect to power or ground rails directly, can be easily damaged
# due to voltage fluctuation in the power supply, such as ESD.
# ESD: the abbreviation of Electro Static Discharge. The ESD is sudden flow of static
# electricity between two electrical charge for a very short duration.
# EOS(Electric Over-Stress) is also one byprouct of ESD.
# ESD generates high peak voltage and current that may damage the IC.
# ESD usually occurs when two objects that have different potential contact directly.
# In terms of VLSI, it is usually occurs the I/O pads which are exposed to external world directly.
# Hence, I/O pads have ESD protection circuits consisted of diodes.
# By the way, to protect ESD, the Tie cells are needed. The Tie cells are didode connected NMOS or PMOS.
# Hence tie cells, which are diode connected nmos or pmos are used instead.
# Also, the outputs of these cells are driven through diffusion to provide isolation
# from the power and ground rails(not directly connect to the rails) for better ESD protection. The standard cell abstract
# methodology assumes that these cells are used to tie off any inputs to power and ground.
# If these cells are not used and the router is allowed to drop vias on the power rail,
# DRC errors or shorts may result.
# The TIEHI cell drives the output to a logic constant high. (usually used when input logic is 1)
# On the contrary, The TIELO cell drives the output to a logic constant low. (usually used when input logic is 0)
# Lastly, due to a configuration of the tie cells in samsung 65nm,
# the tie cells have lower leakage current compared to diodes, and rewiring the ECO cells is easy.

set TIEHI_CELL                  "TIEHIMTR"
set TIELO_CELL                  "TIELOMTR"

#******************************************************************************
#**             Set CTS cells and rule for Clock Tree Synthesis              **
#******************************************************************************

# clock tree layers
set ICC_CTS_RULE_NAME           "shield_65nm_rule"

# cells used for CTS
set ICC_CTS_REF_LIST            "CLKINVX40MTR CLKINVX32MTR CLKINVX24MTR CLKINVX20MTR CLKINVX16MTR CLKINVX12MTR CLKINVX8MTR"

# cells for CTS that are for sizing only
set ICC_CTS_REF_SIZING_ONLY     "CLKINVX40MTR CLKINVX32MTR CLKINVX24MTR CLKINVX20MTR \
                                 CLKINVX16MTR CLKINVX12MTR CLKINVX8MTR CLKINVX6MTR \
                                 CLKINVX4MTR CLKINVX3MTR CLKINVX2MTR CLKINVX1MTR \
                                 CLKBUFX40MTR CLKBUFX32MTR CLKBUFX24MTR CLKBUFX20MTR \
                                 CLKBUFX16MTR CLKBUFX12MTR CLKBUFX8MTR CLKBUFX6MTR \
                                 CLKBUFX4MTR CLKBUFX3MTR CLKBUFX2MTR CLKBUFX1MTR "

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
