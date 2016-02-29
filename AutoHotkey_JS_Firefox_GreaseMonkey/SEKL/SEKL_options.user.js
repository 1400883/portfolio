/*
  Copyright (c) 2016 Tuomas Keinänen
*/

// ==UserScript==
// @name        SEKL_options
// @namespace   SEKL
// @include     http://sekl.fi/pohjois-karjala/wp-admin/post-new.php?post_type=tribe_events
// @require     https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js
// @version     1
// @grant       none
// @noframes
// ==/UserScript==

// Must be defined in unsafeWindow
// to be visible to another script.
unsafeWindow.Options = function() {
  this.title = "Kontiolahti: Talvitapahtuma";
  this.textChapters = [
    "Su–ti 6.–8.3. talvitapahtuma \"Jeesus on elämän leipä\".",
    "",
    "Su 6.3.",
    "*klo 10 messu Kontiolahden srk-talolla, Keskuskatu 26, liturgia Ville Hassinen, saarna Gerson Mgaya. Klo 13 messu Lehmon srk-kodilla, Kylmäojantie 57, liturgia Ville Hassinen, saarna Gerson Mgaya, kirkkokahvit ja päivätilaisuus.",
    "Ma 7.3.",
    "*klo 18 Kontiolahden srk-talolla raamattuopetus \"Minä olen elämän leipä ja valo\", Heimo Karhapää, tarjoilu ja klo 19.15 iltatilaisuus.",
    "*klo 19.15 iltatilaisuus.",
    "Ti 8.3.",
    "*klo 18 Kontiolahden srk-talolla raamattuopetus \"Minä olen tie ja totuus ja elämä\", Gerson Mgaya, tarjoilu ja klo 19.15 iltatilaisuus. Tapahtuman puhujina Gerson Mgaya, Heimo Karhapää, Seppo Lamminsalo, Ville Hassinen, Jukka Reinikainen ja Eija Romppanen.",
    "*klo 19.15 iltatilaisuus. Tapahtuman puhujina Gerson Mgaya, Heimo Karhapää, Seppo Lamminsalo, Ville Hassinen, Jukka Reinikainen ja Eija Romppanen.",
  ];
  this.startDate = "6/3/2016";
  this.startHour = "10";
  this.startMinute = "00";
  this.endDate = "8/3/2016";
  this.endHour = "21";
  this.endMinute = "15";
  this.address = "Kylmäojantie 57";
  this.city = "Kontiolahti";
  this.country = "Suomi";
}