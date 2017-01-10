# Turtle lamp project
#### 
###### Year: 2016
# 
<img src="https://github.com/1400883/portfolio/blob/master/Assembler_(PIC)/Turtle_lamp/screenshot.png?raw=true" width="340" />

A turtle-shaped handicraft lamp I bought second-hand got a facelift with a PIC microcontroller. The lamp had a regular E14 socket and a matching 15-watt bulb. I replaced the socket with an old 5-volt Nokia mobile phone charger, which powers the circuit built on a prototyping stripboard, schematized below. 

The least resource-packed of PIC microcontrollers, a PIC10F200 (16-byte RAM, 256 instructions), functions as a simulated sine PWM signal source, feeding two 1-watt leds via MOSFETs.

Nokia SMPS charger has clearly been designed to supply a very specific load. While powering the circuit, the charger outputs voltages in the range of 6.5 to 6.9 volts, which is dangerously high for the µC. Thus, R1 and ZD1 form a voltage divider to match the supply voltage with the load. Resistor value was chosen based on empiric tests - finding the largest resistance without drop-outs, and going little backwards from there.

Originally, I planned to connect leds to MOSFET drain, leaving source connected directly to ground. The purpose of R2 and R3 was to protect the µC ports from outrush of current required to charge MOSFET gate capacitance. At the end of the day, I ended up placing leds further downstream to MOSFET source. This should render R2 and R3 useless, but they remained physically connected in the circuit nevertheless.

Initially powering the circuit, naturally, causes supply voltage appear in each MOSFET drain. This sudden voltage leap induces transient voltage into gate lines, potentially causing FETs to switch for a split of a second. R4 and R5 pull down the gates, which prevents this undesired led flash phenomenon. Resistor values are not by any means critical as long as R4/R2 and R5/R3 ratios remain very large to ensure solid switching voltages.

R6 and R7 are included to provide temperature stabilization for led current draw.

<img src="https://github.com/1400883/portfolio/blob/master/Assembler_(PIC)/Turtle_lamp/turtle_led_schematic.png?raw=true" />

<img src="https://github.com/1400883/portfolio/blob/master/Assembler_(PIC)/Turtle_lamp/circuit.png?raw=true" width="500" />

[![Click to see the lamp in action](http://img.youtube.com/vi/ZocbIXfMZGQ/0.jpg)](https://www.youtube.com/watch?v=ZocbIXfMZGQ "Click to see the lamp in action")
