  
        
set_property  -dict {PACKAGE_PIN  E17   IOSTANDARD LVCMOS25} [get_ports  pps_in    ] ;
set_property  -dict {PACKAGE_PIN  H16   IOSTANDARD LVCMOS25} [get_ports  clk_40m   ] ;
create_clock -name clk_40m       -period 25 [get_ports clk_40m]


set_property  -dict {PACKAGE_PIN  J15   IOSTANDARD LVCMOS25} [get_ports  dac_nsyc  ] ;
set_property  -dict {PACKAGE_PIN  K16    IOSTANDARD LVCMOS25} [get_ports  dac_din   ] ;
set_property  -dict {PACKAGE_PIN  J16   IOSTANDARD LVCMOS25} [get_ports  dac_clk   ] ;
set_property  -dict {PACKAGE_PIN  k18   IOSTANDARD LVCMOS25} [get_ports  gps_pl_led    ] ; 
set_property  -dict {PACKAGE_PIN  e19   IOSTANDARD LVCMOS25} [get_ports  sel_clk_src    ] ; 
 
  


set_property  -dict {PACKAGE_PIN  d20  IOSTANDARD LVCMOS25} [get_ports  phy_tx_en] ;  
set_property  -dict {PACKAGE_PIN  e18  IOSTANDARD LVCMOS25} [get_ports  phy_tx_err] ;
set_property  -dict {PACKAGE_PIN  f17  IOSTANDARD LVCMOS25} [get_ports  phy_reset_n] ;
set_property  -dict {PACKAGE_PIN  m19  IOSTANDARD LVCMOS25} [get_ports  phy_tx_dout[0]] ;
set_property  -dict {PACKAGE_PIN  m20  IOSTANDARD LVCMOS25} [get_ports  phy_tx_dout[1]] ;
set_property  -dict {PACKAGE_PIN  m17  IOSTANDARD LVCMOS25} [get_ports  phy_tx_dout[2]] ;
set_property  -dict {PACKAGE_PIN  m18  IOSTANDARD LVCMOS25} [get_ports  phy_tx_dout[3]] ;
set_property  -dict {PACKAGE_PIN  l19  IOSTANDARD LVCMOS25} [get_ports  phy_tx_dout[4]] ;
set_property  -dict {PACKAGE_PIN  l20  IOSTANDARD LVCMOS25} [get_ports  phy_tx_dout[5]] ;
set_property  -dict {PACKAGE_PIN  k19  IOSTANDARD LVCMOS25} [get_ports  phy_tx_dout[6]] ;
set_property  -dict {PACKAGE_PIN  j19  IOSTANDARD LVCMOS25} [get_ports  phy_tx_dout[7]] ;
set_property  -dict {PACKAGE_PIN  l16  IOSTANDARD LVCMOS25} [get_ports  phy_tx_clk] ;

set_property  -dict {PACKAGE_PIN  l17  IOSTANDARD LVCMOS25} [get_ports  phy_rx_err] ;
set_property  -dict {PACKAGE_PIN  k17  IOSTANDARD LVCMOS25} [get_ports  phy_rx_clk] ;


create_clock -name phy_rx_clk   -period 8 [get_ports phy_rx_clk]

set_property  -dict {PACKAGE_PIN  h17  IOSTANDARD LVCMOS25} [get_ports  phy_rx_din[0]] ;
set_property  -dict {PACKAGE_PIN  g15  IOSTANDARD LVCMOS25} [get_ports  phy_rx_din[1]] ;
set_property  -dict {PACKAGE_PIN  h18  IOSTANDARD LVCMOS25} [get_ports  phy_rx_din[2]] ;
set_property  -dict {PACKAGE_PIN  f19  IOSTANDARD LVCMOS25} [get_ports  phy_rx_din[3]] ;
set_property  -dict {PACKAGE_PIN  f20  IOSTANDARD LVCMOS25} [get_ports  phy_rx_din[4]] ;
set_property  -dict {PACKAGE_PIN  g17  IOSTANDARD LVCMOS25} [get_ports  phy_rx_din[5]] ;
set_property  -dict {PACKAGE_PIN  g18  IOSTANDARD LVCMOS25} [get_ports  phy_rx_din[6]] ;
set_property  -dict {PACKAGE_PIN  j20  IOSTANDARD LVCMOS25} [get_ports  phy_rx_din[7]] ;


set_property  -dict {PACKAGE_PIN  h20  IOSTANDARD LVCMOS25} [get_ports  phy_rx_dv] ; 
set_property  -dict {PACKAGE_PIN  h15  IOSTANDARD LVCMOS25} [get_ports  phy_gtx_clk] ;
  
set_property  -dict {PACKAGE_PIN M14   IOSTANDARD LVCMOS25  PULLUP true} [ get_ports  scl ]       ;
set_property  -dict {PACKAGE_PIN M15   IOSTANDARD LVCMOS25  PULLUP true}  [ get_ports  sda ]      ;