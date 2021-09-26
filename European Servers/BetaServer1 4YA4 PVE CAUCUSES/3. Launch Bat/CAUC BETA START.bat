@echo off
:dcs
echo (%time%) DCS started BETA SERVER 1.
"D:\DCS World OpenBeta Server 1\bin\DCS.exe" --norender --server -w BetaServer1
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs