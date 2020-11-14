///////////////////////////////////////////////////////////////////////////////
// Module Name : iir_lpf
//
// Description: iir_lpf filter
// Sampling Frequency : 250Hz
// Cut-Off Frequency : 10Hz
//
// LPF_ACoef[0:5]
// 0.0133698 1012600047 0x3c5b0cef
// 0.0267396 1020988655 0x3cdb0cef
// 0.0133698 1012600047 0x3c5b0cef
// 0 0 0x00000000
// 0 0 0x00000000
// 0 0 0x00000000
//
// LPF_BCoef[0:5]
// 1 1065353216 0x3f800000
// -1.64746 3218268152 0xbfd2dff8
// 0.700897 1060335097 0x3f336df9
// 0 0 0x00000000
// 0 0 0x00000000
// 0 0 0x00000000
//
// Use 1 adder, 1 multiplier -> 4 cycle
///////////////////////////////////////////////////////////////////////////////
module iir_lpf(
	input [31:0] i_X_DATA, // input x (float)
	input i_X_DATA_VALID, //input x_data is valid
	output reg o_X_DATA_READY, // iir_lpf busy
	output reg [31:0] o_Y_DATA, // output y (float)
	output reg o_Y_DATA_VALID, // output data is valid
	input i_Y_ACK, // A flag that external module get data, so, o_Y_DATA is going to meaningless
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
		.i_RST(w_rst) // reset activate High(1)(synchronous)
		//CHANGED : .rst(rstn)X
		);


	//============================================================================
	/****************************************************************************
	*                           	   float_multiplier                          	*
	*****************************************************************************/
	//=============================Internal Connection===========================/
	reg [31:0] r_mult_1_A, r_mult_2_A;
	reg [31:0] r_mult_1_B, r_mult_2_B;
	reg r_mult_AB_STB;											//SHARE
	wire w_mult_1_AB_ACK,w_mult_2_AB_ACK;		//SHARE
	wire [31:0] w_mult_1_Z, w_mult_2_Z;
	wire w_mult_1_Z_STB,w_mult_2_Z_STB;			//SHARE
	reg r_mult_Z_ACK;												//SHARE
	wire w_mult_AB_ACK, w_mult_Z_STB;

	assign w_mult_AB_ACK = w_mult_1_AB_ACK & w_mult_2_AB_ACK;
	assign w_mult_Z_STB = w_mult_1_Z_STB & w_mult_2_Z_STB;


	// A*X, B*Y
	float_multiplier mult_1(
		.i_A(r_mult_1_A), // input a
		.i_B(r_mult_1_B), // input b
		.i_AB_STB(r_mult_AB_STB), // input data is valid
		.o_AB_ACK(w_mult_1_AB_ACK), // A flag that next calculation is ready
		.o_Z(w_mult_1_Z),  // output data
		.o_Z_STB(w_mult_1_Z_STB), // Calculation is done, and output data is valid
		.i_Z_ACK(r_mult_Z_ACK), // A flag that external module get data,
		.i_CLK(i_CLK), // clock
		.i_RST(w_rst) // reset activate High(1)(asynchronous)
		//CHANGED : .rst(rstn)X
		);
	float_multiplier mult_2(
		.i_A(r_mult_2_A),
		.i_B(r_mult_2_B),
		.i_AB_STB(r_mult_AB_STB),
		.o_AB_ACK(w_mult_2_AB_ACK),
		.o_Z(w_mult_2_Z),
		.o_Z_STB(w_mult_2_Z_STB),
		.i_Z_ACK(r_mult_Z_ACK),
		.i_CLK(i_CLK),
		.i_RST(w_rst)
		);
	//============================================================================
	/****************************************************************************
	*                           	iir_lpf                               *
	*****************************************************************************/
	//============================Coefficient=====================================
	parameter ACoef0 = 32'h3c5b0cef;
	parameter ACoef1 = 32'h3cdb0cef;
	parameter ACoef2 = 32'h3c5b0cef;
	parameter ACoef3 = 32'h00000000;
	parameter ACoef4 = 32'h00000000;
	parameter ACoef5 = 32'h00000000;

	parameter BCoef0 = 32'hbf800000; // -BCoef[0] for not using subtractor
	parameter BCoef1 = 32'h3fd2dff8; // -BCoef[1] for not using subtractor
	parameter BCoef2 = 32'hbf336df9; // -BCoef[2] for not using subtractor
	parameter BCoef3 = 32'h00000000; // -BCoef[3] for not using subtractor
	parameter BCoef4 = 32'h00000000; // -BCoef[4] for not using subtractor
	parameter BCoef5 = 32'h00000000; // -BCoef[5] for not using subtractor
	//============================================================================
	//==============================State=========================================
	reg [3:0] r_pstate;

	parameter ST_IDLE=4'b0000;
	parameter ST_INIT=4'b0001;
	parameter ST_WAIT_Z=4'b0010;
	parameter ST_FINISH=4'b0011;
	//============================================================================
	//==============================wire & reg====================================
	// In 6th order IIR Filter, we need to store input and output data for calculation
	//32*6=192 => 32*3=96
	// x[5](the oldest data) x[4] x[3] x[2] x[1] x[0] (new data)=> x[2] x[1] x[0]
	// y[5](the oldest data) y[4] y[3] y[2] y[1] y[0] (output data) => y[2] y[1] y[0]
  reg [95:0] r_x_data; // container for input data and shifting
  reg [63:0] r_y_data; // container for input data and shifting


  //counter for loop
  reg [1:0] r_counter;

	//TODO Tried direct connect x_data not using ii_x_data, but failed due to multiple net expression issue
	always @ (posedge i_CLK, negedge w_rstn) begin
		if (!w_rstn) begin
			r_x_data <= 96'b0;
			r_y_data <= 64'b0;
		end else if (i_X_DATA_VALID && o_X_DATA_READY) begin
		 	r_x_data <= {r_x_data[63:0], i_X_DATA}; // shift when x_Data valid is on
			r_y_data <= {r_y_data[31:0], o_Y_DATA}; // shift when x_Data valid is on
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
			// CHANGED Even if Rstn is activated, input data for adder and multiplier won't be reset
			// resetting input data is also necessary

			r_add_A <= 32'b0;
			r_add_B <= 32'b0;
			r_add_AB_STB <= 1'b0;
			r_add_Z_ACK<=1'b0;

			// float_multiplier
			r_mult_1_A <= 32'b0;
			r_mult_1_B <= 32'b0;
			r_mult_2_A <= 32'b0;
			r_mult_2_B <= 32'b0;
			r_mult_AB_STB <= 1'b0;
			r_mult_Z_ACK <= 1'b0;

			//counter
			r_counter <= 2'b0;

			// State
			r_pstate <= ST_IDLE;
		end else begin
			case (r_pstate)
				ST_IDLE:
				begin
					o_X_DATA_READY <= 1'b1; // default for input data
					o_Y_DATA_VALID <= 1'b0; // default for output data
					r_counter <= 2'b0;
					if (i_X_DATA_VALID && o_X_DATA_READY) begin
						o_X_DATA_READY <= 1'b0;
						r_pstate <= ST_INIT;
					end else r_pstate <= ST_IDLE;
				end


				ST_INIT:		//MAKES MUL AND ADDER CHANGE ITS STATE FROM get_ab TO next
				begin
					r_pstate <= ST_INIT;

					//NON-LATCH
					// CHANGED
					// r_mult_1_A <= 32'b0; makes multiplier input data 0 when w_mult_AB_ACK & w_add_AB_ACK is not true
					// Thus, In this state , except first step, only control STB
					// control and connect wire of input and output data on ST_WAIT_Z state
					r_add_A<=r_add_A;
					r_add_B<=r_add_B;

					r_mult_1_A<=r_mult_1_A;
					r_mult_1_B<=r_mult_1_B;
					r_mult_2_A<=r_mult_2_A;
					r_mult_2_B<=r_mult_2_B;

					r_mult_Z_ACK<=1'b0;
					r_add_Z_ACK<=1'b0;

					if (w_mult_AB_ACK & w_add_AB_ACK) begin		//CONDITION OUTSIDE CASE: ALL MODULES ON STATE get_ab
						case (r_counter)
							2'b00:begin
								//ADD
								r_add_AB_STB <= 1'b1;
								r_add_A <= r_x_data[31:0];
								r_add_B <= r_x_data[95:64];
								//MULT
								r_mult_AB_STB <= 1'b1;
								r_mult_1_A <= BCoef1;
								r_mult_1_B <= r_y_data[31:0]; // CHANGED
								r_mult_2_A <= BCoef2;
								r_mult_2_B <= r_y_data[63:32]; // CHANGED
							end
							2'b01: begin
								//ADD
								//CHANGED
								o_Y_DATA <= 32'b0; // initialize output before assign
								r_add_AB_STB <= 1'b1;
								//MULT
								r_mult_AB_STB <= 1'b1;
							end
							2'b10: begin
								//ADD
								r_add_AB_STB <= 1'b1;
								//MULT
								r_mult_AB_STB <= 1'b0;	//state will remain get_ab
								end
							2'b11: begin
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
				begin
					r_pstate <= ST_WAIT_Z;

					r_add_AB_STB <= 1'b0;
					r_mult_AB_STB <= 1'b0;

					case(r_counter)
						2'b00: begin
							if (w_add_Z_STB & w_mult_Z_STB) begin
								//CONDITIONS INSIDE CASE: MODULES ON USE DIFFERS DEPEND ON CNT
								r_mult_1_A <= ACoef1;
								r_mult_1_B <= r_x_data[63:32];
								r_mult_2_A <= ACoef0;
								r_mult_2_B <= w_add_Z;
								r_add_A <= w_mult_1_Z;
								r_add_B <= w_mult_2_Z;
								r_add_Z_ACK <= 1'b1;
								r_mult_Z_ACK <= 1'b1;
								r_counter <= r_counter + 2'b01;
								r_pstate <= ST_INIT;
							end
						end
						2'b01:begin
							if (w_add_Z_STB & w_mult_Z_STB) begin
								o_Y_DATA <= w_mult_1_Z;
								r_add_A <= w_mult_2_Z;
								r_add_B <= w_add_Z;
								r_mult_Z_ACK <= 1'b1;
								r_add_Z_ACK <= 1'b1;
								r_counter <= r_counter + 2'b01;
								r_pstate <= ST_INIT;
							end
						end
						2'b10: begin
							if (w_add_Z_STB) begin
								r_add_A <= o_Y_DATA;
								r_add_B <= w_add_Z;
								r_add_Z_ACK <= 1'b1;
								r_counter <= r_counter + 2'b01;
								r_pstate <= ST_INIT;
							end
						end
						2'b11: begin
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
					o_Y_DATA_VALID <= 1'b1;
					o_Y_DATA <= o_Y_DATA;
					if (o_Y_DATA_VALID && i_Y_ACK) begin
						o_Y_DATA_VALID <= 1'b0;
						r_pstate <= ST_IDLE;
					end else r_pstate <= ST_FINISH;
				end
				default: r_pstate <= ST_IDLE;
			endcase
		end
	end
endmodule
