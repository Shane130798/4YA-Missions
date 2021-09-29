-- Copyright (c) 2021, cytokine-dcs
--
-- Load Jester at DCS server startup.

-- keep jester scripts outside of the writedir so that we can update it for all
-- dcs servers in one go.
JESTER_SCRIPT_DIR = lfs.writedir() .. '../Jester_scripts/'

net.log('[jester::hook] Loading jester from ' .. JESTER_SCRIPT_DIR)
local s, e = pcall(dofile, JESTER_SCRIPT_DIR .. 'jester_load.lua')

if not s then
  net.log('[jester] FATAL: could not load jester agent: ' .. net.lua2json(e))
end
