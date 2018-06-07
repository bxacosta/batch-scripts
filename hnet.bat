::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	A batch script that allows you to set up and manage a hosted network quickly and easily	::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal EnableDelayedExpansion

if [%1] equ [] (
    call :sub_main_menu
) else if ["%1"] equ ["config"] (
    call :sub_new_hostednetwork
) else if ["%1"] equ ["start"] (
	if ["%2"] equ ["*"] (
		call :sub_start_hostednetwork
	) else (
		call admin.bat ? > nul
		if !errorlevel! equ 0 (
			call :sub_create_rules
		) else (
			call admin.bat script %~f0 "start *"	
		)
	)
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
echo config			- Configura una nueva red hospedada o la reconfigura.
echo start			- Inicia la red hospedada.
echo stop			- Detiene la red hospedada.
echo show			- Muestra detalles de la red hospedada.
echo.
goto:eof

:sub_new_hostednetwork
cls
echo Ingrese los datos de configuracion para la red hospedada.
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

if !errorlevel! equ 1 (
    call :sub_stop_hostednetwork > nul
    netsh wlan set hostednetwork mode=allow ssid=%ssid% key=%pass% > nul
	if !errorlevel! equ 0 (
		echo.
		echo Se ha configurado correctamente la red hospedada con los datos ingresados.
	) else (
		echo Ocurrio un error, asegurese que la interfaz wifi de su equipo soperte la crecion
		echo de rede hospedada o tenga los permisos necesarios.
	)
    goto:eof
)
goto:eof
:: End sub_new_hostednetwork

:sub_start_hostednetwork
echo.
netsh wlan start hostednetwork
goto:eof
:: End sub_start_hostednetwork

:sub_stop_hostednetwork
echo.
netsh wlan stop hostednetwork
goto:eof
:: End sub_stop_hostednetwork

:sub_show_hostednetwork
netsh wlan show hostednetwork > nul
if !errorlevel! equ 0 (
	:: initialize the data
	set data.state=
	set data.ssid=
	set data.key=
	set data.num_clients=

	for /f "tokens=1,2 delims=:" %%a in ('netsh wlan show hostednetwork ^| find ":"') do (
		set tag=%%a && set tag=!tag: =!
		set value=%%b && set value=!value:~1!
		if ["!tag!"] equ ["Estado"] set data.state=!value!
		if ["!tag!"] equ ["NombredeSSID"] set data.ssid=!value!
		set tag_aux=!tag:~2!
		if ["!tag_aux!"] equ ["merodeclientes"] set data.num_clients=!value!
	)
	for /f "tokens=1,2 delims=:" %%a in ('netsh wlan show hostednetwork setting^=security ^| find ":"') do (
		set tag=%%a && set tag=!tag: =!
		set value=%%b && set value=!value:~1!
		if ["!tag!"] equ ["Clavedeseguridaddeusuario"] set data.key=!value!
	)
	echo.
	echo Informacion de la red hospedada
	echo -------------------------------
	if [!data.state!] neq [] echo Estado:		!data.state!
	if [!data.ssid!] neq [] echo SSID:		!data.ssid!
	if [!data.key!] neq [] echo Clave:		!data.key!
	if [!data.num_clients!] neq [] (
		if ["!data.num_clients!"] neq ["0 "] (
			set /a index=0
			echo.
			echo Clientes conectados:	!data.num_clients!
			echo -------------------------
			for /f "tokens=1-7 skip=1 delims=: " %%a in ('netsh wlan show hostednetwork ^| findstr /r "..:..:..:..:..:.."') do (
				set /a index+=1
				set clients[!index!].mac=%%a-%%b-%%c-%%d-%%e-%%f
				set clients[!index!].state=%%g
			)
			for /l %%n in (1,1,!index!) do (
				for /f "tokens=1-2" %%a in ('arp -a -N 192.168.137.1 ^| find "!clients[%%n].mac!"') do (
					set clients[%%n].ip=%%a
				)
				echo !clients[%%n].ip!		!clients[%%n].mac!	!clients[%%n].state!
			)
		)
	) 
)
goto:eof
:: End sub_show_hostednetwork