# sandBlocker

a DCS slotblocker tragedy - this program will probably suffer from similar "sandwich" creation malfunctions

===========================================================================================================

## Quick Dev Note
for a mission, only the first 3 blocks (seperated by underscores) are important, these *HAVE* to match 1 on 1 with the config files! (config files also have _SBconfig at the end of the name!)

example:
4YA_CAUC_PVE-whatever-you-want-just-use-hyphens_whatever_you_would_like_here_SB_does_not_read_this.miz

we will need a config file who's full name is:
4YA_CAUC_PVE-whatever-you-want-just-use-hyphens_SBconfig.json

===========================================================================================================

## Configurator

in order to have SandBlocker effectively integrate with your mission i've added a configurator/editor! With this program you can easily create or edit your own config files! Go ham with it!

about:

- can add/change/deactivate airbases
- can add/change/deactivate farps
- can print the current setup
- can print whole config files!
- automatically creates a config file after each session! this will be [mission name]+_SBconfig.json to ensure Sandblocker
  will use the correct file for the mission!

===========================================================================================================

## SandBlocker

SandBlocker is the actual script that handles the slotblocking, for this it requires the config file!

about:

- SandBlocker automatically loads the config file with the right mission name (as long as one is present)
- SandBlocker handles everything as long as the config file is setup completely!
- SandBlocker interfaces with the current running game using the net.chat_send() function from the API
  as long as this is setup accordingly it will enable the switching of base-coalitions for farps and airbases
  completely free from one-another!

how to set up:
[FILE_EXPLORER]

1. in your DCS server saved games: go to hooks, place down sandBlocker.lua
2. in that same hooks folder, make sure to create a new folder called: "SBconfigs"
3. drop/make the SBconfigs in this new folder, SandBlocker will read from this place!

[MISSION_SIDE]

1. make sure to have the corresponding config file open
2. when naming units make sure to use this format:
   {number: digits} {string: config file name for this airport/farp} {string: whatever else you want}
3. make sure the mission name matches that given in the config file name
4. start the server!
5. have fun :)

===========================================================================================================

## closing remarks

incase you run into a problem, a bug or any other issue, please contact me! (sandwich)
or just leave a comment on github :)
