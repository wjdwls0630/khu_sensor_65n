///////////////////////////////////////////////////////////////////////////////
// Module Name : iir_hpf
//
// Description: iir_hpf filter
// Sampling Frequency : 250Hz
// Cut-Off Frequency : 5Hz
//0.888365 1063480288 0x3f636be0
// HPF_ACoef[0:1]
// 0.888365 1063480288 0x3f636be0 (omega)
// -0.888365 3210963939 0xbf636be3 (-omega)
//
// HPF_BCoef[0:1]
// 1 1065353216 0x3f800000
// -0.888365 3210963939 0xbf636be3 (-omega)
//
// Use 1 adder, 1 multiplier -> 3 cycle
///////////////////////////////////////////////////////////////////////////////
module iir_hpf(
	input [31:0] i_X_DATA, // input x (float)
	input i_X_DATA_VALID, //input x_data is valid
	output reg o_X_DATA_READY, // iir_hpf busy
	output reg [31:0] o_Y_DATA, // output y (float)
	output reg o_Y_DATA_VALID, // output data is valid
	input i_Y_ACK, // A flag that external module get data, so, o_Y_DATA is going to be meaningless
	// it can be used as elongating o_Y_DATA_VALID High (1)
	input i_CLK, // clock
	input i_RSTN // reset activate Low(0)
	);
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
	*                           async_rst_synchronizer                                   *
	*****************************************************************************/
