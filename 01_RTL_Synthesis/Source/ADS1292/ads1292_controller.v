///////////////////////////////////////////////////////////////////////////////
// Module Name : ads1292_controller
//
// Description: ads1292_controller is the module which controls ADS1292 chip operation.
//It offers Read, Write register operation and Measuring Bio-potential through SPI communication.
//this module must use in tandem with spi_master.v
///////////////////////////////////////////////////////////////////////////////
// TODO filter connection
module ads1292_controller (
	// Host Side
	output reg [23:0] o_ADS1292_DATA_OUT, // read data from ADS1292
	input [2:0] i_ADS1292_CONTROL, // ADS1292 Control
	input [7:0] i_ADS1292_REG_ADDR, // ADS1292 register address
	input [7:0] i_ADS1292_DATA_IN, // data to write in ADS1292 register
	output reg [7:0] o_ADS1292_REG_DATA_OUT, // ADS1292 register data
	output reg o_ADS1292_INIT_SET, // signal that ADS1292 chip initial setting is done
	output reg o_ADS1292_DATA_VALID, // In Read data continue mode,  flag that 72 bits data is ready (active posedge)
	output reg o_ADS1292_BUSY,

	//	ADS1292, SPI Side
	output o_SPI_CLK,
	input i_SPI_MISO, // SPI data form ADS - Master input Slave output (read)
	output o_SPI_MOSI, // SPI data to ADS - Master Output Slave Input (write)
	input i_ADS1292_DRDY, // Data Ready
	output reg o_ADS1292_RESET,
	output reg o_ADS1292_START,
	output reg o_SPI_CSN, // Chip Select Negative (active low)
	// When CS is taken high, the serial interface is reset, SCLK and DIN are ignored, and DOUT enters a high-impedance state

	input i_CLK, // clock
	input i_RSTN //reset
	);

	/* ADS1292 Pins (ADS192.pdf p.12 PIN ASSIGNMENTS)
	Name 	 						Terminal  		Function					   Description
	SCLK 								20 					Digital input 				SPI clock
	CSN 								18				 	Digital input 				Chip select
	DIN(o_SPI_MOSI)		  19					Digital input 				SPI data in (Master - SPI Master, Slave - ADS1292 Chip)
	DOUT(i_SPI_MISO) 		21 					Digital output 				SPI data out (Master - SPI Master, Slave - ADS1292 Chip)
	START 							16 					Digital input 				Start conversion
	PWDN/RESET(N) 			15 					Digital input 				Power-down or system reset;(active low)
	DRDY(N) 						22 					Digital output 				Data ready; (active low)

	Slave Chip Select
	Chip Select (CS)
	CS selects the ADS1291, ADS1292(We use), and ADS1292R for SPI communication. CS must remain *low for the entire
	duration of the serial communication. After the serial communication is finished, always wait four or more tCLK
	cycles before taking CS high. When CS is taken *high, the serial interface is *reset, SCLK and DIN are ignored,
	and DOUT enters a high-impedance state. DRDY asserts when data conversion is complete, regardless of
	whether CS is high or low.
	*/
	/****************************************************************************
	*                           async_rstn_synchronizer                                   *
	*****************************************************************************/
