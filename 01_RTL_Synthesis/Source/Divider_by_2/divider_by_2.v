module divider_by_2 (
  input i_CLK,
  input i_RSTN,
  output reg o_CLK_DIV_2
  );

  // After reset, starting with same rising edge with skew
  always @ ( posedge i_CLK, negedge i_RSTN ) begin
    if(!i_RSTN) o_CLK_DIV_2 <= 1'b0;
    else o_CLK_DIV_2 <= ~o_CLK_DIV_2;
  end

endmodule //divider_by_2
