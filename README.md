<h1 align="center"> khu_sensor_65n </h1>

khu_sensor is a processor that communicates with MPR121 and ADS1292 and sends filtered **HoD & ECG** data to PC through RS232.  

### khu_sensor GDSII
<img src="./03_Physical_Synthesis/pictures/08_chip_finish_GDSII.png" alt="08_chip_finish_GDSII" width="600" height="600"/>

#### Final Design Specification

|  Spec    |   Value  |
|----------|----------|
| Technology | S65nm |
| Operating Condition | SS 1.08V 125°C (Worst) FF 1.32V -40°C (Best)|
| Main Clock | 111 MHz |
| Slack | 0.2440 ns(Worst) 2.9788 ns(Best) |
| Die Area |  1.4mm x 1.4mm (56 I/O PAD)  |
| Design Area |  1288408 µm^2  |
| Power | 5.9253 mW |

### 01_RTL_Synthesis

###### Compile


###### Re-time


###### Clock-Gating


#### Design Performance

|  Spec (SS 1.08V 125°C)   |   Compile  | Re-time | Clock-Gating |
|----------|------------|--------|-------------|
| Slack (ns) | 0.0 | 0.0  | 4.74  |
| Design Area (µm^2) |  107706.88  | 106533.76 | 100437.12 |
| Power (mw) | 228.0738 | 228.1706 | 5.9253 |

### 03_Physical_Synthesis

#### 00_read_design

<img src="./03_Physical_Synthesis/pictures/00_read_design.png" alt="00_read_design" width="600" height="600"/>

#### 01_floorplan

<img src="./03_Physical_Synthesis/pictures/01_floorplan.png" alt="01_floorplan" width="600" height="600"/>

#### 02_powerplan

<img src="./03_Physical_Synthesis/pictures/02_powerplan.png" alt="02_powerplan" width="600" height="600"/>

##### VDD, VSS, VDDT, CLTCH Check
<img src="./03_Physical_Synthesis/pictures/02_powerplan_VDD_VSS_VDDT.png" alt="02_powerplan_VDD_VSS_VDDT" width="300" height="300"/>
<img src="./03_Physical_Synthesis/pictures/02_powerplan_CLTCH.png" alt="02_powerplan_CLTCH" width="300" height="300"/>

##### FILLTIE Cell (Prevent latchup)
<img src="./03_Physical_Synthesis/pictures/02_powerplan_fill_tie.png" alt="02_powerplan_fill_tie" width="600" height="300"/>
<img src="./03_Physical_Synthesis/pictures/02_powerplan_fill_tie_zoom.png" alt="02_powerplan_fill_tie_zoom" width="600" height="300"/>

#### 03_place_opt

<img src="./03_Physical_Synthesis/pictures/03_place_opt_zoom.png" alt="03_place_opt_zoom" width="600" height="600"/>

#### 04_clock_opt_cts

<img src="./03_Physical_Synthesis/pictures/04_clock_opt_cts.png" alt="04_clock_opt_cts" width="600" height="600"/>

#### 05_clock_opt_post_cts

#### 06_route

<img src="./03_Physical_Synthesis/pictures/06_route.png" alt="06_route" width="600" height="300"/>
<img src="./03_Physical_Synthesis/pictures/06_route_zoom.png" alt="06_route_zoom" width="600" height="300"/>

#### 07_route_opt

##### Clock Shielding
<img src="./03_Physical_Synthesis/pictures/07_route_opt_clock_shielding.png" alt="07_route_opt_clock_shielding" width="600" height="300"/>

##### ANTENNA DIODE Cell
<img src="./03_Physical_Synthesis/pictures/07_route_opt_antenna_diode.png" alt="07_route_opt_antenna_diode" width="600" height="300"/>

##### TIE HIGH Cell
<img src="./03_Physical_Synthesis/pictures/07_route_opt_tie_high.png" alt="07_route_opt_tie_high" width="600" height="300"/>

#### 08_chip_finish

##### Layer
<img src="./03_Physical_Synthesis/pictures/08_chip_finish_Layer.png" alt="08_chip_finish_Layer" width="600" height="600"/>

##### DECAP Cell
<img src="./03_Physical_Synthesis/pictures/08_chip_finish_decap.png" alt="08_chip_finish_Layer" width="600" height="400"/>

##### FILLER Cell
<img src="./03_Physical_Synthesis/pictures/08_chip_finish_Filler.png" alt="08_chip_finish_Layer" width="600" height="300"/>

###### GDSII
<img src="./03_Physical_Synthesis/pictures/08_chip_finish_GDSII.png" alt="08_chip_finish_GDSII" width="600" height="600"/>
<img src="./03_Physical_Synthesis/pictures/08_chip_finish_GDSII_Zoom.png" alt="08_chip_finish_GDSII" width="600" height="600"/>
