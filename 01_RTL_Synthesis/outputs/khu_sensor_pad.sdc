###################################################################

# Created by write_sdc on Thu Nov 19 19:11:04 2020

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -power mW -voltage V       \
-current mA
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
create_clock [get_ports i_CLK]  -name clk  -period 5.4  -waveform {0 2.7}
set_clock_latency 0.05  [get_clocks clk]
set_clock_latency -source 0.7  [get_clocks clk]
set_clock_uncertainty -setup 0.378  [get_clocks clk]
set_clock_transition -max -rise 0.7 [get_clocks clk]
set_clock_transition -min -fall 0.7 [get_clocks clk]
set_clock_transition -max -fall 0.7 [get_clocks clk]
set_clock_transition -min -rise 0.7 [get_clocks clk]
create_generated_clock [get_pins khu_sensor_top/divider_by_2/o_CLK_DIV_2]  -name clk_half  -source [get_ports i_CLK]  -divide_by 2
set_clock_latency 0.05  [get_clocks clk_half]
set_clock_latency -source 0.7  [get_clocks clk_half]
set_clock_uncertainty -setup 0.756  [get_clocks clk_half]
set_clock_transition -max -rise 0.7 [get_clocks clk_half]
set_clock_transition -min -fall 0.7 [get_clocks clk_half]
set_clock_transition -max -fall 0.7 [get_clocks clk_half]
set_clock_transition -min -rise 0.7 [get_clocks clk_half]
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
