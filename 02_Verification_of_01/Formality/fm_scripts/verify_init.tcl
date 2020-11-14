# Initial verify (RTL - Gate Level)
echo "***********************************************************************"
echo "                                                                       "
echo "                            verify_init.tcl                            "
echo "                                                                       "
echo "***********************************************************************"

# MPR121
#source "${tcl_path}MPR121/i2c_master/i2c_master.tcl"
#source "${tcl_path}MPR121/mpr121_controller/mpr121_controller.tcl"

# ADS1292i
#source "${tcl_path}ADS1292/spi_master/spi_master.tcl"
#source "${tcl_path}ADS1292/ads1292_controller/ads1292_controller.tcl"

# ADS1292_Filter
#source "${tcl_path}ADS1292/ADS1292_Filter/float_adder/float_adder.tcl"
source "${tcl_path}ADS1292/ADS1292_Filter/float_multiplier/float_multiplier.tcl"
#source "${tcl_path}ADS1292/ADS1292_Filter/iir_lpf/iir_lpf.tcl"

#source "${tcl_path}ADS1292/ADS1292_Filter/iir_hpf/iir_hpf.tcl"

#source "${tcl_path}ADS1292/ADS1292_Filter/iir_notch/iir_notch.tcl"

#source "${tcl_path}ADS1292/ADS1292_Filter/converter_f2i/converter_f2i.tcl"
#source "${tcl_path}ADS1292/ADS1292_Filter/converter_i2f/converter_i2f.tcl"
#source "${tcl_path}ADS1292/ADS1292_Filter/ads1292_filter/ads1292_filter.tcl"

# Sensor_Core
#source "${tcl_path}Sensor_Core/sensor_core.tcl"

# Uart_Controller
#source "${tcl_path}UART_Controller/uart_rx/uart_rx.tcl"
#source "${tcl_path}UART_Controller/uart_tx/uart_tx.tcl"
#source "${tcl_path}UART_Controller/uart_controller/uart_controller.tcl"

# khu_sensor_top, khu_sensor_pad
#source "${tcl_path}khu_sensor_pad/khu_sensor_pad.tcl"
