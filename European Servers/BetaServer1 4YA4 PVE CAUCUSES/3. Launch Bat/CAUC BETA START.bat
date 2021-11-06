@echo off
:dcs
title BETA1 CAUC
ping 1.1.1.1 -n 1 -w 3000 > nul
echo (%time%) DCS started BETA SERVER 1 CAUCASUS.
"D:\DCS World OpenBeta Server 1\bin\DCS.exe" --norender --server -w BetaServer1
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs