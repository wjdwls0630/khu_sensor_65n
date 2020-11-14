module mpr121_controller (
	// Host Side
	output reg [7:0] o_MPR121_DATA_OUT, // read data from MPR121
	input [7:0] o_MPR121_REG_ADDR, // MPR121 register address
	input [7:0] i_MPR121_DATA_IN, // data to write in MPR121 register
	input i_MPR121_WRITE_ENABLE, // write enable
	input i_MPR121_READ_ENABLE, // read enable
	output reg o_MPR121_INIT_SET,
	output reg o_MPR121_BUSY,
	output wire o_MPR121_FAIL,

	//	I2C Side
	//inout wire I2C_SCL,
	//inout wire I2C_SDA,
	input i_I2C_SCL_IN,
	input i_I2C_SDA_IN,
	output o_I2C_SCL_OUT,
	output o_I2C_SDA_OUT,
	output o_I2C_SCL_EN,
	output o_I2C_SDA_EN,

	input i_CLK, // clock
	input i_RSTN // reset
	);
	/* MPR121 Pins

	//========== Power Pins ==========//
	Vin - this is the power pin. Since the chip uses 3 VDC, we have included a voltage regulator on board that will
	take 3-5VDC and safely convert it down. To power the board, give it the same power as the logic level of your
	microcontroller - e.g. for a 5V micro like Arduino, use 5V

	3Vo - this is the 3.3V output from the voltage regulator, you can grab up to 100mA from this if you like

	GND - common ground for power and logic

	//========== I2C Pins ==========//
	SCL - I2C clock pin, connect to your microcontrollers I2C clock line.
	SDA - I2C data pin, connect to your microcontrollers I2C data line.

	//========== others ==========//
	ADDR - the I2C address select pin. By default this is pulled down to ground with a 100K resistor, for an I2C
	address of 0x5A. You can also connect it to the 3Vo pin for an address of 0x5B, the SDA pin for 0x5C or SCL for
	address 0x5D (Unused)

	IRQ - the Interrupt Request signal pin. It is pulled up to 3.3V on the breakout and when the sensor chip detects a
	change in the touch sense switches, the pin goes to 0V until the data is read over i2c (Unused)

	Slave address
	we can assign 4 I2C addresses to the MPR121 depending on the connection of the ADDR pin
	MPR121 Slave address (AN3895.pdf - p.3 )
	ADDR Pin Connection      I2C Address (7bit) (MPR121 slave's address)
	VSS (not connected) 							                0x5A (we choose)
	3Vo (tied to 3V)                     							0x5B
	SDA (tied to SDA)                     						0x5C
	SCL (tied to SCL)                     						0x5D
	*/
	// we will use VDD for MPR121 Slave addresss (There is no matter which one we assig)