// reset synchronizer for Reset recovery time and dont fall to metastability  
wire w_rst;
async_rst_synchronizer async_rst_synchronizer (
    .i_CLK(i_CLK),
    .i_RSTN(i_RSTN),
    .o_RST(w_rst)
    );
	/****************************************************************************
	*                           	   float_adder                               	*
	*****************************************************************************/
	//=========================Internal Connection===============================
	reg [31:0] r_add_A;
	reg [31:0] r_add_B;
	reg r_add_AB_STB;
	wire w_add_AB_ACK;
	wire [31:0] w_add_Z;
	wire w_add_Z_STB;
	reg r_add_Z_ACK;

	float_adder add(
		.i_A(r_add_A), // input a
		.i_B(r_add_B), // input b
		.i_AB_STB(r_add_AB_STB), // input data is valid
		.o_AB_ACK(w_add_AB_ACK), // A flag that next calculation is ready
		.o_Z(w_add_Z),  // output data
		.o_Z_STB(w_add_Z_STB), // Calculation is done, and output data is valid
		.i_Z_ACK(r_add_Z_ACK), // A flag that external module get data,
		.i_CLK(i_CLK), // clock
		.i_RST(w_rst) // reset activate High(1)(asynchronous)
		//CHANGED : .rst(rstn)X
		);
	//============================================================================
	/****************************************************************************
	*                           	   float_multiplier                          	*
	*****************************************************************************/
	//=============================Internal Connection===========================/
	reg [31:0] r_mult_A;
	reg [31:0] r_mult_B;
	reg r_mult_AB_STB;
	wire w_mult_AB_ACK;
	wire [31:0] w_mult_Z;
	wire w_mult_Z_STB;
	reg r_mult_Z_ACK;

	float_multiplier mult(
		.i_A(r_mult_A), // input a
		.i_B(r_mult_B), // input b
		.i_AB_STB(r_mult_AB_STB), // input data is valid
		.o_AB_ACK(w_mult_AB_ACK), // A flag that next calculation is ready
		.o_Z(w_mult_Z),  // output data
		.o_Z_STB(w_mult_Z_STB), // Calculation is done, and output data is valid
		.i_Z_ACK(r_mult_Z_ACK), // A flag that external module get data,
		.i_CLK(i_CLK), // clock
		.i_RST(w_rst) // reset activate High(1)(asynchronous)
		//CHANGED : .rst(rstn)X
		);
	//============================================================================
	/*****************************************************************************
	*                           	iir_hpf                                        *
	*****************************************************************************/
	//============================Coefficient=====================================
	//            y[0] = omega*y[1] + omega*x[0] + (-omega)*x[1]                 /

	parameter omega = 32'h3f636be3; // 0.8883647883
	//============================================================================
	//==============================State=========================================
	reg [3:0] r_pstate;

	parameter ST_IDLE = 4'd0;
	parameter ST_INIT = 4'd1;
	parameter ST_WAIT_Z = 4'd2;
	parameter ST_FINISH = 4'd3;
	//============================================================================
	//==============================wire & reg====================================
	// In 2nd order IIR Filter, we need to store input and output data for calculation
  reg [63:0] r_x_data; // container for input data and shifting
											 // r_x_data[63:32] = x[1], r_x_data[31:0] = x[0]
  reg [31:0] r_y_data; // container for output data and shifting
									  	 // r_y_data[31:0] = y[1], o_Y_DATA = y[0]


  //counter for loop
  reg [1:0] r_counter;

	//TODO Tried direct connect x_data not using i_X_DATA, but failed due to multiple net expression issue
	always @ (posedge i_CLK, negedge w_rstn) begin
		if (!w_rstn) begin
			r_x_data <= 64'b0;
			r_y_data <= 32'b0;
		end else if (i_X_DATA_VALID && o_X_DATA_READY) begin
		 	r_x_data <= {r_x_data[31:0], i_X_DATA}; // shift when x_Data valid is on
			r_y_data <= o_Y_DATA; // shift when y_Data valid is on
		end else begin
			r_x_data <= r_x_data;
			r_y_data <= r_y_data;
		end
	end
  //============================================================================

  //=============================Sequential Logic===============================
	always @ (posedge i_CLK, negedge w_rstn) begin
		if (!w_rstn) begin
			// output pin
			o_Y_DATA <= 32'b0; // output y (float)
			o_Y_DATA_VALID <= 1'b0; // output data is valid

			// float_adder
			r_add_A <= 32'b0;
			r_add_B <= 32'b0;
			r_add_AB_STB <= 1'b0;
			r_add_Z_ACK<=1'b0;

			// float_multiplier
			r_mult_A <= 32'b0;
			r_mult_B <= 32'b0;
			r_mult_AB_STB <= 1'b0;
			r_mult_Z_ACK <= 1'b0;

			//r_counter
			r_counter <= 2'b0;

			// State
			r_pstate <= ST_IDLE;
		end else begin
			case (r_pstate)
				ST_IDLE: // state that waits until the previous module sends i_X_DATA_VALID <= 1
				begin
					o_X_DATA_READY <= 1'b1; // default for input data, x data was set complete
					o_Y_DATA_VALID <= 1'b0; // default for output data
					r_counter <= 2'b0;
					if (i_X_DATA_VALID && o_X_DATA_READY) begin
						o_X_DATA_READY <= 1'b0;
						r_pstate <= ST_INIT;
					end else r_pstate <= ST_IDLE;
				end


				ST_INIT:		//MAKES MUL AND ADDER CHANGE ITS STATE FROM get_ab TO next
				// needed value for each calculation was set complete
				begin
					r_pstate <= ST_INIT;

					//NON-LATCH
					// CHANGED
					// r_mult_A_1 <= 32'b0; makes multiplier input data 0 when w_mult_AB_ACK & w_add_AB_ACK_1 is not true
					// Thus, In this state , except first step, only control STB
					// control and connect wire of input and output data on ST_WAIT_Z state
					r_add_A <= r_add_A;
					r_add_B <= r_add_B;

					r_mult_A <= r_mult_A;
					r_mult_B <= r_mult_B;

					r_mult_Z_ACK <= 1'b0;
					r_add_Z_ACK <= 1'b0;

					if (w_mult_AB_ACK & w_add_AB_ACK) begin		//CONDITION OUTSIDE CASE: ALL MODULES ON STATE get_ab
					// if calculation is ready
					case (r_counter)
							2'b00:begin // first parallel calculation setting
								o_Y_DATA <= 32'b0; // initialize output before assign
								//ADD
								r_add_AB_STB <= 1'b1; // calculation of adder is start
								r_add_A <= r_x_data[31:0]; // x[0]
								r_add_B <= {~r_x_data[63], r_x_data[62:32]}; // -x[1]
								//MULT
								r_mult_AB_STB <= 1'b1;
								r_mult_A <= omega;
								r_mult_B <= r_y_data[31:0]; // y[1]
							end
							2'b01: begin // second parallel calculation setting
							  //ADD
								r_add_AB_STB <= 1'b0;
								//MULT
								r_mult_AB_STB <= 1'b1;
							end
							2'b10: begin
								//ADD
								r_add_AB_STB <= 1'b1;
								//MULT
								r_mult_AB_STB <= 1'b0;
							end
						endcase
						r_pstate <= ST_WAIT_Z;
					end
				end

				ST_WAIT_Z: //MAKES MUL AND ADDER CHANGE IT'S STATE FROM put_z TO get_ab.
				// get the value that calculated at mult and add module
				begin
					r_pstate <= ST_WAIT_Z;

					r_add_AB_STB <= 1'b0;
					r_mult_AB_STB <= 1'b0;

					case (r_counter)
						2'b00: begin // first parallel calculation is done, ready for second calculation
							if (w_add_Z_STB & w_mult_Z_STB) begin
								// CONDITIONS INSIDE CASE: MODULES ON USE DIFFERS DEPEND ON CNT
								// get the signal that calculation module calculate complete
								r_mult_A <= omega;
								r_mult_B <= w_add_Z;
								o_Y_DATA <= w_mult_Z;
								// signal that hpf module get value of each calculation module
								r_add_Z_ACK <= 1'b1;
								r_mult_Z_ACK <= 1'b1;
								r_counter <= r_counter + 2'b01;
								r_pstate <= ST_INIT;
							end
						end
						2'b01: begin // second calculation is done, ready for third calculation
							if (w_mult_Z_STB) begin
								r_add_A <= w_mult_Z;
								r_add_B <= o_Y_DATA;
								r_mult_Z_ACK <= 1'b1;
								r_counter <= r_counter + 2'b01;
								r_pstate <= ST_INIT;
							end
						end
						2'b10: begin // fourth calculation is done, ready for value out
							if (w_add_Z_STB) begin
								o_Y_DATA <= w_add_Z;
								r_add_Z_ACK <= 1'b1;
								r_counter <= 2'b00;
								r_pstate <= ST_FINISH;
							end
						end
					endcase
				end

				ST_FINISH: begin
					o_Y_DATA_VALID <= 1'b1; // notice that the output is complete
					o_Y_DATA <= o_Y_DATA; // output value
					if (o_Y_DATA_VALID && i_Y_ACK) begin // If the external module received output well
						o_Y_DATA_VALID <= 1'b0;
						r_pstate <= ST_IDLE;
					end else r_pstate <= ST_FINISH; // If the external module not received output
				end
				default: r_pstate <= ST_IDLE;
			endcase
		end
	end
endmodule
