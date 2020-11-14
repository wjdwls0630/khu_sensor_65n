//Integer to IEEE Floating Point Converter (Single Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
module converter_i2f(
  input [31:0] i_A, // input a
  input i_A_STB, // input data is valid
  output reg o_A_ACK, // A flag that next calculation is ready
  output reg [31:0] o_Z,  // output data
  output reg o_Z_STB, // Calculation is done, and output data is valid
  input i_Z_ACK, // A flag that external module get data, so, o_Z is going to meaningless
  // it can be used as elongating o_Z_STB High (1)
  input i_CLK, // clock
  input i_RST // reset activate High(1)(synchronous)
  );

  reg       [2:0] state;
  parameter get_a         = 3'd0,
            convert_0     = 3'd1,
            convert_1     = 3'd2,
            convert_2     = 3'd3,
            round         = 3'd4,
            pack          = 3'd5,
            put_z         = 3'd6;

  reg [31:0] a, z, value;
  reg [23:0] z_m;
  reg [7:0] z_r;
  reg [7:0] z_e;
  reg z_s;
  reg guard, round_bit, sticky;
  // sync_set_reset directive does not affect the logical behavior of a design 
  // instead it only impacts the functional implementation of design 
  // this swithch make DC avoid re-synthesizing the design late 
  // synopsys sync_set_reset "i_RST"

  always @(posedge i_CLK)
  begin
    case(state)
      get_a:
      begin
        o_A_ACK <= 1;
        if (o_A_ACK && i_A_STB) begin
          a <= i_A;
          o_A_ACK <= 0;
          state <= convert_0;
        end
      end

      convert_0:
      begin
        if ( a == 0 ) begin
          z_s <= 0;
          z_m <= 0;
          z_e <= 8'hff; // -127
          state <= pack;
        end else begin
          value <= a[31] ? -a : a;
          z_s <= a[31];
          state <= convert_1;
        end
      end

      convert_1:
      begin
        z_e <= 8'd31;
        z_m <= value[31:8];
        z_r <= value[7:0];
        state <= convert_2;
      end

      convert_2:
      begin
        if (!z_m[23]) begin
          z_e <= z_e - 1'b1;
          z_m <= z_m << 1;
          z_m[0] <= z_r[7];
          z_r <= z_r << 1;
        end else begin
          guard <= z_r[7];
          round_bit <= z_r[6];
          sticky <= z_r[5:0] != 0;
          state <= round;
        end
      end

      round:
      begin
        if (guard && (round_bit || sticky || z_m[0])) begin
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
        z[30 : 23] <= z_e + 8'h7f; // 127
        z[31] <= z_s;
        state <= put_z;
      end

      put_z:
      begin
        o_Z_STB <= 1;
        o_Z <= z;
        if (o_Z_STB && i_Z_ACK) begin
          o_Z_STB <= 0;
          state <= get_a;
        end
      end

    endcase

    if (i_RST == 1) begin
      state <= get_a;
      o_A_ACK <= 0;
      o_Z_STB <= 0;
    end

  end
endmodule
