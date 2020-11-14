module async_rstn_synchronizer (
  input i_CLK,
  input i_RSTN,
  output reg o_RSTN
  );
  reg r_ff;

  always @ ( posedge i_CLK, negedge i_RSTN ) begin
    if(!i_RSTN) {o_RSTN, r_ff} <= 2'b0;
    else {o_RSTN, r_ff} <= {r_ff, 1'b1};
  end

endmodule //async_rst_n_synchronizer
