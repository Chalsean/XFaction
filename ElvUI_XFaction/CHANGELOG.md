### Version 1.11.5 [ 06.09.2022 ]

**Bug Fixes**  
[XFaction] 
- Removed all whisper logic, Blizz API was sometimes throwing a "player not found" error
- Implemented lockdown logic if a player gquit/gkick
- Fixed logout message getting fired during load screens (PLAYER_LEAVING_WORLD event firing). Switched to PLAYER_LOGOUT event

[DTLinks]
- Bug fix for when player is not in a guild

[DTSoulbind]
- Bug fix for when player is not in a guild

[DTGuild]
- Bug fix for when player is not in a guild

**Misc Changes** 
