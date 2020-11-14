module async_rstn_glitch_synchronizer (
  input i_CLK,
  input i_RSTN,
  output reg o_RSTN
  );

  wire w_or_1;
  //wire w_buf_1;
  //buf(w_buf_1, i_RSTN);
  or(w_or_1, i_RSTN, i_RSTN);
  async_rstn_synchronizer async_rstn_synchronizer (
    .i_CLK(i_CLK),
    .i_RSTN(w_or_1),
    .o_RSTN(o_RSTN)
    );

endmodule //async_rstn_glitch_synchronizer
