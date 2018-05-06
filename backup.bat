::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::			A batch script that allows you to get a backup of your external discs			::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal EnableDelayedExpansion

if [%1] equ [] (
	call :sub_main_menu
) else (
	set continue=no
	if [%2] equ [] (
		echo.
		echo Ingrese el disco de destino.
	) else (
		set in=%1
		set out=%2

		for /F "tokens=2-4 delims=/ " %%a in ('date /t') do (
			set current_date=%%a-%%b-%%c
		)
		set current_time=%time:~0,-9%-%time:~3,-6%-%time:~6,-3%
		set	folder_name=backup_!current_date!_!current_time!

		echo.
		echo Disco de origen:	!in!
		echo Disco de destino:	!out!
		echo Nombre de la carpeta:	!folder_name!
		echo.
		pause

		xcopy !in!:\*  !out!:\!folder_name! /s /i	
	)
)
endlocal
goto:eof

:: SUBROUTINES
:sub_main_menu
cls
echo Opciones de BackUp
echo.
echo Uso: backup [disco origne] [disco destino]
goto:eof