module khu_sensor_pad (
  // System I/O
  input i_CLK, // Clock
  input i_RSTN, // Reset
  //output CLK_OUT,
  // RS232 UART
  input UART_RXD,
  output UART_TXD,

  // DUT IO: for MPR121 (I2C)
  inout MPR121_SCL,
  inout MPR121_SDA,

  // DUT IO: for ADS1292 (SPI)
  output ADS1292_SCLK,
  input ADS1292_MISO,
  output ADS1292_MOSI,
  input ADS1292_DRDY,
  output ADS1292_RESET,
  output ADS1292_START,
  output ADS1292_CSN
  );
  /*
  4x4mm core
  maximum port number : 208
  52 ports are allocated on each side.  (.tdf file)(include coordinate data)
  */
  /*
  Input : output-driver(3.3V) -> pre-driver (3.3V) -> internal(1.2V)
  Output : internal(1.2V) -> pre-driver (3.3V) -> output-driver(3.3V)
  */

  /****************************************************************************
	*                           	   PAD Output Signal : _p			                *
	*****************************************************************************/
  //=========================Internal Connection===============================
  // Actual Signal input to main core/module(khu_sensor_top)
  // System I/O
  wire w_clk_p; // Clock
  //wire w_clk_out_p; // Clock Out
  wire w_rstn_p; // Reset

  wire w_clk_half_p;
  wire w_clk_half_out_p;
  // RS232 UART
  wire w_uart_rx_p;
  wire w_uart_tx_p;

  // DUT IO: for MPR121 (I2C)
  wire w_mpr121_scl_in_p;
  wire w_mpr121_sda_in_p;
  wire w_mpr121_scl_out_p;
  wire w_mpr121_sda_out_p;
  wire w_mpr121_scl_en_p;
  wire w_mpr121_sda_en_p;

  // DUT IO: for ADS1292 (SPI)
  wire w_ads1292_sclk_p;
  wire w_ads1292_miso_p;
  wire w_ads1292_mosi_p;
  wire w_ads1292_drdy_p;
  wire w_ads1292_reset_p;
  wire w_ads1292_start_p;
  wire w_ads1292_csn_p;
  //============================================================================
  //============================================================================
  // Basic Function of I/O Pad
  // Interface between internal and external part of chip
  // Protect internal part of chip from external stress(ESD)
  // Supply power and ground to drive chip

  // Types of I/O

  // Normal I/O (GPIO)
  // Digital signal Buffering, Level Shifting, Current Driving, Tolerant, ESD protection
  // pvhbcudtart(Low Driver Stregth Output) pvhbcudtbrt(High Driver Strength Output)
  // CI: Input Enable
  // CPU: Pull up Control
  // CPD: Pull down Control
  // CD0: Driver Strength Control
  // CD1: Driver Strength Control
  // CE: Output Enable
  // A: Data Input
  // PI: Nandtree Input
  // CLTCH: Retention Control (Retention or Fail-safe IO have feature for reducing leakage power consumption.)
  // Y: Output data
  // PAD: In-Out data

  // Analog I/O
  // Analog signal bypassing, ESD protection
  // Not used

  // Power Cell
  // Supply Power, Ground, ESD protection

  // Power Ring (internal to external, in order)
  // VDDI: 1.2V I/O power ring
  // VSSIP: 1.2V I/O ground ring
  // VDDP: 1.8V/2.5V/3.3V I/O power ring
  // VDDO: 1.8V/2.5V/3.3V I/O power ring
  // VSSO: 1.8V/2.5V/3.3V I/O ground ring

  // vddtvh, vsstvh: vddtvh, vsstvh are total power-ground pair.
  // vddth supplies 1.8~3.3V power on VDDP, VDDO rings and VDDT internal port
  // vssth supplies ground on VSSO ring, VSST internal port

  // vddivh, vssipvh: vddivh, vssipvh are internal power power-ground pair.
  // vddivh supplies 1.2V power on VDDI ring and internal port.
  // vssipvh supplies ground on VSSIP ring and internal port.

  // I/O pad guide
  //It is the best way that 3.3V logic is located on the corner of chip,
  //owing to being deprived of connection with main(internal) module.
  // Setting a number of GND PAD as much as possible has advantageous for stabilizing supply voltage,
  // especially periphery of high frequency such as i_CLK.

  // Normal I/O
  // break - vsstv - N_I/O - vssipv - vddiv - vddtv - break

  // Analog I/O
  // break - A_I/O - vsstv - vddtv - A_I/O - break
  //============================================================================
  /****************************************************************************
  *                    LEFT (pad1() ~ pad11()) 		                         *
  *****************************************************************************/
  ec_breakv pad1();
  vddtvh pad2();
  pvhbcudtart pad3(.CI(1'b1), .CPU(1'b0), .CPD(1'b0), .CD0(1'b0), .CD1(1'b0), .CE(1'b0), .A(1'b0), .PI(1'b0), .CLTCH(), .PAD(i_CLK), .Y(w_clk_p));
  vsstvh pad4();
  ec_breakv pad5();
  vsstvh pad6();
  pvhbcudtbrt pad7(.CI(1'b0), .CPU(1'b0), .CPD(1'b0), .CD0(1'b1), .CD1(1'b1), .CE(1'b1), .A(w_ads1292_reset_p), .PI(1'b0), .CLTCH(), .PAD(ADS1292_RESET));
  pvhbcudtbrt pad9(.CI(1'b0), .CPU(1'b0), .CPD(1'b0), .CD0(1'b1), .CD1(1'b1), .CE(1'b1), .A(w_ads1292_start_p), .PI(1'b0), .CLTCH(), .PAD(ADS1292_START));
  vssipvh pad8();
  vddivh pad10();
  pvhbcudtbrt pad11(.CI(1'b0), .CPU(1'b0), .CPD(1'b0), .CD0(1'b1), .CD1(1'b1), .CE(1'b1), .A(w_ads1292_csn_p), .PI(1'b0), .CLTCH(), .PAD(ADS1292_CSN));
  //============================================================================
  /****************************************************************************
  *                    Bottom (pad12() ~ pad22())          	                 *
  *****************************************************************************/
  //============================================================================
  vddtvh pad12();
  pvhbcudtbrt pad13(.CI(1'b0), .CPU(1'b0), .CPD(1'b0), .CD0(1'b1), .CD1(1'b1), .CE(1'b1), .A(w_ads1292_sclk_p), .PI(1'b0), .CLTCH(), .PAD(ADS1292_SCLK));
  vsstvh pad14();
  pvhbcudtbrt pad15(.CI(1'b1), .CPU(1'b0), .CPD(1'b0), .CD0(1'b0), .CD1(1'b0), .CE(1'b0), .A(1'b0), .PI(1'b0), .CLTCH(), .PAD(ADS1292_MISO), .Y(w_ads1292_miso_p));
  vssipvh pad16();
  vddivh pad17();
  pvhbcudtbrt pad18(.CI(1'b0), .CPU(1'b0), .CPD(1'b0), .CD0(1'b1), .CD1(1'b1), .CE(1'b1), .A(w_ads1292_mosi_p), .PI(1'b0), .CLTCH(), .PAD(ADS1292_MOSI));
  vsstvh pad19();
  vddtvh pad20();
  pvhbcudtbrt pad21(.CI(1'b1), .CPU(1'b0), .CPD(1'b0), .CD0(1'b0), .CD1(1'b0), .CE(1'b0), .A(1'b0), .PI(1'b0), .CLTCH(), .PAD(ADS1292_DRDY), .Y(w_ads1292_drdy_p));
  vsstvh pad22();
  //============================================================================
  /****************************************************************************
  *                    Right (pad23() ~ pad33())           	                 *
  *****************************************************************************/
  //============================================================================
  vssipvh pad23();
  vddivh pad24();
  vddtvh pad25();
  pvhbcudtbrt pad26(.CI(1'b0), .CPU(1'b0), .CPD(1'b0), .CD0(1'b1), .CD1(1'b1), .CE(1'b1), .A(w_uart_tx_p), .PI(1'b0), .CLTCH(), .PAD(UART_TXD));
  vddivh pad27();
  vssipvh pad28();
  pvhbcudtbrt pad29(.CI(1'b1), .CPU(1'b0), .CPD(1'b0), .CD0(1'b0), .CD1(1'b0), .CE(1'b0), .A(1'b0), .PI(1'b0), .CLTCH(), .PAD(UART_RXD), .Y(w_uart_rx_p));
  vsstvh pad30();
  vddivh pad31();
  vssipvh pad32();
  vddtvh pad33();
  //============================================================================
  /****************************************************************************
  *                    TOP (pad34() ~ pad44())                                *
  *****************************************************************************/
  //============================================================================
  // w_mpr121_scl_en_p ? in : out
  // w_mpr121_sda_en_p ? in : out
  pvhbcudtbrt pad34(.CI(w_mpr121_scl_en_p), .CPU(1'b0), .CPD(1'b0), .CD0(1'b0), .CD1(1'b0), .CE(~w_mpr121_scl_en_p), .A(w_mpr121_scl_out_p), .PI(1'b0), .CLTCH(), .PAD(MPR121_SCL), .Y(w_mpr121_scl_in_p));
  ec_breakv pad35();
  pvhbcudtbrt pad36(.CI(w_mpr121_sda_en_p), .CPU(1'b0), .CPD(1'b0), .CD0(1'b0), .CD1(1'b0), .CE(~w_mpr121_sda_en_p), .A(w_mpr121_sda_out_p), .PI(1'b0), .CLTCH(), .PAD(MPR121_SDA), .Y(w_mpr121_sda_in_p));
  vddtvh pad37();
  vsstvh pad38();
  // vsstv - N_I/O - vssipv - vddiv - vddtv
  // schmitt trigger for global reset
  pvhbsudtart pad39(.CI(1'b1), .CPU(1'b0), .CPD(1'b0), .CD0(1'b0), .CD1(1'b0), .CE(1'b0), .A(1'b0), .PI(1'b0), .CLTCH(), .PAD(i_RSTN), .Y(w_rstn_p));
  vssipvh pad40();
  vddivh pad41();
  vddtvh pad42();
  ec_breakv pad43();
  //============================================================================
	/****************************************************************************
	*                           async_rstn_glitch_synchronizer                                   *
	*****************************************************************************/
// reset synchronizer with glitch filter for Reset recovery time and dont fall to metastability
wire w_rstn;
async_rstn_glitch_synchronizer async_rstn_glitch_synchronizer (
    .i_CLK(i_CLK),
    .i_RSTN(w_rstn_p),
    .o_RSTN(w_rstn)
    );
  /****************************************************************************
  *                           khu_sensor_top   		                          	*
  *****************************************************************************/
  //=========================Internal Connection===============================
  khu_sensor_top khu_sensor_top(
  	// System I/O
  	.i_CLK(w_clk_p), // Clock
  	.i_RSTN(w_rstn), // Reset

  	// RS232 UART
  	.UART_RXD(w_uart_rx_p),
  	.UART_TXD(w_uart_tx_p),

  	// DUT IO: for MPR121 (I2C)
  	.MPR121_SCL_IN(w_mpr121_scl_in_p),
  	.MPR121_SDA_IN(w_mpr121_sda_in_p),
  	.MPR121_SCL_OUT(w_mpr121_scl_out_p),
  	.MPR121_SDA_OUT(w_mpr121_sda_out_p),
  	.MPR121_SCL_EN(w_mpr121_scl_en_p),
  	.MPR121_SDA_EN(w_mpr121_sda_en_p),

  	// DUT IO: for ADS1292 (SPI)
  	.ADS1292_SCLK(w_ads1292_sclk_p),
  	.ADS1292_MISO(w_ads1292_miso_p),
  	.ADS1292_MOSI(w_ads1292_mosi_p),
  	.ADS1292_DRDY(w_ads1292_drdy_p),
  	.ADS1292_RESET(w_ads1292_reset_p),
  	.ADS1292_START(w_ads1292_start_p),
  	.ADS1292_CSN(w_ads1292_csn_p)
  	);
endmodule //khu_sensor_pad
