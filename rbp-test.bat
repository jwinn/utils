@echo off

setlocal EnableDelayedExpansion

set rbp=react-boilerplate
set git_branch=%1
if %1.==. set git_branch=dev
set initial_dir=%~dp0

cd %TEMP%

echo(
echo --== React Boilerplate (branch: %git_branch%) Windows tester ==--
echo --== https://github.com/mxstbr/react-boilerplate ==--

rem clear existing dir to start from scratch
if exist %rbp% (
	echo(
	echo -- Removing old dir %rbp%
	rd /q /s %rbp%
)

echo(
echo --== Cloning into %TEMP%\react-boilerplate ==--
echo(
git clone -b %git_branch% --depth=1 https://github.com/mxstbr/react-boilerplate.git %rbp%

cd %rbp%

echo(
echo --== Executing `git checkout %git_branch%` ==--
call git checkout %git_branch%

echo(
echo --== Executing `npm run setup` ==--
call npm run setup

echo(
echo --== Executing `npm test` ==--
echo(
call npm test

echo(
echo --== Executing `npm start` ==--
echo(
echo(-- Please manually verify the site is visible, then <ctrl-c> (twice) to continue
call npm start

echo(
echo --== Executing `npm run clean` ==--
echo(
call npm run clean

echo(
echo --== Executing `npm test` ==--
echo(
call npm test

echo(
echo --== Executing `npm start` ==--
echo --== Please manually verify  the site is visible, then <ctrl-c> (twice) to continue
echo(
call npm start

echo(
echo --== Environment ==--
echo Time:                      %TIME%
echo(
echo # Processors:              %NUMBER_OF_PROCESSORS%
echo Architecture:              %PROCESSOR_ARCHITECTURE%
echo Processor ID:              %PROCESSOR_IDENTIFIER%
echo(
for /f "delims=" %%a in ('systeminfo ^| findstr /B /C:"OS"') do echo %%a
echo(
for /f "tokens=3" %%a in ('git --version') do echo Git Version:               %%a
echo Git Branch:                %git_branch%
for /f %%a in ('node --version') do echo Node:                      %%a
for /f %%a in ('npm --version') do echo NPM:                       %%a
echo(

cd %initial_dir%

endlocal
