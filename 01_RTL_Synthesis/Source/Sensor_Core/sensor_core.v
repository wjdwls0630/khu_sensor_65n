///////////////////////////////////////////////////////////////////////////////
// Module Name : sensor_core
//
// Description: sensor_core is module for controlling mpr121 and ads1292,
// 							In addition, process data from TX and RX
//
//
///////////////////////////////////////////////////////////////////////////////
//TODO fix filter connection, uart wire ,  modify header, tail parameter name
// delete unused wire and reg, mpr121 Transimit Hertz 250Hz?
// keep LED status changing hertz, let sensor core extract mpr data and give it to uart controller when ads data is ready
module sensor_core(
	// UART Controller
	output reg [55:0] o_UART_DATA_TX, // tx data which send to PC
	output reg o_UART_DATA_TX_VALID, // tx data valid
	input i_UART_DATA_TX_READY, // tx Ready for next byte
	input [15:0] i_UART_DATA_RX, // rx data which receive from PC
	input i_UART_DATA_RX_VALID, // rx data valid pulse

	// MPR121
	input [7:0] i_MPR121_DATA_OUT,  // received data from MPR121 (read data)
	output reg [7:0] o_MPR121_REG_ADDR,   // transmitted register address to MPR121 (write data)
	output reg [7:0] o_MPR121_DATA_IN,  // transmitted data to MPR121 (write data)
	output reg o_MPR121_WRITE_ENABLE,
	output reg o_MPR121_READ_ENABLE,
	input i_MPR121_INIT_SET,
	input i_MPR121_BUSY,
	input i_MPR121_FAIL,

	// System connection with MPR121 data
	output reg o_MPR121_ERROR,

	// ADS1292
	input [23:0] i_ADS1292_FILTERED_DATA_OUT, // read data from ADS1292
	output reg [2:0] o_ADS1292_CONTROL, // ADS1292 Control
	output reg [7:0] o_ADS1292_REG_ADDR, // ADS1292 register address
	output reg [7:0] o_ADS1292_DATA_IN, // data to write in ADS1292 register
	input [7:0] i_ADS1292_REG_DATA_OUT,
	input i_ADS1292_INIT_SET, // signal that start to read data in RDATAC mode
	input i_ADS1292_FILTERED_DATA_VALID, // In Read data continue mode,  flag that 72 bits data is ready
	output reg o_ADS1292_FILTERED_DATA_ACK,
	input i_ADS1292_BUSY,

	// System I/O
	input i_CLK,
	input i_RSTN
	);

	/*****************************************************************************
	*                          		UART Controller                                *
	*****************************************************************************/
	//==============================Parameter=====================================
	// UART Signal (user defined)
	parameter UART_SG_MPR_SEND_DATA = 8'hBB;
	parameter UART_SG_MPR_READ_REG = 8'h6D; // 'm'
	parameter UART_SG_ADS_SEND_DATA = 8'hAA;
	parameter UART_SG_ADS_READ_REG = 8'h61; // 'a'
	parameter UART_SG_RUN = 8'h52; // 'R'
	parameter UART_SG_STOP = 8'h53; // 'S'
	//============================================================================
	//==============================State=========================================
	reg [7:0] r_uart_pstate;

	// uart_controller
	// 8'b0011_xxxx
	parameter ST_UART_IDLE  = 8'd48;
	parameter ST_UART_STANDBY  = 8'd49;
	parameter ST_UART_RX = 8'd50;
	//============================================================================

	//==============================wire & reg====================================
	reg [15:0] r_uart_data_rx;
	reg r_run_mode;
	reg r_mpr_read_reg_mode;
	reg r_ads_read_reg_mode;
	reg r_ads_data_send_ready; // ads data is ready to send
	reg [23:0] r_ads_ch2_data_out; // ch2 data
	reg [15:0] r_mpr_touch_status; // 0x01 + 0x00
	reg r_ads_read_reg_done;
	reg r_mpr_read_reg_done;
	reg [7:0] r_mpr_reg_addr;
	reg [7:0] r_mpr_reg_data;
	reg [7:0] r_ads_reg_addr;
	reg [7:0] r_ads_reg_data;
	reg [3:0] r_uart_clk_counter;
	//============================================================================
	/****************************************************************************
	*                           async_rst_synchronizer                                   *
	*****************************************************************************/
