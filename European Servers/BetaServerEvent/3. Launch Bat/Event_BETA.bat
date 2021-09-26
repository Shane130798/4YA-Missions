@echo off
:dcs
echo (%time%) DCS started Beta Event.
"D:\DCS World OpenBeta Server Events\bin\DCS.exe" --norender --server -w BetaEvent
echo (%time%) WARNING: dcs closed or crashed, restarting.
ping 1.1.1.1 -n 1 -w 3000 >nul
goto dcs