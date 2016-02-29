# SEKL form filler
#### 
###### Year: 2016
# 

I've been volunteering for a number of years for North Karelian branch of Finnish Lutheran Mission (Suomen Evankelis-Luterilainen Kansanlähetys, acronym SEKL). My task has been to maintain event update listing at their website. I am regularly emailed pre-formatted event listings I am then to type into a website form. 

After a while into this, I realized the process could really use automated inputting system. What I initially did was to use Autohotkey to parse event listings and send data using virtual keypresses to the browser window. The solution wasn't optimal either in terms of speed or reliability. It took surprisingly long for me to find out it's possible to inject JavaScript into a web page loaded in your browser. After discovering GreaseMonkey add-on for Firefox, this version is what I came up with.

The application reads the event listing string from clipboard and, for each event, parses
- title
- start date and time
- end date and time
- street address (the first one it finds, if several)
- city
- text chapters, out of which individual day program schedules in multi-day events are prepended with an asterisk flag that GreaseMonkey will later turn into HTML bullet points.
- ID of an associated attachment image, if any

Finally, the app converts parsed data into GreaseMonkey JavaScript file for the first event. After that it's all pretty straightforward:

1. Load the event input page.
2. Let GreaseMonkey fill in the form.
3. Submit the form.
4. Press a hotkey to have AutoHotkey convert next event into GreaseMonkey JS.
5. Repeat until no more events left.

Partially on purpose, it's not completely unattended yet, but has saved a lot of time already.

Due to resticted access to input form, giving the app a full test run in a 3rd party environment is not possible. Nevertheless, skimming through the sources should give you some idea of the internals. I've also included two GreaseMonkey files:
- `SEKL_populateData.user.js`: fixed logic for populating data in the form
- `SEKL_options.user.js`: example of the data parsed from event listing

RegEx is extensively used for parsing. Code comments are in Finnish.

To run the project, AutoHotkey Classic binary is required. This has been included in the project repository. For those who wish to be certain of the origin of binaries they are asked to execute, portable AutoHotkey Classic official download link is at
```
    https://autohotkey.com/download/1.0/AutoHotkey104805.zip
```
unzip Autohotkey.exe into the source file location and run
```
    Autohotkey.exe sekl.ahk
```