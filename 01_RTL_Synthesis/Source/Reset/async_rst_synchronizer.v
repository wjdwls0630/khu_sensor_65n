module async_rst_synchronizer (
  input i_CLK,
  input i_RSTN,
  output reg o_RST
  );
  reg r_ff;

  always @ ( posedge i_CLK, negedge i_RSTN ) begin
    if(!i_RSTN) {o_RST, r_ff} <= 2'b11;
    else {o_RST, r_ff} <= {r_ff, 1'b0};
  end

endmodule //async_rst_synchronizer
