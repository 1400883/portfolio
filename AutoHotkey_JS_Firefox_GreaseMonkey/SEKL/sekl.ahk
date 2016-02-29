/*
  Copyright (c) 2016 Tuomas Keinänen
*/

  #installkeybdhook
  #ltrim
  ;reload_script()
  ahktitleclassname := "Mozilla Firefox ahk_class MozillaWindowClass"
  gmFile := "Z:\Mozilla_profiles\7uxpsos8.default\gm_scripts\SEKL_options\SEKL_options.user.js"
  gmImageLabelDbnJoensuu := "DBN_2016_kevät_Hukanhauta"
  gmImageLabelDbnPolvijarvi := "DBN_2016_kevät_Polvijärvi"
  gmImageLabel3kJoensuu := "Kolme Kohtaamista 2016_kevät"
  gmImageLabelLeipisJoensuu := "Leipis 2016_kevät"
  gmImageLabelPHSeminaariJoensuu := "Pyhän Hengen seminaari_kevät 2016"
  gui, add, listbox, vvlistbox glistbox altsubmit multi r20 w200 t48 t80
  gui, add, edit, section readonly ym w300 h264 vvedit
  gui, add, button, gupdate w510 h30 xm, Päivitä leikepöydältä 
  gui, show, autosize
  inputBoxTitle := "Täydennä tapahtuman otsikko"

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
return

f12:: return

; Kasvata tai vähennä YYYYMMDDHH24MISS-aikaleimaa syötteen mukaisesti
AdjustDate(date, value, valuetype, operation)
{
  if (operation = "+")
    date += %value%, %valuetype%
  else
    date -= %value%, %valuetype%
  return % date
}

