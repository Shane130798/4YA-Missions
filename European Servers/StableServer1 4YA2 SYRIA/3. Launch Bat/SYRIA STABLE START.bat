@echo off
:dcs
echo (%time%) DCS started STABLE SERVER 1 SYRIA.
"C:\Program Files\Eagle Dynamics\DCS World Server 1\bin\DCS.exe" --norender --server -w StableServer1
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs