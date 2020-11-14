///////////////////////////////////////////////////////////////////////////////
// Module Name : ads1292_filter
//
// Description: ads1292 filter
// Sampling Frequency : 250Hz
//
// LPF (the 6th order IIR Filter)
// Cut-Off Frequency : 10 Hz
//
// Notch (the 6th order IIR Filter)
// Mid Frequency (High Q Factor Frequency) : 60Hz
//
// HPF
// Cut-Off Frequency : 5 Hz
//
// ADS1292 Ch2 Signal is passed by the order of LPF - Notch - HPF.
//
// To begin with, 24bits data is scaled up to 32bits by shifting bits left (MSB is left)
// when ADS1292 data(72bits) is received from ads1292_controller.v.
// For precise calculation(float range), ads1292 Ch2 data will be converted by converter_i2f before passed filters.
//
// Likewise, after passed filters, output data will be converted again to int for easier calculation on PC(Qt5 or Serial Packet Analyzer).
//
// Ultimately, scaling down 32bits int to 24bits by shifting bits right.
///////////////////////////////////////////////////////////////////////////////

module ads1292_filter (
  input [23:0] i_ADS1292_DATA_OUT, // read data from ADS1292
  input i_ADS1292_DATA_VALID, // In Read data continue mode,  flag that 72 bits data is ready
  output reg [23:0] o_ADS1292_FILTERED_DATA,
  output reg o_ADS1292_FILTERED_DATA_VALID,
  input i_ADS1292_FILTERED_DATA_ACK,
  input i_CLK, // clock
  input i_RSTN //reset
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

  //=========================Internal Connection===============================
  // CHANGED Direct connection is failed by timing of crossing stb and ack
  // And also connected with ack and stb, pre-order module will be activated while post-order module stay
  // converter_i2f
  // input
  reg [31:0] r_converter_i2f_a; // input a (int)
  reg r_converter_i2f_a_stb;  // input data is valid
  wire w_converter_i2f_a_ack; // A flag that next calculation is ready
  //assign  = w_converter_i2f_a_ack;
  // output
  wire [31:0] w_converter_i2f_z; // output data (float)
  wire w_converter_i2f_z_stb; // Calculation is done, and output data is valid
  reg r_converter_i2f_z_ack;

  // iir_lpf
  // input
  reg [31:0] r_iir_lpf_x; // input x (float)
  reg r_iir_lpf_x_valid;  // input data is valid
  wire w_iir_lpf_x_ready; // input is ready for next float data
  // output
  wire [31:0] w_iir_lpf_y; // output y (float)
  wire w_iir_lpf_y_valid; // output data is valid
  reg r_iir_lpf_y_ack; // A flag that external module got Y Data

  // iir_notch
  // input
  reg [31:0] r_iir_notch_x; // input x (float)
  reg r_iir_notch_x_valid;  // input data is valid
  wire w_iir_notch_x_ready; // input is ready for next float data
  // output
  wire [31:0] w_iir_notch_y; // output y (float)
  wire w_iir_notch_y_valid; // output data is valid
  reg r_iir_notch_y_ack; // A flag that external module got Y Data

  // iir_hpf
  // input
  reg [31:0] r_iir_hpf_x; // input x (float)
  reg r_iir_hpf_x_valid;  // input data is valid
  wire w_iir_hpf_x_ready; // input is ready for next float data
  // output
  wire [31:0] w_iir_hpf_y; // output y (float)
  wire w_iir_hpf_y_valid; // output data is valid
  reg r_iir_hpf_y_ack; // A flag that external module got Y Data

  // converter_f2i
  // input
  reg [31:0] r_converter_f2i_a; // input a (float)
  reg r_converter_f2i_a_stb;  // input data is valid
  wire w_converter_f2i_a_ack; // A flag that next calculation is ready
  //assign  = w_converter_i2f_a_ack;
  // output
  wire [31:0] w_converter_f2i_z; // output data (int)
  wire w_converter_f2i_z_stb; // Calculation is done, and output data is valid
  reg r_converter_f2i_z_ack;

  converter_i2f converter_i2f(
    .i_A(r_converter_i2f_a), // input a
    .i_A_STB(r_converter_i2f_a_stb), // input data is valid
    .o_A_ACK(w_converter_i2f_a_ack), // A flag that next calculation is ready
    .o_Z(w_converter_i2f_z),  // output data
    .o_Z_STB(w_converter_i2f_z_stb), // Calculation is done, and output data is valid
    .i_Z_ACK(r_converter_i2f_z_ack), // A flag that external module get data, so, o_Z is going to meaningless
    // it can be used as elongating o_Z_STB High (1)
    .i_CLK(i_CLK), // clock
    .i_RST(w_rst) // reset activate High(1)(asynchronous)
    );

  iir_lpf iir_lpf(
    .i_X_DATA(r_iir_lpf_x), // input x (float)
    .i_X_DATA_VALID(r_iir_lpf_x_valid), //input x_data is valid
    .o_X_DATA_READY(w_iir_lpf_x_ready), // input is ready for next float data
    .o_Y_DATA(w_iir_lpf_y), // output y (float)
    .o_Y_DATA_VALID(w_iir_lpf_y_valid), // output data is valid
    .i_Y_ACK(r_iir_lpf_y_ack), // A flag that external module got Y Data
    .i_CLK(i_CLK), // clock
    .i_RSTN(w_rstn) // reset activate Low(0)
    );

  iir_notch iir_notch(
    .i_X_DATA(r_iir_notch_x), // input x (float)
    .i_X_DATA_VALID(r_iir_notch_x_valid), //input x_data is valid
    .o_X_DATA_READY(w_iir_notch_x_ready), // input is ready for next float data
    .o_Y_DATA(w_iir_notch_y), // output y (float)
    .o_Y_DATA_VALID(w_iir_notch_y_valid), // output data is valid
    .i_Y_ACK(r_iir_notch_y_ack),
    .i_CLK(i_CLK), // clock
    .i_RSTN(w_rstn) // reset activate Low(0)
  );

  iir_hpf iir_hpf(
    .i_X_DATA(r_iir_hpf_x), // input x (float)
    .i_X_DATA_VALID(r_iir_hpf_x_valid), //input x_data is valid
    .o_X_DATA_READY(w_iir_hpf_x_ready), // input is ready for next float data
    .o_Y_DATA(w_iir_hpf_y), // output y (float)
    .o_Y_DATA_VALID(w_iir_hpf_y_valid), // output data is valid
    .i_Y_ACK(r_iir_hpf_y_ack),
    .i_CLK(i_CLK), // clock
    .i_RSTN(w_rstn) // reset activate Low(0)
    );

  converter_f2i converter_f2i(
    .i_A(r_converter_f2i_a), // input a
    .i_A_STB(r_converter_f2i_a_stb), // input data is valid
    .o_A_ACK(w_converter_f2i_a_ack), // A flag that next calculation is ready
    .o_Z(w_converter_f2i_z),  // output data
    .o_Z_STB(w_converter_f2i_z_stb), // Calculation is done, and output data is valid
    .i_Z_ACK(r_converter_f2i_z_ack), // A flag that external module get data, so, o_Z is going to meaningless
    // it can be used as elongating o_Z_STB High (1)
    .i_CLK(i_CLK), // clock
    .i_RST(w_rst) // reset activate High(1)(asynchronous)
    );
  //============================================================================
  //==============================State=========================================
  reg [1:0] r_pstate;
  parameter ST_IDLE = 2'd0;
  parameter ST_INIT = 2'd1;
  parameter ST_WAIT_Z = 2'd2;
  parameter ST_FINISH = 2'd3;
  //============================================================================
  //==============================wire & reg====================================
  reg [7:0] r_counter;
  //============================================================================
  //=============================Sequential Logic===============================
  always @ ( posedge i_CLK, negedge w_rstn ) begin
    if(!w_rstn) begin
      o_ADS1292_FILTERED_DATA <= 24'b0;
      o_ADS1292_FILTERED_DATA_VALID <= 1'b0;

      // converter_i2f
      // input
      r_converter_i2f_a <= 32'b0; // input a (int)
      r_converter_i2f_a_stb <= 1'b0;  // input data is valid
      // output
      r_converter_i2f_z_ack <= 1'b0;

      // iir_lpf
      // input
      r_iir_lpf_x <= 32'b0; // input x (float)
      r_iir_lpf_x_valid <= 1'b0;  // input data is valid
      // output
      r_iir_lpf_y_ack <= 1'b0; // A flag that external module got Y Data

      // iir_notch
      // input
      r_iir_notch_x <= 32'b0; // input x (float)
      r_iir_notch_x_valid <= 1'b0;  // input data is valid
      // output
      r_iir_notch_y_ack <= 1'b0; // A flag that external module got Y Data

      // iir_hpf
      // input
      r_iir_hpf_x <= 32'b0; // input x (float)
      r_iir_hpf_x_valid <= 1'b0;  // input data is valid
      // output
      r_iir_hpf_y_ack <= 1'b0; // A flag that external module got Y Data

      // converter_f2i
      // input
      r_converter_f2i_a <= 32'b0; // input a (float)
      r_converter_f2i_a_stb <= 1'b0;  // input data is valid

      // output
      r_converter_f2i_z_ack <= 1'b0;
      r_counter <= 8'b0;
      r_pstate <= ST_IDLE;
    end else begin
      case (r_pstate)
        ST_IDLE:
        begin
          o_ADS1292_FILTERED_DATA_VALID <= 1'b0; // default for output data
          r_counter <= 8'b0;
          if (i_ADS1292_DATA_VALID) begin
            // scale up 24bits to 32bits
            r_converter_i2f_a <= {i_ADS1292_DATA_OUT, 8'b0};
            r_pstate <= ST_INIT;
          end else r_pstate <= ST_IDLE;
        end

        ST_INIT:
        begin
          r_pstate <= ST_INIT;

          r_converter_i2f_a <= r_converter_i2f_a;
          r_iir_lpf_x <= r_iir_lpf_x;
          r_iir_notch_x <= r_iir_notch_x;
          r_iir_hpf_x <= r_iir_hpf_x;
          r_converter_f2i_a <= r_converter_f2i_a;

          r_converter_i2f_z_ack <= 1'b0;
          r_iir_lpf_y_ack <= 1'b0;
          r_iir_notch_y_ack <= 1'b0;
          r_iir_hpf_y_ack <= 1'b0;
          r_converter_f2i_z_ack <= 1'b0;

          case (r_counter)
            8'd0:
            begin
              if (w_converter_i2f_a_ack) begin
                r_converter_i2f_a_stb <= 1'b1;
                r_pstate <= ST_WAIT_Z;
              end
            end

            8'd1:
            begin
              if (w_iir_lpf_x_ready) begin
                r_iir_lpf_x_valid <= 1'b1;
                r_pstate <= ST_WAIT_Z;
              end
            end

            8'd2:
            begin
              if (w_iir_notch_x_ready) begin
                r_iir_notch_x_valid <= 1'b1;
                r_pstate <= ST_WAIT_Z;
              end
            end

            8'd3:
            begin
              if (w_iir_hpf_x_ready) begin
                r_iir_hpf_x_valid <= 1'b1;
                r_pstate <= ST_WAIT_Z;
              end
            end

            8'd4:
            begin
              if (w_converter_f2i_a_ack) begin
                r_converter_f2i_a_stb <= 1'b1;
                r_pstate <= ST_WAIT_Z;
              end
            end
          endcase
        end

        ST_WAIT_Z:
        begin
          r_pstate <= ST_WAIT_Z;
          r_converter_i2f_a_stb <= 1'b0;
          r_iir_lpf_x_valid <= 1'b0;
          r_iir_notch_x_valid <= 1'b0;
          r_iir_hpf_x_valid <= 1'b0;
          r_converter_f2i_a_stb <= 1'b0;

          case (r_counter)
            8'd0:
            begin
              if(w_converter_i2f_z_stb) begin
                r_iir_lpf_x <= w_converter_i2f_z;
                r_converter_i2f_z_ack <= 1'b1;
                r_counter <= r_counter + 1'b1;
                r_pstate <= ST_INIT;
              end
            end

            8'd1:
            begin
              if(w_iir_lpf_y_valid) begin
                r_iir_notch_x <= w_iir_lpf_y;
                r_iir_lpf_y_ack <= 1'b1;
                r_counter <= r_counter + 1'b1;
                r_pstate <= ST_INIT;
              end
            end

            8'd2:
            begin
              if(w_iir_notch_y_valid) begin
                r_iir_hpf_x <= w_iir_notch_y;
                r_iir_notch_y_ack <= 1'b1;
                r_counter <= r_counter + 1'b1;
                r_pstate <= ST_INIT;
              end
            end

            8'd3:
            begin
              if(w_iir_hpf_y_valid) begin
                r_converter_f2i_a <= w_iir_hpf_y;
                r_iir_hpf_y_ack <= 1'b1;
                r_counter <= r_counter + 1'b1;
                r_pstate <= ST_INIT;
              end
            end

            8'd4:
            begin
              if(w_converter_f2i_z_stb) begin
                // scale dwon 32bits to 24bits
                o_ADS1292_FILTERED_DATA <= {w_converter_f2i_z[31:8]};
                r_converter_f2i_z_ack <= 1'b1;
                r_counter <= 8'b0;
                r_pstate <= ST_FINISH;
              end
            end
          endcase
        end

        ST_FINISH:
        begin
          o_ADS1292_FILTERED_DATA_VALID <= 1'b1;
          o_ADS1292_FILTERED_DATA <= o_ADS1292_FILTERED_DATA;
          if (o_ADS1292_FILTERED_DATA_VALID && i_ADS1292_FILTERED_DATA_ACK) begin
            r_converter_f2i_z_ack <= 1'b0; // finish
            o_ADS1292_FILTERED_DATA_VALID <= 1'b0;
            r_pstate <= ST_IDLE;
          end else r_pstate <= ST_FINISH;
        end
      endcase
    end
  end
  //============================================================================
endmodule //ads1292_filter
