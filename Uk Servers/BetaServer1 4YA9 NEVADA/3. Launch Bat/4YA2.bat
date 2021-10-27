@echo off
:dcs
echo (%time%) DCS started. 4YA 2 Beta
"C:\Program Files\Eagle Dynamics 42B\DCS World OpenBeta Server\bin\dcs.exe" --server --norender -w 7.4YA2
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs