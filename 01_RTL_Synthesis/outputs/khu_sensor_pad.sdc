###################################################################

# Created by write_sdc on Sat Nov 14 08:56:51 2020

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -power mW -voltage V       \
-current mA
set_operating_conditions -analysis_type on_chip_variation ss_1p08v_125c        \
-library scmetro_cmos10lp_rvt_ss_1p08v_125c_sadhm
set_max_area 0
set_disable_timing [get_ports i_RSTN]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_controller/spi_master/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_controller/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_filter/iir_hpf/async_rst_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_filter/iir_hpf/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_filter/iir_notch/async_rst_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_filter/iir_notch/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_filter/iir_lpf/async_rst_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_filter/iir_lpf/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_filter/async_rst_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/ads1292_filter/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/mpr121_controller/i2c_master/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/mpr121_controller/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/sensor_core/async_rst_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/uart_controller/uart_rx/async_rst_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/uart_controller/uart_tx/async_rst_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/uart_controller/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/uart_controller/async_rst_synchronizer]
set_disable_timing [get_cells khu_sensor_top/async_rstn_glitch_synchronizer]
set_disable_timing [get_cells                                                  \
khu_sensor_top/async_rstn_glitch_synchronizer/async_rstn_synchronizer]
set_disable_timing [get_cells                                                  \
async_rstn_glitch_synchronizer/async_rstn_synchronizer]
set_load -pin_load 0.025 [get_ports UART_TXD]
set_load -pin_load 0.025 [get_ports MPR121_SCL]
set_load -pin_load 0.025 [get_ports MPR121_SDA]
set_load -pin_load 0.025 [get_ports ADS1292_SCLK]
set_load -pin_load 0.025 [get_ports ADS1292_MOSI]
set_load -pin_load 0.025 [get_ports ADS1292_RESET]
set_load -pin_load 0.025 [get_ports ADS1292_START]
set_load -pin_load 0.025 [get_ports ADS1292_CSN]
set_ideal_network [get_ports i_CLK]
set_ideal_network [get_ports i_RSTN]
set_ideal_network [get_pins async_rstn_glitch_synchronizer/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/async_rstn_glitch_synchronizer/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins khu_sensor_top/divider_by_2/o_CLK_DIV_2_reg/Q]
set_ideal_network [get_pins khu_sensor_top/uart_controller/async_rst_synchronizer/o_RST_reg/Q]
set_ideal_network [get_pins khu_sensor_top/uart_controller/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins khu_sensor_top/sensor_core/async_rst_synchronizer/o_RST_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/mpr121_controller/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins khu_sensor_top/ads1292_filter/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins khu_sensor_top/ads1292_filter/async_rst_synchronizer/o_RST_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/ads1292_controller/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/uart_controller/uart_tx/async_rst_synchronizer/o_RST_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/uart_controller/uart_rx/async_rst_synchronizer/o_RST_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/mpr121_controller/i2c_master/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/ads1292_filter/iir_lpf/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/ads1292_filter/iir_lpf/async_rst_synchronizer/o_RST_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/ads1292_filter/iir_notch/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/ads1292_filter/iir_notch/async_rst_synchronizer/o_RST_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/ads1292_filter/iir_hpf/async_rstn_synchronizer/o_RSTN_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/ads1292_filter/iir_hpf/async_rst_synchronizer/o_RST_reg/Q]
set_ideal_network [get_pins                                                                     \
khu_sensor_top/ads1292_controller/spi_master/async_rstn_synchronizer/o_RSTN_reg/Q]
create_clock [get_ports i_CLK]  -name clk  -period 4.2  -waveform {0 2.1}
set_clock_latency 0.05  [get_clocks clk]
set_clock_latency -source 0.7  [get_clocks clk]
set_clock_uncertainty -setup 0.294  [get_clocks clk]
set_clock_transition -max -rise 0.5 [get_clocks clk]
set_clock_transition -min -fall 0.5 [get_clocks clk]
set_clock_transition -max -fall 0.5 [get_clocks clk]
set_clock_transition -min -rise 0.5 [get_clocks clk]
create_generated_clock [get_pins khu_sensor_top/divider_by_2/o_CLK_DIV_2]  -name clk_half  -source [get_ports i_CLK]  -divide_by 2
set_clock_latency 0.05  [get_clocks clk_half]
set_clock_latency -source 0.7  [get_clocks clk_half]
set_clock_uncertainty -setup 0.588  [get_clocks clk_half]
set_clock_transition -max -rise 0.5 [get_clocks clk_half]
set_clock_transition -min -fall 0.5 [get_clocks clk_half]
set_clock_transition -max -fall 0.5 [get_clocks clk_half]
set_clock_transition -min -rise 0.5 [get_clocks clk_half]
group_path -name FEEDTHROUGH  -from [list [get_ports i_RSTN] [get_ports UART_RXD] [get_ports MPR121_SCL]    \
[get_ports MPR121_SDA] [get_ports ADS1292_MISO] [get_ports ADS1292_DRDY]]  -to [list [get_ports UART_TXD] [get_ports MPR121_SCL] [get_ports MPR121_SDA]  \
[get_ports ADS1292_SCLK] [get_ports ADS1292_MOSI] [get_ports ADS1292_RESET]    \
[get_ports ADS1292_START] [get_ports ADS1292_CSN]]
group_path -name REGIN  -from [get_ports i_RSTN]
group_path -name REGIN  -from [list [get_ports UART_RXD] [get_ports MPR121_SCL] [get_ports            \
MPR121_SDA] [get_ports ADS1292_MISO] [get_ports ADS1292_DRDY]]
group_path -name REGOUT  -to [list [get_ports UART_TXD] [get_ports MPR121_SCL] [get_ports MPR121_SDA]  \
[get_ports ADS1292_SCLK] [get_ports ADS1292_MOSI] [get_ports ADS1292_RESET]    \
[get_ports ADS1292_START] [get_ports ADS1292_CSN]]
set_false_path   -from [get_ports i_RSTN]
set_false_path   -from [get_pins                                                               \
async_rstn_glitch_synchronizer/async_rstn_synchronizer/r_ff_reg/CK]
set_false_path   -from [get_pins                                                               \
async_rstn_glitch_synchronizer/async_rstn_synchronizer/o_RSTN_reg/CK]
set_false_path   -to [get_pins                                                                 \
async_rstn_glitch_synchronizer/async_rstn_synchronizer/o_RSTN_reg/RN]
set_false_path   -to [get_pins                                                                 \
async_rstn_glitch_synchronizer/async_rstn_synchronizer/r_ff_reg/RN]
set_false_path   -from [list [get_pins                                                         \
khu_sensor_top/async_rstn_glitch_synchronizer/async_rstn_synchronizer/r_ff_reg/CK] \
[get_pins khu_sensor_top/uart_controller/async_rstn_synchronizer/r_ff_reg/CK]  \
[get_pins                                                                      \
khu_sensor_top/mpr121_controller/async_rstn_synchronizer/r_ff_reg/CK]          \
[get_pins khu_sensor_top/ads1292_filter/async_rstn_synchronizer/r_ff_reg/CK]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_controller/async_rstn_synchronizer/r_ff_reg/CK]]
set_false_path   -from [list [get_pins                                                         \
khu_sensor_top/async_rstn_glitch_synchronizer/async_rstn_synchronizer/o_RSTN_reg/CK] \
[get_pins                                                                      \
khu_sensor_top/uart_controller/async_rstn_synchronizer/o_RSTN_reg/CK]          \
[get_pins                                                                      \
khu_sensor_top/mpr121_controller/async_rstn_synchronizer/o_RSTN_reg/CK]        \
[get_pins khu_sensor_top/ads1292_filter/async_rstn_synchronizer/o_RSTN_reg/CK] \
[get_pins                                                                      \
khu_sensor_top/ads1292_controller/async_rstn_synchronizer/o_RSTN_reg/CK]]
set_false_path   -to [list [get_pins                                                           \
khu_sensor_top/async_rstn_glitch_synchronizer/async_rstn_synchronizer/o_RSTN_reg/RN] \
[get_pins                                                                      \
khu_sensor_top/uart_controller/async_rstn_synchronizer/o_RSTN_reg/RN]          \
[get_pins                                                                      \
khu_sensor_top/mpr121_controller/async_rstn_synchronizer/o_RSTN_reg/RN]        \
[get_pins khu_sensor_top/ads1292_filter/async_rstn_synchronizer/o_RSTN_reg/RN] \
[get_pins                                                                      \
khu_sensor_top/ads1292_controller/async_rstn_synchronizer/o_RSTN_reg/RN]]
set_false_path   -to [list [get_pins                                                           \
khu_sensor_top/async_rstn_glitch_synchronizer/async_rstn_synchronizer/r_ff_reg/RN] \
[get_pins khu_sensor_top/uart_controller/async_rstn_synchronizer/r_ff_reg/RN]  \
[get_pins                                                                      \
khu_sensor_top/mpr121_controller/async_rstn_synchronizer/r_ff_reg/RN]          \
[get_pins khu_sensor_top/ads1292_filter/async_rstn_synchronizer/r_ff_reg/RN]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_controller/async_rstn_synchronizer/r_ff_reg/RN]]
set_false_path   -from [list [get_pins                                                         \
khu_sensor_top/mpr121_controller/i2c_master/async_rstn_synchronizer/r_ff_reg/CK] \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_lpf/async_rstn_synchronizer/r_ff_reg/CK]     \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_notch/async_rstn_synchronizer/r_ff_reg/CK]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_hpf/async_rstn_synchronizer/r_ff_reg/CK]     \
[get_pins                                                                      \
khu_sensor_top/ads1292_controller/spi_master/async_rstn_synchronizer/r_ff_reg/CK]]
set_false_path   -from [list [get_pins                                                         \
khu_sensor_top/mpr121_controller/i2c_master/async_rstn_synchronizer/o_RSTN_reg/CK] \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_lpf/async_rstn_synchronizer/o_RSTN_reg/CK]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_notch/async_rstn_synchronizer/o_RSTN_reg/CK] \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_hpf/async_rstn_synchronizer/o_RSTN_reg/CK]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_controller/spi_master/async_rstn_synchronizer/o_RSTN_reg/CK]]
set_false_path   -to [list [get_pins                                                           \
khu_sensor_top/mpr121_controller/i2c_master/async_rstn_synchronizer/o_RSTN_reg/RN] \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_lpf/async_rstn_synchronizer/o_RSTN_reg/RN]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_notch/async_rstn_synchronizer/o_RSTN_reg/RN] \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_hpf/async_rstn_synchronizer/o_RSTN_reg/RN]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_controller/spi_master/async_rstn_synchronizer/o_RSTN_reg/RN]]
set_false_path   -to [list [get_pins                                                           \
khu_sensor_top/mpr121_controller/i2c_master/async_rstn_synchronizer/r_ff_reg/RN] \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_lpf/async_rstn_synchronizer/r_ff_reg/RN]     \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_notch/async_rstn_synchronizer/r_ff_reg/RN]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_hpf/async_rstn_synchronizer/r_ff_reg/RN]     \
[get_pins                                                                      \
khu_sensor_top/ads1292_controller/spi_master/async_rstn_synchronizer/r_ff_reg/RN]]
set_false_path   -from [list [get_pins                                                         \
khu_sensor_top/uart_controller/async_rst_synchronizer/r_ff_reg/CK] [get_pins   \
khu_sensor_top/sensor_core/async_rst_synchronizer/r_ff_reg/CK] [get_pins       \
khu_sensor_top/ads1292_filter/async_rst_synchronizer/r_ff_reg/CK]]
set_false_path   -from [list [get_pins                                                         \
khu_sensor_top/uart_controller/async_rst_synchronizer/o_RST_reg/CK] [get_pins  \
khu_sensor_top/sensor_core/async_rst_synchronizer/o_RST_reg/CK] [get_pins      \
khu_sensor_top/ads1292_filter/async_rst_synchronizer/o_RST_reg/CK]]
set_false_path   -to [list [get_pins                                                           \
khu_sensor_top/uart_controller/async_rst_synchronizer/o_RST_reg/SN] [get_pins  \
khu_sensor_top/sensor_core/async_rst_synchronizer/o_RST_reg/SN] [get_pins      \
khu_sensor_top/ads1292_filter/async_rst_synchronizer/o_RST_reg/SN]]
set_false_path   -to [list [get_pins                                                           \
khu_sensor_top/uart_controller/async_rst_synchronizer/r_ff_reg/SN] [get_pins   \
khu_sensor_top/sensor_core/async_rst_synchronizer/r_ff_reg/SN] [get_pins       \
khu_sensor_top/ads1292_filter/async_rst_synchronizer/r_ff_reg/SN]]
set_false_path   -from [list [get_pins                                                         \
khu_sensor_top/uart_controller/uart_tx/async_rst_synchronizer/r_ff_reg/CK]     \
[get_pins                                                                      \
khu_sensor_top/uart_controller/uart_rx/async_rst_synchronizer/r_ff_reg/CK]     \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_lpf/async_rst_synchronizer/r_ff_reg/CK]      \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_notch/async_rst_synchronizer/r_ff_reg/CK]    \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_hpf/async_rst_synchronizer/r_ff_reg/CK]]
set_false_path   -from [list [get_pins                                                         \
khu_sensor_top/uart_controller/uart_tx/async_rst_synchronizer/o_RST_reg/CK]    \
[get_pins                                                                      \
khu_sensor_top/uart_controller/uart_rx/async_rst_synchronizer/o_RST_reg/CK]    \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_lpf/async_rst_synchronizer/o_RST_reg/CK]     \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_notch/async_rst_synchronizer/o_RST_reg/CK]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_hpf/async_rst_synchronizer/o_RST_reg/CK]]
set_false_path   -to [list [get_pins                                                           \
khu_sensor_top/uart_controller/uart_tx/async_rst_synchronizer/o_RST_reg/SN]    \
[get_pins                                                                      \
khu_sensor_top/uart_controller/uart_rx/async_rst_synchronizer/o_RST_reg/SN]    \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_lpf/async_rst_synchronizer/o_RST_reg/SN]     \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_notch/async_rst_synchronizer/o_RST_reg/SN]   \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_hpf/async_rst_synchronizer/o_RST_reg/SN]]
set_false_path   -to [list [get_pins                                                           \
khu_sensor_top/uart_controller/uart_tx/async_rst_synchronizer/r_ff_reg/SN]     \
[get_pins                                                                      \
khu_sensor_top/uart_controller/uart_rx/async_rst_synchronizer/r_ff_reg/SN]     \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_lpf/async_rst_synchronizer/r_ff_reg/SN]      \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_notch/async_rst_synchronizer/r_ff_reg/SN]    \
[get_pins                                                                      \
khu_sensor_top/ads1292_filter/iir_hpf/async_rst_synchronizer/r_ff_reg/SN]]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/uart_controller/uart_tx/clk_gate_r_Tx_Data_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/uart_controller/uart_tx/clk_gate_o_Tx_Serial_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/uart_controller/uart_rx/clk_gate_r_Bit_Index_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/uart_controller/clk_gate_r_uart_data_tx_shift_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/uart_controller/clk_gate_r_uart_data_tx_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/uart_controller/clk_gate_o_UART_DATA_RX_reg_2/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/uart_controller/clk_gate_o_UART_DATA_RX_reg_1/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/sensor_core/clk_gate_o_UART_DATA_TX_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_ads_ch2_data_out_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_uart_clk_counter_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_ads_second_param_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_mpr_touch_status_reg_0/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/sensor_core/clk_gate_r_mpr_reg_data_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_ads_read_reg_done_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_mpr_touch_status_0_reg_0/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/sensor_core/clk_gate_r_mpr_reg_addr_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_mpr_first_param_reg_0/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/sensor_core/clk_gate_r_ads_reg_addr_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_o_MPR121_REG_ADDR_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_o_ADS1292_REG_ADDR_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_o_ADS1292_DATA_IN_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_mpr_second_param_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_o_MPR121_DATA_IN_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_mpr_touch_status_1_reg_0/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/sensor_core/clk_gate_r_mpr_lstate_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_ads_run_set_done_reg/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/sensor_core/clk_gate_r_ads_lstate_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/sensor_core/clk_gate_r_mpr_chip_set_done_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/mpr121_controller/i2c_master/clk_gate_last_reg_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/mpr121_controller/i2c_master/clk_gate_data_out_reg_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/mpr121_controller/i2c_master/clk_gate_phy_rx_data_reg_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/mpr121_controller/clk_gate_r_i2c_reg_addr_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/mpr121_controller/clk_gate_o_MPR121_INIT_SET_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/mpr121_controller/clk_gate_r_i2c_data_in_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/mpr121_controller/clk_gate_o_MPR121_DATA_OUT_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/mpr121_controller/clk_gate_r_i2c_write_multiple_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_i2f/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_i2f/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_i2f/clk_gate_z_m_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_i2f/clk_gate_value_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_i2f/clk_gate_a_reg_0/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_b_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_z_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_b_m_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_a_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_guard_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/add/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_a_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_product_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_b_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_a_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_sticky_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_1/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_a_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_product_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_b_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_a_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_sticky_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/mult_2/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/clk_gate_r_mult_1_A_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/clk_gate_r_x_data_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/clk_gate_r_y_data_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/clk_gate_r_add_B_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_lpf/clk_gate_o_Y_DATA_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_b_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_z_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_b_m_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_a_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_guard_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_1/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_b_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_z_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_b_m_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_a_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_guard_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/add_2/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_b_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_product_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_b_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_a_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_sticky_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_1/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_b_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_product_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_b_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_b_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_sticky_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_2/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_b_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_product_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_b_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_b_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_sticky_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/mult_3/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_r_mult_2_B_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_r_x_data_reg_1/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_r_x_data_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_r_y_data_reg_1/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_r_add_2_B_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_r_add_1_A_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_r_mult_3_B_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_o_Y_DATA_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_notch/clk_gate_r_mult_3_AB_STB_reg/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_b_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_z_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_b_m_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_a_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_round_bit_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/add/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_b_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_product_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_b_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_a_s_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_sticky_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_z_e_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/mult/clk_gate_a_e_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/clk_gate_r_x_data_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/clk_gate_r_add_A_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/clk_gate_r_mult_A_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/iir_hpf/clk_gate_o_Y_DATA_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_f2i/clk_gate_a_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_f2i/clk_gate_z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_f2i/clk_gate_o_Z_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_f2i/clk_gate_a_m_reg_2/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/converter_f2i/clk_gate_a_m_reg_1/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/clk_gate_r_iir_notch_x_reg_0/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/ads1292_filter/clk_gate_r_iir_lpf_x_reg_0/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/ads1292_filter/clk_gate_r_iir_hpf_x_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/clk_gate_r_converter_f2i_a_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/clk_gate_r_converter_i2f_a_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/clk_gate_o_ADS1292_FILTERED_DATA_reg_0/ENCLK]
set_max_delay 0  -from [get_pins khu_sensor_top/ads1292_filter/clk_gate_r_counter_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_filter/clk_gate_r_converter_f2i_a_stb_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/spi_master/clk_gate_r_TX_Byte_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/spi_master/clk_gate_r_SPI_Clk_Count_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/spi_master/clk_gate_o_RX_Byte_reg/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/spi_master/clk_gate_r_SPI_Clk_Edges_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_r_clk_counter_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_r_ads_data_out_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_o_ADS1292_DATA_OUT_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_r_ads_data_in_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_r_spi_data_in_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_r_ads_command_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_o_ADS1292_REG_DATA_OUT_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_r_lstate_reg_0/ENCLK]
set_max_delay 0  -from [get_pins                                                               \
khu_sensor_top/ads1292_controller/clk_gate_o_ADS1292_BUSY_reg/ENCLK]
set_input_delay -clock clk  -max 0.35  [get_ports UART_RXD]
set_input_delay -clock clk  -max 0.35  [get_ports MPR121_SCL]
set_input_delay -clock clk  -max 0.35  [get_ports MPR121_SDA]
set_input_delay -clock clk  -max 0.35  [get_ports ADS1292_MISO]
set_input_delay -clock clk  -max 0.35  [get_ports ADS1292_DRDY]
set_output_delay -clock clk  -max 0.5  [get_ports MPR121_SCL]
set_output_delay -clock clk  -max 0.5  [get_ports MPR121_SDA]
set_output_delay -clock clk  -max 0.5  [get_ports UART_TXD]
set_output_delay -clock clk  -max 0.5  [get_ports ADS1292_SCLK]
set_output_delay -clock clk  -max 0.5  [get_ports ADS1292_MOSI]
set_output_delay -clock clk  -max 0.5  [get_ports ADS1292_RESET]
set_output_delay -clock clk  -max 0.5  [get_ports ADS1292_START]
set_output_delay -clock clk  -max 0.5  [get_ports ADS1292_CSN]
set_input_transition -max 0.12  [get_ports UART_RXD]
set_input_transition -min 0.12  [get_ports UART_RXD]
set_input_transition -max 0.12  [get_ports MPR121_SCL]
set_input_transition -min 0.12  [get_ports MPR121_SCL]
set_input_transition -max 0.12  [get_ports MPR121_SDA]
set_input_transition -min 0.12  [get_ports MPR121_SDA]
set_input_transition -max 0.12  [get_ports ADS1292_MISO]
set_input_transition -min 0.12  [get_ports ADS1292_MISO]
set_input_transition -max 0.12  [get_ports ADS1292_DRDY]
set_input_transition -min 0.12  [get_ports ADS1292_DRDY]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad36]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad34]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad29]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad26]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad21]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad18]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad15]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad13]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad11]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad9]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad7]
set_operating_conditions -max SS65LP3P3V_WST_108_300_P125 -max_library         \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -min                \
SS65LP3P3V_WST_108_300_P125 -min_library                                       \
ss65lp3p3v_wst_108_300_p125.db:ss65lp3p3v_wst_108_300_p125 -object_list        \
[get_cells pad3]
set_load 0  [get_nets i_CLK]
set_resistance 0  [get_nets i_CLK]
set_load 0  [get_nets i_RSTN]
set_resistance 0  [get_nets i_RSTN]
set_load 0  [get_nets UART_RXD]
set_resistance 0  [get_nets UART_RXD]
set_load 0  [get_nets UART_TXD]
set_resistance 0  [get_nets UART_TXD]
set_load 0  [get_nets MPR121_SCL]
set_resistance 0  [get_nets MPR121_SCL]
set_load 0  [get_nets MPR121_SDA]
set_resistance 0  [get_nets MPR121_SDA]
set_load 0  [get_nets ADS1292_SCLK]
set_resistance 0  [get_nets ADS1292_SCLK]
set_load 0  [get_nets ADS1292_MISO]
set_resistance 0  [get_nets ADS1292_MISO]
set_load 0  [get_nets ADS1292_MOSI]
set_resistance 0  [get_nets ADS1292_MOSI]
set_load 0  [get_nets ADS1292_DRDY]
set_resistance 0  [get_nets ADS1292_DRDY]
set_load 0  [get_nets ADS1292_RESET]
set_resistance 0  [get_nets ADS1292_RESET]
set_load 0  [get_nets ADS1292_START]
set_resistance 0  [get_nets ADS1292_START]
set_load 0  [get_nets ADS1292_CSN]
set_resistance 0  [get_nets ADS1292_CSN]
