/*
  Copyright (c) 2016 Tuomas Keinänen
*/

// ==UserScript==
// @name        SEKL_populateData
// @namespace   SEKL
// @require     jquery.min.js
// @include     http://sekl.fi/pohjois-karjala/wp-admin/post-new.php?post_type=tribe_events
// @version     1
// @noframes
// @grant       none
// ==/UserScript==

onload = function() {
  /////////////////////
  var options = new Options();
  /*
  var options.title = "";
  var options.textChapters = [
    "",
    "",
    "",
    "",
  ];
  var options.startDate = ""; // "dd/mm/YYYY"
  var options.startHour = ""; // "HH"
  var options.startMinute = ""; // "MM"
  var options.endDate = ""; // "dd/mm/YYYY"
  var options.endHour = ""; // "HH"
  var options.endMinute = ""; // "MM"

  var options.address = "";
  var options.city = "";
  var options.country = "";
  */
  /////////////////////
  /////////////////////////////////////////////
  // TAPAHTUMAN OTSIKKO
  /////////////////////////////////////////////
    $("#title").val(options.title); 
  /////////////////////////////////////////////
  // TAPAHTUMATEKSTI
  /////////////////////////////////////////////
    var iFrame = document.getElementById("content_ifr");
    // Hae iFramen body
    var iFrameBody = $(iFrame.contentDocument.getElementById("tinymce"));
    // Lisää teksti websivun tekstikenttään
    var html = "";
    var isListTagOpen = false;
    for (var i = 0; i < options.textChapters.length; ++i) {
      if (options.textChapters[i][0] == "*") {
        // Luo lista monipäivisen tapahtuman päiväohjelman esitykseen
        if (!isListTagOpen) {
          // Avaa ul-tagi
          html += "<ul>";
          isListTagOpen = true;
        }
        // Lisää lista-item
        html += "<li>" + options.textChapters[i].substr(1) + "</li>";
      }
      else if (isListTagOpen) {
        // Sulje ul-tagi
        html += "</ul>";
        isListTagOpen = false;
      }

      if (options.textChapters[i][0] != "*")
        // Lisää tekstikappale. Korvaa tyhjä merkkijono HTML
        // placeholderilla &nbsp;
        html += "<p>" + (options.textChapters[i] == ""
          ? "&nbsp;" : options.textChapters[i])  + "</p>";
    }
    // Varmista, että viimeisellä rivillä oleva lista suljetaan
    if (isListTagOpen)
      html += "</ul>";
    
    $(iFrameBody).html(html);
  /////////////////////////////////////////////
  // ALOITUS- JA LOPETUSPÄIVÄ JA -AIKA
  /////////////////////////////////////////////
    $("#EventStartDate").val(options.startDate);
    $("#EventEndDate").val(options.endDate);
    
    $("select").each(function(index, element) {
      if ($(element).attr("name") == "EventStartHour")
        $(element).html(
          "<option value=\"" + options.startHour + "\" " +
          "selected=\"selected\">" + options.startHour + "</option>"
        );
      else if ($(element).attr("name") == "EventStartMinute")
        $(element).html(
          "<option value=\"" + options.startMinute + "\" " +
          "selected=\"selected\">" + options.startMinute + "</option>"
        );
      else if ($(element).attr("name") == "EventEndHour")
        $(element).html(
          "<option value=\"" + options.endHour + "\" " +
          "selected=\"selected\">" + options.endHour + "</option>"
        );
      else if ($(element).attr("name") == "EventEndMinute")
        $(element).html(
          "<option value=\"" + options.endMinute + "\" " +
          "selected=\"selected\">" + options.endMinute + "</option>"
        );
    });

  /////////////////////////////////////////////
  // TAPAHTUMAPAIKKA
  /////////////////////////////////////////////
  $("input").each(function(index, element) {
    // Osoite
    if ($(element).attr("name") == "venue[Address]")
      $(element).val(options.address);
    // Kaupunki
    else if ($(element).attr("name") == "venue[City]")
      $(element).val(options.city);
  });
  // Maa
  $("#EventCountry_chosen a span").html(options.country);
  
  // Lisää tapahtumakuva
  if (options.imageLabel) {
    // Paina Lisää-painiketta
    // Käytä painallukseen perus-JavaScriptiä jQueryn sijasta,
    // jQuery-klikkaus ei mene läpi jostain syystä.
    document.getElementById("set-post-thumbnail").click();
    // Odota kuvan labelia vastaavan ominaisuuden ilmaantumista.
    // Tällöin sivu on latautunut.
    var interval = setInterval(function() {
      $("li.attachment.save-ready").each(function() {
        if ($(this).attr("aria-label") == options.imageLabel) {
          // Osuma löytynyt!
          clearInterval(interval);
          // Klikkaa pohjalla olevaa kuvapainike-elementtiä
          this.children[1].click();
          // Odota kuvan asetuspainikkeen enabloitumista
          interval = setInterval(function() {
            $("button.media-button.button-primary.button-large.media-button-select").each(function() {
              if (!$(this).prop("disabled")) {
                // Painike käytössä!
                clearInterval(interval);
                // Klikkaa Aseta kuva -painiketta
                this.click();
                // Odota kuvan ilmestymistä tapahtumasyöttösivulle
                interval = setInterval(function() {
                  if ($("#set-post-thumbnail").children("img").length) {
                    // Kuva näkyvissä!
                    // Julkaise artikkeli
                    clearInterval(interval);
                    document.getElementById("publish").click();
                    return false;
                  }
                }, 200);
              }
            });
          }, 500);
          return false;
        };
      });
    }, 500);
  }
}