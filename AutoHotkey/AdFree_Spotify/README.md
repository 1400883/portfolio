# AdFree Spotify
#### 
###### Year: 2011
# 
<img src="https://github.com/1400883/portfolio/blob/master/AutoHotkey/AdFree_Spotify/screenshot.png?raw=true" width="340" />

AdFree Spotify, as its name suggests, was a blood pressure level controller for music enthusiasts. The application interfaced with Spotify streaming client software in Windows, introducing a completely unattended and unintrusive way to detect and mute audio commercials that frequently annoyed the heck out of folks. The application also included a GUI with an option to setup a display of the title of the currently playing song in the screen.

There were a few other applications with similar purpose published at the time. AdFree Spotify's detection mechanism was a bit more advanced in comparison: instead of having the user manually maintain a blacklist of audio commercial playing titles - which needed frequent updating - the application used Windows API PrintWindow method to capture Spotify GUI pixels and made the muting decision based on transport button color.

AdFree Spotify hasn't been updated in years and it's certainly been rendered obsolete somewhere on the way by Spotify client app updates that used to break something in the functionality all the time.

Source code has been written in AutoHotkey, a very efficient procedural scripting language. Looking at the code today, there are so many things wrong with it, starting from variable naming, quality and amount of source comments, line lengths, etc.

To run the project AutoHotkey Classic binary is required. This has been included in the project repository. For those who wish to be certain of the origin of binaries they are asked to execute, portable AutoHotkey Classic official download link is at
```
    https://autohotkey.com/download/1.0/AutoHotkey104805.zip
```
unzip Autohotkey.exe into the source file location and run
```
    Autohotkey.exe spotify_autoexec.ahk
```

Closing GUI will minimize it to tray. To exit, right click the tray icon and select Exit.