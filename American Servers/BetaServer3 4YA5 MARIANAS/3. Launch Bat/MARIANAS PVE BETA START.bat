@echo off
:dcs
echo (%time%) DCS started BETA SERVER 3.
"D:\DCS World OpenBeta Server 3\bin\DCS.exe" --norender --server -w BetaServer3
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs