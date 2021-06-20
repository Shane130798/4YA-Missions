do
	local seconds = timer.getTime( )
	local restart
	local message
	local msg = {}
	if seconds <= 0 then
		message = "06:00:00";
	else
		restart = 39600 - seconds;
		hours = string.format("%02.f", math.floor(restart/3600));
		mins = string.format("%02.f", math.floor(restart/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(restart - hours*3600 - mins *60));
		message = hours..":"..mins..":"..secs
	end
	msg.text = 'Time remaining before server restart: '..message 
    msg.displayTime = 10  
    msg.msgFor = {coa = {'all'}} 
    mist.message.add(msg)
end