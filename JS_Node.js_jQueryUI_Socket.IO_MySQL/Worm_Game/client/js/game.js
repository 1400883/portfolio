/*
  Copyright (c) 2015 Tuomas Keinänen
*/

function Game() {
  var _this = this;
  this.gameContext = this;
  this.isPaused = false;
  this.isRunning = false;
  this.isGameOverReasonWin;  
  this.score = 0;
  this.boardSizeOptions = { large: "suuri", average: "keskikoko", small: "pieni" };
  this.boardSizeDim = { large: 20, average: 14, small: 8 };
  this.speedOptions = { high: "nopea", medium: "normaali", slow: "hidas"};
  this.speedLevel = { high: 10, medium: 6, slow: 3 };
};

///////////////////////////////////////////////////////////
// PELIN ALUSTUSFUNKTIO ///////////////////////////////////
///////////////////////////////////////////////////////////
Game.prototype.Start = function(boardWidth, boardHeight) {
  // Elementtiviitteet
  this.board = document.getElementById("gameboard");

  // Sisäänkirjaus
  this.login = new Login();
  // Rekisteröintidialogi
  this.registerDialog = new RegisterDialog();
  // Chat
  this.chat = new Chat(this);
  // Pelilauta
  this.gameboard = new Gameboard(game, boardWidth, boardHeight);
  this.gameboard.Init(this.board, this.boardSizeOptions, this.speedOptions);
  // Näppäinmanageri
  this.keyboardControl = new KeyboardControl(this);
  this.keyboardControl.Init();
  // Mato
  this.worm = new Worm(this);
  // Ruoka
  this.food = new Food(this);
  
  // Aseta mato aloitussijaintiin ja -suuntaan
  this.worm.Init();
};

///////////////////////////////////////////////////////////
// PELIN TILAN PÄIVITYSFUNKTIO ////////////////////////////
///////////////////////////////////////////////////////////
Game.prototype.Update = function() {
  var _this = this;
  
  // Päivitetään madon sijainti
  var nextPos = this.gameboard.getNextPos[this.worm.dir](this.worm.pos[this.worm.pos.length - 1]);

  // Madon törmäystarkistus
  for (var i = 1; i < this.worm.pos.length - 3; ++i) {
    if (nextPos == this.worm.pos[i]) {
      // Mato on törmännyt omaan kylkeensä
      this.isRunning = false;
      this.isGameOverReasonWin = false;
      break;
    }
  }
  
  if (this.isRunning) {
    // Merkitse mato liikkuneeksi liikesuunnan mukaiseen 
    // seuraavaan sijaintiin
    this.worm.pos.push(nextPos);
    // Merkitse madon peräpääruudusta pelilaudalta madon 
    // väri pois pyyhittäväksi, jos mato ei ole juuri syönyt 
    // ruokaa (= mato liikkuu eteenpäin).
    // Vastaavasti jos mato söi ruoan, sen pituus pitenee 
    // ja venyy pään puoleisesta päästä seuraavalla siirrolla.
    // Tällöin peräpää jää vielä paikalleen.
    if (!this.worm.hasJustEatenFood) {
      // Mato ei ole syönyt -> poista matoväri peräpään 
      // alla olevasta pelilaudan ruudusta
      this.worm.RestoreBackground();
      // Merkitse ruutu matoon kuulumattomaksi
      this.worm.pos.shift();
    }
    else
      // Mato on syönyt eikä sen perää pyyhitty tällä siirrolla.
      // Nollataan syönnistä kertova muuttuja seuraavaan siirtoon.
      this.worm.hasJustEatenFood = false;
  
    // Piirrä mato suunnan mukaiseen uuteen sijaintiin
    this.worm.Draw();

    // Ruoan hallinta ja pistelasku
    /////////////////////////////
    if (this.worm.pos[this.worm.pos.length - 1] == this.food.pos) {
      // Mato poimi ruoan -> välitetään viesti madon piirto-
      // funktiolle madon pidennystä varten
      this.worm.hasJustEatenFood = true;
      // Kasvata pistelukemaa
      this.gameboard.scoreDisplay.textContent = ++this.score;
      // Piirretään uusi ruoka pelilaudalle
      if (!this.food.Draw()) {
        // Uusi ruoka ei mahtunut pelilaudalle -> 
        // mato täyttää jo koko pelilaudan
        this.isRunning = false;
        this.isGameOverReasonWin = true;
      }
    }
    if (this.isRunning) {
      // Madon sijainnin näppäimistöpuskurin käsittely
      this.keyboardControl.ProcessBuffer();
    }
  }

  if (!this.isRunning) {
    this.StopInterval();
    setTimeout(function() { _this.GameOver(); }, 50);
  }
};

///////////////////////////////////////////////////////////
// PELIN ETENEMIS- JA PYSÄYTYSFUNKTIOT ////////////////////
///////////////////////////////////////////////////////////
Game.prototype.StartInterval = function() {
  var _this = this;
  this.setIntervalId = setInterval(function() {
    // Käynnistä Update()-funktion ajastettu suoritus
    _this.Update();
  }, 
  Math.round(1000 / this.worm.movesPerSecond));
};

Game.prototype.StopInterval = function() {
  // Pysäytä Update()-funktion ajastettu suoritus
  clearInterval(this.setIntervalId);
};

///////////////////////////////////////////////////////////
// PELIN PÄÄTTYMISFUNKTIO /////////////////////////////////
///////////////////////////////////////////////////////////
Game.prototype.GameOver = function() {
  if (this.isGameOverReasonWin) {
    // Pelaaja sai täytettyä madollaan koko ruudun!
    console.log("Win");
  }
  else {
    // Pelaajan mato törmäsi itseensä
    console.log("Lose");
  }
  // Aseta pelin aloituspainikkeen teksti alkuarvoonsa.
  this.gameboard.startButton.value = this.gameboard.startButtonText.off;
};

/*
Pelilaudan visualisointia auttamaan:

20 x 20 matriisi

000 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015 016 017 018 019
020 021 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039
040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059
060 061 062 063 064 065 066 067 068 069 070 071 072 073 074 075 076 077 078 079
080 081 082 083 084 085 086 087 088 089 090 091 092 093 094 095 096 097 098 099
100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119
120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139
140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159
160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179
180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199
200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219
220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239
240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259
260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279
280 281 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299
300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319
320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339
340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359
360 361 362 363 364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379
380 381 382 383 384 385 386 387 388 389 390 391 392 393 394 395 396 397 398 399
*/