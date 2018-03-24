:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  A batch script that allows you to set up and manage a hosted network quickly and easily  ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal

if [%1] equ [] (
    call :sub_main_menu
) else if ["%1"] equ ["new"] (
    call :sub_new_hostednetwork
) else if ["%1"] equ ["start"] (
    call :sub_start_hostednetwork
) else if ["%1"] equ ["stop"] (
    call :sub_stop_hostednetwork
) else if ["%1"] equ ["show"] (
    call :sub_show_hostednetwork
) else (
    echo "%1" no se reconoce como un comando valido.
)
endlocal
goto:eof

:: SUBROUTINES
:sub_main_menu
cls
echo Opciones de Red hospedada - HostedNetwork
echo.
echo Uso: hnet [comando]
echo.
echo Comandos disponibles:
echo new        - Configura una nueva red hospedada o la reconfigura.
echo start      - Inicia la red hospedada.
echo stop       - Detiene la red hospedada.
echo show       - Muestra detalles de la red hospedada.
echo.
goto:eof

:sub_new_hostednetwork
cls
echo Configura una nueva red hospedada.
echo.
set /p ssid=Ingrese el nombre de la red SSID: 
set /p pass=Ingrese una clave para la red: 
echo.
echo Parametros de la red hospedada:
echo.
echo Nombre:        %ssid%
echo Clave:         %pass%
echo.
choice /m "Desea configurar la red hospedada "

if errorlevel 1 (
    call :sub_stop_hostednetwork > nul
    netsh wlan set hostednetwork mode=allow ssid=%ssid% key=%pass%
    goto:eof
) else (
    goto:eof
)
:: End sub_new_hostednetwork

:sub_start_hostednetwork
cls
echo Iniciando la red hospedada.
echo.
netsh wlan start hostednetwork
goto:eof
:: End sub_start_hostednetwork

:sub_stop_hostednetwork
cls
echo Deteniendo la red hospedada.
echo.
netsh wlan stop hostednetwork
goto:eof
:: End sub_stop_hostednetwork

:sub_show_hostednetwork
cls
netsh wlan show hostednetwork setting=security
netsh wlan show hostednetwork
goto:eof
:: End sub_show_hostednetwork