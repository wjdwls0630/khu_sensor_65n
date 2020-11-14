//IEEE Floating Point Multiplier (Single Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
// A*B => Z
module float_multiplier(
  input [31:0] i_A, // input a
  input [31:0] i_B, // input b
  input i_AB_STB, // input data is valid
  output reg o_AB_ACK, // A flag that next calculation is ready
  output reg [31:0] o_Z,  // output data
  output reg o_Z_STB, // Calculation is done, and output data is valid
  input i_Z_ACK, // A flag that external module get data, so, o_Z is going to meaningless
  // it can be used as elongating o_Z_STB High (1)
  input i_CLK, // clock
  input i_RST // reset activate High(1)(synchronous)
  );
  // CHANGED: remove state get_b
  reg       [3:0] state;
  parameter get_ab         = 4'd0,
            unpack        = 4'd1,
            special_cases = 4'd2,
            normalise_a   = 4'd3,
            normalise_b   = 4'd4,
            multiply_0    = 4'd5,
            multiply_1    = 4'd6,
            normalise_1   = 4'd7,
            normalise_2   = 4'd8,
            round         = 4'd9,
            pack          = 4'd10,
            put_z         = 4'd11;

  reg       [31:0] a, b, z;
  reg       [23:0] a_m, b_m, z_m;
  reg       [9:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [49:0] product;
  // sync_set_reset directive does not affect the logical behavior of a design 
  // instead it only impacts the functional implementation of design 
  // this swithch make DC avoid re-synthesizing the design late 
  // synopsys sync_set_reset "i_RST"

  always @(posedge i_CLK)
  begin
    case(state)
      get_ab:
      begin
        o_AB_ACK <= 1;
		    if (o_AB_ACK && i_AB_STB) begin
          a <= i_A;
          b <= i_B;
			    o_AB_ACK <= 0;
			    state <= unpack;
        end
      end

      unpack:
      begin
        a_m <= a[22 : 0];
        b_m <= b[22 : 0];
        a_e <= a[30 : 23] - 8'h7f;
        b_e <= b[30 : 23] - 8'h7f;
        a_s <= a[31];
        b_s <= b[31];
        state <= special_cases;
      end

      special_cases:
      begin
        //if a is NaN or b is NaN return NaN
        if ((a_e == 128 && a_m != 0) || (b_e == 128 && b_m != 0)) begin
          z[31] <= 1;
          z[30:23] <= 255;
          z[22] <= 1;
          z[21:0] <= 0;
          state <= put_z;
        //if a is inf return inf
        end else if (a_e == 128) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          //if b is zero return NaN
          if (($signed(b_e) == -127) && (b_m == 0)) begin
            z[31] <= 1;
            z[30:23] <= 255;
            z[22] <= 1;
            z[21:0] <= 0;
          end
          state <= put_z;
        //if b is inf return inf
        end else if (b_e == 128) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          //if a is zero return NaN
          if (($signed(a_e) == -127) && (a_m == 0)) begin
            z[31] <= 1;
            z[30:23] <= 255;
            z[22] <= 1;
            z[21:0] <= 0;
          end
          state <= put_z;
        //if a is zero return zero
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 0;
          z[22:0] <= 0;
          state <= put_z;
        //if b is zero return zero
        end else if (($signed(b_e) == -127) && (b_m == 0)) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 0;
          z[22:0] <= 0;
          state <= put_z;
        end else begin
          //Denormalised Number
          if ($signed(a_e) == -127) begin
            // TODO why $signed(10'b1001111110)(-126) is worked in float_adder
            // not in float_multiplier?
            a_e <= -126;
          end else begin
            a_m[23] <= 1;
          end
          //Denormalised Number
          if ($signed(b_e) == -127) begin
            b_e <= -126; // -126
          end else begin
            b_m[23] <= 1;
          end
          state <= normalise_a;
        end
      end

      normalise_a:
      begin
        if (a_m[23]) begin
          state <= normalise_b;
        end else begin
          a_m <= a_m << 1;
          a_e <= a_e - 1'b1;
        end
      end

      normalise_b:
      begin
        if (b_m[23]) begin
          state <= multiply_0;
        end else begin
          b_m <= b_m << 1;
          b_e <= b_e - 1'b1;
        end
      end

      multiply_0:
      begin
        z_s <= a_s ^ b_s;
        z_e <= a_e + b_e + 1'b1;
        product <= a_m * b_m * 4;
        state <= multiply_1;
      end

      multiply_1:
      begin
        z_m <= product[49:26];
        guard <= product[25];
        round_bit <= product[24];
        sticky <= (product[23:0] != 0);
        state <= normalise_1;
      end

      normalise_1:
      begin
        if (z_m[23] == 0) begin
          z_e <= z_e - 1'b1;
          z_m <= z_m << 1;
          z_m[0] <= guard;
          guard <= round_bit;
          round_bit <= 0;
        end else begin
          state <= normalise_2;
        end
      end

      normalise_2:
      begin
        if ($signed(z_e) < -126) begin
          z_e <= z_e + 1'b1;
          z_m <= z_m >> 1;
          guard <= z_m[0];
          round_bit <= guard;
          sticky <= sticky | round_bit;
        end else begin
          state <= round;
        end
      end

      round:
      begin
        if (guard && (round_bit | sticky | z_m[0])) begin
          z_m <= z_m + 1'b1;
          if (z_m == 24'hffffff) begin
            z_e <=z_e + 1'b1;
          end
        end
        state <= pack;
      end

      pack:
      begin
        z[22 : 0] <= z_m[22:0];
        z[30 : 23] <= z_e[7:0] + 8'h7f;
        z[31] <= z_s;
        if ($signed(z_e) == -126 && z_m[23] == 0) begin
          z[30 : 23] <= 0;
        end
        //if overflow occurs, return inf
        if ($signed(z_e) > 127) begin
          z[22 : 0] <= 0;
          z[30 : 23] <= 255;
          z[31] <= z_s;
        end
        state <= put_z;
      end

      put_z:
      begin
        //even if o_Z_STB is high when mother module doesn't want data(output_z_ack low) stay still
        // TODO : keep stb flag one clock
        o_Z_STB <= 1;
        o_Z <= z;
        if (o_Z_STB && i_Z_ACK) begin
          o_Z_STB <= 0;
          state <= get_ab;
        end
      end
    endcase

    if (i_RST == 1) begin
      state <= get_ab;
      o_AB_ACK <= 0;
      o_Z_STB <= 0;
    end
  end

endmodule