//	parameter I2C_MPR121_ADDR = 7'b1011_010; // ADDR pin connect to Ground  - 0x5A

	//I2C instantiation
  //CHANGED side to connection
  //I2C connection
  /*
  I2C protocol (On the I2C_master file, there is more precise description of operation)
  - I2C(Inter-Integrated Circuit) is a bus with a clock(SCL : Serial Clock Line) and data(SDA : Serial Data Line) lines with 7-bit addressing
  bus is formed with two nodes that operate different roles.
  Master node – node that generates the clock and initiates communication with slaves.
  Slave node – node that receives the clock and responds when addressed by the master.

  The bus is a multi-master bus which means that any number of master noedes can be present.

  There is four modes of operation for a given bus device
  master – master node is sending data to a slave,
  master receive – master node is receiving data from a slave,
  slave transmit – slave node is sending data to the master,
  slave receive – slave node is receiving data from the master.

  In addition to 0 and 1 data bits, the I2C bus allows special START and STOP signals
  which act as message delimiters and are distinct from the data bits. (This is in contrast to the start bits and stop bits used in asynchronous serial communication, which are distinguished from data bits only by their timing.)

  The master is initially in master transmit mode by sending a START followed by the 7-bit address of the slave it wishes to communicate with,
  which is finally followed by a single bit representing whether it wishes to write (0) to or read (1) from the slave.

  If the slave exists on the bus then it will respond with an ACK bit
  (active low for acknowledged : 0000110_2 or 0x06_16 -> indicate that it is operating normally)
  for that address.
  When the master is transmitting to the MPR121, the MPR121 generates the acknowledge bit,
  since the MPR121 is the recipient.
  When the MPR121 is transmitting to the master, the master generates the acknowledge bit,
  since the master is the recipient.

  masters                    slaves (complementary mode of master)
  transmit write(0)          receive  --slave generate ACK bits on 9th clock pulse
  receive  read(1)           transmit --master generate ACK bits on 9th clock pulse

  // master

  transmit mode (write (0))
  If the master wishes to write to the slave,
  then it repeatedly sends a byte with the slave sending an ACK bit.
  (In this situation, the master is in master transmit mode, and the slave is in slave receive mode.)

  // master receive mode (read (1))
  If the master wishes to read from the slave,
  then it repeatedly receives a byte from the slave, the master sending an ACK bit after every byte except the last one.
  (In this situation, the master is in master receive mode, and the slave is in slave transmit mode.)

  start condition

  SCL               SDA
  ------ (High)     ----
                        |______     (High to Low)

  stop condition

  SCL               SDA
  ------ (High)          ------
                    ____|            (
                    Low to High)

  All other

  SCL               SDA
           (Low)    ----- ------ 1
  _______            ____X______ 0    (High to Low, Low to High)

  The address and the data bytes are sent MSB first.

  In this case MPR121(chip) to be slave, and need to make I2C master module. (Source/MPR121/i2c_master.v)

  Hierarchy
  MPR121_controller
          |
          |
  I2C_master(master)
          |
          |
  MPR121_chip(slave)

	Message format for writing or reading the MPR121
	Configuration of Serial data MPR121 received (Write data to the MPR121)

	S(Start or Stop bit) - Slave Address(7bit)(in our case is 1011011_2) W(Write(0)) - ACK - Command byte(8bit)(register of the MPR121 eg.0x00 --> ELE0 - ELE7 Touch Status) - ACK - Data byte(8bit)(data to write)

	Configuration of Serial data Master received (Read data from the MPR121)
	S(Start or Stop bit) - Slave Address(7bit)(in our case is 1011011_2) W(Write(0)) - ACK - Command byte(8bit)(register of the MPR121 eg.0x00 --> ELE0 - ELE7 Touch Status) - ACK - S(Start or Stop bit) - Slave Address(7bit)(in our case is 1011011_2) R(Read(1)) - ACK - Data byte(8bit)(data to write)

	Write mode of Slave Address in our case
	I2C_MPR121_addr_Write -> 8'b1011_0110

	Read mode of Slave Address in our case
	I2C_MPR121_addr_Read -> 8'b1011_0111
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
	*                           		i2c_master                                   *
	*****************************************************************************/
	//=========================Internal Connection===============================
	/*
		reg == input of i2c_master
		wire == output of i2c_master
	*/
	// i2c cmd
	reg r_i2c_rst; // i2c reset
	reg r_i2c_start; // i2c start condition
	reg r_i2c_read; // i2c read bit (1)
	reg r_i2c_write; // i2c write bit (0)
	reg r_i2c_write_multiple; // write successively
	reg r_i2c_stop; // i2c stop condition
	reg r_i2c_cmd_valid; // valid of command byte
	wire w_i2c_cmd_ready; // ready to operate command

	// Master (I2C)(write)(transmit) - Slave (MPR121)(receive)
	reg [7:0] r_i2c_data_in; // 1byte data to MPR121 - i2c(master input)
	reg r_i2c_data_in_valid; // valid of input data byte
	wire w_i2c_data_in_ready; // ready flag which indicate status that Master can receive data byte to write when Master finish to write previous data sent
	reg r_i2c_data_in_last; // flag of last data to write (using for write multiple)

	// Master (I2C)(read)(receive) - Slave (MPR121)(transmit)
	wire [7:0] w_i2c_data_out; // 1 byte data from MPR121 - i2c(master output)
	wire w_i2c_data_out_valid; //  valid of output data byte
	reg r_i2c_data_out_ready;  // ready flag which indicate status that Slave finish to read 1 byte data
	wire w_i2c_data_out_last; //  flag of last data to read (In general, we don't know how much long data is )
	wire w_i2c_missed_ack; //  check missed ack (nak)?
	assign o_MPR121_FAIL = w_i2c_missed_ack;
  // data to store
  reg [7:0] r_i2c_reg_addr; // mpr121's register address
  reg [7:0] r_i2c_reg_data_in; // data to write in register

	/*
	I2C interface
	Example of interfacing with tristate pins:
	(this will work for any tristate bus)
	assign scl_i = scl_pin;
	assign scl_pin = scl_t ? 1'bz : scl_o;
	assign sda_i = sda_pin;
	assign sda_pin = sda_t ? 1'bz : sda_o;
	*/
	/*
	wire w_scl_in, w_scl_out, w_scl_out_enable;
	wire w_sda_in, w_sda_out, w_sda_out_enable;

	assign I2C_SCL = w_scl_out_enable ? 1'bz : w_scl_out;
	assign I2C_SDA = w_sda_out_enable ? 1'bz : w_sda_out;
	assign w_sda_in = I2C_SDA;  //I2C_SDA -> inout wire
	assign w_scl_in = I2C_SCL; //I2C_SCL -> inout wire
	*/
        
	i2c_master i2c_master(
    .i_CLK(i_CLK),
    .i_RSTN(w_rstn),

    // Host interface
    //.cmd_address(I2C_MPR121_ADDR), // MPR121 (slave) address
    .cmd_start(r_i2c_start),
    .cmd_read(r_i2c_read),
    .cmd_write(r_i2c_write),
    .cmd_write_multiple(r_i2c_write_multiple),
    .cmd_stop(r_i2c_stop),
    .cmd_valid(r_i2c_cmd_valid),
    .cmd_ready(w_i2c_cmd_ready),

		// Master (I2C)(write)(transmit) - Slave (MPR121)(receive)
    .data_in(r_i2c_data_in),
    .data_in_valid(r_i2c_data_in_valid),
    .data_in_ready(w_i2c_data_in_ready),
    .data_in_last(r_i2c_data_in_last),

		// Master (I2C)(read)(receive) - Slave (MPR121)(transmit)
    .data_out(w_i2c_data_out),
    .data_out_valid(w_i2c_data_out_valid),
    .data_out_ready(r_i2c_data_out_ready),
    .data_out_last(w_i2c_data_out_last),


  	// I2C interface
    .scl_i(i_I2C_SCL_IN),
    .scl_o(o_I2C_SCL_OUT),
    .scl_t(o_I2C_SCL_EN),
    .sda_i(i_I2C_SDA_IN),
    .sda_o(o_I2C_SDA_OUT),
    .sda_t(o_I2C_SDA_EN),

		// Status
    .busy(),
    .bus_control(),
    .bus_active(),
    .missed_ack(w_i2c_missed_ack)


    // Configuration
    //.prescale(16'd125), // 16'd125
    //.stop_on_idle(1'b1) // stop_on_idle automatically issue stop when command input is not valid
		);

	/*
	Common I²C bus speeds are the 100 kbit/s standard mode
	prescale
	set prescale to 1/4 of the minimum clock period in units
	of input i_CLK cycles (prescale = Fclk / (FI2Cclk * 4))
	(Basic frequency of altera board)50M/(100k*4) = 125
	*/
	//============================================================================

	//==============================State=========================================
	reg [7:0] r_pstate; // present state
	reg [7:0] r_lstate; // last state

	parameter ST_IDLE	= 8'd0;
	parameter ST_RESET = 8'd1;
	parameter ST_STANDBY = 8'd2;

	// Write Status 8'b0001_xxxx
	parameter ST_WRITE_INIT = 8'd16;
	parameter ST_WRITE_START = 8'd17;
	parameter ST_WRITE_SEND_REG_ADDR = 8'd18;
	parameter ST_WRITE_REG_ADDR_WAIT = 8'd19;
	parameter ST_WRITE_SEND_DATA = 8'd20;
	parameter ST_WRITE_SEND_DATA_1 = 8'd21;
	parameter ST_WRITE_SEND_DATA_2 = 8'd22;
	parameter ST_WRITE_STOP = 8'd23;
	parameter ST_WRITE_FINISH = 8'd24;

	// Read Status 8'b0010_xxxx
	parameter ST_READ_INIT = 8'd32;
	parameter ST_READ_START = 8'd33;
	parameter ST_READ_SEND_REG_ADDR = 8'd34;
	parameter ST_READ_REG_ADDR_WAIT	= 8'd35;
	parameter ST_READ_START_REPEAT = 8'd36;
	parameter ST_READ_START_1 = 8'd37;
	parameter ST_READ_GET_DATA = 8'd38;
	parameter ST_READ_FINISH	= 8'd39;
	//============================================================================

	//==============================wire & reg====================================
	reg [9:0] r_clk_counter;
	//============================================================================

	//=============================Sequential Logic===============================
	always @ (posedge i_CLK or negedge w_rstn) begin
		if(!w_rstn) begin

				// Host interface
				r_i2c_start <= 1'b0;
				r_i2c_read <= 1'b0;
				r_i2c_write <= 1'b0;
				r_i2c_write_multiple <= 1'b0;
				r_i2c_stop <= 1'b0;
				r_i2c_cmd_valid <= 1'b0;
				//w_i2c_cmd_ready

				// Master (I2C)(write)(transmit) - Slave (MPR121)(receive)
				r_i2c_data_in <= 8'b0;
				r_i2c_data_in_valid <= 1'b0;
				//w_i2c_data_in_ready
				r_i2c_data_in_last <= 1'b0;

				// Master (I2C)(read)(receive) - Slave (MPR121)(transmit)
	      // i2c_data_out
	      // i2c_data_out_valid
	      r_i2c_data_out_ready <= 1'b0;
	      // i2c_data_out_last

				// MPR121_Controller Output
				o_MPR121_DATA_OUT <= 8'b0;
				o_MPR121_INIT_SET <= 1'b0;
				o_MPR121_BUSY <= 1'b0;

				r_clk_counter <= 10'b0;

				// State
				r_lstate <= ST_IDLE;
				r_pstate <=	ST_IDLE;
		end
		else begin
			case (r_pstate)
				ST_IDLE: begin
					// Host interface
					r_i2c_start <= 1'b0;
					r_i2c_read <= 1'b0;
					r_i2c_write <= 1'b0;
					r_i2c_write_multiple <= 1'b0;
					r_i2c_stop <= 1'b0;
					r_i2c_cmd_valid <= 1'b0;

					// Master (I2C)(write)(transmit) - Slave (MPR121)(receive)
					r_i2c_data_in <= 8'b0;
					r_i2c_data_in_valid <= 1'b0;
					r_i2c_data_in_last <= 1'b0;

					// Master (I2C)(read)(receive)(input) - Slave (MPR121)(transmit)(output)
					r_i2c_data_out_ready <= 1'b0;

					// MPR121_Controller Output
					o_MPR121_INIT_SET <= 1'b0;
					o_MPR121_BUSY <= 1'b0;

					r_clk_counter <= 10'b0;
					r_lstate <= ST_IDLE;
					r_pstate <= ST_RESET;
				end

				ST_RESET:
				begin
					if(r_clk_counter > 10'd63) begin
						//wait for releasing
						//i2c_master reset due to
						//reset synchronizer 
						// Soft Reset(0x80)
						r_clk_counter <= 10'b0;
						r_i2c_reg_addr <= 8'h80;
						r_i2c_reg_data_in <= 8'h63;
						r_lstate <= ST_RESET;
						r_pstate <= ST_WRITE_INIT;
					end else begin
						r_clk_counter <= r_clk_counter + 1'b1; 
						r_i2c_reg_addr <= 8'h00;
						r_i2c_reg_data_in <= 8'h00;
						r_lstate <= ST_IDLE;
						r_pstate <= ST_RESET;
					end

				end

				ST_STANDBY:
				begin
					// store input data
					r_i2c_reg_addr <= o_MPR121_REG_ADDR;
					r_i2c_reg_data_in <= i_MPR121_DATA_IN;
					r_lstate <= ST_STANDBY;
					if (i_MPR121_WRITE_ENABLE) begin
						o_MPR121_BUSY <= 1'b1;
						r_pstate <= ST_WRITE_INIT;
					end else if (i_MPR121_READ_ENABLE) begin
						o_MPR121_BUSY <= 1'b1;
						r_pstate <= ST_READ_INIT;
					end
					else begin
						o_MPR121_BUSY <= 1'b0;
						r_pstate <= ST_STANDBY;
					end
				end

				ST_WRITE_INIT:
				begin
				  // S(Start or Stop bit)- Slave Address(7bit)(in our case is 1011011_2) W(Write(0))
					r_i2c_start <= 1'b1;
					r_i2c_read <= 1'b0;
					r_i2c_write <= 1'b0;
					r_i2c_write_multiple <= 1'b1;  // for reg addr, and reg data
					r_i2c_stop <= 1'b0;
					r_i2c_cmd_valid <= 1'b0;
					r_i2c_data_in_valid <= 1'b0;
					r_i2c_data_in_last <= 1'b0;
					r_i2c_data_out_ready <= 1'b0;
					r_pstate <= ST_WRITE_START;
				end

				ST_WRITE_START:
				begin
					r_i2c_cmd_valid <= 1'b1; // send cmd is valid to i2c master
					r_pstate <= ST_WRITE_SEND_REG_ADDR;
				end

				ST_WRITE_SEND_REG_ADDR:
				begin
					if (w_i2c_data_in_ready) begin // wait for the slave address send
						// if master wrote slave address, then write reg addr
						r_i2c_data_in <= r_i2c_reg_addr; // MPR121 register address
						r_i2c_data_in_valid <= 1'b1; // if (data_in_ready & data_in_valid) i2c_master
						r_pstate <= ST_WRITE_REG_ADDR_WAIT;
					end else r_pstate <= ST_WRITE_SEND_REG_ADDR;
				end

				ST_WRITE_REG_ADDR_WAIT:
				begin
					if (!w_i2c_data_in_ready) begin // reg_addr sending
						r_i2c_data_in_valid <= 1'b0; // release valid set for write reg addr again
						r_pstate <= ST_WRITE_SEND_DATA;
					end else r_pstate <= ST_WRITE_REG_ADDR_WAIT;
				end

				ST_WRITE_SEND_DATA:
				begin
					if (w_i2c_data_in_ready) begin // wait for the reg addr send
						// if master wrote reg addr, then write reg data
						r_i2c_data_in <= r_i2c_reg_data_in;
						r_i2c_data_in_valid <= 1'b1;
						r_i2c_data_in_last <= 1'b1; // send this data is last to write
						r_pstate <= ST_WRITE_STOP;
					end else r_pstate <= ST_WRITE_SEND_DATA;
				end

				ST_WRITE_STOP:
				begin
					r_i2c_cmd_valid <= 1'b0;
					r_pstate <= ST_WRITE_FINISH;
				end

				ST_WRITE_FINISH:
				begin
					// for the sake of stability, wait 10us (i2c scl one clock)
					if(r_clk_counter > 10'd500) begin
						r_clk_counter <= 10'b0;
						o_MPR121_BUSY <= 1'b0;
						if(r_lstate == ST_RESET) begin
							o_MPR121_INIT_SET <= 1'b1;
							r_pstate <= ST_STANDBY;
						end
						else begin
							if (!i_MPR121_WRITE_ENABLE) r_pstate <= ST_STANDBY;
							else r_pstate <= ST_WRITE_FINISH;
						end
					end else begin
						r_clk_counter <= r_clk_counter + 1'b1;
						r_pstate <= ST_WRITE_FINISH;
					end

				end

				ST_READ_INIT:
				begin
					// S(Start or Stop bit)- Slave Address(7bit)(in our case is 1011011_2) W(Write(0))
					r_i2c_start <= 1'b1;
					r_i2c_read <= 1'b0;
					r_i2c_write <= 1'b1; // only write reg addr
					r_i2c_write_multiple <= 1'b0;
					r_i2c_stop <= 1'b0;
					r_i2c_cmd_valid <= 1'b0;
					r_i2c_data_in_valid <= 1'b0;
					r_i2c_data_in_last <= 1'b1;
					r_i2c_data_out_ready <= 1'b0;
					r_pstate <= ST_READ_START;
				end

				ST_READ_START:
				begin
					r_i2c_cmd_valid <= 1'b1; // send cmd is valid to i2c master
					r_pstate <= ST_READ_SEND_REG_ADDR;
				end

				ST_READ_SEND_REG_ADDR:
				begin
					if (w_i2c_data_in_ready) begin // wait for the slave address send
						// if master wrote slave address, then write reg addr
						r_i2c_data_in <= r_i2c_reg_addr; // MPR121 register address
						r_i2c_data_in_valid <= 1'b1; // if (data_in_ready & data_in_valid) i2c_master
						r_pstate <= ST_READ_REG_ADDR_WAIT;
					end else r_pstate <= ST_READ_SEND_REG_ADDR;
				end

				ST_READ_REG_ADDR_WAIT:
				begin
					if (!w_i2c_data_in_ready) begin // reg_addr sending
						r_i2c_data_in_valid <= 1'b0; // release valid set for write reg addr again
						r_pstate <= ST_READ_START_REPEAT;
					end else r_pstate <= ST_READ_REG_ADDR_WAIT;
				end

				ST_READ_START_REPEAT:
				begin
					r_i2c_start <= 1'b1; // repeated start signal
					r_i2c_read <= 1'b1; // turn on , master write again slave address
					r_i2c_write <= 1'b0;
					r_i2c_write_multiple<= 1'b0;
					r_i2c_stop<= 1'b0;
					r_i2c_cmd_valid<= 1'b0;
					r_i2c_data_in_valid<= 0;
					r_i2c_data_in_last<= 1'b0;
					r_i2c_data_out_ready<= 1'b0;
					r_i2c_data_in <= 8'b0;
					r_pstate <= ST_READ_START_1;
				end

				ST_READ_START_1:
				begin
					r_i2c_cmd_valid <= 1'b1; // send cmd is valid to i2c master
					r_pstate <= ST_READ_GET_DATA;
				end

				ST_READ_GET_DATA:
				begin
					if (w_i2c_data_out_valid) begin // wait data
						r_i2c_cmd_valid <= 1'b0;
						r_i2c_stop <= 1'b1;
						r_i2c_data_out_ready <= 1'b1;
						o_MPR121_DATA_OUT <= w_i2c_data_out;
						r_pstate <= ST_READ_FINISH;
					end else r_pstate <= ST_READ_GET_DATA;
				end

				ST_READ_FINISH:
				begin
					o_MPR121_BUSY <= 1'b0;
					if (!i_MPR121_READ_ENABLE) r_pstate <= ST_STANDBY;
					else r_pstate <= ST_READ_FINISH;
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
