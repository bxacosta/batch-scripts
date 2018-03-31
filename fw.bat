:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  				A batch script that allows you to manage firewall rules 				 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
setlocal EnableDelayedExpansion

::::::::::::::::::::::::::::::::::::: Setup Section ::::::::::::::::::::::::::::::::::::::::::
:: Configure the firewall rules you want to manage with this program
set rules[1].short_name=icmp
set rules[1].name="IN ICMP V4"
set rules[1].direcction=in
set rules[1].protocol=icmpv4

set rules[2].short_name=http
set rules[2].name="IN PORT 80 TCP"
set rules[2].direcction=in
set rules[2].protocol=tcp
set rules[2].localport=80

set rules[3].short_name=dev
set rules[3].name="8080-8085 TCP"
set rules[3].direcction=in
set rules[3].protocol=tcp
set rules[3].localport=8080-8085
::::::::::::::::::::::::::::::::::: End Setup Section ::::::::::::::::::::::::::::::::::::::::

if [%1] equ [] (
	call :sub_main_menu
) else if ["%1"] equ ["create"] (
    call :sub_create_rules
) else if ["%1"] equ ["show"] (
    call :sub_show_configuration
) else if ["%1"] equ ["delete"] (
	if [%2] equ [] (
		echo.
		echo La sintaxis del comando no es correcta.
		echo.
		echo Parametros disponibles:
		echo delete [nombre_corto]	- Elimina la regla.
		echo delete all		- Elimina todas las reglas.
	) else (
		call :sub_delete_rule %2
	)
) else (
	if [%2] equ [] (
		echo.
		echo La sintaxis del comando no es correcta.
		echo.
		echo Parametros disponibles:
		echo [nombre_corto] on	- Habilita la regla.
		echo [nombre_corto] off	- Desabilita la regla.
	) else (
		set aux=no
		if ["%2"] equ ["on"] (
			set aux=yes
		)
		if ["%2"] equ ["off"] (
			set aux=yes
		)
		if ["!aux!"] equ ["yes"] (
			call :sub_change_enable %1 %2
		) else (
			echo.
			echo La sintaxis del comando no es correcta.
			echo.
			echo Parametros disponibles:
			echo [nombre_corto] on	- Habilita la regla.
			echo [nombre_corto] off	- Desabilita la regla.		
		)
	)
)
pause
endlocal
goto:eof

:: SUBROUTINES
:sub_main_menu
cls
echo Administrador de Firewall
echo.
echo Uso: fw [comando] [parametro]
echo.
echo Comandos disponibles:
echo create			- Crea todas las reglas nuevas que se hayan configurado.
echo [nombre_corto]		- Nombre corto de la regla, definido al momento de configurar una regla.
echo show			- Muestra informacion de las reglas configuradas.
echo delete			- Elimina todas las reglas que se hayan creado por este programa.
echo.
echo Parametros disponibles:
echo [nombre_corto] on	- Habilita la regla.
echo [nombre_corto] off	- Desabilita la regla.
echo delete [nombre_corto]	- Elimina la regla.
echo delete all		- Elimina todas las reglas.
echo.
echo Notas:
echo				- Algunos comandos requieres que sean ejecutados como permisos de administrador.
echo				- Si elimina una regla con el comando [delete] asegurece de eliminarla tambien del
echo				  apartado de configuracion para que no sea creada nuevamente.
goto:eof

:sub_create_rules
set /a rules_created=0
SET /a new_rules=0

call :sub_get_array_size rules size
set /a size-=1
for /l %%a in (1,1,%size%) do (
    netsh advfirewall firewall show rule name=!rules[%%a].name! > nul
    if !errorlevel! neq 0 (
		set /a new_rules+=1
		set tcp_or_udp=no

		if ["!rules[%%a].protocol!"] equ ["tcp"] set tcp_or_udp=yes
		if ["!rules[%%a].protocol!"] equ ["udp"] set tcp_or_udp=yes

		if ["!tcp_or_udp!"] equ ["yes"] (
			netsh advfirewall firewall add rule name=!rules[%%a].name! dir=!rules[%%a].direcction! action=allow protocol=!rules[%%a].protocol! localport=!rules[%%a].localport! > nul
		) else (
			netsh advfirewall firewall add rule name=!rules[%%a].name! dir=!rules[%%a].direcction! action=allow protocol=!rules[%%a].protocol! > nul
		)

        if !errorlevel! equ 0 (
            set /a rules_created+=1
            echo La regla !rules[%%a].name! se ha creado correctamente.
        ) else (
            echo Ocurrio un error al crear la regla !rules[%%a].name!, asegurese que tiene los permisos necesarios.
        )
    )
)
echo.
echo Se han creado %rules_created% de %new_rules% regla/s nuevas.
goto:eof

