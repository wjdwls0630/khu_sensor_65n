//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_CLK)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
`timescale 1ns/1ns
module uart_rx(
   input        i_CLK,
   input			  i_RSTN,
   input        i_Rx_Serial,
   output       o_Rx_DV,
   output [7:0] o_Rx_Byte

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

  localparam s_IDLE         = 3'b000;
  localparam s_RX_START_BIT = 3'b001;
  localparam s_RX_DATA_BITS = 3'b010;
  localparam s_RX_STOP_BIT  = 3'b011;
  localparam s_CLEANUP      = 3'b100;

  reg           r_Rx_Data_R;
  reg           r_Rx_Data;

   //2020.5.13 r_Clock_Count bit changed: 16->8
  reg [7:0]     r_Clock_Count;
  reg [2:0]     r_Bit_Index; //8 bits total
  reg [7:0]     r_Rx_Byte;
  reg           r_Rx_DV;
  reg [2:0]     r_SM_Main;

  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge i_CLK, posedge w_rst)begin
	 if(w_rst)begin
		r_Rx_Data_R<=1'b1;
		r_Rx_Data<=1'b1;
	 end
	 else begin
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end
end


  // Purpose: Control RX state machine
  always @(posedge i_CLK, posedge w_rst)
    begin
    if(w_rst)begin
		r_Clock_Count<=8'b0;
		r_Bit_Index<=3'b0;
		r_Rx_Byte<=8'b0;
		r_Rx_DV<=1'b0;
		r_SM_Main<=3'b0;
	 end
	 else begin
      case (r_SM_Main)
        s_IDLE :
          begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;

            if (r_Rx_Data == 1'b0)          // Start bit detected
              r_SM_Main <= s_RX_START_BIT;
            else
              r_SM_Main <= s_IDLE;
          end

        // Check middle of start bit to make sure it's still low
        s_RX_START_BIT :
          begin
            if (r_Clock_Count == 108)
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // reset counter, found the middle
                    r_SM_Main     <= s_RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= s_IDLE;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_START_BIT;
              end
          end // case: s_RX_START_BIT


        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < 216)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;

                // Check if we have received all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS


        // Receive Stop bit.  Stop bit = 1
        s_RX_STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < 216)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_STOP_BIT;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // case: s_RX_STOP_BIT


        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;
          end


        default :
          r_SM_Main <= s_IDLE;

      endcase
    end
 end

  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;

endmodule // uart_rx
