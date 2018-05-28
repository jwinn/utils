@echo off & setlocal enabledelayedexpansion
set Basefolder=%cd%
chcp 1252>NUL
REM Based on the idea and script by 2Flower http://forum.xbmc.org/showthread.php?tid=153253
REM written by Jotha, revised by Sir Quickly
REM ====== Instructions ======
REM Just change the path of the folder above and to the one where you keep all your unscrapeable videos you wish to have .nfo files generated for. 
REM Please do not let this script run over your existing, scrapeable tv series folder! Use a separate one instead!
REM I highly recommend to create one folder per "show" and to avoid subfolders below that in order to achieve a clean, working structure in the XBMC database.
REM After running this script, go into XBMC, add your folder as a new source to your database and set the type to "tv series". Please make sure to choose a tv series scraper as well though it will take the information just from the .nfo files you just generated.

echo Creating a .nfo files for each new video. The last used episode 
echo number will be stored in the episodecounter.txt for the next time.
echo ===========================================================================
pushd %Basefolder%
echo Scanning for new videos in %Basefolder% and Subdirectories ...
echo.
REM %recentfolder% is only there to determine if new videos already have been found in this directory.
set recentfolder=
REM For each videofile, found in the Basefolder oder Subfolders ...
for /f "delims=" %%f in ('dir /b /s /O:N *.mkv *.avi *.flv *.mp4 *.wmv *.f4v *.m4v *.mpg *.mpeg') do (
pushd "%%~dpf"
REM Getting Name of TVShow (parent folder)
FOR %%A IN (.) DO set tvshow=%%~nA
REM Getting the creation date of the video file, splits it up and uses it as air date.
set "timestamp=%%~tf"
set "month=!timestamp:~3,2!"
set "year=!timestamp:~6,4!"
set "day=!timestamp:~0,2!"
REM Checking whether an episode counter file exists. If not it generates one starting with zero.
if not exist episodecounter.txt (
echo 0 > episodecounter.txt
)
REM Checking wheter a tvshow.nfo exists
if not exist "%%~dpftvshow.nfo" (
echo.
echo ---------------------------------------------------------------------------
echo New folder "!tvshow!" found. tvshow.nfo generated
REM Writing a basic XML structure to the tvshow.nfo just using the folder name as a title.
REM Codepage 1252 is needed, if there are special Chars in the filename like äöüß
echo ^<tvshow^>^<title^>!tvshow!^</title^>^<premiered^>!year!-!month!-!day!^</premiered^>^<season^>1^</season^>^<episode^>!Episode!^</episode^>^</tvshow^> > %%~dpftvshow.nfo
)
REM Checking for (new) video files without according .nfo
if not exist "%%~nf.nfo" (
REM is that video the first new video, found in this directory?
if not "%%~dpf" == "!recentfolder!" (
echo.
echo New video^(s^) found in %%~dpf
echo ---------------------------------------------------------------------------
echo.
)
REM Using the last known episode number in each folder and sets it +1.
set /p "Episode=" < episodecounter.txt
set /A Episode +=1

REM Just for the looks... If the episode number is below 10 it adds an zero to get e.g. s01e05 instead of s01e5
if !Episode! LSS 10 (
REM Writing a basic XML structure to the according .nfo just using the file name as a title.
echo ^<episodedetails^>^<title^>%%~nf^</title^>^<aired^>!year!-!month!-!day!^</aired^>^<season^>1^</season^>^<episode^>!Episode!^</episode^>^</episodedetails^> > %%~nf-s01e0!Episode!.nfo
REM Renaming the video file by adding season and episode, e.g. "orginialfilename-s01e08.avi"
rename "%%~nxf" "%%~nf-s01e0!Episode!%%~xf"
REM If a Fanart exists, rename it too
if exist "%%~nf-fanart.*" (
for /f "delims=" %%i in ('dir /b /s /O:N "%%~nf-fanart.*"') do (
REM If there is no .tbn, save this Fanart as .tbn
if not exist "%%~nf.tbn" copy "%%~nxi" "%%~nf-s01e0!Episode!.tbn">nul
rename "%%~nxi" "%%~nf-s01e0!Episode!-fanart%%~xi">nul
)
)
REM If there is already a .tbn, rename it
if exist "%%~nf.tbn" rename "%%~nf.tbn" "%%~nf-s01e0!Episode!.tbn">nul
chcp 850>NUL
echo %%~nf-s01e0!Episode!
chcp 1252>NUL
) else (
echo ^<episodedetails^>^<title^>%%~nf^</title^>^<aired^>!year!-!month!-!day!^</aired^>^<season^>1^</season^>^<episode^>!Episode!^</episode^>^</episodedetails^> > %%~nf-s01e!Episode!.nfo
rename "%%~nxf" "%%~nf-s01e!Episode!%%~xf"
if exist "%%~nf-fanart.*" (
for /f "delims=" %%i in ('dir /b /s /O:N "%%~nf-fanart.*"') do (
if not exist "%%~nf.tbn" copy "%%~nxi" "%%~nf-s01e!Episode!.tbn">nul
rename "%%~nxi" "%%~nf-s01e!Episode!-fanart%%~xi">nul
)
)
REM If there is already a .tbn, rename it
if exist "%%~nf.tbn" rename "%%~nf.tbn" "%%~nf-s01e!Episode!.tbn">nul
chcp 850>NUL
echo %%~nf-s01e!Episode!
chcp 1252>NUL
)
REM Writes the last used episode number into a .txt for later use
echo !Episode! > episodecounter.txt
set recentfolder=%%~dpf
)
)
echo Done.
chcp 850>NUL
pause

endlocal