:sub_show_configuration
set created=
set enable=

call :sub_get_array_size rules size
set /a size-=1

echo.
echo Nombre de la Regla	Nombre Corto	Creado		Habilitado
echo ------------------------------------------------------------------
for /l %%a in (1,1,%size%) do (
    netsh advfirewall firewall show rule name=!rules[%%a].name! > nul
    if !errorlevel! equ 0 (
        set created=Si
		for /f "tokens=2 delims=:" %%a in ('netsh advfirewall firewall show rule name^=!rules[%%a].name! ^| find /i "Habilitada:"') do (
			set enable=%%a && set enable=!enable: =!
		)
    ) else (
        set created=No
		set enable=
    )
    echo !rules[%%a].name:~1,-1! 		!rules[%%a].short_name!		!created!		!enable!
)
goto:eof

:: sub_change_enable [short_name_of_the_rule, on | off ]
:sub_change_enable
echo.
set changed=no

call :sub_get_array_size rules size
set /a size-=1
for /l %%a in (1,1,%size%) do (
	if ["!rules[%%a].short_name!"] equ ["%1"] (
		netsh advfirewall firewall show rule name=!rules[%%a].name! > nul
		if !errorlevel! equ 0 (
			if ["%2"] equ ["on"] (
				netsh advfirewall firewall set rule name=!rules[%%a].name! dir=!rules[%%a].direcction! protocol=!rules[%%a].protocol! new enable=yes > nul
			) else (
				netsh advfirewall firewall set rule name=!rules[%%a].name! dir=!rules[%%a].direcction! protocol=!rules[%%a].protocol! new enable=no > nul
			)
			if !errorlevel! equ 0 (
				if ["%2"] equ ["on"] (
					echo La regla "%1" se ha habilitado correctamente.
				) else (
					echo La regla "%1" se ha Desabilito correctamente.
				)
			) else (
				echo Ocurrio un error al modificar la regla "%1", asegurese que tiene los permisos necesarios.
			)
		) else (
			echo La regla !rules[%%a].name! aun no ha sido creada, usar el comando [create] para crearla.
		)
		exit /b
	)
)
echo "%1" no se reconoce como una regla valida.
goto:eof

:: sub_delete_rule [short_name_of_the_rule | all]
:sub_delete_rule
call :sub_get_array_size rules size
set /a size-=1

if ["%1"] equ ["all"] (
	set /a deleted_rules=0
	set exist_created_rules=no

	for /l %%a in (1,1,%size%) do (
		netsh advfirewall firewall show rule name=!rules[%%a].name! > nul
		if !errorlevel! equ 0 (
			netsh advfirewall firewall delete rule name=!rules[%%a].name! dir=!rules[%%a].direcction! protocol=!rules[%%a].protocol! > nul
			if !errorlevel! equ 0 (
				set /a deleted_rules+=1
				echo La regla !rules[%%a].name! se ha borrado correctamente.
			) else (
				echo Ocurrio un error al borrar la regla !rules[%%a].name!, asegurese que tiene los permisos necesarios.
			)
			set exist_created_rules=yes
		)
	)
	echo.
	if ["!exist_created_rules!"] equ ["yes"] (
		echo Se han borrado !deleted_rules! de %size% regla/s configuradas.
	) else (
		echo Las reglas configuradas aun no has sido creadas, usar el comando [create] para crearlas.
	)
) else (
	for /l %%a in (1,1,%size%) do (
		if ["!rules[%%a].short_name!"] equ ["%1"] (
			netsh advfirewall firewall show rule name=!rules[%%a].name! > nul
			if !errorlevel! equ 0 (
				netsh advfirewall firewall delete rule name=!rules[%%a].name! dir=!rules[%%a].direcction! protocol=!rules[%%a].protocol! > nul
				if !errorlevel! equ 0 (
					echo La regla "!rules[%%a].short_name!" se ha borrado correctamente, asegurese tambien de borrar la regla
					echo del apartado de configuracion para que no sea creada nuevamente.
				) else (
					echo Ocurrio un error al eliminar la regla !rules[%%a].name!, asegurese que tiene los permisos necesarios.
				)
			) else (
				echo La regla !rules[%%a].name! aun no ha sido creada, usar el comando [create] para crearla.
			)
			exit /b
		)
	)
	echo "%1" no se reconoce como una regla valida. 
)
goto:eof

:: sub_get_array_size [array_name] [variable_name]
:sub_get_array_size
set /a cont=1
:loop
if defined %1[%cont%].name (
   	set /a cont+=1
   	goto loop 
)
set %2=%cont%
goto:eof