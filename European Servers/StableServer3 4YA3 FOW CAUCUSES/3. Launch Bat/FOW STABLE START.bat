@echo off
:dcs
title STABLE3 CAUC PVP
echo (%time%) DCS started STABLE SERVER 3 CAUCASUS PVP.
"C:\Program Files\Eagle Dynamics\DCS World Server 1\bin\DCS.exe" --norender --server -w StableServer3
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs