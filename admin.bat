::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  			Script that allows you to execute other scripts as administrator			::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal EnableDelayedExpansion

if [%1] equ [] (
    call :sub_main_menu
) else if ["%1"] equ ["."] (
	for /f "tokens=* delims=" %%a in ('chdir') do set current_path=%%a
	set script=cd !current_path! ^&^& %~d1
    echo.
    call :sub_create_vbscript_file "!script!"
) else if ["%1"] equ ["?"] (
    :: Check if we are running as Admin
    fsutil dirty query %SystemDrive% > nul
    if !errorlevel! equ 0 (
        echo.
        echo Con permisos de Administrador
    ) else (
        echo.
        echo Sin permisos de Administrador
    )
) else if ["%1"] equ ["cmd"] (
    call :sub_create_vbscript_file
) else if ["%1"] equ ["script"] (
    if [%2] equ [] (
        echo.
        echo Parametros disponibles:
        echo script [path]		- [path] ruta del script batch que desea ejecutar como administrador.
    ) else (
        call :sub_execute_script %2 %3
    )
) else (
	echo "%1" no se reconoce como un comando valido.
)
endlocal
goto:eof

:: SUBROUTINES
:sub_main_menu
cls
echo Ejecutar como Administrador
echo.
echo Uso: admin [comando] [parametro] 
echo.
echo Comandos disponibles:
echo .			- Abre una consola CMD como administrador ubicado en el directorio actual.
echo ?			- Consulta si la consola se esta ejecutando con permisos de administrador.
echo cmd			- Abre una consola CMD con permisos de administrador.
echo script			- Ejecuta el script batch que se le indique con permisos de administrador.
echo.
echo Parametros disponibles:
echo script [path] [param]	- [path] ruta del script batch que desea ejecutar como administrador.
echo				  [param] parametros del script.
echo.
echo Notas:
echo				- Este script utiliza la funcionalidad de Windows UAC (Control de Cuentas de Usuario).
goto:eof

:sub_execute_script
if exist %~f1 (
    call :sub_create_vbscript_file %~f1 %2
) else (
    echo El archivo que desea ejecutar no existe.
)
goto:eof

:: sub_create_vbscript_file [script, parameters]
:sub_create_vbscript_file
set file_path="%temp%\getadmin.vbs"
set application="cmd"
set parameters="/k ""%~1"" %~2"
:: Create a vbscript file inside %temp% folder
echo Set UAC = CreateObject^("Shell.Application"^) > %file_path%
echo UAC.ShellExecute %application%, %parameters%, "", "runas", 1 >> %file_path%

:: Execute the VBScript
cscript %file_path% > nul

if exist %file_path% (
    del %file_path%
)
goto:eof