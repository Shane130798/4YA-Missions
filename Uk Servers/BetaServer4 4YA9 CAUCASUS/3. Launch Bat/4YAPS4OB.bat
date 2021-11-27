@echo off
:dcs
echo (%time%) DCS started. 4YA Server 4 Beta 
"C:\Program Files\Eagle Dynamics 4YA\DCS World OpenBeta Server\bin\dcs.exe" --server --norender -w 4YAPS4OB
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs