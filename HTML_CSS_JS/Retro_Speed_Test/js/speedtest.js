var lcd_level = [];
var button = [];
var button_container = [];
var keyboard_key = [];
var keyboard_keycode = [];

var invalid_key = [];
var blink_keybox_counter = 0;
var blink_keybox_timer;

var lcd_score;
var score_timer;
var score_counter = 0;
var start_button;

var LCD_LEVEL_TOTAL = 7;
var BUTTONS_TOTAL = 4;

var countdown_counter = 0;
var countdown_timer;

var game_timer;
var lcd_star_left;
var lcd_star_right;

var SPEED_MS = 500;
var HIGH_SPEED_CHANCE = 1/6;

var previous_speed = 0;
var previous_light = 0;
var score = 0;

var IDLE_BLINK_MS = 1000;
var idle_counter = 0;
var idle_counter2 = 0;
var idle_timer;

// A streak of up to MAX_MISSES unclicked lights allowed to accumulate 
// at any given time before it's considered 'game over'.
var MAX_MISSES = 7;
var missed_lights = [];

onload = function() {
	var i;
	
	// Start button object and start game event listener
	start_button = document.getElementById("start_button");
	start_button.addEventListener("click", start_game);

	// Level ninja light objects
	for (i = 0; i < LCD_LEVEL_TOTAL; i++)
		lcd_level[i] = document.getElementById("level" + i);
	
	// Star light objects
	lcd_star_left = document.getElementById("stars_left");
	lcd_star_right = document.getElementById("stars_right");

	// LCD scoreboard object
	lcd_score = document.getElementById("score");
	lcd_score.style.textAlign = "right";

	// Button light objects
	for (i = 0; i < BUTTONS_TOTAL; i++) {
		button_container[i] = document.getElementById("button_container" + i);
		button[i] = document.getElementById("button" + i);
	}

	// Keyboard key configuration objects
	for (i = 0; i < BUTTONS_TOTAL; i++)
		keyboard_key[i] = document.getElementById("key_button" + i);

	// Start idle flashing demo
	idle_timer = setInterval(game_idle, IDLE_BLINK_MS);
}

// Show idle flashing demo 
function game_idle() {
	var i;
	
	lcd_score.style.visibility = (idle_counter2 ? (idle_counter + 1) : idle_counter) % 2 ? "visible" : "hidden";
	lcd_star_left.style.visibility = (idle_counter2 ? (idle_counter + 1): idle_counter) % 2 ? "hidden" : "visible";
	lcd_star_right.style.visibility = (idle_counter2 ? (idle_counter + 1): idle_counter) % 2 ? "hidden" : "visible";

	if (!idle_counter)
		for (i = 1; i < LCD_LEVEL_TOTAL; i++)
			lcd_level[i].style.visibility = "hidden";

	for (i = 0; i <= idle_counter; i++)
		lcd_level[i].style.visibility = "visible";
	
	if (idle_counter < 6)
		++idle_counter;
	else {
		idle_counter = 0;
		idle_counter2 = !idle_counter2;
		
		clearInterval(idle_timer);
		idle_timer = setInterval(
						game_idle, 
						(IDLE_BLINK_MS < 100 
							? IDLE_BLINK_MS = 1000 
							: (IDLE_BLINK_MS = Math.floor(IDLE_BLINK_MS / 2))));
		
	}
}

// Check for duplicate or empty keys
function validate_keys() {
	// Inits
	invalid_key[0] = false;
	invalid_key[BUTTONS_TOTAL] = false;

	// Game keyboard configuration
	for (i = 0; i < BUTTONS_TOTAL; i++) {
		// Must use uppercase character codes, lower case is incompatible
		keyboard_keycode[i] = keyboard_key[i].value.toUpperCase().charCodeAt(0);
		
		// Search for duplicate keys
		for (j = 0; j < i; j++) {
			invalid_key[i] = (keyboard_keycode[i] === keyboard_keycode[j] 
								? (invalid_key[BUTTONS_TOTAL] = true)
								: false);
			if (invalid_key[i])
				break;
		}
		
		// Search for empty keys
		if (isNaN(keyboard_keycode[i]))
			invalid_key[i] = invalid_key[BUTTONS_TOTAL] = true;
	}
}