// reset synchronizer for Reset recovery time and dont fall to metastability  
wire w_rst;
async_rst_synchronizer async_rst_synchronizer (
    .i_CLK(i_CLK),
    .i_RSTN(i_RSTN),
    .o_RST(w_rst)
    );

	//=============================Sequential Logic===============================
	always @ ( posedge i_CLK, posedge w_rst ) begin
		if(w_rst) begin
			o_UART_DATA_TX <= 56'b0;
			o_UART_DATA_TX_VALID <= 1'b0;
			r_uart_data_rx <= 16'b0;

			r_run_mode <= 1'b0;
			r_mpr_read_reg_mode <= 1'b0;
			r_ads_read_reg_mode <= 1'b0;
			r_uart_clk_counter <= 4'b0;
			// state
			r_uart_pstate <= ST_UART_IDLE;
		end else begin
			case (r_uart_pstate)
				ST_UART_IDLE:
				begin
					r_uart_data_rx <= 16'b0;
					r_run_mode <= 1'b0;
					r_mpr_read_reg_mode <= 1'b0;
					r_ads_read_reg_mode <= 1'b0;
					// wait for other modules 
					// due to reset synchronizer
					if(r_uart_clk_counter == 4'b1111) begin 
						r_uart_clk_counter <= 4'b0;
						r_uart_pstate <= ST_UART_STANDBY;
					end else begin 
						r_uart_clk_counter <= r_uart_clk_counter + 1'b1;
						r_uart_pstate <= ST_UART_IDLE;
					end
				end

				ST_UART_STANDBY:
				begin
					if(i_UART_DATA_RX_VALID) begin
						r_uart_data_rx <= i_UART_DATA_RX;
						r_uart_pstate <= ST_UART_RX;
					end else begin
						// update tx data
						if(i_UART_DATA_TX_READY) begin
							if(r_ads_data_send_ready) begin
								o_UART_DATA_TX <= {UART_SG_ADS_SEND_DATA, r_ads_ch2_data_out, r_mpr_touch_status, UART_SG_MPR_SEND_DATA};
								o_UART_DATA_TX_VALID <= 1'b1;
							end else if(r_ads_read_reg_done) begin
							r_ads_read_reg_mode <= 1'b0;
								o_UART_DATA_TX <= {UART_SG_ADS_READ_REG, r_ads_reg_addr, r_ads_reg_data, 32'b0};
								o_UART_DATA_TX_VALID <= 1'b1;
							end else if(r_mpr_read_reg_done) begin
								r_mpr_read_reg_mode <= 1'b0;
								o_UART_DATA_TX <= {UART_SG_MPR_READ_REG, r_mpr_reg_addr, r_mpr_reg_data, 32'b0};
								o_UART_DATA_TX_VALID <= 1'b1;
							end else o_UART_DATA_TX_VALID <= 1'b0;
						end else o_UART_DATA_TX_VALID <= 1'b0;
						r_uart_pstate <= ST_UART_STANDBY;
					end
				end

				ST_UART_RX:
				begin
					if(r_uart_data_rx[15:8] == UART_SG_RUN) r_run_mode <= 1'b1;
					else if(r_uart_data_rx[15:8] == UART_SG_STOP) r_run_mode <= 1'b0;
					else if(r_uart_data_rx[15:8] == UART_SG_MPR_READ_REG) r_mpr_read_reg_mode <= 1'b1;
					else if(r_uart_data_rx[15:8] == UART_SG_ADS_READ_REG) r_ads_read_reg_mode <= 1'b1;
					r_uart_pstate <= ST_UART_STANDBY;
				end

				default:
				begin
					r_uart_pstate <= ST_UART_IDLE;
				end
			endcase
		end
	end
	//============================================================================

	/****************************************************************************
	*                           	Sensor_Core                                  	*
	*****************************************************************************/
	//==============================State=========================================
	reg [7:0] r_core_pstate;

	// Sensor_Core
	// 8'b0000_xxxx
	parameter ST_CORE_IDLE  = 8'd0;
	parameter ST_CORE_WAIT_INIT_SET = 8'd1;
	parameter ST_CORE_CHIP_SET = 8'd2;
	parameter ST_CORE_STANDBY = 8'd3;
	parameter ST_CORE_IS_READING = 8'd4;
	//============================================================================

	//==============================wire & reg====================================
	// chip setting logic
	reg r_mpr_chip_set; // signal that change mpr setting state
	reg r_mpr_chip_set_done; // signal that mpr chip setting process is done
	reg r_ads_chip_set; // signal that change ads setting state
	reg r_ads_chip_set_done; // signal that ads chip setting process is done
	reg r_chip_set;
	always @ ( posedge i_CLK, posedge w_rst ) begin
		if(w_rst) r_chip_set <= 1'b0;
		else r_chip_set <= r_mpr_chip_set_done & r_ads_chip_set_done;
	end


	// run condition logic for both mpr and ads
	reg r_mpr_run_set; // signal that change mpr run state
	reg r_mpr_run_set_done; // signal that turning on mpr run state process is done
	reg r_ads_run_set; // signal that change ads run state
	reg r_ads_run_set_done; // signal that turning on ads run state process is done
	reg r_run_set;
	always @ ( posedge i_CLK, posedge w_rst ) begin
		if(w_rst) r_run_set <= 1'b0;
		else r_run_set <= r_mpr_run_set_done & r_ads_run_set_done;
	end


	// reading condition logic for both mpr and ads
	reg r_mpr_is_reading; // flag that mpr is reading or not
	reg r_ads_is_reading; // flag that ads is reading or not
	/*
	reg r_core_busy;
	always @ ( posedge i_CLK, posedge i_RST ) begin
		if(i_RST) r_core_busy <= 1'b0;
		else r_core_busy <= r_mpr_is_reading & r_ads_is_reading;
	end
	*/


	// read reg condition
	reg r_mpr_read_reg;
	reg r_ads_read_reg;
	//============================================================================

	//=============================Sequential Logic===============================
	always @ ( posedge i_CLK, posedge w_rst ) begin
		if(w_rst) begin
			// MPR121 State Control
			r_mpr_chip_set <= 1'b0;
			r_mpr_run_set <= 1'b0;
			r_mpr_is_reading <= 1'b0;
			r_mpr_read_reg <= 1'b0;

			// ADS1292 State Control
			r_ads_chip_set <= 1'b0;
			r_ads_run_set <= 1'b0;
			r_ads_is_reading <= 1'b0;
			r_ads_read_reg <= 1'b0;

			// state
			r_core_pstate <= ST_CORE_IDLE;
		end else begin
			case (r_core_pstate)
				ST_CORE_IDLE:
				begin
					// MPR121 State Control
					r_mpr_chip_set <= 1'b0;
					r_mpr_run_set <= 1'b0;
					r_mpr_is_reading <= 1'b0;
					r_mpr_read_reg <= 1'b0;

					// ADS1292 State Control
					r_ads_chip_set <= 1'b0;
					r_ads_run_set <= 1'b0;
					r_ads_is_reading <= 1'b0;
					r_ads_read_reg <= 1'b0;

					// state
					r_core_pstate <= ST_CORE_WAIT_INIT_SET;
				end

				ST_CORE_WAIT_INIT_SET:
				begin
					// wait inital setting of both MPR121 and ADS1292
					if(i_MPR121_INIT_SET & i_ADS1292_INIT_SET) r_core_pstate <= ST_CORE_CHIP_SET;
					else r_core_pstate <= ST_CORE_WAIT_INIT_SET;
				end

				ST_CORE_CHIP_SET:
				begin
					if(!r_chip_set) begin
						if(!r_mpr_chip_set_done) r_mpr_chip_set <= 1'b1;
						else r_mpr_chip_set <= 1'b0; // don't need to set the chip again before reset or power off
						if(!r_ads_chip_set_done) r_ads_chip_set <= 1'b1;
						else r_ads_chip_set <= 1'b0; // don't need to set the chip again before reset or power off
						r_core_pstate <= ST_CORE_CHIP_SET;
					end else r_core_pstate <= ST_CORE_STANDBY;
				end

				ST_CORE_STANDBY:
				begin
					if(r_run_mode) begin // when receive run signal
						if(!r_mpr_run_set_done) r_mpr_run_set <= 1'b1;
						else r_mpr_is_reading <= 1'b1;
						if(!r_ads_run_set_done) r_ads_run_set <= 1'b1;
						else r_ads_is_reading <= 1'b1;
					end else if(r_mpr_read_reg_mode) begin
						if(!r_mpr_read_reg_done) r_mpr_read_reg <= 1'b1;
						else r_mpr_read_reg <= 1'b0;
					end else if(r_ads_read_reg_mode) begin
						if(!r_ads_read_reg_done) r_ads_read_reg <= 1'b1;
						else r_ads_read_reg <= 1'b0;
					end else begin // when receive stop signal
						if(r_mpr_run_set_done) r_mpr_run_set <= 1'b0;
						else r_mpr_is_reading <= 1'b0;

						if(r_ads_run_set_done) r_ads_run_set <= 1'b0;
						else r_ads_is_reading <= 1'b0;;
					end
					// if satisfy all condition to run & read, sensor_core is going to ~
					if (r_run_mode & r_run_set) r_core_pstate <= ST_CORE_IS_READING;
					else r_core_pstate <= ST_CORE_STANDBY;
				end

				ST_CORE_IS_READING:
				begin
					// core is reading
					if(r_run_mode) r_core_pstate <= ST_CORE_IS_READING;
					else r_core_pstate <= ST_CORE_STANDBY;
				end

				default:
				begin
					r_core_pstate <= ST_CORE_IDLE;
				end
			endcase
		end
	end
	//============================================================================

	/****************************************************************************
	*                           		MPR121                                     	*
	*****************************************************************************/
	//==============================Parameter=====================================
	// MPR121 Register Setting
	// Reference - Data Sheet - MPR121 setting recommendation
	parameter MPR_TOUCH_STATUS_0_REG = 8'h00; //read only (ELE0 ~ ELE7)
	parameter MPR_TOUCH_STATUS_1_REG = 8'h01; //read only (ELE8 ~ ELE11)
	parameter MPR_MHDR_REG = 8'h2B; parameter MPR_MHDR_DATA = 8'h01;
	parameter MPR_NHDAR_REG = 8'h2C; parameter MPR_NHDAR_DATA = 8'h01;
	parameter MPR_NCLR_REG = 8'h2D; parameter MPR_NCLR_DATA = 8'h0E;
	parameter MPR_FDLR_REG = 8'h2E; parameter MPR_FDLR_DATA = 8'h00;
	parameter MPR_MHDF_REG = 8'h2F; parameter MPR_MHDF_DATA = 8'h01;
	parameter MPR_NHDAF_REG = 8'h30; parameter MPR_NHDAF_DATA = 8'h05;
	parameter MPR_NCLF_REG = 8'h31; parameter MPR_NCLF_DATA = 8'h01;
	parameter MPR_FDLF_REG = 8'h32; parameter MPR_FDLF_DATA = 8'h00;
	parameter MPR_NHDAT_REG = 8'h33; parameter MPR_NHDAT_DATA = 8'h00;
	parameter MPR_NCLT_REG = 8'h34; parameter MPR_NCLT_DATA = 8'h00;
	parameter MPR_FDLT_REG = 8'h35; parameter MPR_FDLT_DATA = 8'h00;
	parameter MPR_DEBOUNCE_REG = 8'h5B; parameter MPR_DEBOUNCE_DATA = 8'h00;
	parameter MPR_FILTER_CDC_CONFIG_REG = 8'h5C; parameter MPR_FILTER_CDC_CONFIG_DATA = 8'h10;
	parameter MPR_FILTER_CDT_CONFIG_REG = 8'h5D; parameter MPR_FILTER_CDT_CONFIG_DATA = 8'h20;
	parameter MPR_ELE_CONFIG_REG = 8'h5E; parameter MPR_ELE_CONFIG_RUN = 8'h8F;

	// Auto config
	parameter MPR_AUTOCONFIG_0_REG = 8'h7B; parameter MPR_AUTOCONFIG_0_DATA = 8'h0B;
	parameter MPR_AUTOCONFIG_USL_REG = 8'h7D; parameter MPR_AUTOCONFIG_USL_DATA = 8'h9C;
	parameter MPR_AUTOCONFIG_LSL_REG = 8'h7E; parameter MPR_AUTOCONFIG_LSL_DATA = 8'h65;
	parameter MPR_AUTOCONFIG_TLR_REG = 8'h7F; parameter MPR_AUTOCONFIG_TLR_DATA = 8'h8C;
	//============================================================================

	//==============================State=========================================
	reg [7:0] r_mpr_lstate;
	reg [7:0] r_mpr_pstate;

	// MPR121
	// 8'b0001_xxxx
	parameter ST_MPR_IDLE  = 8'd16;
	parameter ST_MPR_SETTING = 8'd17;
	parameter ST_MPR_RUN = 8'd18;
	parameter ST_MPR_STOP = 8'd19;
	parameter ST_MPR_WRITE_REG_INIT = 8'd20;
	parameter ST_MPR_WRITE_REG_EN = 8'd21;
	parameter ST_MPR_WRITE_REG_CONFIRM = 8'd22;
	parameter ST_MPR_WRITE_REG_WAIT = 8'd23;
	parameter ST_MPR_READ_REG_INIT = 8'd24;
	parameter ST_MPR_READ_REG_EN = 8'd25;
	parameter ST_MPR_READ_REG_CONFIRM = 8'd26;
	parameter ST_MPR_READ_REG_WAIT = 8'd27;
	parameter ST_MPR_READ_STATUS_INIT = 8'd28;
	parameter ST_MPR_READ_STATUS_START = 8'd29;
	parameter ST_MPR_READ_STATUS_EN = 8'd30;
	parameter ST_MPR_READ_STATUS_CONFIRM = 8'd31;
	parameter ST_MPR_READ_STATUS_CHANGE = 8'd32;
	parameter ST_MPR_READ_STATUS_WAIT = 8'd33;
	parameter ST_MPR_ERROR_REPORT = 8'd34;
	//============================================================================

	//==============================wire & reg====================================
	reg [3:0] r_mpr_set_counter; // mpr setting counter
	reg [7:0] r_mpr_first_param;
	reg [7:0] r_mpr_second_param;
	reg r_mpr_status; // status_0 read(0) status_1 read(1)
	reg [7:0] r_mpr_touch_status_0; // reg_addr : 0x00 data
	reg [7:0] r_mpr_touch_status_1; // reg_addr : 0x01 data
	reg [3:0] r_mpr_clk_counter;
	//============================================================================

	//=============================Sequential Logic===============================
	always @ ( posedge i_CLK, posedge w_rst ) begin
		if(w_rst) begin

			// i_MPR121_DATA_OUT,  // received data from MPR121 (read data)
			o_MPR121_REG_ADDR <= 8'b0;   // transmitted register address to MPR121 (write data)
			o_MPR121_DATA_IN <= 8'b0;  // transmitted data to MPR121 (write data)
			o_MPR121_WRITE_ENABLE <= 1'b0;
			o_MPR121_READ_ENABLE <= 1'b0;

			// System connection with MPR121 data
			o_MPR121_ERROR <= 1'b0;

			// sensor_core & uart
			r_mpr_read_reg_done <= 1'b0; // default
			r_mpr_reg_addr <= 8'b0;
			r_mpr_reg_data <= 8'b0;

			// sensor_core
			r_mpr_chip_set_done <= 1'b0;
			r_mpr_run_set_done <= 1'b0;

			// reg
			r_mpr_set_counter <= 4'b0;
			r_mpr_first_param <= 8'b0;
			r_mpr_second_param <= 8'b0;
			r_mpr_reg_addr <= 8'b0;
			r_mpr_reg_data <= 8'b0;
			r_mpr_status <= 1'b0;
			r_mpr_touch_status_0 <= 8'b0;
			r_mpr_touch_status_1 <= 8'b0;
			r_mpr_touch_status <= 16'b0;
			r_mpr_clk_counter <= 4'b0;

			// state
			r_mpr_lstate <= ST_MPR_IDLE;
			r_mpr_pstate <= ST_MPR_IDLE;
		end else begin
			case (r_mpr_pstate)
				ST_MPR_IDLE:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b0;

					// sensor_core & uart
					r_mpr_read_reg_done <= 1'b0; // default
					r_mpr_reg_addr <= 8'b0;
					r_mpr_reg_data <= 8'b0;

					r_mpr_set_counter <= 4'b0;
					r_mpr_first_param <= 8'b0;
					r_mpr_second_param <= 8'b0;
					r_mpr_reg_addr <= 8'b0;
					r_mpr_reg_data <= 8'b0;
					r_mpr_status <= 1'b0;
					r_mpr_touch_status_0 <= 8'b0;
					r_mpr_touch_status_1 <= 8'b0;
					r_mpr_touch_status <= 16'b0;
					r_mpr_clk_counter <= 4'b0;

					if(r_mpr_chip_set &&(!r_mpr_chip_set_done)) r_mpr_pstate <= ST_MPR_SETTING;
					else if(r_mpr_run_set &&(!r_mpr_run_set_done)) r_mpr_pstate <= ST_MPR_RUN;
					else if (r_mpr_read_reg &&(!r_mpr_read_reg_done)) begin
						r_mpr_first_param <= r_uart_data_rx[7:0];
						r_mpr_reg_addr <= r_uart_data_rx[7:0]; // for sending data to pc
						r_mpr_pstate <= ST_MPR_READ_REG_INIT;
					end else r_mpr_pstate <= ST_MPR_IDLE;
				end

				ST_MPR_SETTING:
				begin
					// MPR121 Setting
					if(r_mpr_set_counter > 4'd13) begin
						r_mpr_chip_set_done <= 1'b1;
						r_mpr_set_counter <= 4'd0;
						r_mpr_pstate <= ST_MPR_IDLE;
					end else begin
						if(r_mpr_set_counter == 4'd0) begin
							r_mpr_first_param <= MPR_MHDR_REG;
							r_mpr_second_param <= MPR_MHDR_DATA;
						end

						if(r_mpr_set_counter == 4'd1) begin
							r_mpr_first_param <= MPR_NHDAR_REG;
							r_mpr_second_param <= MPR_NHDAR_DATA;
						end

						if(r_mpr_set_counter == 4'd2) begin
							r_mpr_first_param <= MPR_NCLR_REG;
							r_mpr_second_param <= MPR_NCLR_DATA;
						end

						if(r_mpr_set_counter == 4'd3) begin
							r_mpr_first_param <= MPR_FDLR_REG;
							r_mpr_second_param <= MPR_FDLR_DATA;
						end

						if(r_mpr_set_counter == 4'd4) begin
							r_mpr_first_param <= MPR_MHDF_REG;
							r_mpr_second_param <= MPR_MHDF_DATA;
						end

						if(r_mpr_set_counter == 4'd5) begin
							r_mpr_first_param <= MPR_NHDAF_REG;
							r_mpr_second_param <= MPR_NHDAF_DATA;
						end

						if(r_mpr_set_counter == 4'd6) begin
							r_mpr_first_param <= MPR_NCLF_REG;
							r_mpr_second_param <= MPR_NCLF_DATA;
						end

						if(r_mpr_set_counter == 4'd7) begin
							r_mpr_first_param <= MPR_FDLF_REG;
							r_mpr_second_param <= MPR_FDLF_DATA;
						end

						if(r_mpr_set_counter == 4'd8) begin
							r_mpr_first_param <= MPR_NHDAT_REG;
							r_mpr_second_param <= MPR_NHDAT_DATA;
						end

						if(r_mpr_set_counter == 4'd9) begin
							r_mpr_first_param <= MPR_NCLT_REG;
							r_mpr_second_param <= MPR_NCLT_DATA;
						end

						if(r_mpr_set_counter == 4'd10) begin
							r_mpr_first_param <= MPR_FDLT_REG;
							r_mpr_second_param <= MPR_FDLT_DATA;
						end

						if(r_mpr_set_counter == 4'd11) begin
							r_mpr_first_param <= MPR_DEBOUNCE_REG;
							r_mpr_second_param <= MPR_DEBOUNCE_DATA;
						end

						if(r_mpr_set_counter == 4'd12) begin
							r_mpr_first_param <= MPR_FILTER_CDC_CONFIG_REG;
							r_mpr_second_param <= MPR_FILTER_CDC_CONFIG_DATA;
						end

						if(r_mpr_set_counter == 4'd13) begin
							r_mpr_first_param <= MPR_FILTER_CDT_CONFIG_REG;
							r_mpr_second_param <= MPR_FILTER_CDT_CONFIG_REG;
						end

						r_mpr_set_counter <= r_mpr_set_counter + 1'b1;
						r_mpr_lstate <= ST_MPR_SETTING;
						r_mpr_pstate <= ST_MPR_WRITE_REG_INIT;
					end
				end

				ST_MPR_RUN:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b0;
					r_mpr_first_param <= MPR_ELE_CONFIG_REG;
					r_mpr_second_param <= MPR_ELE_CONFIG_RUN;
					r_mpr_lstate <= ST_MPR_RUN;
					r_mpr_pstate <= ST_MPR_WRITE_REG_INIT;
				end

				ST_MPR_STOP:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b0;
					r_mpr_first_param <= MPR_ELE_CONFIG_REG;
					r_mpr_second_param <= 8'h00; // disable
					r_mpr_lstate <= ST_MPR_STOP;
					r_mpr_pstate <= ST_MPR_WRITE_REG_INIT;
				end

				// Write data to a register of MPR121 then read back
				ST_MPR_WRITE_REG_INIT:
				begin
					o_MPR121_REG_ADDR <= r_mpr_first_param;
					o_MPR121_DATA_IN <= r_mpr_second_param;
					r_mpr_pstate <= ST_MPR_WRITE_REG_EN;
				end

				ST_MPR_WRITE_REG_EN:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b1;
					o_MPR121_READ_ENABLE <= 1'b0;
					r_mpr_pstate <= ST_MPR_WRITE_REG_CONFIRM;
				end

				ST_MPR_WRITE_REG_CONFIRM:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b0;
					if (i_MPR121_BUSY) r_mpr_pstate <= ST_MPR_WRITE_REG_CONFIRM;
					else begin
						if (i_MPR121_FAIL) r_mpr_pstate <= ST_MPR_ERROR_REPORT;
						else r_mpr_pstate <= ST_MPR_WRITE_REG_WAIT;
					end
				end

				ST_MPR_WRITE_REG_WAIT:
				begin
					if(r_mpr_lstate == ST_MPR_SETTING) r_mpr_pstate <= ST_MPR_SETTING;
					else begin
						if(r_mpr_lstate == ST_MPR_RUN) begin
							r_mpr_run_set_done <= 1'b1;
							r_mpr_pstate <= ST_MPR_READ_STATUS_INIT;
						end else begin
						 	// when mpr stop
							r_mpr_run_set_done <= 1'b0;
							r_mpr_pstate <= ST_MPR_IDLE;
						end
					end
				end

				ST_MPR_READ_REG_INIT:
				begin
					o_MPR121_REG_ADDR <= r_mpr_first_param;
					r_mpr_pstate <= ST_MPR_READ_REG_EN;
				end

				ST_MPR_READ_REG_EN:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b1;
					r_mpr_pstate <= ST_MPR_READ_REG_CONFIRM;
				end

				ST_MPR_READ_REG_CONFIRM:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b0;
					if (i_MPR121_BUSY) r_mpr_pstate <= ST_MPR_READ_REG_CONFIRM;
					else begin
						if (i_MPR121_FAIL) r_mpr_pstate <= ST_MPR_ERROR_REPORT;
						else begin
							r_mpr_read_reg_done <= 1'b1;
							r_mpr_reg_data <= i_MPR121_DATA_OUT;
							r_mpr_pstate <= ST_MPR_READ_REG_WAIT;
						end
					end
				end

				ST_MPR_READ_REG_WAIT:
				begin
					if(r_mpr_clk_counter > 4'd4) begin
						r_mpr_clk_counter <= 4'b0;
						r_mpr_pstate <= ST_MPR_IDLE;
					end else begin
						r_mpr_clk_counter <= r_mpr_clk_counter + 1'b1;
						r_mpr_pstate <= ST_MPR_READ_REG_WAIT;
					end
				end

				// read data from MPR121
				ST_MPR_READ_STATUS_INIT:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b0;
					if((!r_mpr_run_set) && r_mpr_run_set_done) r_mpr_pstate <= ST_MPR_STOP;
					else begin
						if(r_mpr_status == 1'b0) r_mpr_first_param <= MPR_TOUCH_STATUS_0_REG; // MPR Touch_0 Status Register addr
						else r_mpr_first_param <= MPR_TOUCH_STATUS_1_REG;
						r_mpr_pstate <= ST_MPR_READ_STATUS_START;
					end
				end

				ST_MPR_READ_STATUS_START:
				begin
					o_MPR121_REG_ADDR <= r_mpr_first_param;
					r_mpr_pstate <= ST_MPR_READ_STATUS_EN;
				end

				ST_MPR_READ_STATUS_EN:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b1;
					r_mpr_pstate <= ST_MPR_READ_STATUS_CONFIRM;
				end

				ST_MPR_READ_STATUS_CONFIRM:
				begin
					o_MPR121_WRITE_ENABLE <= 1'b0;
					o_MPR121_READ_ENABLE <= 1'b0;
					if (i_MPR121_BUSY) r_mpr_pstate <= ST_MPR_READ_STATUS_CONFIRM;
					else begin
						if (i_MPR121_FAIL) r_mpr_pstate <= ST_MPR_ERROR_REPORT;
						else begin
							if (r_mpr_status == 1'b0) begin
								r_mpr_touch_status_0 <= i_MPR121_DATA_OUT;
							end else begin
								r_mpr_touch_status_1 <= i_MPR121_DATA_OUT;
							end
							r_mpr_pstate <= ST_MPR_READ_STATUS_CHANGE;
						end
					end
				end

				ST_MPR_READ_STATUS_CHANGE:
				begin
					r_mpr_status <= ~r_mpr_status; // change its read status;
					if(r_mpr_status == 1'b0) r_mpr_pstate <= ST_MPR_READ_STATUS_INIT;
					else begin
						r_mpr_touch_status <= {4'b0, r_mpr_touch_status_1[3:0], r_mpr_touch_status_0[7:0]};
						r_mpr_lstate <= ST_MPR_READ_STATUS_CHANGE;
						r_mpr_pstate <= ST_MPR_READ_STATUS_WAIT;
					end
				end

				ST_MPR_READ_STATUS_WAIT:
				begin
					// TODO adjust wating time for optimizing serial communication
					// wait one clock for turning off read_start and uart sending(uart_controller)
					r_mpr_pstate <= ST_MPR_READ_STATUS_INIT;
				end

				ST_MPR_ERROR_REPORT:
				begin
					o_MPR121_ERROR <= 1'b1;
					r_mpr_lstate <= ST_MPR_ERROR_REPORT;
					r_mpr_pstate <= ST_MPR_IDLE;
				end

				default:
				begin
					r_mpr_pstate <= ST_MPR_IDLE;
				end
			endcase
		end
	end

	/****************************************************************************
	*                           		ADS1292                                   	*
	*****************************************************************************/
	//==============================Parameter=====================================
	// ADS1292 Control bits
	parameter ADS_CB_IDLE = 3'b000;
	parameter ADS_CB_SYSCMD = 3'b001;
	parameter ADS_CB_WREG = 3'b010;
	parameter ADS_CB_RREG = 3'b011;
	parameter ADS_CB_RDATAC = 3'b100;
	parameter ADS_CB_SDATAC = 3'b101;
	parameter ADS_CB_DUMMY = 3'b111;

	// ADS1292 Register Setting
	parameter ADS_CONFIG_1_REG = 8'h01; parameter ADS_CONFIG_1_DATA = 8'h01;
	parameter ADS_CONFIG_2_REG = 8'h02; parameter ADS_CONFIG_2_DATA = 8'hE0;
	parameter ADS_LOFF_REG = 8'h03; parameter ADS_LOFF_DATA = 8'h10;
	parameter ADS_CH1SET_REG = 8'h04; parameter ADS_CH1SET_DATA = 8'h00; // disable 8'h81
	parameter ADS_CH2SET_REG = 8'h05; parameter ADS_CH2SET_DATA = 8'h00;
	parameter ADS_RLD_SENS_REG = 8'h06; parameter ADS_RLD_SENS_DATA = 8'h2C;
	parameter ADS_LOFF_SENS_REG = 8'h07; parameter ADS_LOFF_SENS_DATA = 8'h0E;
	parameter ADS_LOFF_STAT_REG = 8'h08; parameter ADS_LOFF_STAT_DATA = 8'h40; // f MOD = f CLK / 16, f CLK = 2.048 MHz)
	parameter ADS_RESP1_REG = 8'h09; parameter ADS_RESP1_DATA = 8'h02;
	parameter ADS_RESP2_REG = 8'h0A; parameter ADS_RESP2_DATA = 8'h87; // Calib_onf (offset calibration), Bit2 must be written with 1 in ADS1292
	parameter ADS_GPIO_REG = 8'h0B; parameter ADS_GPIO_DATA = 8'h00;
	//============================================================================

	//==============================State=========================================
	reg [7:0] r_ads_lstate;
	reg [7:0] r_ads_pstate;

	// ADS1292
	// 8'b0010_xxxx(>=35 from MPR121)
	parameter ST_ADS_IDLE  = 8'd35;
	parameter ST_ADS_SETTING = 8'd36;
	parameter ST_ADS_RUN = 8'd37;
	parameter ST_ADS_STOP = 8'd38;
	parameter ST_ADS_WREG_INIT = 8'd39;
	parameter ST_ADS_WREG_CONFIRM = 8'd40;
	parameter ST_ADS_RREG_INIT = 8'd41;
	parameter ST_ADS_RREG_CONFIRM = 8'd42;
	parameter ST_ADS_RREG_WAIT = 8'd43;
	parameter ST_ADS_RDATAC_INIT = 8'd44;
	parameter ST_ADS_RDATAC_WAIT = 8'd45;
	//============================================================================

	//==============================wire & reg====================================
	reg [3:0] r_ads_set_counter; // ads setting counter
	reg [7:0] r_ads_first_param;
	reg [7:0] r_ads_second_param;
	reg [3:0] r_ads_clk_counter;
	//============================================================================

	//=============================Sequential Logic===============================
	always @ ( posedge i_CLK, posedge w_rst ) begin
		if(w_rst) begin
			// ADS1292 port
			o_ADS1292_CONTROL <= 3'b0; // ADS1292 Control
			o_ADS1292_REG_ADDR <= 8'b0; // ADS1292 register address
			o_ADS1292_DATA_IN <= 8'b0; // data to write in ADS1292 register
			o_ADS1292_FILTERED_DATA_ACK <= 1'b0;

			// sensor_core & uart
			r_ads_read_reg_done <= 1'b0; // default
			r_ads_reg_addr <= 8'b0;
			r_ads_reg_data <= 8'b0;

			// sensor_core
			r_ads_chip_set_done <= 1'b0;
			r_ads_run_set_done <= 1'b0;

			// reg
			r_ads_set_counter <= 4'b0; // ads setting counter
			r_ads_first_param <= 8'b0;
			r_ads_second_param <= 8'b0;
			r_ads_ch2_data_out <= 24'b0;
			r_ads_data_send_ready <= 1'b0;
			r_ads_clk_counter <= 4'b0;

			// state
			r_ads_lstate <= ST_ADS_IDLE;
			r_ads_pstate <= ST_ADS_IDLE;
		end else begin
			case (r_ads_pstate)
				ST_ADS_IDLE:
				begin
					// but in later, if we use command input for wakeup and standby , delete it
					// sensor_core & uart
					r_ads_read_reg_done <= 1'b0; // default
					r_ads_reg_addr <= 8'b0;
					r_ads_reg_data <= 8'b0;

					// reg
					r_ads_set_counter <= 4'b0; // ads setting counter
					r_ads_first_param <= 8'b0;
					r_ads_second_param <= 8'b0;
					r_ads_ch2_data_out <= 24'b0;
					r_ads_data_send_ready <= 1'b0;
					r_ads_clk_counter <= 4'b0;

					o_ADS1292_CONTROL <= 3'b111; // Send Dummy, do nothing
					if(r_ads_chip_set &&(!r_ads_chip_set_done)) r_ads_pstate <= ST_ADS_SETTING;
					else if(r_ads_run_set &&(!r_ads_run_set_done)) r_ads_pstate <= ST_ADS_RUN;
					else if (r_ads_read_reg &&(!r_ads_read_reg_done)) begin
						r_ads_first_param <= r_uart_data_rx[7:0];
						r_ads_reg_addr <= r_uart_data_rx[7:0]; // for sending data to pc
						r_ads_pstate <= ST_ADS_RREG_INIT;
					end else r_ads_pstate <= ST_ADS_IDLE;
				end

				ST_ADS_SETTING:
				begin
					// ADS1292 Setting
					/*
					Note that an internal RESET is automatically issued to the digital filter whenever the CONFIG1, RESP1, and
					RESP2 registers are set to a new value with a WREG command.
					The digital filter on each channel consists of a third-order sinc filter.
					The decimation ratio on the sinc filters can be adjusted by the DR bits in the CONFIG1 register.
					*/
					if(r_ads_set_counter > 4'd10) begin
						r_ads_chip_set_done <= 1'b1;
						r_ads_set_counter <= 4'd0;
						r_ads_pstate <= ST_ADS_IDLE;
					end else begin
						if(r_ads_set_counter == 4'd0) begin
							r_ads_first_param <= ADS_RESP1_REG;
							r_ads_second_param <= ADS_RESP1_DATA;
						end

						if(r_ads_set_counter == 4'd1) begin
							r_ads_first_param <= ADS_RESP2_REG;
							r_ads_second_param <= ADS_RESP2_DATA;
						end

						if(r_ads_set_counter == 4'd2) begin
							r_ads_first_param <= ADS_CONFIG_1_REG;
							r_ads_second_param <= ADS_CONFIG_1_DATA;
						end

						if(r_ads_set_counter == 4'd3) begin
							r_ads_first_param <= ADS_CONFIG_2_REG;
							r_ads_second_param <= ADS_CONFIG_2_DATA;
						end

						if(r_ads_set_counter == 4'd4) begin
							r_ads_first_param <= ADS_LOFF_REG;
							r_ads_second_param <= ADS_LOFF_DATA;
						end

						if(r_ads_set_counter == 4'd5) begin
							r_ads_first_param <= ADS_CH1SET_REG;
							r_ads_second_param <= ADS_CH1SET_DATA;
						end

						if(r_ads_set_counter == 4'd6) begin
							r_ads_first_param <= ADS_CH2SET_REG;
							r_ads_second_param <= ADS_CH2SET_DATA;
						end

						if(r_ads_set_counter == 4'd7) begin
							r_ads_first_param <= ADS_RLD_SENS_REG;
							r_ads_second_param <= ADS_RLD_SENS_DATA;
						end

						if(r_ads_set_counter == 4'd8) begin
							r_ads_first_param <= ADS_LOFF_SENS_REG;
							r_ads_second_param <= ADS_LOFF_SENS_DATA;
						end

						if(r_ads_set_counter == 4'd9) begin
							r_ads_first_param <= ADS_LOFF_STAT_REG;
							r_ads_second_param <= ADS_LOFF_STAT_DATA;
						end

						if(r_ads_set_counter == 4'd10) begin
							r_ads_first_param <= ADS_GPIO_REG;
							r_ads_second_param <= ADS_GPIO_DATA;
						end

						r_ads_set_counter <= r_ads_set_counter + 1'b1;
						r_ads_lstate <= ST_ADS_SETTING;
						r_ads_pstate <= ST_ADS_WREG_INIT;
					end
				end

				/*
				ST_ADS_WAKEUP:
				begin
					Reference - ADS1292 - ADS1292.pdf p.35
					exit the low-power standby mode. All parts of the circuit are shut down.
					Time(From STANDBY mode to DRDY low 10 ms) is required when exiting standby mode
				end

				ST_ADS_STANDBY:
				begin
					Reference - ADS1292 - ADS1292.pdf p.35
					enter the low-power standby mode. All parts of the circuit are shut down.
					do not send any other command other than the wake up command after the device enters the standby mode.
				end
				*/

				ST_ADS_RUN:
				begin
					o_ADS1292_CONTROL <= ADS_CB_RDATAC;
					r_ads_run_set_done <= 1'b1;
					r_ads_pstate <= ST_ADS_RDATAC_INIT;
				end

				ST_ADS_STOP:
				begin
					o_ADS1292_CONTROL <= ADS_CB_SDATAC;
					r_ads_run_set_done <= 1'b0;
					r_ads_pstate <= ST_ADS_IDLE;
				end

				ST_ADS_WREG_INIT:
				begin
					o_ADS1292_CONTROL <= ADS_CB_WREG;
					o_ADS1292_REG_ADDR <= r_ads_first_param;
					o_ADS1292_DATA_IN <= r_ads_second_param;
					r_ads_pstate <= ST_ADS_WREG_CONFIRM;
				end

				ST_ADS_WREG_CONFIRM:
				begin
					o_ADS1292_CONTROL <= ADS_CB_DUMMY;
					if(i_ADS1292_BUSY) r_ads_pstate <= ST_ADS_WREG_CONFIRM;
					else begin
						if (r_ads_lstate == ST_ADS_SETTING) r_ads_pstate <= ST_ADS_SETTING;
					end
				end

				ST_ADS_RREG_INIT:
				begin
					o_ADS1292_CONTROL <= ADS_CB_RREG;
					o_ADS1292_REG_ADDR <= r_ads_first_param;
					r_ads_pstate <= ST_ADS_RREG_CONFIRM;
				end

				ST_ADS_RREG_CONFIRM:
				begin
					o_ADS1292_CONTROL <= ADS_CB_DUMMY;
					if(i_ADS1292_BUSY) r_ads_pstate <= ST_ADS_RREG_CONFIRM;
					else begin
						r_ads_read_reg_done <= 1'b1;
						r_ads_reg_data <= i_ADS1292_REG_DATA_OUT;
						r_ads_pstate <= ST_ADS_RREG_WAIT;
					end
				end

				ST_ADS_RREG_WAIT:
				begin
					if(r_ads_clk_counter > 4'd4) begin
						r_ads_clk_counter <= 4'b0;
						r_ads_pstate <= ST_ADS_IDLE;
					end else begin
						r_ads_clk_counter <= r_ads_clk_counter + 1'b1;
						r_ads_pstate <= ST_ADS_RREG_WAIT;
					end
				end


				ST_ADS_RDATAC_INIT:
				begin
					// The MSB of the data on DOUT is clocked out on the first SCLK rising edge (ADS1292.pdf p.29)

					if((!r_ads_run_set) && r_ads_run_set_done) r_ads_pstate <= ST_ADS_STOP;
					else begin
						if(i_ADS1292_FILTERED_DATA_VALID) begin
							r_ads_ch2_data_out <= i_ADS1292_FILTERED_DATA_OUT;
							o_ADS1292_FILTERED_DATA_ACK <= 1'b1;
							r_ads_data_send_ready <= 1'b1;
							r_ads_pstate <= ST_ADS_RDATAC_WAIT;
						end else begin
							r_ads_data_send_ready <= 1'b0;
							r_ads_pstate <= ST_ADS_RDATAC_INIT;
						end
					end
				end

				ST_ADS_RDATAC_WAIT:
				begin
					// wait data for Receiving Stop Signal
					o_ADS1292_FILTERED_DATA_ACK <= 1'b0;
					r_ads_data_send_ready <= 1'b1;
					r_ads_pstate <= ST_ADS_RDATAC_INIT;
				end

				default:
				begin
					r_ads_pstate <= ST_ADS_IDLE;
				end
			endcase
		end
	end
	//============================================================================
endmodule // sensor_core
