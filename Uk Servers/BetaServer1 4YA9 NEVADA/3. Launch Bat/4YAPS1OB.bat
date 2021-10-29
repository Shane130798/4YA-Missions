@echo off
:dcs
echo (%time%) DCS started. 4YA Public Server 1 NEVADA
"C:\Program Files\Eagle Dynamics 4YA\DCS World OpenBeta Server\bin\dcs.exe" --server --norender -w 4YAPS1OB
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs