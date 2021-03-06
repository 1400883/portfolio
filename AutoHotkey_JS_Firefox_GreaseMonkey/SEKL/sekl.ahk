  #installkeybdhook
  #ltrim
  reload_script()
  gmFile := "Z:\Waterfox\Data\profile\gm_scripts\SEKL_options\SEKL_options.user.js"
  ;gmFile := "Z:\Mozilla_profiles\7uxpsos8.default\gm_scripts\SEKL_options\SEKL_options.user.js"
  gmImageLabelDbnJoensuu := "DBN_2016_kev�t_Hukanhauta"
  gmImageLabelDbnPolvijarvi := "DBN_2016_kev�t_Polvij�rvi"
  gmImageLabel3kJoensuu := "Kolme Kohtaamista 2016_kev�t"
  gmImageLabelLeipisJoensuu := "Leipis 2016_kev�t"
  gmImageLabelPHSeminaariJoensuu := "Pyh�n Hengen seminaari_kev�t 2016"
  gui, add, listbox, vvlistbox glistbox altsubmit multi r20 w200 t48 t80
  gui, add, edit, section readonly ym w300 h264 vvedit
  gui, add, button, gupdate w510 h30 xm, P�ivit� leikep�yd�lt� 
  gui, show, autosize
  ;clipboard := "JOENSUU Ma 19.8. klo 9 rukouspiiri toimistolla. MUUALLA JOENSUUSSA To 15.8. klo 18 Nuorten aikuisten ilta M�nnikk�niemess�, Vainoniementie 2, Markku Fr�ntil�, R�is�sten l�hettiperheen kuulumisia.`r`n`r`nJUUKA Su 18.8. klo 18 Kotiseurat Raimo ja Liisa Tanskasella, Kuhnustantie 892, Jorma Hoppa, Veikko Kettunen.`r`n`r`nNURMES To 15.8. klo 18 Eloseurat srk-keskuksessa, Ikolantie 3, Heimo Karhap��, Jouko Puhakka.`r`n`r`nPIELISENSUU Pe 16.8. klo 18 Sulkulan kotailta Pyh�sel�n rannalla, Matti Innanen, Raimo Kukkonen, Arja Ryyn�nen, R�is�sten l�hettiperheen kuulumisia.`r`n`r`nTOHMAJ�RVI Su 18.8. klo 10 L�hetyspyh�, messu kirkossa, saarna Heimo Karhap��, liturgi Mikko Lappalainen, kirkkokahvit ja l�hetystilaisuus Kes�kahvilassa, Kirkkotie 600, Heimo Karhap��."
  ;gosub, update
  inputBoxTitle := "T�ydenn� tapahtuman otsikko"

  gmHeader =
  (
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
  
  )
  gmFooter = }
  
  gmTitle         := "  this.title = "
  gmTextChapters1 := "  this.textChapters = ["
  gmTextChapters2 := "  ]`;"
  gmStartDate     := "  this.startDate = "
  gmStartHour     := "  this.startHour = "
  gmStartMinute   := "  this.startMinute = "
  gmEndDate       := "  this.endDate = "
  gmEndHour       := "  this.endHour = "
  gmEndMinute     := "  this.endMinute = "
  gmAddress       := "  this.address = "
  gmCity          := "  this.city = "
  gmCountry       := "  this.country = "
  gmImageLabel    := "  this.imageLabel = "
  gmIsLastItem    := "  this.isLastItem = "
return

f12:: return

; Increments or decrements YYYYMMDDHH24MISS date by given amount
AdjustDate(date, value, valuetype, operation)
{
  if (operation = "+")
    date += %value%, %valuetype%
  else
    date -= %value%, %valuetype%
  return % date
}

; Converts DD.MM to YYYYMMDDHH24MISS
ConvertDate(dayDotMonthDot, time = 0)
{
  ; Extract day and make two chars wide
  day := regexreplace(dayDotMonthDot, "^(\d+).*$", "$1")
  if (strlen(day) = 1)
    day := "0" day

  ; Extract month and make two chars wide
  month := regexreplace(dayDotMonthDot, "^\d+\.(\d+).*$", "$1")
  if (strlen(month) = 1)
    month := "0" month
  
  ; Increment the year if current month is 12 and given month 01
  year := a_year + (month < a_mm)

  if (time) {
    ; Extract hours from the time string
    hours := regexreplace(time, "^(\d+).*$", "$1")
    if (strlen(hours) = 1)
      hours := "0" hours

    ; Try to extract minutes from the time string
    minutes := regexreplace(time, "^\d+\.(\d+).*$", "$1", replacements)
    if !replacements
      ; Just hours given
      minutes := "00"
  }
  else {
      hours := "00"
    , minutes := "00"
  }
  seconds := "00"

  ; Return YYYYMMDDHH24MISS
  return % year month day hours minutes seconds
}

update:
  weekdayRegexUpper := "\b(?:Ma|Ti|Ke|To|Pe|La|Su)\b"
  weekdayRegexLower := "\b(?:ma|ti|ke|to|pe|la|su)\b"
  stringcasesense, on
  if clipboard
  {
    iEventRow := iAllEvents := 0
    loop, parse, clipboard, `n, `r
      if (a_loopfield != "") {
        iEventRow++
        numEvents%iEventRow% := 0
        ; Remove "MUUALLA JOENSUUSSA "
        stringreplace, loopfield, a_loopfield, % "MUUALLA JOENSUUSSA "
        ; Remove TABs
        stringreplace, loopfield, loopfield, % a_tab
        ; "JOENSUU|RANTAKYL�" etc..
        eventCity := regexreplace(loopfield, "^([A-Z���][A-Z���\s]{2,}[A-Z���])(?=\s).*", "$1")
        ; Remove event city and trailing whitespace from the string
        loopfield := regexreplace(loopfield, eventCity "\s")
        loop 
        {
          iEventInCity := a_index
          ; -- RANTAKYL�-esimerkki --
          ; Pe�su 15.�17.1. talvitapahtuma. Pe 15.1. klo 18 raamattuopetus �Rakastakaa toisianne�, Gerson Mgaya. Tarjoilu ja iltatilaisuus. La 16.1. klo 18 raamattuopetus �Rohkeasti suuressa mukana�, Anssi Savonen. Tarjoilu, laulua ja rukousta. Su 17.1. klo 10 messu, saarna Gerson Mgaya, liturgia Tiina Laakkonen. L�hetyslounas ja l�hetystilaisuus. Puhujina past. Gerson Mgaya, Japanin-l�hetti Anssi Savonen, past. Antti Kyyts�nen ja past. Anna Holopainen.

          ; -- JOENSUU-esimerkki --
          ; Ma 18.1. klo 9 rukouspiiri toimistolla, Kauppakatu 17 B. Ke 20.1. klo 9 rukouspiiri toimistolla, Kauppakatu 17 B.
          isMultiMatch%iEventInCity% := 0
          if (regexmatch(loopfield
            ; "Pe�su "
            , "^(" weekdayRegexUpper ")�(" weekdayRegexLower ")\s"
            ; "15.�17.1. "
            . "(\d+)\.�(\d+)\.(\d+)\.\s"
            . ".*$", dateMatch%iEventInCity%))
          {
            ; Monip�iv�inen tapahtuma
            isMultiMatch%iEventInCity% := 1
            ; "17\.1\."
            eventStartWeekdayRegex := dateMatch%iEventInCity%1
            eventEndWeekdayRegex := dateMatch%iEventInCity%2
            eventEndDateRegex := dateMatch%iEventInCity%4 "\." dateMatch%iEventInCity%5 "\." 
            ; Alku- ja loppuaika
            regexmatch(loopfield
            ; "Pe�su.*klo (18)"
            , "^" eventStartWeekdayRegex "�" eventEndWeekdayRegex ".*?klo\s(\d+(?:\.\d+)?)"
            ; ".*Su 17.1. klo (10)"
            . ".*?" eventEndWeekdayRegex ".*klo\s(\d+(?:\.\d+)?)"
            . ".*$", timeMatch%iEventInCity%)
            /*
              Su�ti 6.�8.3. talvitapahtuma �Jeesus on el�m�n leip�. Su 6.3. klo 10 messu 
              Kontiolahden srk-talolla, Keskuskatu 26, liturgia Ville Hassinen, saarna Gerson 
              Mgaya. Klo 13 messu Lehmon srk-kodilla, Kylm�ojantie 57, liturgia Ville Hassinen, 
              saarna Gerson Mgaya, kirkkokahvit ja p�iv�tilaisuus. Ma 7.3. klo 18 Kontiolahden 
              srk-talolla raamattuopetus �Min� olen el�m�n leip� ja valo�, Heimo Karhap��, 
              tarjoilu ja klo 19.15 iltatilaisuus. Ti 8.3. klo 18 Kontiolahden srk-talolla 
              raamattuopetus �Min� olen tie ja totuus ja el�m�, Gerson Mgaya, tarjoilu ja 
              klo 19.15 iltatilaisuus. Tapahtuman puhujina Gerson Mgaya, Heimo Karhap��, Seppo 
              Lamminsalo, Ville Hassinen, Jukka Reinikainen ja Eija Romppanen.
            */
          }
          else
          {
            ; Yksip�iv�inen tapahtuma
            ; Huom! My�s yksip�iv�isess� tapahtumassa t�ytyy varautua eri alku- 
            ; ja p��ttymisaikoihin. Esim:

            ; La 14.11. yst�v�retriitti �Te olette minun todistajani� kirkossa, Rantakyl�nkatu 2: Klo 10 messu, Gerson Mgaya, klo 11 �Henkil�kohtainen evankelioiminen I�, Raimo Lappi, klo 12 lounas, klo 12.45 �Henkil�kohtainen evankelioiminen II�, Raimo Lappi, klo 13.30 laulua yhdess�, klo 14 rukousta ja keskustelua, klo 15 p��t�skahvi. Lapsille omaa ohjelmaa.
            ; P�iv� ja kuukausi
            /*
              Ma 25.1. klo 9 rukouspiiri toimistolla, Kauppakatu 17 B. Ke 27.1. klo 9 rukouspiiri toimistolla.  Su 24.1. klo 17 Leip�sunnuntai Noljakan kirkossa, Noljakantie 81, �Ovatko ihmeet historiaa?�, Ville Hassinen. Lapsille omaa ohjelmaa, kaikkien yhteiset iltakahvit.
            */
            regexmatch(loopfield
              ; "Ma "
              , "^" weekdayRegexUpper "\s"
              ; "(18).(1)."
              . "(\d+)\.(\d+)\."
              . ".*$", dateMatch%iEventInCity%)
            eventEndDateRegex := dateMatch%iEventInCity%1 "\." dateMatch%iEventInCity%2 "\."
            ; Alkuaika
            regexmatch(loopfield
              ; ".*Rantakyl�nkatu 2: Klo (10)"
              , "^.*?(?:K|k)lo\s(\d+(?:\.\d+)?)"
              . ".*$", timeMatch%iEventInCity%)
            ; Loppuaika (voi olla my�s sama kuin alkuaika)
            regexmatch(loopfield
              ; ".*ja keskustelua, klo (15)"
              , "^" weekdayRegexUpper ".*?(?:K|k)lo\s(\d+(?:\.\d+)?)"
              . ".*?(?:\s" weekdayRegexUpper "\s\d+\.\d+\..*)?$", endTimeMatch)
            timeMatch%iEventInCity%2 := endTimeMatch1
          }
          ; Seuraava tapahtumateksti
          eventText%iEventInCity% := regexreplace(loopfield
            ; Ma.*Kauppakatu 17 B.|Pe�su.*Anna Holopainen
            , "^(.*?" eventEndDateRegex 
            . (isMultiMatch%iEventInCity% ? ".*?" eventEndDateRegex : "") 
            . ".*?)(?:\s" weekdayRegexUpper ".*)?$"
            , "$1")
          ; Eskapoi regex-ohjausmerkit
          eventTextRegex := "\Q" eventText%iEventInCity% "\E"

          ; Poista k�sitelty tapahtuma merkkijonosta
          loopfield := regexreplace(loopfield
            ; Ma.*Kauppakatu 17 B.|Pe�su.*Anna Holopainen
            , "^" eventTextRegex 
            ; (Ke.*Kauppakatu 17 B.)
            . "(?:\s(" weekdayRegexUpper ".*))?"
            , "$1")
          ;msgbox % eventText%iEventInCity% "`n`n" loopfield
          numEvents%iEventRow%++
          
          if !loopfield
            ; Tyhj� merkkijono => kaikki tapahtumat k�sitelty
            break
        }
        ; Parsi tapahtuma kerrallaan
        loop % numEvents%iEventRow%
        {
          iEventInCity := a_index
            ; Alusta muuttuja, tarvitaan
          , replacements := 1
          , iAllEvents++
          , eventText := eventText%iEventInCity%
          , place%iAllEvents% := eventCity ; Kaupunki
          if regexmatch(eventText
            , "`a).*\s.*?([A-Z���][a-z���]+(?:tie|katu|kuja|polku)\s"
            . "[0-9]+)(\s?)((?:[a-zA-Z]+)?)(\s?)((?:A|a)s\s)?((?:[0-9]+)?)[^0-9].*", addressMatch) 
            address%iAllEvents% := addressMatch1 addressMatch2 addressMatch3 addressMatch4 addressMatch5 addressMatch6
          else
            address%iAllEvents% := (instr(eventText, "piiri ") AND instr(eventText,"toimistolla") 
                  ? "Kauppakatu 17 B" ; Joensuu SEKL:n toimisto
                  : (instr(eventText, "L�hetyssopessa") 
                  ? "Kauppakuja 2 B 4" ; L�hetyssoppi
                  : (instr(eventText, "Mutalan kirk")
                  ? "Mutalantie 12" ; Mutalan kirkko
                  : (instr(eventText, "Kemien s")
                  ? "Maiju Lassilan tie 16" ; Kemien seurakuntatalo
                  : ""))))
          text%iAllEvents% := regexreplace(eventText, "(.*?)\s*$", "$1")
          ;msgbox % eventText "`n`n" datetimestart%iAllEvents% ", " datetimeend%iAllEvents%
          /*
            Pe�su 15.�17.1. talvitapahtuma. Pe 15.1. klo 18 raamattuopetus �Rakastakaa
            toisianne�, Gerson Mgaya. Tarjoilu ja iltatilaisuus. La 16.1. klo 18 raamattuopetus 
            �Rohkeasti suuressa mukana�, Anssi Savonen. Tarjoilu, laulua ja rukousta. Su 17.1. 
            klo 10 messu, saarna Gerson Mgaya, liturgia Tiina Laakkonen. L�hetyslounas ja 
            l�hetystilaisuus. Puhujina past. Gerson Mgaya, Japanin-l�hetti Anssi Savonen, past. 
            Antti Kyyts�nen ja past. Anna Holopainen.
            La 14.11. yst�v�retriitti �Te olette minun todistajani� kirkossa, Rantakyl�nkatu 2: 
            Klo 10 messu, Gerson Mgaya, klo 11 �Henkil�kohtainen evankelioiminen I�, Raimo Lappi, 
            klo 12 lounas, klo 12.45 �Henkil�kohtainen evankelioiminen II�, Raimo Lappi, klo 13.30 
            laulua yhdess�, klo 14 rukousta ja keskustelua, klo 15 p��t�skahvi. Lapsille omaa ohjelmaa.
          */

            timeStart%iAllEvents% := timeMatch%iEventInCity%1
          , timeEnd%iAllEvents% := timeMatch%iEventInCity%2

          if (isMultiMatch%iEventInCity%)
          {
            ; Tapahtuman alku- ja loppuajat monip�iv�iseen tapahtumaan
              datestart%iAllEvents% := dateMatch%iEventInCity%3 "." dateMatch%iEventInCity%5 "."
            , dateend%iAllEvents% := dateMatch%iEventInCity%4 "." dateMatch%iEventInCity%5 "."

            ; Monip�iv�isen tapahtuman ohjelmatekstin jakaminen tekstikappaleisiin
            dateMatchPos := numTextChapters := 0
            ++numTextChapters
            textChapters%iAllEvents%_%numTextChapters% := regexreplace(eventText
              , "^(.*?)\s" weekdayRegexUpper "\s\d+\.\d+\..*", "$1") "`r`n"
            loop
            {
              dateMatchPos := regexmatch(eventText
                ; ".* (Pe 15.1.)\s("
                ; Huom! My�s kuukausi voi vaihtua kesken tapahtuman, joten
                ; parempi k�ytt�� \d-syntaksia kuin dateMatch%a_index%3
                , "(?<=\s)(" weekdayRegexUpper "(?:\s\d{1,2}\.\d{1,2}\.)?)"
                ; "iltatilaisuus.) La 16.1."
                . "\s(.*?)(?:(?:\s" weekdayRegexUpper "\s(?:\d{1,2}\.\d{1,2}\.)?).*)?$"
                , subDateMatch, dateMatchPos + 1)
              if (dateMatchPos) 
              {
                ++numTextChapters
                ; Lis�� p�iv�m��r� tekstikappaleeksi
                textChapters%iAllEvents%_%numTextChapters% := subDateMatch1
                ;msgbox % eventText "`n`n" subDateMatch1 ", " iEventRow ", " numTextChapters
                ;subDate%a_index% := subDateMatch1
                subDateString%a_index% := subDateMatch2
                subEventMatchPos := 0
                subDateIndex := a_index
                ; Tapahtumap�iv�n sis�isten tapahtumien jakaminen tekstikappaleisiin
                loop 
                {
                  /*
                    Su 17.1. 
                    klo 10 messu, saarna Gerson Mgaya, liturgia Tiina Laakkonen. 
                    L�hetyslounas ja l�hetystilaisuus. Puhujina past. Gerson Mgaya, 
                    Japanin-l�hetti Anssi Savonen, past. Antti Kyyts�nen ja past. Anna 
                    Holopainen. (<= pilkku korvattu pisteell�)
                    klo 18 raamattuopetus �Rohkeasti suuressa mukana�, Anssi Savonen. 
                    Tarjoilu, laulua ja rukousta.
                  */
                  subEventMatchPos := regexmatch(subDateString%subDateIndex%
                    ; "(klo 10.*Anna Holopainen), klo NN.*"
                    , "(klo\s\d+(?:\.\d+)?.*?)"
                    . "(?:(?:,\sklo\s\d+(?:\.\d+)?).*)?$"
                    , subEventMatch, subEventMatchPos + 1)
                  if (subEventMatchPos) 
                  {
                    ++numTextChapters
                    ; Lis�� piste tapahtumakellonaika ja -tekstirivin loppuun
                    ; Lis�� tapahtumakellonaika ja -teksti tekstikappaleeksi
                    ; K�yt� t�hte� luettelomerkkin� JavaScript-parserille
                    textChapters%iAllEvents%_%numTextChapters% := "*" regexreplace(subEventMatch1
                      , "^(.*?)\.?$", "$1.")
                    ;msgbox % subDateString%subDateIndex% "`n`n" subEventMatch1 
                      ;. ", " iEventRow ", " numTextChapters
                  }
                  else
                    break
                }
              }
              else
                break
            }
          }
          else 
          {
            ; Tapahtuman alku- ja loppuajat yksip�iv�iseen tapahtumaan
              datestart%iAllEvents% := dateMatch%a_index%1 "." dateMatch%a_index%2 "."
            , dateend%iAllEvents% := datestart%iAllEvents%
            ;, timestart%iAllEvents% := timeMatch%a_index%1
            ;, timeend%iAllEvents% := timeMatch%a_index%2
            ;, datetimestart%iAllEvents% := ConvertDate(datestart%iAllEvents%, timestart%iAllEvents%)
            ; Lis�� kaksi tuntia p��ttymiskellonaikaan
            ;, datetimeend%iAllEvents% := AdjustDate(datetimeend%iAllEvents%, 2, "h", "+")
            
            if (timeStart%iAllEvents% != timeEnd%iAllEvents%) 
            {
              ; Yksip�iv�isen monivaiheisen tapahtuman ohjelmatekstin jakaminen tekstikappaleisiin
              /*
              La 14.11. yst�v�retriitti �Te olette minun todistajani� kirkossa, Rantakyl�nkatu 2: Klo 10 messu, Gerson Mgaya, klo 11 �Henkil�kohtainen evankelioiminen I�, Raimo Lappi, klo 12 lounas, klo 12.45 �Henkil�kohtainen evankelioiminen II�, Raimo Lappi, klo 13.30 laulua yhdess�, klo 14 rukousta ja keskustelua, klo 15 p��t�skahvi. Lapsille omaa ohjelmaa.
              */
              subEventMatchPos := numTextChapters := 0
              ++numTextChapters
              textChapters%iAllEvents%_%numTextChapters% := regexreplace(eventText
                ; "La 14.11..*Rantakyl�nkatu 2:"
                , "^(.*?)\s(?:K|k)lo.*", "$1") "`r`n"
              ; Sis�isten tapahtumien jakaminen tekstikappaleisiin
              loop 
              {
                subEventMatchPos := regexmatch(eventText
                  ; ".* (Klo 10.*Mgaya)\s, klo 11"
                  , "(\b(?:K|k)lo\s\d+(?:\.\d+)?.*?)"
                  . "(?:(?:,\sklo\s\d+(?:\.\d+)?|\.).*)?$"
                  , subEventMatch, subEventMatchPos + 1)
                if (subEventMatchPos) 
                {
                  ++numTextChapters
                  subEventMatch1 := regexreplace(subEventMatch1, "Klo", "klo")
                  ; Lis�� piste tapahtumakellonaika ja -tekstirivin loppuun
                  ; Lis�� tapahtumakellonaika ja -teksti tekstikappaleeksi
                  ; K�yt� t�hte� luettelomerkkin� JavaScript-parserille
                  textChapters%iAllEvents%_%numTextChapters% := "*" regexreplace(subEventMatch1
                    , "^(.*?)\.?$", "$1.")
                }
                else
                  break
              }
              ; Lis�� viimeisen pisteen j�lkeinen osuus, jos l�ytyy
              if regexmatch(eventText
                ; "Lapsille omaa ohjelmaa."
                , "^.*\Q" substr(textChapters%iAllEvents%_%numTextChapters%, 2) "\E\s?(.*)$"
                , finalPartMatch) 
              {
                ; Lis�� ylim��r�inen rivinvaihto viimeisen tekstirivin loppuun
                textChapters%iAllEvents%_%numTextChapters% .= "`r`n"
                ; Lis�� viimeinen osuus
                ++numTextChapters
                textChapters%iAllEvents%_%numTextChapters% := finalPartMatch1
              }
            }
            else
              textChapters%iAllEvents%_1 := text%iAllEvents%
          }
            datetimestart%iAllEvents% := ConvertDate(datestart%iAllEvents%, timestart%iAllEvents%)
          , datetimeend%iAllEvents% := ConvertDate(dateend%iAllEvents%, timeend%iAllEvents%)
          ; Lis�� kaksi tuntia p��ttymiskellonaikaan
          , datetimeend%iAllEvents% := AdjustDate(datetimeend%iAllEvents%, 2, "h", "+")
        }
      }
    /*
    iCh := 0
    loop % iEventRow {
      msgbox % "iEventRow: " iEventRow
      iRow := a_index
      loop {
        iChapter := a_index
        if (textChapters%iRow%_%iChapter%) {
          msgbox % "textChapters: " textChapters%iRow%_%iChapter%
          s .= ++iCh ": " textChapters%iRow%_%iChapter% "`r`n"
        }
        else
          break
      }
    }
    msgbox % eventText "`n`n" s
    */
    ; Populate listbox
    loop % iAllEvents
      guicontrol, , vlistbox, % (a_index = 1 ? "|" : "") 
      . place%a_index% a_tab datestart%a_index% a_tab timestart%a_index% 
      . (a_index < replacements + 1 ? "|" : "")    
  }