// reset synchronizer for Reset recovery time and dont fall to metastability  
wire w_rstn;
async_rstn_synchronizer async_rstn_synchronizer (
    .i_CLK(i_CLK),
    .i_RSTN(i_RSTN),
    .o_RSTN(w_rstn)
    );

	/****************************************************************************
	*                           		spi_master                                   *
	*****************************************************************************/
	//=========================Internal Connection===============================
	/*
	reg == input of spi_master
	wire == output of spi_master
	*/
	// Master (SPI)(write)(transmit) - Slave (ADS1292)(receive)
	reg [7:0] r_spi_data_in; // 1byte data to ADS1292 - spi(master input)
	reg r_spi_data_in_valid; // valid of input data byte
	wire w_spi_data_in_ready; // ready flag which indicate status that Master can receive data byte to write when Master finish to write previous data sent

	// Master (SPI)(read)(receive) - Slave (ADS1292)(transmit)
	wire [7:0] w_spi_data_out;  // 1 byte data from ADS1292 - spi(master output)
	wire w_spi_data_out_valid; //  valid of output data byte

	/*
	Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
	1   |             0             |        1

	CLKS_PER_HALF_BIT(2) - Sets frequency of o_SPI_Clk.  o_SPI_Clk is derived from i_Clk.
	Set to integer number of clocks for each half-bit of SPI data.
	E.g. 100 MHz i_Clk, CLKS_PER_HALF_BIT = 2 would create o_SPI_CLK of 25 MHz.  Must be >= 2

	We can cosider three cases.
	1) 50MHz i_Clk, CLKS_PER_HALF_BIT = 49 would create o_SPI_CLK of 510.204 kHz.
	Try to be as similar as possible to f_CLK = 512kHz

	2) 50MHz i_Clk, CLKS_PER_HALF_BIT = 64 would create o_SPI_CLK of 390.625 kHz.
	Try to be as similar as possible to I2C_SCL = 400kHz

	3) 50MHz i_Clk, CLKS_PER_HALF_BIT = 25 would create o_SPI_CLK of 1 MHz.
	4) 50MHz i_Clk, CLKS_PER_HALF_BIT = 7 would create o_SPI_CLK of 3.57143 MHz.

	*/
	/* default #(.SPI_MODE(0), .CLKS_PER_HALF_BIT(2)) 64*/
	spi_master spi_master( // following default setting of spi
		// Control/Data Signals,
		.i_RSTN(w_rstn),     // FPGA Reset (i_Rst_L - active low)
		.i_CLK(i_CLK),       // FPGA Clock

		// TX(Master Transimit) (MOSI) Signals (write)
		.i_TX_Byte(r_spi_data_in),        // Byte to transmit on MOSI
		.i_TX_DV(r_spi_data_in_valid),          // Data Valid Pulse with i_TX_Byte
		.o_TX_Ready(w_spi_data_in_ready),       // Transmit Ready for next byte, it trigger sclk

		// RX(Master Receive) (MISO) Signals (read)
		.o_RX_DV(w_spi_data_out_valid),     // Data Valid pulse (1 clock cycle)
		.o_RX_Byte(w_spi_data_out),   // Byte received on MISO

		// SPI Interface
		.o_SPI_Clk(o_SPI_CLK),
		.i_SPI_MISO(i_SPI_MISO),
		.o_SPI_MOSI(o_SPI_MOSI)
		);
	//============================================================================

	//==============================State=========================================
	reg [7:0] r_pstate; // present state
	reg [7:0] r_lstate; // last state

	// INIT 8'b0000_xxxx
	parameter ST_IDLE = 8'd0;
	parameter ST_POWER_ON_RESET = 8'd1;
	parameter ST_POWER_ON_RESET_WAIT = 8'd2;
	parameter ST_RESET = 8'd3;
	parameter ST_RESET_WAIT = 8'd4;
	parameter ST_STANDBY = 8'd5;

	// SYSCMD 8'b0001_xxxx (>8'd0)
	parameter ST_SYSCMD_INIT = 8'd16;
	parameter ST_SYSCMD_SEND_CMD = 8'd17;

	// WREG 8'b0010_xxxx
	parameter ST_WREG_INIT = 8'd32;
	parameter ST_WREG_INIT_WAIT = 8'd33;
	parameter ST_WREG_SEND_REG_ADDR = 8'd34;
	parameter ST_WREG_SEND_REG_ADDR_WAIT = 8'd35;
	parameter ST_WREG_SEND_REG_NUM = 8'd36;
	parameter ST_WREG_SEND_REG_NUM_WAIT = 8'd37;
	parameter ST_WREG_SEND_DATA = 8'd38;

	// RREG 8'b0011_xxxx
	parameter ST_RREG_INIT = 8'd48;
	parameter ST_RREG_INIT_WAIT = 8'd49;
	parameter ST_RREG_SEND_REG_ADDR = 8'd50;
	parameter ST_RREG_SEND_REG_ADDR_WAIT = 8'd51;
	parameter ST_RREG_SEND_REG_NUM = 8'd52;
	parameter ST_RREG_GET_DATA = 8'd53;
	parameter ST_RREG_WAIT_SCLK = 8'd54;

	// RDATAC 8'b0100_xxxx
	parameter ST_RDATAC_INIT = 8'd64;
	parameter ST_RDATAC_WAIT_DRDY = 8'd65;
	parameter ST_RDATAC_WAIT_SETTILING_TIME = 8'd66;
	parameter ST_RDATAC_WAIT_SETTLED_DATA = 8'd67;
	parameter ST_RDATAC_WAIT_DRDY_PULSE = 8'd68;
	parameter ST_RDATAC_GET_DATA = 8'd69;
	parameter ST_RDATAC_WAIT_SCLK = 8'd70;

	// SDATAC 8'b0101_xxxx
	parameter ST_SDATAC_INIT = 8'd80;
	parameter ST_SDATAC_WAIT = 8'd81;

	// SPI  8'b0110_xxxx
	parameter ST_SPI_SELECT = 8'd96;
	parameter ST_SPI_CLK_WAIT = 8'd97;
	//============================================================================

	//==============================Parameter=====================================
	/*
	Notation
	SYSCMD : System Command (start, and stop we only control by pin)
	WREG : Write Register (we only write on only one register)
	RREG : Read Register (we only read one register)
	RDATAC : Read Data Continuously
	SDATAC : Stop Read Data Continuously
	*/
	// Command byte by r_ads_command 
	parameter CM_RESET = 8'h06;
	parameter CM_START = 8'h08;
	parameter CM_STOP = 8'h0A;
	parameter CM_RDATAC = 8'h10;
	parameter CM_SDATAC = 8'h11;

	// WREG, RREG by i_ADS1292_REG_ADDR
	/*
	Data Sheet - ADS1292.pdf p.38
	Read First opcode byte
	First opcode byte: 001r rrrr, where r rrrr is the starting register address (Read)
	First opcode byte: 010r rrrr, where r rrrr is the starting register address (Write)
	Second opcode byte
	000n nnnn, where n nnnn is the number of registers to write(or read) – 1.
	e.g 1 register to write(or read) opcode = 8'b0000_0000
	*/
	parameter OP_READ_REG = 3'b001;
	parameter OP_WRITE_REG = 3'b010;
	parameter OP_NUM_REG = 8'b0000_0000;

	/*
	ADS1292 Control Cases: (User defined) (exclude other mode in data sheet)
														i_ADS1292_CONTROL
	0. IDLE :											3'b000
	1. System control:						3'b001 (use i_ADS1292_REG_ADDR)
	2. Write Register:						3'b010 (use i_ADS1292_REG_ADDR)
	3. Read Register:							3'b011 (use i_ADS1292_REG_ADDR)
	4. Read Data Continue:				3'b100 (only works by control bits)
	5. Stop Read Data Continue : 	3'b101 (only works if controller is rdatac_mode, and works by control bits)
	7. Dummy:       							3'b111 do nothing
	*/

	parameter CB_IDLE = 3'b000;
	parameter CB_SYSCMD = 3'b001;
	parameter CB_WREG = 3'b010;
	parameter CB_RREG = 3'b011;
	parameter CB_RDATAC = 3'b100;
	parameter CB_SDATAC = 3'b101;
	parameter CB_DUMMY = 3'b111;
	//============================================================================

	//==============================Mode Control==================================

	// mode register
	reg r_idle_mode;
	reg r_syscmd_mode;
	reg r_wreg_mode;
	reg r_rreg_mode;
	reg r_rdatac_mode;
	reg r_sdatac_mode;

	// For turn on/off mode
	always @ ( posedge i_CLK, negedge w_rstn ) begin
		if(!w_rstn) begin
			r_idle_mode <= 1'b0;
			r_syscmd_mode <= 1'b0;
			r_wreg_mode <= 1'b0;
			r_rreg_mode <= 1'b0;
			r_rdatac_mode <= 1'b0;
			r_sdatac_mode <= 1'b0;
		end else begin
			if (i_ADS1292_CONTROL == CB_IDLE) r_idle_mode <= 1'b1;
			else if(i_ADS1292_CONTROL == CB_SYSCMD) r_syscmd_mode <= 1'b1;
			else if(i_ADS1292_CONTROL == CB_WREG) r_wreg_mode <= 1'b1;
			else if(i_ADS1292_CONTROL == CB_RREG) r_rreg_mode <= 1'b1;
			else if(i_ADS1292_CONTROL == CB_RDATAC) r_rdatac_mode <= 1'b1;
			else if(i_ADS1292_CONTROL ==CB_SDATAC) r_sdatac_mode <= 1'b1;
			else begin
				// default
				r_idle_mode <= 1'b0;
				r_syscmd_mode <= 1'b0;
				r_wreg_mode <= 1'b0;
				r_rreg_mode <= 1'b0;
				r_rdatac_mode <= 1'b0;
				r_sdatac_mode <= 1'b0;
			end
		end
	end
	//============================================================================

	//==============================wire & reg====================================
	// For store data
	reg [7:0] r_ads_command; // command byte
	reg [7:0] r_ads_reg_addr; // register addr byte
	reg [7:0] r_ads_data_in; // register data to write
	reg [31:0] r_clk_counter; // wait clock
	reg [71:0] r_ads_data_out; // RDATAC Data 72bits
	reg [3:0] r_data_counter; // data counter for RDATAC
	reg [3:0] r_drdy_edge_counter; // drdy posedge counter
	//============================================================================

	//===========================negedge detector=================================
	reg r_ldrdy; // last drdy
	wire w_drdy_negedge_detect; // if detect posedge of drdy, then value go up to the high(1)
	always @ ( posedge i_CLK, negedge w_rstn ) begin
		if(!w_rstn) r_ldrdy <= 1'b0;
		else r_ldrdy <= i_ADS1292_DRDY;
	end
	assign w_drdy_negedge_detect = (~i_ADS1292_DRDY) && (r_ldrdy^i_ADS1292_DRDY);

	//============================================================================


	//=============================Sequential Logic===============================
	always @ ( posedge i_CLK, negedge w_rstn ) begin
		if(!w_rstn) begin
			// SPI interface

			// Master (SPI)(write)(transmit) - Slave (ADS1292)(receive)
			r_spi_data_in <= 8'b0; // 1byte data to ADS1292 - spi(master input)
			r_spi_data_in_valid <= 1'b0; // valid of input data byte
			// w_spi_data_in_ready

			// Master (SPI)(read)(receive) - Slave (ADS1292)(transmit)
			//w_spi_data_out;
			//w_spi_data_out_valid;

			// ADS1292_Controller Output
			r_ads_data_out <= 72'b0; // read data from ADS1292 Status(24 bits) - CH1(24 bits) - CH2(24 - bits)
			o_ADS1292_INIT_SET <= 1'b0;
			o_ADS1292_DATA_VALID <= 1'b0;
			o_ADS1292_BUSY <= 1'b0;

			//	ADS1292, SPI Side
			o_ADS1292_RESET <= 1'b1; // Reset activ low, don't reset even KEY[0] is pressed.
			// This is because, we already have reset switch on ads chip, however mpr doesn't have reset
			o_ADS1292_START <= 1'b0;
			o_SPI_CSN <= 1'b1; // Chip Select Negative (active low) if csn is high, then reset serial interface

			r_ads_command <= 8'b0;
			r_ads_reg_addr <= 8'b0;
			r_ads_data_in <= 8'b0;
			r_clk_counter <= 32'b0;
			r_data_counter <= 4'b0;
			r_drdy_edge_counter <= 4'b0;

			// State
			r_pstate <= ST_IDLE;
		end else begin
			case (r_pstate)
				ST_IDLE:
				begin
					// SPI interface

					// Master (SPI)(write)(transmit) - Slave (ADS1292)(receive)
					r_spi_data_in <= 8'b0;
					r_spi_data_in_valid  <= 1'b0;

					r_clk_counter <= 32'b0;
					r_data_counter <= 4'b0;
					r_drdy_edge_counter <= 4'b0;

					o_ADS1292_INIT_SET <= 1'b0;
					o_ADS1292_START <= 1'b0;
					o_ADS1292_RESET <= 1'b1;

					// state
					r_pstate <= ST_POWER_ON_RESET;
				end

				ST_POWER_ON_RESET:
				begin
					/*
					Reference-ADS1292-ADS1292.pdf p.63
					Set PWDN/RESET(N) High(1), and wait for 1s for Power_On Reset
					*/
					//wait for releasing
					//spi_master reset due to
					//reset synchronizer 
					if(r_clk_counter > 32'd15) begin
						r_clk_counter <= 32'b0;
					  	o_ADS1292_RESET <= 1'b1;
						r_pstate <= ST_POWER_ON_RESET_WAIT;
					end else begin
						r_clk_counter <= r_clk_counter + 1'b1;
						r_pstate <= ST_POWER_ON_RESET;
					end
				end

				ST_POWER_ON_RESET_WAIT:
				begin
					/*
					Reference-ADS1292-ADS1292.pdf p.63
					Set PWDN/RESET(N) High(1), and wait for 1s for Power_On Reset
					Wait for 1s for Power-On Reset
					*/
					if(r_clk_counter > 32'd5000000) begin
						r_clk_counter <= 32'b0;
						r_pstate <= ST_RESET;
					end else begin
						r_clk_counter <= r_clk_counter + 1'b1;
						r_pstate <= ST_POWER_ON_RESET_WAIT;
					end
				end

				ST_RESET:
				begin
					/*
					Reference-ADS1292-ADS1292.pdf p.63
					Issue Reset Pulse, and Wait for 18*t_clk (Activate DUT(ADS1292))
					CSN can be tied Low
					*/
					o_ADS1292_RESET <= 1'b0;
					o_SPI_CSN <= 1'b0; // if command are sent, we can selectively pulled down before sending
					r_lstate <= ST_RESET;
					r_pstate <= ST_RESET_WAIT;
				end

				ST_RESET_WAIT:
				begin
					/*
					Reference-ADS1292-ADS1292.pdf p.63
					Wait for 18*t_clk
					*/
					if(r_clk_counter > 32'd1758) begin
						r_clk_counter <= 32'b0;
						o_SPI_CSN <= 1'b1;
						if(r_lstate == ST_SYSCMD_INIT) r_pstate <= ST_SPI_SELECT;
						else begin
							r_lstate <= ST_RESET_WAIT;
							r_pstate <= ST_SDATAC_INIT;
						end
					end else begin
						r_clk_counter <= r_clk_counter + 1'b1;
						r_pstate <= ST_RESET_WAIT;
					end
				end



				ST_STANDBY:
				begin
					// CSN must remain low for the entire duration of the serial communication
					// After the serial communication is finished, always wait 4 CLK or more cycles before taking CSN high
					// store input data
					r_ads_command <= i_ADS1292_REG_ADDR;
					r_ads_reg_addr <= i_ADS1292_REG_ADDR;
					r_ads_data_in <= i_ADS1292_DATA_IN;
					r_lstate <= ST_STANDBY;
					if(r_syscmd_mode) begin
						o_ADS1292_START <= 1'b0;
						o_SPI_CSN <= 1'b0;
						o_ADS1292_BUSY <= 1'b1;
						r_pstate <= ST_SYSCMD_INIT;
					end else if(r_wreg_mode) begin
						o_ADS1292_START <= 1'b0;
						o_SPI_CSN <= 1'b0;
						o_ADS1292_BUSY <= 1'b1;
						r_pstate <= ST_WREG_INIT;
					end else if(r_rreg_mode) begin
						o_ADS1292_START <= 1'b0;
						o_SPI_CSN <= 1'b0;
						o_ADS1292_BUSY <= 1'b1;
						r_pstate <= ST_RREG_INIT;
					end else if(r_rdatac_mode) begin
						/*
						To retrieve data from the device after RDATAC command is issued,
						make sure either the START pin is high or the START command is issued.
						*/
						o_ADS1292_START <= 1'b1;
						o_SPI_CSN <= 1'b0;
						o_ADS1292_BUSY <= 1'b1;
						r_pstate <= ST_RDATAC_INIT;
						// if ADS1292 is not RDATAC_MODE, SDATAC is meaningless
					end else if(r_idle_mode) begin
						o_ADS1292_START <= 1'b0;
						o_SPI_CSN <= 1'b1;
						o_ADS1292_BUSY <= 1'b0;
						r_pstate <= ST_IDLE;
					end else begin
						o_ADS1292_START <= 1'b0;
						o_SPI_CSN <= 1'b1;
						o_ADS1292_BUSY <= 1'b0;
						r_pstate <= ST_STANDBY;
					end
				end


				ST_SYSCMD_INIT:
				begin
					/*
					START pin low to control conversions by Command
					The START pin must be set high or the START command sent to begin conversions

					when control by command, send START command and keep START pin Low(0)
					If you use start control by command, keep the start pin low untill the STOP command is issued (unused)

					when control START or STOP by pin set START pin High(1) (we choose)

					Summary:
					we only control START, STOP, RESET by ADS1292_START or ADS1292_RESET pin
					if you want to START , set ADS1292_START pin High, or want to STOP, set pin Low
					if you want to RESET, set ADS1292_RESET pin Low;
					*/
					if((r_lstate != ST_RESET_WAIT) && (r_lstate != ST_RDATAC_INIT) && (r_lstate != ST_SDATAC_WAIT)) r_lstate <= ST_SYSCMD_INIT;
					if (r_ads_command == CM_START) begin
						o_ADS1292_START <= 1'b1;
						r_pstate <= ST_SPI_SELECT; // skip send command
					end else if(r_ads_command == CM_STOP) begin
						o_ADS1292_START <= 1'b0;
						r_pstate <= ST_SPI_SELECT; // skip send command
					end else if(r_ads_command == CM_RESET) begin
						o_ADS1292_RESET <= 1'b0;
						r_pstate <= ST_RESET_WAIT; // skip send command
					end else begin
						r_spi_data_in <= r_ads_command; // using r_ads_command
						r_spi_data_in_valid <= 1'b1; // triggering sclk condition
						r_pstate <= ST_SYSCMD_SEND_CMD;
					end
				end


				ST_SYSCMD_SEND_CMD:
				begin
					/*
					there is a keep out zone of 4*t CLK cycles around the DRDY pulse
					where SDATAC command cannot be issued in.
					then wait reading process
					*/
					if(!w_spi_data_in_ready) begin
						r_spi_data_in_valid <= 1'b0;
						r_pstate <= ST_SYSCMD_SEND_CMD;
					end else begin
						if((r_lstate != ST_RESET_WAIT) && (r_lstate != ST_RDATAC_INIT) && (r_lstate != ST_SDATAC_WAIT)) r_lstate <= ST_SYSCMD_SEND_CMD;
						r_pstate <= ST_SPI_SELECT;
					end
				end

				ST_WREG_INIT:
				begin
					// we write only one register
					r_spi_data_in <= {OP_WRITE_REG, r_ads_reg_addr[4:0]};
					r_spi_data_in_valid <= 1'b1;
					r_pstate <= ST_WREG_INIT_WAIT;
				end

				ST_WREG_INIT_WAIT:
				begin
					// wait o_TX_Ready to be Low
					r_spi_data_in_valid <= 1'b0;
					r_pstate <= ST_WREG_SEND_REG_ADDR;
				end

				ST_WREG_SEND_REG_ADDR:
				begin
					if(!w_spi_data_in_ready) r_pstate <= ST_WREG_SEND_REG_ADDR;
					else begin
						r_spi_data_in <= OP_NUM_REG;
						r_spi_data_in_valid <= 1'b1;
						r_pstate <= ST_WREG_SEND_REG_ADDR_WAIT;
					end
				end

				ST_WREG_SEND_REG_ADDR_WAIT:
				begin
					// wait o_TX_Ready to be Low
					r_spi_data_in_valid <= 1'b0;
					r_pstate <= ST_WREG_SEND_REG_NUM;
				end

				ST_WREG_SEND_REG_NUM:
				begin
					if(!w_spi_data_in_ready) r_pstate <= ST_WREG_SEND_REG_NUM;
					else begin
						r_spi_data_in <= r_ads_data_in;
						r_spi_data_in_valid <= 1'b1;
						r_pstate <= ST_WREG_SEND_REG_NUM_WAIT;
					end
				end

				ST_WREG_SEND_REG_NUM_WAIT:
				begin
					// wait o_TX_Ready to be Low
					r_spi_data_in_valid <= 1'b0;
					r_pstate <= ST_WREG_SEND_DATA;
				end

				ST_WREG_SEND_DATA:
				begin
					r_lstate <= ST_WREG_SEND_DATA;
					if(!w_spi_data_in_ready) r_pstate <= ST_WREG_SEND_DATA;
					else r_pstate <= ST_SPI_SELECT;
				end

				ST_RREG_INIT:
				begin
					// we only read one register
					r_spi_data_in <= {OP_READ_REG, r_ads_reg_addr[4:0]};
					r_spi_data_in_valid <= 1'b1;
					r_pstate <= ST_RREG_INIT_WAIT;
				end

				ST_RREG_INIT_WAIT:
				begin
					// wait o_TX_Ready to be Low
					r_spi_data_in_valid <= 1'b0; // for stopping sclk when 8 bits is all sent
					r_pstate <= ST_RREG_SEND_REG_ADDR;
				end

				ST_RREG_SEND_REG_ADDR:
				begin
					if(!w_spi_data_in_ready) r_pstate <= ST_RREG_SEND_REG_ADDR;
					else begin
						r_spi_data_in <= OP_NUM_REG;
						r_spi_data_in_valid <= 1'b1; // active sclk
						r_pstate <= ST_RREG_SEND_REG_ADDR_WAIT;
					end
				end

				ST_RREG_SEND_REG_ADDR_WAIT:
				begin
					// wait o_TX_Ready to be Low
					r_spi_data_in_valid <= 1'b0; // for stopping sclk when 8 bits is all sent
					r_pstate <= ST_RREG_SEND_REG_NUM;
				end

				ST_RREG_SEND_REG_NUM:
				begin
					// wait o_TX_Ready to be Low
					if(!w_spi_data_in_ready) begin
						r_spi_data_in_valid <= 1'b0; // for stopping sclk when 8 bits is all sent
						r_pstate <= ST_RREG_SEND_REG_NUM;
					end else begin
						r_spi_data_in <= 8'b0;	 // send dummy data
						r_spi_data_in_valid <= 1'b1; // active sclk for reading
						r_pstate <= ST_RREG_GET_DATA;
					end
				end

				ST_RREG_GET_DATA:
				begin
					r_spi_data_in_valid <= 1'b0;
					if(w_spi_data_out_valid) begin
						o_ADS1292_REG_DATA_OUT[7:0] <= w_spi_data_out;
						r_pstate <= ST_RREG_WAIT_SCLK;
					end else r_pstate <= ST_RREG_GET_DATA;
				end

				ST_RREG_WAIT_SCLK:
				begin
					r_lstate <= ST_RREG_WAIT_SCLK;
					if(!w_spi_data_in_ready) r_pstate <= ST_RREG_WAIT_SCLK;
					else r_pstate <= ST_SPI_SELECT;
				end

				ST_RDATAC_INIT:
				begin
					r_ads_command <= CM_RDATAC;
					o_ADS1292_DATA_VALID <= 1'b0;
					r_lstate <= ST_RDATAC_INIT;
					r_pstate <= ST_SYSCMD_INIT;
				end

				ST_RDATAC_WAIT_DRDY:
				begin
					o_ADS1292_DATA_VALID <= 1'b0; // wait 2 clock to turn off since sensor_core's clock is 25MHz
					if(!i_ADS1292_DRDY) begin
						if(r_lstate == ST_RDATAC_INIT) r_pstate <= ST_RDATAC_WAIT_SETTILING_TIME;
						else r_pstate <= ST_RDATAC_WAIT_DRDY_PULSE;
					end else begin
						if (r_sdatac_mode) r_pstate <= ST_SDATAC_INIT;
						else r_pstate <= ST_RDATAC_WAIT_DRDY;
					end
				end

				ST_RDATAC_WAIT_SETTILING_TIME:
				begin
					/*
				 	Reference - ADS1292 - ADS1292.pdf p.31 Settling time
				 	The settling time (t_SETTLE ) is the time it takes for the converter to output fully settled data when the START signal is pulled high.
				 	The settling time depends on f CLK and the decimation ratio (controlled by the DR[2:0] bits in the CONFIG1(0x01) register). Refer to Table 10 for the settling time as a function of t_MOD.
				 	In our case, DR[2:0] == 3'b001, we need to wait 2052 t_MOD
					Settling time number uncertainty is one t MOD cycle. Therefore, it is recommended to add one t MOD cycle delay before issuing SCLK to retrieve data
					Thus, we will wait 2054 t_MOD
					(we set the LOFF_STAT(0x08)'s BIT 6 to 0, f_MOD = f_CLK/16 (f_CLK = 2.048MkHz)
					*/
					if(r_clk_counter > 32'd802344) begin //2054 settling 16*tclk
						r_clk_counter <= 32'b0;
						r_pstate <= ST_RDATAC_WAIT_SETTLED_DATA;
					end else begin
						r_clk_counter <= r_clk_counter + 1'b1;
						r_pstate <= ST_RDATAC_WAIT_SETTILING_TIME;
					end
				end

				ST_RDATAC_WAIT_SETTLED_DATA:
				begin
					/*
					Reference - ADS1292 - ADS1292.pdf p.31 Settling time
					Note that when START is held high and
					there is a step change in the input signal, it takes 3 t_DR for the filter to settle to the new value.
					Settled data are available on the fourth DRDY pulse.
					one drdy pulse time is t_MOD
					*/
					// when catch drdy posedge
					r_lstate <= ST_RDATAC_WAIT_SETTLED_DATA;
					if(w_drdy_negedge_detect) r_drdy_edge_counter <= r_drdy_edge_counter + 1'b1;
					if(r_drdy_edge_counter > 4'd2) begin
						r_drdy_edge_counter <= 4'b0;
						r_pstate <= ST_RDATAC_WAIT_DRDY;
					end else r_pstate <= ST_RDATAC_WAIT_SETTLED_DATA;
				end

				ST_RDATAC_WAIT_DRDY_PULSE:
				begin
					/*
					Reference - ADS1292 - ADS1292.pdf p.31 Settling time
					one drdy pulse time is t_MOD = 16 *t_clk
					*/
					if(r_clk_counter > 32'd391) begin // 391
						r_clk_counter <= 32'b0;
						r_spi_data_in <= 8'b0; // send dummy for reading
						r_spi_data_in_valid <= 1'b1; // active sclk for reading
						if(r_sdatac_mode) r_pstate <= ST_SDATAC_INIT;
						else r_pstate <= ST_RDATAC_GET_DATA; // wait until read start High(1)
					end else begin
						r_clk_counter <= r_clk_counter + 1'b1;
						r_pstate <= ST_RDATAC_WAIT_DRDY_PULSE;
					end
				end

				ST_RDATAC_GET_DATA:
				begin
					// CPHA=1 means the "out" side changes the data on leading edge of clock
					//              the "in" side captures data on the trailing edge of clock
					// This means that reading is complete at falling edge and after that, when rising edge trigger, writing is done.
					r_spi_data_in_valid <= 1'b0;
					if(w_spi_data_out_valid) begin
						r_ads_data_out <= {r_ads_data_out[63:0], w_spi_data_out};
						// read 72 bits
						if(r_data_counter > 4'd7) begin // read 8 byte, since we already triggerd one byte sclk in ST_RDATAC_WAIT_DATA_SETTLING
							r_data_counter <= 4'b0; // reset data counter
							o_ADS1292_DATA_VALID <= 1'b1; // data is ready
							r_lstate <= ST_RDATAC_GET_DATA;
							r_pstate <= ST_SPI_SELECT;
						end else r_pstate <= ST_RDATAC_WAIT_SCLK;
					end else r_pstate <= ST_RDATAC_GET_DATA;
				end

				ST_RDATAC_WAIT_SCLK:
				begin
					if(!w_spi_data_in_ready) r_pstate <= ST_RDATAC_WAIT_SCLK;
					else begin
						r_spi_data_in <= 8'b0;  // send dummy for reading
						r_spi_data_in_valid <= 1'b1;  // active sclk for reading
						r_data_counter <= r_data_counter + 1'b1;
						r_pstate <= ST_RDATAC_GET_DATA;
					end

				end

				ST_SDATAC_INIT:
				begin
					// there is a keep out zone of 4 t_CLK = t_MOD cycles around the DRDY pulse where this command cannot be issued in
					// for certainty of issuing SDATAC, send sdatac after next DRDY
					if(r_lstate == ST_RESET_WAIT) begin
						r_ads_command <= CM_SDATAC;
						r_pstate <= ST_SYSCMD_INIT;
					end else begin
						if(i_ADS1292_DRDY) r_pstate <= ST_SDATAC_WAIT;
						else r_pstate <= ST_SDATAC_INIT;
					end
				end

				ST_SDATAC_WAIT:
				begin
					if(r_clk_counter > 32'd3610) begin
						// wait for sending 72bits
						r_clk_counter <= 32'b0;
						r_ads_command <= CM_SDATAC;
						r_lstate <= ST_SDATAC_WAIT;
						r_pstate <= ST_SYSCMD_INIT;
					end else begin
						// TODO make w_spi_data_out empty?
						r_clk_counter <= r_clk_counter + 1'b1;
						r_pstate <= ST_SDATAC_WAIT;
					end
				end

				ST_SPI_SELECT:
				begin
					if(r_lstate == ST_RESET_WAIT) begin
						o_ADS1292_INIT_SET <= 1'b1;
						r_pstate <= ST_SPI_CLK_WAIT;
					end
					else if(r_lstate == ST_SYSCMD_INIT) begin
						o_ADS1292_BUSY <= 1'b0;
						r_pstate <= ST_STANDBY;
					end else if(r_lstate == ST_SYSCMD_SEND_CMD) r_pstate <= ST_SPI_CLK_WAIT;
					else if(r_lstate == ST_WREG_SEND_DATA) r_pstate <= ST_SPI_CLK_WAIT;
					else if(r_lstate == ST_RREG_WAIT_SCLK) r_pstate <= ST_SPI_CLK_WAIT;
					else if(r_lstate == ST_RDATAC_INIT) r_pstate <= ST_RDATAC_WAIT_DRDY;
					else if(r_lstate == ST_RDATAC_GET_DATA) begin
						o_ADS1292_DATA_OUT <= r_ads_data_out[23:0];
						r_pstate <= ST_RDATAC_WAIT_DRDY;
					end
					else if(r_lstate == ST_SDATAC_WAIT) begin
						o_ADS1292_START <= 1'b0; // turn off conversion
						o_ADS1292_DATA_VALID <= 1'b0;
						r_pstate <= ST_SPI_CLK_WAIT;
					end else r_pstate <= ST_SPI_SELECT;
				end

				ST_SPI_CLK_WAIT:
				begin
					// TODO 4*t_clk or 16*t_clk in 2.048MHz
					// After the serial communication is finished, always wait 16*t_CLK(2.048MHz) or more cycles before taking CSN high
					if (r_clk_counter > 32'd391) begin
						// wait 16 t_CLK
						r_clk_counter <= 32'b0;  // reset counter for ST_CLK_WAIT
						o_ADS1292_BUSY <= 1'b0;
						o_SPI_CSN <= 1'b1;
						r_pstate <= ST_STANDBY;
					end else begin
						r_clk_counter <= r_clk_counter + 1'b1;
						r_pstate <= ST_SPI_CLK_WAIT;
					end
				end

				default:
				begin
					r_pstate <= ST_IDLE;
				end
			endcase
		end
	end
	//============================================================================
endmodule
