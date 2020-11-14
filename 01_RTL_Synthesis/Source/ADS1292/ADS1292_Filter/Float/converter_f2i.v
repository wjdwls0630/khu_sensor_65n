//IEEE Floating Point to Integer Converter (Single Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
module converter_f2i(
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
            special_cases = 3'd1,
            unpack        = 3'd2,
            convert       = 3'd3,
            put_z         = 3'd4;

  reg [31:0] a_m, a, z;
  reg [8:0] a_e;
  reg a_s;
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
          state <= unpack;
        end
      end

      unpack:
      begin
        a_m[31:8] <= {1'b1, a[22 : 0]};
        a_m[7:0] <= 0;
        a_e <= a[30 : 23] - 8'h7f;
        a_s <= a[31];
        state <= special_cases;
      end

      special_cases:
      begin
        if ($signed(a_e) == -127) begin
          z <= 0;
          state <= put_z;
        end else if ($signed(a_e) > 31) begin
          z <= 32'h80000000;
          state <= put_z;
        end else begin
          state <= convert;
        end
      end

      convert:
      begin
        if ($signed(a_e) < 31 && a_m) begin
          a_e <= a_e + 1'b1;
          a_m <= a_m >> 1;
        end else begin
          if (a_m[31]) begin
            z <= 32'h80000000;
          end else begin
            z <= a_s ? -a_m : a_m;
          end
          state <= put_z;
        end
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
