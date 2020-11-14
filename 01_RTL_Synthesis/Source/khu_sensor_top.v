/** Top module **/
module khu_sensor_top(
	// System I/O
	input i_CLK, // Clock
	input i_RSTN, // Reset

	// RS232 UART
	input UART_RXD,
	output UART_TXD,

	// DUT IO: for MPR121 (I2C)
	input MPR121_SCL_IN,
	input MPR121_SDA_IN,
	output MPR121_SCL_OUT,
	output MPR121_SDA_OUT,
	output MPR121_SCL_EN,
	output MPR121_SDA_EN,

	// DUT IO: for ADS1292 (SPI)
	output ADS1292_SCLK,
	input ADS1292_MISO,
	output ADS1292_MOSI,
	input ADS1292_DRDY,
	output ADS1292_RESET,
	output ADS1292_START,
	output ADS1292_CSN
	);
	/****************************************************************************
	*                           async_rstn_glitch_synchronizer                                   *
	*****************************************************************************/
// reset synchronizer with glitch filter for Reset recovery time and dont fall to metastability  
wire w_rstn;
async_rstn_glitch_synchronizer async_rstn_glitch_synchronizer (
    .i_CLK(i_CLK),
    .i_RSTN(i_RSTN),
    .o_RSTN(w_rstn)
    );
	/****************************************************************************
	*                           divider_by_2		                               	*
	*****************************************************************************/
	//=========================Internal Connection===============================
	wire w_CLOCK_HALF;
	divider_by_2 divider_by_2 (
	  .i_CLK(i_CLK),
	  .i_RSTN(w_rstn),
	  .o_CLK_DIV_2(w_CLOCK_HALF)
	  );

	//============================================================================
	//==============================wire & reg====================================
	// uart_controller
	wire [55:0] w_uart_data_tx;
	wire w_uart_data_tx_valid;
	wire w_uart_data_tx_ready;
	wire [15:0] w_uart_data_rx;
	wire w_uart_data_rx_valid;

	// sensor_core
	// System I/O
	wire w_chip_set;
	wire w_run_set;
	wire w_core_busy;

	// mpr121_controller
	wire [7:0] w_mpr121_data_out;
	wire [7:0] w_mpr121_reg_addr;
	wire [7:0] w_mpr121_data_in;
	wire w_mpr121_write_enable;
	wire w_mpr121_read_enable;
	wire w_mpr121_init_set;
	wire w_mpr121_busy;
	wire w_mpr121_fail;
	wire w_mpr121_error;

	// ads1292_filter
	wire [23:0] w_ads1292_filtered_data;
	wire w_ads1292_filtered_data_valid;
	wire w_ads1292_filtered_data_ack;

	// ads1292
	wire [23:0] w_ads1292_data_out;
	wire [2:0] w_ads1292_control;
	wire [7:0] w_ads1292_reg_addr;
	wire [7:0] w_ads1292_data_in;
	wire w_ads1292_data_valid;
	wire [7:0] w_ads1292_reg_data_out;
	wire w_ads1292_init_set;
	wire w_ads1292_busy;
	wire w_ads1292_fail;
	/****************************************************************************
	*                           uart_controller			                          	*
	*****************************************************************************/
	//=========================Internal Connection===============================

	uart_controller uart_controller(
		// TX
		.i_UART_DATA_TX(w_uart_data_tx),
		.i_UART_DATA_TX_VALID(w_uart_data_tx_valid),
		.o_UART_DATA_TX_READY(w_uart_data_tx_ready),
		// RX
		.o_UART_DATA_RX(w_uart_data_rx),
		.o_UART_DATA_RX_VALID(w_uart_data_rx_valid),

		.i_CORE_BUSY(w_core_busy),
		// System I/O
		.i_UART_RXD(UART_RXD), // external_interface.RXD
		.o_UART_TXD(UART_TXD), // external_interface.TXD
		.i_CLK(w_CLOCK_HALF),
		.i_RSTN(w_rstn)
		);
	//============================================================================

	/****************************************************************************
	*                           	sensor_core			        		                 	*
	*****************************************************************************/
	//=========================Internal Connection===============================
	sensor_core sensor_core(
		// UART Controller
		// TX
		.o_UART_DATA_TX(w_uart_data_tx), // tx data which send to PC
		.o_UART_DATA_TX_VALID(w_uart_data_tx_valid), // tx data valid
		.i_UART_DATA_TX_READY(w_uart_data_tx_ready), // tx Ready for next byte

		// RX
		.i_UART_DATA_RX(w_uart_data_rx), // rx data which receive from PC
		.i_UART_DATA_RX_VALID(w_uart_data_rx_valid), // rx data valid pulse

		// MPR121
		.i_MPR121_DATA_OUT(w_mpr121_data_out),  // received data from MPR121 (read data)
		.o_MPR121_REG_ADDR(w_mpr121_reg_addr),   // transmitted register address to MPR121 (write data)
		.o_MPR121_DATA_IN(w_mpr121_data_in),  // transmitted data to MPR121 (write data)
		.o_MPR121_WRITE_ENABLE(w_mpr121_write_enable),
		.o_MPR121_READ_ENABLE(w_mpr121_read_enable),
		.i_MPR121_INIT_SET(w_mpr121_init_set),
		.i_MPR121_BUSY(w_mpr121_busy),
		.i_MPR121_FAIL(w_mpr121_fail),

		// System connection with MPR121 data
		.o_MPR121_ERROR(w_mpr121_error),

		// ADS1292
		.i_ADS1292_FILTERED_DATA_OUT(w_ads1292_filtered_data), // read data from ADS1292
		.o_ADS1292_CONTROL(w_ads1292_control), // ADS1292 Control
		.o_ADS1292_REG_ADDR(w_ads1292_reg_addr), // ADS1292 register address
		.o_ADS1292_DATA_IN(w_ads1292_data_in), // data to write in ADS1292 register
		.i_ADS1292_REG_DATA_OUT(w_ads1292_reg_data_out), // reg data read 
		.i_ADS1292_INIT_SET(w_ads1292_init_set), // signal that start to read data in RDATAC mode
		.i_ADS1292_FILTERED_DATA_VALID(w_ads1292_filtered_data_valid), // In Read data continue mode,  flag that 72 bits data is ready (active posedge)
		.o_ADS1292_FILTERED_DATA_ACK(w_ads1292_filtered_data_ack),
		.i_ADS1292_BUSY(w_ads1292_busy),

		// System I/O
		.i_CLK(w_CLOCK_HALF),
		.i_RSTN(w_rstn)
	);
	//============================================================================

	/****************************************************************************
	*                           	mpr121_controller		     		                 	*
	*****************************************************************************/
	//=========================Internal Connection===============================
	mpr121_controller mpr121_controller(
		// Host Side
		.o_MPR121_DATA_OUT(w_mpr121_data_out), // read data from MPR121
		.o_MPR121_REG_ADDR(w_mpr121_reg_addr), // MPR121 register address
		.i_MPR121_DATA_IN(w_mpr121_data_in), // data to write in MPR121 register
		.i_MPR121_WRITE_ENABLE(w_mpr121_write_enable), // write enable
		.i_MPR121_READ_ENABLE(w_mpr121_read_enable), // read enable
		.o_MPR121_INIT_SET(w_mpr121_init_set),
		.o_MPR121_BUSY(w_mpr121_busy),
		.o_MPR121_FAIL(w_mpr121_fail),

		//	I2C Side
		.i_I2C_SCL_IN(MPR121_SCL_IN),
		.i_I2C_SDA_IN(MPR121_SDA_IN),
		.o_I2C_SCL_OUT(MPR121_SCL_OUT),
		.o_I2C_SDA_OUT(MPR121_SDA_OUT),
		.o_I2C_SCL_EN(MPR121_SCL_EN),
		.o_I2C_SDA_EN(MPR121_SDA_EN),

		.i_CLK(i_CLK), // clock
		.i_RSTN(w_rstn) // reset
		);
	//============================================================================
	/****************************************************************************
	*                           	ads1292_filter		   		                     	*
	*****************************************************************************/
	//=========================Internal Connection===============================
	ads1292_filter ads1292_filter(
	  .i_ADS1292_DATA_OUT(w_ads1292_data_out), // read data from ADS1292
	  .i_ADS1292_DATA_VALID(w_ads1292_data_valid), // In Read data continue mode,  flag that 72 bits data is ready
	  .o_ADS1292_FILTERED_DATA(w_ads1292_filtered_data),
	  .o_ADS1292_FILTERED_DATA_VALID(w_ads1292_filtered_data_valid),
	  .i_ADS1292_FILTERED_DATA_ACK(w_ads1292_filtered_data_ack),
	  .i_CLK(i_CLK), // clock
	  .i_RSTN(w_rstn) //reset
	  );
	/****************************************************************************
	*                           	ads1292_controller		   		                 	*
	*****************************************************************************/
	//=========================Internal Connection===============================
	ads1292_controller ads1292_controller(
		// Host Side
		.o_ADS1292_DATA_OUT(w_ads1292_data_out), // read data from ADS1292
		.i_ADS1292_CONTROL(w_ads1292_control), // ADS1292 Control
		.i_ADS1292_REG_ADDR(w_ads1292_reg_addr), // ADS1292 register address
		.i_ADS1292_DATA_IN(w_ads1292_data_in), // data to write in ADS1292 register
		.o_ADS1292_REG_DATA_OUT(w_ads1292_reg_data_out),
		.o_ADS1292_INIT_SET(w_ads1292_init_set), // signal that start to read data in RDATAC mode
		.o_ADS1292_DATA_VALID(w_ads1292_data_valid), // In Read data continue mode,  flag that 72 bits data is ready (active posedge)
		.o_ADS1292_BUSY(w_ads1292_busy),

		//	ADS1292, SPI Side
		.o_SPI_CLK(ADS1292_SCLK),
		.i_SPI_MISO(ADS1292_MISO), // SPI data form ADS - Master input Slave output (read)
		.o_SPI_MOSI(ADS1292_MOSI), // SPI data to ADS - Master Output Slave Input (write)
		.i_ADS1292_DRDY(ADS1292_DRDY), // Data Ready (active low) (change it active high)
		.o_ADS1292_RESET(ADS1292_RESET),
		.o_ADS1292_START(ADS1292_START),
		.o_SPI_CSN(ADS1292_CSN), // Chip Select Negative (active low)
		// When CS is taken high, the serial interface is reset, SCLK and DIN are ignored, and DOUT enters a high-impedance state

		.i_CLK(i_CLK), // clock
		.i_RSTN(w_rstn) //reset
		);
	//============================================================================
endmodule