; Muuntaa DD.MM-formaatin muotoon YYYYMMDDHH24MISS
ConvertDate(dayDotMonthDot, time = 0)
{
  ; Erota päivä ja täytä tarvittaessa etunollalla
  day := regexreplace(dayDotMonthDot, "^(\d+).*$", "$1")
  if (strlen(day) = 1)
    day := "0" day

  ; Erota kuukausi ja täytä tarvittaessa etunollalla
  month := regexreplace(dayDotMonthDot, "^\d+\.(\d+).*$", "$1")
  if (strlen(month) = 1)
    month := "0" month
  
  ; Kasvata vuosi yhdellä, jos on parhaillaan joulukuu ja annettu kuukausi tammikuu
  year := a_year + (month < a_mm)

  if (time) 
  {
    ; Erota tunnit ja täyta tarvittaessa etunollalla
    hours := regexreplace(time, "^(\d+).*$", "$1")
    if (strlen(hours) = 1)
      hours := "0" hours

    ; Yritä erottaa minuutit
    minutes := regexreplace(time, "^\d+\.(\d+).*$", "$1", replacements)
    if !replacements
      ; Vain tunnit annettiin
      minutes := "00"
  }
  else 
  {
      hours := "00"
    , minutes := "00"
  }
  seconds := "00"

  ; Palauta muodossa YYYYMMDDHH24MISS
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
      if (a_loopfield != "")
      {
        iEventRow++
        numEvents%iEventRow% := 0
        ; Poista "MUUALLA JOENSUUSSA "
        stringreplace, loopfield, a_loopfield, % "MUUALLA JOENSUUSSA "
        ; Poista TABit
        stringreplace, loopfield, loopfield, % a_tab
        ; "JOENSUU|RANTAKYLÄ" etc..
        eventCity := regexreplace(loopfield, "^([A-ZÅÄÖ][A-ZÅÄÖ\s]{2,}[A-ZÅÄÖ])(?=\s).*", "$1")
        ; Poista merkkijonosta tapahtumakaupunki ja perästä välilyönnit
        loopfield := regexreplace(loopfield, eventCity "\s")
        loop 
        {
          iEventInCity := a_index
          ; -- RANTAKYLÄ-esimerkki --
          ; Pe–su 15.–17.1. talvitapahtuma. Pe 15.1. klo 18 raamattuopetus ”Rakastakaa toisianne”, Gerson Mgaya. Tarjoilu ja iltatilaisuus. La 16.1. klo 18 raamattuopetus ”Rohkeasti suuressa mukana”, Anssi Savonen. Tarjoilu, laulua ja rukousta. Su 17.1. klo 10 messu, saarna Gerson Mgaya, liturgia Tiina Laakkonen. Lähetyslounas ja lähetystilaisuus. Puhujina past. Gerson Mgaya, Japanin-lähetti Anssi Savonen, past. Antti Kyytsönen ja past. Anna Holopainen.

          ; -- JOENSUU-esimerkki --
          ; Ma 18.1. klo 9 rukouspiiri toimistolla, Kauppakatu 17 B. Ke 20.1. klo 9 rukouspiiri toimistolla, Kauppakatu 17 B.
          isMultiMatch%iEventInCity% := 0
          if (regexmatch(loopfield
            ; "Pe–su "
            , "^(" weekdayRegexUpper ")–(" weekdayRegexLower ")\s"
            ; "15.–17.1. "
            . "(\d+)\.–(\d+)\.(\d+)\.\s"
            . ".*$", dateMatch%iEventInCity%))
          {
            ; Monipäiväinen tapahtuma
            isMultiMatch%iEventInCity% := 1
            ; "17\.1\."
            eventStartWeekdayRegex := dateMatch%iEventInCity%1
            eventEndWeekdayRegex := dateMatch%iEventInCity%2
            eventEndDateRegex := dateMatch%iEventInCity%4 "\." dateMatch%iEventInCity%5 "\." 
            ; Alku- ja loppuaika
            regexmatch(loopfield
            ; "Pe–su.*klo (18)"
            , "^" eventStartWeekdayRegex "–" eventEndWeekdayRegex ".*?klo\s(\d+(?:\.\d+)?)"
            ; ".*Su 17.1. klo (10)"
            . ".*?" eventEndWeekdayRegex ".*klo\s(\d+(?:\.\d+)?)"
            . ".*$", timeMatch%iEventInCity%)
            /*
              Su–ti 6.–8.3. talvitapahtuma ”Jeesus on elämän leipä”. Su 6.3. klo 10 messu 
              Kontiolahden srk-talolla, Keskuskatu 26, liturgia Ville Hassinen, saarna Gerson 
              Mgaya. Klo 13 messu Lehmon srk-kodilla, Kylmäojantie 57, liturgia Ville Hassinen, 
              saarna Gerson Mgaya, kirkkokahvit ja päivätilaisuus. Ma 7.3. klo 18 Kontiolahden 
              srk-talolla raamattuopetus ”Minä olen elämän leipä ja valo”, Heimo Karhapää, 
              tarjoilu ja klo 19.15 iltatilaisuus. Ti 8.3. klo 18 Kontiolahden srk-talolla 
              raamattuopetus ”Minä olen tie ja totuus ja elämä”, Gerson Mgaya, tarjoilu ja 
              klo 19.15 iltatilaisuus. Tapahtuman puhujina Gerson Mgaya, Heimo Karhapää, Seppo 
              Lamminsalo, Ville Hassinen, Jukka Reinikainen ja Eija Romppanen.
            */
          }
          else
          {
            ; Yksipäiväinen tapahtuma
            ; Huom! Myös yksipäiväisessä tapahtumassa täytyy varautua eri alku- 
            ; ja päättymisaikoihin. Esim:

            ; La 14.11. ystäväretriitti ”Te olette minun todistajani” kirkossa, Rantakylänkatu 2: Klo 10 messu, Gerson Mgaya, klo 11 ”Henkilökohtainen evankelioiminen I”, Raimo Lappi, klo 12 lounas, klo 12.45 ”Henkilökohtainen evankelioiminen II”, Raimo Lappi, klo 13.30 laulua yhdessä, klo 14 rukousta ja keskustelua, klo 15 päätöskahvi. Lapsille omaa ohjelmaa.
            ; Päivä ja kuukausi
            /*
              Ma 25.1. klo 9 rukouspiiri toimistolla, Kauppakatu 17 B. Ke 27.1. klo 9 rukouspiiri toimistolla.  Su 24.1. klo 17 Leipäsunnuntai Noljakan kirkossa, Noljakantie 81, ”Ovatko ihmeet historiaa?”, Ville Hassinen. Lapsille omaa ohjelmaa, kaikkien yhteiset iltakahvit.
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
              ; ".*Rantakylänkatu 2: Klo (10)"
              , "^.*?(?:K|k)lo\s(\d+(?:\.\d+)?)"
              . ".*$", timeMatch%iEventInCity%)
            ; Loppuaika (voi olla myös sama kuin alkuaika)
            regexmatch(loopfield
              ; ".*ja keskustelua, klo (15)"
              , "^" weekdayRegexUpper ".*?(?:K|k)lo\s(\d+(?:\.\d+)?)"
              . ".*?(?:\s" weekdayRegexUpper "\s\d+\.\d+\..*)?$", endTimeMatch)
            timeMatch%iEventInCity%2 := endTimeMatch1
          }
          ; Seuraava tapahtumateksti
          eventText%iEventInCity% := regexreplace(loopfield
            ; Ma.*Kauppakatu 17 B.|Pe–su.*Anna Holopainen
            , "^(.*?" eventEndDateRegex 
            . (isMultiMatch%iEventInCity% ? ".*?" eventEndDateRegex : "") 
            . ".*?)(?:\s" weekdayRegexUpper ".*)?$"
            , "$1")
          ; Eskapoi regex-ohjausmerkit
          eventTextRegex := "\Q" eventText%iEventInCity% "\E"

          ; Poista käsitelty tapahtuma merkkijonosta
          loopfield := regexreplace(loopfield
            ; Ma.*Kauppakatu 17 B.|Pe–su.*Anna Holopainen
            , "^" eventTextRegex 
            ; (Ke.*Kauppakatu 17 B.)
            . "(?:\s(" weekdayRegexUpper ".*))?"
            , "$1")
          ;msgbox % eventText%iEventInCity% "`n`n" loopfield
          numEvents%iEventRow%++
          
          if !loopfield
            ; Tyhjä merkkijono => kaikki tapahtumat käsitelty
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
            , "`a).*\s.*?([A-ZÅÄÖ][a-zåäö]+(?:tie|katu|kuja|polku)\s"
            . "[0-9]+)(\s?)((?:[a-zA-Z]+)?)(\s?)((?:A|a)s\s)?((?:[0-9]+)?)[^0-9].*", addressMatch) 
            address%iAllEvents% := addressMatch1 addressMatch2 addressMatch3 addressMatch4 addressMatch5 addressMatch6
          else
            address%iAllEvents% := (instr(eventText, "piiri ") AND instr(eventText,"toimistolla") 
                  ? "Kauppakatu 17 B" ; Joensuu SEKL:n toimisto
                  : (instr(eventText, "Lähetyssopessa") 
                  ? "Kauppakuja 2 B 4" ; Lähetyssoppi
                  : (instr(eventText, "Mutalan kirk")
                  ? "Mutalantie 12" ; Mutalan kirkko
                  : (instr(eventText, "Kemien s")
                  ? "Maiju Lassilan tie 16" ; Kemien seurakuntatalo
                  : ""))))
          text%iAllEvents% := regexreplace(eventText, "(.*?)\s*$", "$1")
          ;msgbox % eventText "`n`n" datetimestart%iAllEvents% ", " datetimeend%iAllEvents%
          /*
            Pe–su 15.–17.1. talvitapahtuma. Pe 15.1. klo 18 raamattuopetus ”Rakastakaa
            toisianne”, Gerson Mgaya. Tarjoilu ja iltatilaisuus. La 16.1. klo 18 raamattuopetus 
            ”Rohkeasti suuressa mukana”, Anssi Savonen. Tarjoilu, laulua ja rukousta. Su 17.1. 
            klo 10 messu, saarna Gerson Mgaya, liturgia Tiina Laakkonen. Lähetyslounas ja 
            lähetystilaisuus. Puhujina past. Gerson Mgaya, Japanin-lähetti Anssi Savonen, past. 
            Antti Kyytsönen ja past. Anna Holopainen.

            La 14.11. ystäväretriitti ”Te olette minun todistajani” kirkossa, Rantakylänkatu 2: 
            Klo 10 messu, Gerson Mgaya, klo 11 ”Henkilökohtainen evankelioiminen I”, Raimo Lappi, 
            klo 12 lounas, klo 12.45 ”Henkilökohtainen evankelioiminen II”, Raimo Lappi, klo 13.30 
            laulua yhdessä, klo 14 rukousta ja keskustelua, klo 15 päätöskahvi. Lapsille omaa ohjelmaa.
          */

            timeStart%iAllEvents% := timeMatch%iEventInCity%1
          , timeEnd%iAllEvents% := timeMatch%iEventInCity%2

          if (isMultiMatch%iEventInCity%)
          {
            ; Tapahtuman alku- ja loppuajat monipäiväiseen tapahtumaan
              datestart%iAllEvents% := dateMatch%iEventInCity%3 "." dateMatch%iEventInCity%5 "."
            , dateend%iAllEvents% := dateMatch%iEventInCity%4 "." dateMatch%iEventInCity%5 "."

            ; Monipäiväisen tapahtuman ohjelmatekstin jakaminen tekstikappaleisiin
            dateMatchPos := numTextChapters := 0
            ++numTextChapters
            textChapters%iAllEvents%_%numTextChapters% := regexreplace(eventText
              , "^(.*?)\s" weekdayRegexUpper "\s\d+\.\d+\..*", "$1") "`r`n"
            loop
            {
              dateMatchPos := regexmatch(eventText
                ; ".* (Pe 15.1.)\s("
                ; Huom! Myös kuukausi voi vaihtua kesken tapahtuman, joten
                ; parempi käyttää \d-syntaksia kuin dateMatch%a_index%3
                , "(?<=\s)(" weekdayRegexUpper "\s\d{1,2}\.\d{1,2}\.)"
                ; "iltatilaisuus.) La 16.1."
                . "\s(.*?)(?:(?:\s" weekdayRegexUpper "\s\d{1,2}\.\d{1,2}\.).*)?$"
                , subDateMatch, dateMatchPos + 1)
              if (dateMatchPos) 
              {
                ++numTextChapters
                ; Lisää päivämäärä tekstikappaleeksi
                textChapters%iAllEvents%_%numTextChapters% := subDateMatch1
                ;msgbox % eventText "`n`n" subDateMatch1 ", " iEventRow ", " numTextChapters
                ;subDate%a_index% := subDateMatch1
                subDateString%a_index% := subDateMatch2
                subEventMatchPos := 0
                subDateIndex := a_index
                ; Tapahtumapäivän sisäisten tapahtumien jakaminen tekstikappaleisiin
                loop 
                {
                  /*
                    Su 17.1. 
                    klo 10 messu, saarna Gerson Mgaya, liturgia Tiina Laakkonen. 
                    Lähetyslounas ja lähetystilaisuus. Puhujina past. Gerson Mgaya, 
                    Japanin-lähetti Anssi Savonen, past. Antti Kyytsönen ja past. Anna 
                    Holopainen. (<= pilkku korvattu pisteellä)
                    klo 18 raamattuopetus ”Rohkeasti suuressa mukana”, Anssi Savonen. 
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
                    ; Lisää piste tapahtumakellonaika ja -tekstirivin loppuun
                    ; Lisää tapahtumakellonaika ja -teksti tekstikappaleeksi
                    ; Käytä tähteä luettelomerkkinä JavaScript-parserille
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
            ; Tapahtuman alku- ja loppuajat yksipäiväiseen tapahtumaan
              datestart%iAllEvents% := dateMatch%a_index%1 "." dateMatch%a_index%2 "."
            , dateend%iAllEvents% := datestart%iAllEvents%
            ;, timestart%iAllEvents% := timeMatch%a_index%1
            ;, timeend%iAllEvents% := timeMatch%a_index%2
            ;, datetimestart%iAllEvents% := ConvertDate(datestart%iAllEvents%, timestart%iAllEvents%)
            ; Lisää kaksi tuntia päättymiskellonaikaan
            ;, datetimeend%iAllEvents% := AdjustDate(datetimeend%iAllEvents%, 2, "h", "+")
            
            if (timeStart%iAllEvents% != timeEnd%iAllEvents%) 
            {
              ; Yksipäiväisen monivaiheisen tapahtuman ohjelmatekstin jakaminen tekstikappaleisiin
              /*
              La 14.11. ystäväretriitti ”Te olette minun todistajani” kirkossa, Rantakylänkatu 2: Klo 10 messu, Gerson Mgaya, klo 11 ”Henkilökohtainen evankelioiminen I”, Raimo Lappi, klo 12 lounas, klo 12.45 ”Henkilökohtainen evankelioiminen II”, Raimo Lappi, klo 13.30 laulua yhdessä, klo 14 rukousta ja keskustelua, klo 15 päätöskahvi. Lapsille omaa ohjelmaa.
              */
              subEventMatchPos := numTextChapters := 0
              ++numTextChapters
              textChapters%iAllEvents%_%numTextChapters% := regexreplace(eventText
                ; "La 14.11..*Rantakylänkatu 2:"
                , "^(.*?)\s(?:K|k)lo.*", "$1") "`r`n"
              ; Sisäisten tapahtumien jakaminen tekstikappaleisiin
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
                  ; Lisää piste tapahtumakellonaika ja -tekstirivin loppuun
                  ; Lisää tapahtumakellonaika ja -teksti tekstikappaleeksi
                  ; Käytä tähteä luettelomerkkinä JavaScript-parserille
                  textChapters%iAllEvents%_%numTextChapters% := "*" regexreplace(subEventMatch1
                    , "^(.*?)\.?$", "$1.")
                }
                else
                  break
              }
              ; Lisää viimeisen pisteen jälkeinen osuus, jos löytyy
              if regexmatch(eventText
                ; "Lapsille omaa ohjelmaa."
                , "^.*\Q" substr(textChapters%iAllEvents%_%numTextChapters%, 2) "\E\s?(.*)$"
                , finalPartMatch) 
              {
                ; Lisää ylimääräinen rivinvaihto viimeisen tekstirivin loppuun
                textChapters%iAllEvents%_%numTextChapters% .= "`r`n"
                ; Lisää viimeinen osuus
                ++numTextChapters
                textChapters%iAllEvents%_%numTextChapters% := finalPartMatch1
              }
            }
            else
              textChapters%iAllEvents%_1 := text%iAllEvents%
          }
            datetimestart%iAllEvents% := ConvertDate(datestart%iAllEvents%, timestart%iAllEvents%)
          , datetimeend%iAllEvents% := ConvertDate(dateend%iAllEvents%, timeend%iAllEvents%)
          ; Lisää kaksi tuntia päättymiskellonaikaan
          , datetimeend%iAllEvents% := AdjustDate(datetimeend%iAllEvents%, 2, "h", "+")
        }
      }
    ; Täytä listbox
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
  ; Täytä ensin epävarmat tapahtumaotsikot ja lado vasta sen jälkeen kaikki tapahtumat
  ; verkkosivulle. Tällöin tapahtumien lisääminen sivuille sujuu täysin automaattisesti.
  ; --------------------------------------------------------------------------------
  loop % numListboxSelections
  {
    iListbox := listboxSelectionIndex%a_index%
    ; Alusta tyhjäksi, käytetään vertailussa
    uncertainEventType := ""
    
    ; Hae tapahtuman tyyppitekstiä
    eventType := (instr(text%iListbox%, "rukouspiiri") AND instr(text%iListbox%, "toimistolla")
                    ? "Rukouspiiri"
                    : instr(text%iListbox%, "nuorten aikuisten ja opiskelijoiden")
                    ? "Nuorten aikuisten ja opiskelijoiden ilta"
                    : instr(text%iListbox%, "Leipäsunnuntai")
                    ? "Leipäsunnuntai"
                    : instr(text%iListbox%, "Filia")
                    ? "Filia-ryhmä"
                    : instr(text%iListbox%, "Maija Kukkosella")
                    ? "Seurat"
                    : instr(text%iListbox%, "Ilta Sanan äärellä")
                    ? "Ilta Sanan äärellä"
                    : instr(text%iListbox%, "Donkkis Big Night")
                    ? "Donkkis Big Night"
                    : instr(text%iListbox%, "Sanan ja lähetyksen ilta")
                    ? "Sanan ja lähetyksen ilta"
                    : instr(text%iListbox%, "Lähetyspyhä")
                    ? "Lähetyspyhä"
                    : instr(text%iListbox%, "Päivälähetyspiiri")
                    ? "Päivälähetyspiiri"
                    : instr(text%iListbox%, "Iltalähetyspiiri")
                    ? "Iltalähetyspiiri"
                    : instr(text%iListbox%, "Lähetyspiiri")
                    ? "Lähetyspiiri"
                    : instr(text%iListbox%, "Seurat (KL")
                    ? "Seurat"
                    : instr(text%iListbox%, "aamattupiiri")
                    ? "Raamattupiiri"
                    : instr(text%iListbox%, "Donkkis-kerho")
                    ? "Donkkis-kerho"
                    : instr(text%iListbox%, "Pyhän Hengen seminaari")
                    ? "Pyhän Hengen seminaari"
                    : instr(text%iListbox%, "Valoa kohti -ilta")
                    ? "Valoa kohti -ilta"
                    : (uncertainEventType := regexreplace(text%iListbox%
                      , "^[\w–]+\s\d+\.(?:–\d+\.)?\d+\.\s(?:(?:K|k)lo\s\d+(?:\.\d+)?\s)?"
                      . "([a-zA-ZåäöÅÄÖ]+).*$", "$1")))
    ; ---------------------------------------
    ; Tapahtuman otsikko. 
    ; ---------------------------------------
    eventTitle%iListbox% := StringToTitleCase(place%iListbox%) ": "
    if (uncertainEventType) 
    {
      ; Mikäli tapahtumatyyppi on epävarma, kysy käyttäjältä 
      ;tooltip % uncertainEventType
      ; Poista tekstin oletusvalinta siirtämällä kursori ajastimella rivin päätyyn
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

  ; Otsikot täytetty, aloita tapahtumien lisääminen sivustolle
  loop % numListboxSelections
  {
    iListbox := listboxSelectionIndex%a_index%

    ; Poista edellinen tiedosto
    if fileexist(gmFile)
      filedelete, % gmFile
    ; Lisää header
    fileappend
    , % gmHeader
    , % gmFile

    fileappend, % gmTitle """" eventTitle%iListbox% """`;`r`n", % gmFile
    ; ---------------------------------------
    ; Tapahtuman kuvaus
    ; ---------------------------------------
    fileappend, % gmTextChapters1 "`r`n", % gmFile
    textChapters := ""
    loop 
    {
      chapter := textChapters%iListbox%_%a_index%
      if (chapter) 
      {
        ; Korvaa MS Wordin lainausmerkit perus-ASCII-lainausmerkeillä ja eskapoi
        stringreplace, chapter, chapter, ”, \", 1
        AnsiToUTF8(chapter)
        ; Ota mahdollinen ekstrarivinvaihto talteen ja lisää lopuksi
        isLinebreak := regexmatch(chapter, "^(.*)`r`n$", chapterWithoutLinebreak)
        textChapters .= "    """ (isLinebreak ? chapterWithoutLinebreak1 : chapter) """,`r`n"
        if (isLineBreak)
          ; Lisää rivinvaihto uudeksi tyhjäksi kappaleeksi
          textChapters .= "    """",`r`n"
      }
      else 
      {
        ; Poista viimeinen pilkku, mutta säilytä rivinvaihto
        regexreplace(textChapters, "s)^(.*),(.*)$", "$1$2")
        break
      }
    }
    fileappend, % textChapters, % gmFile
    fileappend, % gmTextChapters2 "`r`n", % gmFile
    
    ; ---------------------------------------
    ; Tapahtuman alkupäivä
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
    ; Tapahtuman loppupäivä
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
        ? (string_in(place%iListbox%,"PIELISENSUU`,RANTAKYLÄ")
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
    ; Palauta ANSI-versio tapahtumatyypistä vertailua varten
    UTF8ToAnsi(eventType) 
    if (eventType = "Donkkis Big Night") 
    {
      AnsiToUTF8(gmImageLabelDbnJoensuu)
      AnsiToUTF8(gmImageLabelDbnPolvijarvi)
      ;isEventCompleteWithImages = 1
      fileappend, % gmImageLabel """" (replaceText = "Joensuu" 
        ? gmImageLabelDbnJoensuu : gmImageLabelDbnPolvijarvi) """`;`r`n", % gmFile
    }
    else if (eventType = "Nuorten aikuisten ja opiskelijoiden ilta") 
    {
      AnsiToUTF8(gmImageLabel3kJoensuu)
      fileappend, % gmImageLabel """" gmImageLabel3kJoensuu """`;`r`n", % gmFile
    }
    else if (eventType = "Leipäsunnuntai") 
    {
      AnsiToUTF8(gmImageLabelLeipisJoensuu)
      fileappend, % gmImageLabel """" gmImageLabelLeipisJoensuu """`;`r`n", % gmFile
    }
    else if (eventType = "Pyhän Hengen seminaari") 
    {
      AnsiToUTF8(gmImageLabelPHSeminaariJoensuu)
      fileappend, % gmImageLabel """" gmImageLabelPHSeminaariJoensuu """`;`r`n", % gmFile 
    }

    fileappend, % gmFooter, % gmFile

    ; Tulosta ohjeet käyttäjälle
    tooltip % "Viimeistele tapahtuman syöttö. "
            . (a_index < numListboxSelections 
              ? "Uudelleenlataa tapahtumansyöttösivu`n"
            . "ja täytä seuraava tapahtuma painamalla F12."
              : "Tämä on listan viimeinen tapahtuma.")
    keywait, f12, d
    keywait, f12, u
  }
  tooltip
return

AnsiToUTF8(byref str) 
{
  stringreplace, str, str, Ä, Ã„, All
  stringreplace, str, str, ä, Ã¤, All
  stringreplace, str, str, Ö, Ã–, All
  stringreplace, str, str, ö, Ã¶, All
  stringreplace, str, str, Å, Ã…, All
  stringreplace, str, str, å, Ã¥, All
  stringreplace, str, str, –, â€“, All
}

UTF8ToAnsi(byref str) 
{
  stringreplace, str, str, Ã„, Ä, All
  stringreplace, str, str, Ã¤, ä, All
  stringreplace, str, str, Ã–, Ö, All
  stringreplace, str, str, Ã¶, ö, All
  stringreplace, str, str, Ã…, Å, All
  stringreplace, str, str, Ã¥, å, All
  stringreplace, str, str, â€“, –, All
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

string_in(string, matchlist)
{
  if string in %matchlist%
    return 1
  return 0
}

guiclose:
  exitapp
return
/*
  JOENSUU Ma 12.8. klo 9 rukouspiiri toimistolla. Ma 19.8. klo 19 rukouspiiri toimistolla. Pe 16.8. klo 18 Sulkulan kotailta Pyhäselän rannalla, Matti Innanen, Raimo Kukkonen, Arja Ryynänen, Räisästen lähettiperheen kuulumisia. MUUALLA JOENSUUSSA Ma 12.8. klo 18 Eloseurat lähetystyön merkeissä Noljakan kirkossa, Kauppakuja 2, Veikko Kettunen, Jouko Puhakka, Tapio ja Helena Räisänen. To 15.8. klo 18 Nuorten aikuisten ilta Männikköniemessä, Vainoniementie 2, Markku Fräntilä, Tapio ja Helena Räisänen, Arja Ryynänen.

  JUUKA Su 18.8. klo 18 Kotiseurat Raimo ja Liisa Tanskasella, Kuhnustantie 892, Jorma Hoppa, Veikko Kettunen.

  NURMES To 15.8. klo 18 Eloseurat srk-keskuksessa, Ikolantie 3, Heimo Karhapää, Jouko Puhakka.

  PIELISENSUU Pe 16.8. klo 18 Sulkulan kotailta Pyhäselän rannalla, Matti Innanen, Raimo Kukkonen, Arja Ryynänen, Räisästen lähettiperheen kuulumisia.

  TOHMAJÄRVI Su 18.8. klo 10 Lähetyspyhä, messu kirkossa, saarna Heimo Karhapää, liturgi Mikko Lappalainen, kirkkokahvit ja lähetystilaisuus Kesäkahvilassa, Kirkkotie 600, Heimo Karhapää.
  
  
  
  
  JOENSUU Ma 19.8. klo 9 rukouspiiri toimistolla. MUUALLA JOENSUUSSA To 15.8. klo 18 Nuorten aikuisten ilta Männikköniemessä, Vainoniementie 2, Markku Fräntilä, Räisästen lähettiperheen kuulumisia.

  JUUKA Su 18.8. klo 18 Kotiseurat Raimo ja Liisa Tanskasella, Kuhnustantie 892, Jorma Hoppa, Veikko Kettunen.

  NURMES To 15.8. klo 18 Eloseurat srk-keskuksessa, Ikolantie 3, Heimo Karhapää, Jouko Puhakka.

  PIELISENSUU Pe 16.8. klo 18 Sulkulan kotailta Pyhäselän rannalla, Matti Innanen, Raimo Kukkonen, Arja Ryynänen, Räisästen lähettiperheen kuulumisia.

  TOHMAJÄRVI Su 18.8. klo 10 Lähetyspyhä, messu kirkossa, saarna Heimo Karhapää, liturgi Mikko Lappalainen, kirkkokahvit ja lähetystilaisuus Kesäkahvilassa, Kirkkotie 600, Heimo Karhapää.
*/