return

listbox:
  gui, submit, nohide
  numListboxSelections := 0
  loop, parse, vlistbox, |
  {
      listboxSelectionIndex%a_index% := a_loopfield
    , numListboxSelections := a_index
  }
  guicontrol, , vedit
    , % numListboxSelections > 1 
      ? numListboxSelections " kohdetta valittu" 
      : (numListboxSelections = 1 ? text%vlistbox% : "")
return

f8::
  setbatchlines, -1
  ; --------------------------------------------------------------------------------
  ; T�yt� ensin ep�varmat tapahtumaotsikot ja lado vasta sen j�lkeen kaikki tapahtumat
  ; verkkosivulle. T�ll�in tapahtumien lis��minen sivuille sujuu t�ysin automaattisesti.
  ; --------------------------------------------------------------------------------
  loop % numListboxSelections
  {
    iListbox := listboxSelectionIndex%a_index%
    ; Alusta tyhj�ksi, k�ytet��n vertailussa
    uncertainEventType := ""
    
    ; Hae tapahtuman tyyppiteksti�
    eventType := (instr(text%iListbox%, "rukouspiiri") AND instr(text%iListbox%, "toimistolla")
                    ? "Rukouspiiri"
                    : instr(text%iListbox%, "nuorten aikuisten ja opiskelijoiden")
                    ? "Nuorten aikuisten ja opiskelijoiden ilta"
                    : instr(text%iListbox%, "Leip�sunnuntai")
                    ? "Leip�sunnuntai"
                    : instr(text%iListbox%, "Filia")
                    ? "Filia-ryhm�"
                    : instr(text%iListbox%, "Maija Kukkosella")
                    ? "Seurat"
                    : instr(text%iListbox%, "Ilta Sanan ��rell�")
                    ? "Ilta Sanan ��rell�"
                    : instr(text%iListbox%, "Donkkis Big Night")
                    ? "Donkkis Big Night"
                    : instr(text%iListbox%, "Sanan ja l�hetyksen ilta")
                    ? "Sanan ja l�hetyksen ilta"
                    : instr(text%iListbox%, "L�hetyspyh�")
                    ? "L�hetyspyh�"
                    : instr(text%iListbox%, "P�iv�l�hetyspiiri")
                    ? "P�iv�l�hetyspiiri"
                    : instr(text%iListbox%, "Iltal�hetyspiiri")
                    ? "Iltal�hetyspiiri"
                    : instr(text%iListbox%, "L�hetyspiiri")
                    ? "L�hetyspiiri"
                    : instr(text%iListbox%, "Seurat (KL")
                    ? "Seurat"
                    : instr(text%iListbox%, "aamattupiiri")
                    ? "Raamattupiiri"
                    : instr(text%iListbox%, "Donkkis-kerho")
                    ? "Donkkis-kerho"
                    : instr(text%iListbox%, "Pyh�n Hengen seminaari")
                    ? "Pyh�n Hengen seminaari"
                    : instr(text%iListbox%, "Valoa kohti -ilta")
                    ? "Valoa kohti -ilta"
                    : (uncertainEventType := regexreplace(text%iListbox%
                      , "^[\w�]+\s\d+\.(?:�\d+\.)?\d+\.\s(?:(?:K|k)lo\s\d+(?:\.\d+)?\s)?"
                      . "([a-zA-Z������]+).*$", "$1")))
    ; ---------------------------------------
    ; Tapahtuman otsikko. 
    ; ---------------------------------------
    eventTitle%iListbox% := StringToTitleCase(place%iListbox%) ": "
    if (uncertainEventType) {
      ; Mik�li tapahtumatyyppi on ep�varma, kysy k�ytt�j�lt� 
      ;tooltip % uncertainEventType
      ; Poista tekstin oletusvalinta siirt�m�ll� kursori ajastimella rivin p��tyyn
      settimer, SetCursorToEnd, -1
      InputBox
        , eventTitle%iListbox%
        , % inputBoxTitle
        , % text%iListbox%
        , , , , , , , , % eventTitle%iListbox% StringToTitleCase(uncertainEventType)
      ;tooltip
    }
    else
      eventTitle%iListbox% .= eventType
    AnsiToUTF8(eventTitle%iListbox%)
  }

  ; Otsikot t�ytetty, aloita tapahtumien lis��minen sivustolle
  loop % numListboxSelections
  {
    iListbox := listboxSelectionIndex%a_index%

    ; Poista edellinen tiedosto
    if fileexist(gmFile)
      filedelete, % gmFile
    ; Lis�� header
    fileappend
    , % gmHeader
    , % gmFile

    fileappend, % gmTitle """" eventTitle%iListbox% """`;`r`n", % gmFile
    ; ---------------------------------------
    ; Tapahtuman kuvaus
    ; ---------------------------------------
    fileappend, % gmTextChapters1 "`r`n", % gmFile
    textChapters := ""
    loop {
      chapter := textChapters%iListbox%_%a_index%
      if (chapter) {
        ; Korvaa MS Wordin lainausmerkit perus-ASCII-lainausmerkeill� ja eskapoi
        stringreplace, chapter, chapter, �, \", 1
        AnsiToUTF8(chapter)
        ; Ota mahdollinen ekstrarivinvaihto talteen ja lis�� lopuksi
        isLinebreak := regexmatch(chapter, "^(.*)`r`n$", chapterWithoutLinebreak)
        textChapters .= "    """ (isLinebreak ? chapterWithoutLinebreak1 : chapter) """,`r`n"
        if (isLineBreak)
          ; Lis�� rivinvaihto uudeksi tyhj�ksi kappaleeksi
          textChapters .= "    """",`r`n"
      }
      else {
        ; Poista viimeinen pilkku, mutta s�ilyt� rivinvaihto
        regexreplace(textChapters, "s)^(.*),(.*)$", "$1$2")
        break
      }
    }
    fileappend, % textChapters, % gmFile
    fileappend, % gmTextChapters2 "`r`n", % gmFile
    
    ; ---------------------------------------
    ; Tapahtuman alkup�iv�
    ; ---------------------------------------
    FormatTime, replaceText, % datetimestart%iListbox%, d/M/yyyy
    fileappend, % gmStartDate """" replaceText """`;`r`n", % gmFile
    ; ---------------------------------------
    ; Tapahtuman alkutunnit
    ; ---------------------------------------
    FormatTime, replaceText, % datetimestart%iListbox%, HH
    fileappend, % gmStartHour """" replaceText """`;`r`n", % gmFile
    ; ---------------------------------------
    ; Tapahtuman alkuminuutit
    ; ---------------------------------------
    FormatTime, replaceText, % datetimestart%iListbox%, mm
    fileappend, % gmStartMinute """" replaceText """`;`r`n", % gmFile

    ; ---------------------------------------
    ; Tapahtuman loppup�iv�
    ; ---------------------------------------
    FormatTime, replaceText, % datetimeend%iListbox%, d/M/yyyy
    fileappend, % gmEndDate """" replaceText """`;`r`n", % gmFile
    ; ---------------------------------------
    ; Tapahtuman lopputunnit
    ; ---------------------------------------
    FormatTime, replaceText, % datetimeend%iListbox%, HH
    fileappend, % gmEndHour """" replaceText """`;`r`n", % gmFile
    ; ---------------------------------------
    ; Tapahtuman loppuminuutit
    ; ---------------------------------------
    FormatTime, replaceText, % datetimeend%iListbox%, mm
    fileappend, % gmEndMinute """" replaceText """`;`r`n", % gmFile

    ; ---------------------------------------
    ; Tapahtumapaikan katuosoite
    ; ---------------------------------------
    AnsiToUTF8(address%iListbox%)
    fileappend, % gmAddress """" address%iListbox% """`;`r`n", % gmFile
    ; ---------------------------------------
    ; Tapahtumapaikan paikkakunta
    ; ---------------------------------------
    replaceText := address%iListbox% 
        ? (string_in(place%iListbox%,"PIELISENSUU`,RANTAKYL�")
          ? "Joensuu"
          : StringToTitleCase(place%iListbox%))
        : ""
    AnsiToUTF8(replaceText)
    fileappend, % gmCity """" replaceText """`;`r`n", % gmFile
    ; ---------------------------------------
    ; Tapahtumapaikkamaa
    ; ---------------------------------------
    fileappend, % gmCountry """Suomi""`;`r`n", % gmFile

    ; ---------------------------------------
    ; Tapahtumakuvaviite
    ; ---------------------------------------
    ;isEventCompleteWithImages = 0
    eventType := regexreplace(eventTitle%iListbox%, "^.*?:\s(.*)", "$1")
    ; Palauta ANSI-versio tapahtumatyypist� vertailua varten
    UTF8ToAnsi(eventType) 
    if (eventType = "Donkkis Big Night") {
      AnsiToUTF8(gmImageLabelDbnJoensuu)
      AnsiToUTF8(gmImageLabelDbnPolvijarvi)
      ;isEventCompleteWithImages = 1
      fileappend, % gmImageLabel """" (replaceText = "Joensuu" 
        ? gmImageLabelDbnJoensuu : gmImageLabelDbnPolvijarvi) """`;`r`n", % gmFile
    }
    else if (eventType = "Nuorten aikuisten ja opiskelijoiden ilta") {
      AnsiToUTF8(gmImageLabel3kJoensuu)
      fileappend, % gmImageLabel """" gmImageLabel3kJoensuu """`;`r`n", % gmFile
    }
    else if (eventType = "Leip�sunnuntai") {
      AnsiToUTF8(gmImageLabelLeipisJoensuu)
      fileappend, % gmImageLabel """" gmImageLabelLeipisJoensuu """`;`r`n", % gmFile
    }
    else if (eventType = "Pyh�n Hengen seminaari") {
      AnsiToUTF8(gmImageLabelPHSeminaariJoensuu)
      fileappend, % gmImageLabel """" gmImageLabelPHSeminaariJoensuu """`;`r`n", % gmFile 
    }
    ; ---------------------------------------
    ; Onko viimeinen tapahtuma?
    ; ---------------------------------------
    ;if (numListboxSelections = a_index)
      ;fileappend, % gmIsLastItem "true`;`r`n", % gmFile

    fileappend, % gmFooter, % gmFile

    ;if !isEventCompleteWithImages {
      ; Tulosta ohjeet k�ytt�j�lle
      tooltip % "Viimeistele tapahtuman sy�tt�. "
              . (a_index < numListboxSelections 
                ? "Uudelleenlataa tapahtumansy�tt�sivu`n"
              . "ja t�yt� seuraava tapahtuma painamalla F12."
                : "T�m� on listan viimeinen tapahtuma.")
      keywait, f12, d
      keywait, f12, u
    ;}
  }
  tooltip
return

AnsiToUTF8(byref str) {
  stringreplace, str, str, �, Ä, All
  stringreplace, str, str, �, ä, All
  stringreplace, str, str, �, Ö, All
  stringreplace, str, str, �, ö, All
  stringreplace, str, str, �, Å, All
  stringreplace, str, str, �, å, All
  stringreplace, str, str, �, �`��, All
  stringreplace, str, str, �, –, All
}

UTF8ToAnsi(byref str) {
  stringreplace, str, str, Ä, �, All
  stringreplace, str, str, ä, �, All
  stringreplace, str, str, Ö, �, All
  stringreplace, str, str, ö, �, All
  stringreplace, str, str, Å, �, All
  stringreplace, str, str, å, �, All
  stringreplace, str, str, �`��, �, All
  stringreplace, str, str, –, �, All
}

SetCursorToEnd:
  winwait, % inputBoxTitle " ahk_class #32770"
  controlsend, Edit1, {end}
return

StringToTitleCase(str)
{
  stringupper, uppercased, str, t
  return % uppercased
}

guiclose:
  exitapp
return
/*
  JOENSUU Ma 12.8. klo 9 rukouspiiri toimistolla. Ma 19.8. klo 19 rukouspiiri toimistolla. Pe 16.8. klo 18 Sulkulan kotailta Pyh�sel�n rannalla, Matti Innanen, Raimo Kukkonen, Arja Ryyn�nen, R�is�sten l�hettiperheen kuulumisia. MUUALLA JOENSUUSSA Ma 12.8. klo 18 Eloseurat l�hetysty�n merkeiss� Noljakan kirkossa, Kauppakuja 2, Veikko Kettunen, Jouko Puhakka, Tapio ja Helena R�is�nen. To 15.8. klo 18 Nuorten aikuisten ilta M�nnikk�niemess�, Vainoniementie 2, Markku Fr�ntil�, Tapio ja Helena R�is�nen, Arja Ryyn�nen.

  JUUKA Su 18.8. klo 18 Kotiseurat Raimo ja Liisa Tanskasella, Kuhnustantie 892, Jorma Hoppa, Veikko Kettunen.

  NURMES To 15.8. klo 18 Eloseurat srk-keskuksessa, Ikolantie 3, Heimo Karhap��, Jouko Puhakka.

  PIELISENSUU Pe 16.8. klo 18 Sulkulan kotailta Pyh�sel�n rannalla, Matti Innanen, Raimo Kukkonen, Arja Ryyn�nen, R�is�sten l�hettiperheen kuulumisia.

  TOHMAJ�RVI Su 18.8. klo 10 L�hetyspyh�, messu kirkossa, saarna Heimo Karhap��, liturgi Mikko Lappalainen, kirkkokahvit ja l�hetystilaisuus Kes�kahvilassa, Kirkkotie 600, Heimo Karhap��.
  
  
  
  
  JOENSUU Ma 19.8. klo 9 rukouspiiri toimistolla. MUUALLA JOENSUUSSA To 15.8. klo 18 Nuorten aikuisten ilta M�nnikk�niemess�, Vainoniementie 2, Markku Fr�ntil�, R�is�sten l�hettiperheen kuulumisia.

  JUUKA Su 18.8. klo 18 Kotiseurat Raimo ja Liisa Tanskasella, Kuhnustantie 892, Jorma Hoppa, Veikko Kettunen.

  NURMES To 15.8. klo 18 Eloseurat srk-keskuksessa, Ikolantie 3, Heimo Karhap��, Jouko Puhakka.

  PIELISENSUU Pe 16.8. klo 18 Sulkulan kotailta Pyh�sel�n rannalla, Matti Innanen, Raimo Kukkonen, Arja Ryyn�nen, R�is�sten l�hettiperheen kuulumisia.

  TOHMAJ�RVI Su 18.8. klo 10 L�hetyspyh�, messu kirkossa, saarna Heimo Karhap��, liturgi Mikko Lappalainen, kirkkokahvit ja l�hetystilaisuus Kes�kahvilassa, Kirkkotie 600, Heimo Karhap��.



*/