/*	key	i 	keyboard_keycode[i]		invalid_key[i]
	1	0 	49 						undefined
		1 	NaN 					false
	3	2 	51 						false
	1	3	49 						true
*/

// Prepare a new game, validate player's 
// key selections and start countdown timer
function start_game() {
	var i, j;
	
	idle_counter = 0;
	clearInterval(idle_timer);
	start_button.removeEventListener("click", start_game);
	
	// Hide level ninja lights
	for (i = 0; i < LCD_LEVEL_TOTAL; i++)
		lcd_level[i].style.visibility = "hidden";
	
	// Hide flashing stars
	lcd_star_left.style.visibility = "hidden";
	lcd_star_right.style.visibility = "hidden";

	// Make sure score is visible
	lcd_score.style.visibility = "visible";

	validate_keys();
	
	if (!invalid_key[BUTTONS_TOTAL]) { // Keyboard configuration OK
		// Startup countdown
		countdown_timer = setInterval(countdown, 1500);
		start_button.innerHTML = "käynnissä";

		// MUST alter text color via CSS class name change instead
		// of directly altering style.color. Otherwise :hover will
		// stop working!
		start_button.className = "yellow";
		
		// Disable game key configurations for the duration of the game
		disable_keyconfig();
	}
	else // At least one invalid key found
		// Blink invalid key input boxes a couple of times
		blink_keybox_timer = setInterval(blink_keybox, 100);
}

// Blink keybox as a sign of a invalid key
function blink_keybox() {
	var i;

	blink_keybox_counter++;
	
	for (i = 0; i < BUTTONS_TOTAL; i++)
		if (invalid_key[i])
			keyboard_key[i].style.background = blink_keybox_counter % 2 
												? "#f00"
												: "#777";
	
	if (blink_keybox_counter > 15) {
		start_button.addEventListener("click", start_game);
		clearInterval(blink_keybox_timer);
		blink_keybox_counter = 0;
		invalid_key[0] = false;
	}
}

// Enable key configuration
function enable_keyconfig() {
	var i;
	for (i = 0; i < BUTTONS_TOTAL; i++) {
		keyboard_key[i].removeAttribute("disabled");
		keyboard_key[i].style.opacity = "1";
	}
}

// Disable key configuration
function disable_keyconfig() {
	var i;
	var node_list;
	for (i = 0; i < BUTTONS_TOTAL; i++) {
		keyboard_key[i].setAttribute("disabled", "disabled");
		keyboard_key[i].style.opacity = "0.7";
	}
	/*node_list = document.getElementsByClassName("span_key");
	for (i = 0; i < node_list.length; i++)
		node_list[i].style.opacity = "0.8";*/
}

// Start game countdown
function countdown() {
	switch (countdown_counter) {
		case 0:
			lcd_score.innerHTML = "";
			lcd_score.innerHTML = "RDY";
			lights_turnon(1);
			break;
		case 1:
			lights_turnon(12);
			break;
		case 2:
			lcd_score.innerHTML = "SET";
			lights_turnon(123);
			break;
		case 3:
			lights_turnon(1234);
			break;
		case 4:
			lcd_score.innerHTML = "GO!"
			// Speed up a bit
			clearInterval(countdown_timer);
			countdown_timer = setInterval(countdown, 1000);
			break;
		default:
			lcd_score.innerHTML = "0000";
			lights_turnon(0);
			clearInterval(countdown_timer);
			game_timer = setInterval(alternate_lights, SPEED_MS[0]);
	}
	countdown_counter++;
}

// Calculate new game speed
function calculate_speed() {
	return (SPEED_MS - (score <= 9
						? 0
						: (score <= 19 
							? 1 
							: (score <= 29
								? 2
								: (score <= 49
									? 3
									: (score <= 69
										? 4
										: (score <= 99
											? 5
											: (score <= 250
												? (Math.floor(score / 50) + 4)
												: 9)))))) * 40))
						// Add some randomness in the period
						* (Math.random() > 1 - HIGH_SPEED_CHANCE 
							? 0.5 
							: 1);
}

// Update game speed
function update_speed(current_speed) {
	if (previous_speed != current_speed) {
		clearInterval(game_timer);
		game_timer = setInterval(alternate_lights, current_speed);
		previous_speed = current_speed;
	}
}

