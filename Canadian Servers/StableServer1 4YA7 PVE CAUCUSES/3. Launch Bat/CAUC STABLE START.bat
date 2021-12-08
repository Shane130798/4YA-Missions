@echo off
:dcs
title STABLE2 CAUC
echo (%time%) DCS started STABLE SERVER 2 CAUCASUS.
"C:\Program Files\Eagle Dynamics\DCS World Server Stable\bin\DCS.exe" --norender --server -w StableServer1
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs