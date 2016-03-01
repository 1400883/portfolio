# Worm Game
#### Licensed under MIT
###### Year: 2015
# 
<img src="https://github.com/1400883/portfolio/blob/master/JS_Node.js_jQueryUI_Socket.IO_MySQL/Worm_Game/screenshot.png?raw=true" width="340" />
This was one of those the less fortunate student-driven team projects in Karelian University of Applied Sciences, where you end up doing pretty much everything yourself.

The objective was to create a multiplayer worm game with following features:
- Single-player mode
- Multi-player mode
- Registration
- Login
- Ranking list
- Chat

One of the teammates did a decent job on the game board appearance (CSS + images), so at least it won't scare too many children. I got the single-player mode, registration, login and chat finished, both server and client side, though some of that could use proper testing to wipe out lurking bugs.

The server is based on Node.js. Communication between the client and the server is realized using socket.IO. A little bit of jQuery UI for the registration form and MySQL database for the permanent storage - that's what little kids are made of!

Online testing site @ [OpenShift]. Please don't type rude stories in the chat, so I won't have to blush reading them. Thanks.

[OpenShift]: http://matopeli-1400883.rhcloud.com/