// Start alternating lights in random order
function alternate_lights() {
	var current_speed;
	var light;

	// Calculate current speed based on 
	// present score and random variation
	current_speed = calculate_speed()
	
	// Adjust speed as needed
	update_speed(current_speed);
	
	// Determine the next light to light up
	do {
		light = Math.floor(Math.random() * 4) + 1;
	} while (light === previous_light);
	
	
	// Activate event listeners if game just started
	if (!previous_light)
		start_eventlisteners();
	
	previous_light = light;

	// Turn on the next light
	lights_turnon(light);

	// Add the light to the array of unclicked lights
	missed_lights.unshift(light - 1);
	
	// Too many missed clicks accumulated?
	if (missed_lights.length > MAX_MISSES)
		stop_game();
}

// Increase game score by one
function score_addone() {
	var zero_padding = "";
	// Pop the last element out of the array of unclicked lights
	missed_lights.pop();
	
	// Calculate zero padding and display updated score
	++score;
	for (i = 0; i < 4 - score.toString().length; i++)
		zero_padding += "0";
	
	lcd_score.innerHTML = zero_padding + score;
}

// Light button push event
function push_lightbutton(event) {
	
	var i;
	var button_ID;
	
	if (event.button != undefined) // Mouse button
		button_ID = this.id.charAt(this.id.length - 1);
	else
		for (i = 0; i < BUTTONS_TOTAL; i++)
			if (event.keyCode == keyboard_keycode[i])
				button_ID = i;
	
	// Correct light button has been pressed?
	if (button_ID == missed_lights[missed_lights.length - 1])
		score_addone();
	else
		stop_game();
}

// Turn on button lights
function lights_turnon(buttons) {
	var i;

	// Light all up?
	if (!buttons) 
		for (i = 0; i < BUTTONS_TOTAL; i++)
			button[i].style.visibility = "hidden";
	// Light up one or some of the lights
	else {
		buttons += ""; // to string
		for (i = 0; i < BUTTONS_TOTAL; i++)
			button[i].style.visibility = (buttons.indexOf(i + 1) + 1) 
										 ? "visible"
										 : "hidden";
	}
}

// Start mouse & keyboard event listeners
function start_eventlisteners() {
	var i;
	document.addEventListener("keydown", push_lightbutton);
	for (i = 0; i < BUTTONS_TOTAL; i++)
		button_container[i].addEventListener("mousedown", push_lightbutton);
}

// Stop mouse & keyboard event listeners
function stop_eventlisteners() {
	var i;
	document.removeEventListener("keydown", push_lightbutton);
	for (i = 0; i < BUTTONS_TOTAL; i++)
		button_container[i].removeEventListener("mousedown", push_lightbutton);
}

// Lights up ninja figures based on player's score
function display_ninjas() {
	var level, i;
	level = score <= 9
			? 0
			: (score <= 19 
				? 1 
				: (score <= 29
					? 2
					: (score <= 49
						? 3
						: (score <= 69
							? 4
							: (score <= 99
								? 5
								: 6)))));
	for (i = 0; i < level + 1; i++)
		lcd_level[i].style.visibility = "visible";
}

// Quit the game, display the lighted ninja figures
// according to score and start end-game score flashing.
// Also re-initialize variables etc for another game
function stop_game() {
	var level;
	var i;
	
	// Turn off lights from the previous game
	lights_turnon(0);

	// Disable mouse & keyboard event listeners
	stop_eventlisteners();

	// Stop game timer
	clearInterval(game_timer);

	// Display ninja figures
	display_ninjas();


	// Re-init stuff for a new game
	enable_keyconfig();
	
	previous_speed = 0;
	score = 0;
	missed_lights = [];
	previous_light = 0;
	countdown_counter = 0;

	// Re-enable start button
	start_button.innerHTML = "aloita";
	start_button.className = "";
	start_button.addEventListener("click", start_game);

	// Flash score display
	score_timer = setInterval(endgame_flash, 1000);
}

// Flash score after game over
function endgame_flash() {
	lcd_score.style.visibility = score_counter % 2 ? "hidden" : "visible";
	
	if (score_counter++ >= 8) {
		clearInterval(score_timer);
		score_counter = 0;
		// Have a dummy pause between endgame flash and demo
		setTimeout(dummy_pause, 1000);
	}
}

// Dummy pause function
function dummy_pause() {
	// Start idle flashing demo
	idle_timer = setInterval(game_idle, IDLE_BLINK_MS = 1000);
}