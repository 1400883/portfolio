# Turtle lamp project
#### 
###### Year: 2016
# 
<img src="https://github.com/1400883/portfolio/blob/master/Assembler_(PIC)/Turtle_lamp/screenshot.png?raw=true" width="340" />

A turtle-shaped handicraft lamp I bought second-hand got a facelift with a PIC microcontroller. The lamp had a regular E14 socket and a matching 15-watt bulb. I replaced the socket with an old 5-volt Nokia mobile phone charger, which powers the circuit built on a prototyping stripboard, schematized below. 

The least resource-packed of PIC microcontrollers, a PIC10F200 (16-byte RAM, 256 instructions), functions as a simulated sine PWM signal source, feeding two 1-watt leds via MOSFETs.

R1 and ZD1 form a current limiting voltage divider to minimize µC current consumption. Not that it makes much of a difference in this application, because leds suck the most of the juice drawn by the circuit anyway.

The purpose of R2 and R3 is to protect the µC ports from outrush of current required to charge MOSFET gate capacitance. They are probably an overkill, but better safe than sorry.

Initially powering the circuit induces input voltage appearing in MOSFET drains into gate lines, potentially causing FETs to switch momentarily. R4 and R5 are there to pull down the gates, which prevents this annoying led flash. Resistor values are not by any means critical as long as R4/R2 and R5/R3 ratios remain very large to ensure solid switching voltages.

R6 and R7 are included to provide temperature stabilization for led current draw.

<img src="https://github.com/1400883/portfolio/blob/master/Assembler_(PIC)/Turtle_lamp/turtle_led_schematic.png?raw=true" />

<img src="https://github.com/1400883/portfolio/blob/master/Assembler_(PIC)/Turtle_lamp/circuit.png?raw=true" width="500" />

[![Click to watch the lamp in action](http://img.youtube.com/vi/1zPA86Bnflw/0.jpg)](https://www.youtube.com/watch?v=1zPA86Bnflw "Click to watch the Lamp in action")
