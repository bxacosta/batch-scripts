:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  				A batch script that allows you to manage the WiFi settings 				 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal EnableDelayedExpansion

if [%1] equ [] (
	call :sub_main_menu
) else if ["%1"] equ ["key"] (
	if [%2] equ [] (
		call :sub_get_wifi_profile wifi_profile
	) else (
		set wifi_profile=%~2
	)
    call :sub_show_profile_key "!wifi_profile!"
) else if ["%1"] equ ["delete"] (
	if [%2] equ [] (
		call :sub_get_wifi_profile wifi_profile
	) else (
		set wifi_profile=%~2
	)
    call :sub_delete_profile "!wifi_profile!"
) else if ["%1"] equ ["show"] (
	cls
	netsh wlan show profiles
) else (
    echo "%1" no se reconoce como un comando valido.
)
endlocal
goto:eof

:: SUBROUTINES
:sub_main_menu
cls
echo Opciones de Red WiFi
echo.
echo Uso: wlan [comando] [parametro]
echo.
echo Comandos disponibles:
echo key			- Muestra la clave de un perfil wifi configurado en el sistema.
echo delete			- Elimina un perfil wifi configurado en el sistema.
echo show			- Muestra todos los perfiles wifi configurados en el sistema.
echo.
echo Parametros disponibles:
echo key [nombre_perfil]	- Muestra la clave del perfil wifi especificado.
echo delete [nombre_perfil]	- Elimina el perfil wifi especificado.
goto:eof

:sub_show_profile_key
for /f "tokens=2 delims=:" %%a in ('netsh wlan show profile name^=%1 key^=clear ^| find "Contenido de la clave"') do (
	set key=%%a
)
echo.
echo La clave del perfil wifi "%~1" es:%key% 
goto:eof

:sub_delete_profile
cls
echo Eliminando perfil %1
echo.
netsh wlan delete profile name=%1
goto:eof

:sub_get_wifi_profile
set /a index=0
echo.
echo Indice	Nombre
for /f "skip=1 tokens=2 delims=:" %%a in ('netsh wlan show profiles ^| find ":"') do (
	set /a index+=1
	set name=%%a && set name=!name:~1,-1!
	set profiles[!index!]=!name!
	echo !index!	!name!
)
set /p user_res=Ingrese el indice del perfil WiFi: 
set %1=!profiles[%user_res%]!
goto:eof