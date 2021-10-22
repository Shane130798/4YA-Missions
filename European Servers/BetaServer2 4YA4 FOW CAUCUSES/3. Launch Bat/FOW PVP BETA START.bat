@echo off
:dcs
echo (%time%) DCS started BETA SERVER 2 CAUCASUS PVP.
"D:\DCS World OpenBeta Server 1\bin\DCS.exe" --norender --server -w BetaServer2
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs