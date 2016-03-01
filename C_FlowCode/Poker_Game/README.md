# Poker Game
#### 
###### Year: 2013
# 
<img src="https://github.com/1400883/portfolio/blob/master/C_FlowCode/Poker_Game/screenshot.jpg?raw=true" width="340" />

Poker Game is a program that mimics the logic of old-school two-round poker slot machines. It was made for an embedded system a few years back while studing electronics in North Karelian professional college.

At the heart of the game there was ECIO, a PIC-based USB programmable single board computer designed by Matrix Technology Solutions Ltd. Poker game system incorporated three units from a multitude of what are called E-Blocks, small circuit boards that implement various types of electronics directly interfaceable to ECIO base board via DB9 connectors. The block types used in the game were LCD display board (yay ASCII graphics!), led board and button board, which together consumed every single output available in the microcontroller, so it was a close call.

Most of the code was done by flowchart symbol connections in FlowCode, a graphical programming environment with low learning curve. However, in this project I had to mix in pure C as well, as winning hand checks would've taken far too many graphics items and screen estate to be practical anymore.

Full documentation included in ECIO-pokeripelikone.pdf (in Finnish).
Watch gameplay @ [Youtube]

[Youtube]: https://www.youtube.com/watch?v=HSC5H1ce-U0