### Version 2.8.3 [ 07.06.2022 ]

[XFaction]
- Removed channel sort option as it was not meeting user expectations
- Addon will now always ensure addon-channel is last if enabled

### Version 2.8.0 [ 07.04.2022 ]

[XFaction]
- Fixed corner case where player data was not retrieved properly upon login
- Added ad-hoc debug print capability

[Guild (X)]
- Can configure the columns in any order and change justification
- Added item level, raid progress, pvp score as columns
- PvP score is your highest score in 2, 3 and 10 brackets
- Raid progress and M+ rating are dependent upon RaiderIO
  - RaiderIO is optional but cannot provide raid/M+ columns without it

### Version 2.7.1 [ 07.02.2022 ]

[XFaction]
- Increased "login give up" timer on trying to get guild information

### Version 2.7.0 [ 06.29.2022 ]

[XFaction]
- WIM guild chat integration (Zyroxia)
- Achievement and login/logout provide click ability (Zyroxia)
- Login/logout config options to enable/disable faction/guild/alt (Zyroxia)
- Cleaned up a rare corner case where link became stale
- Fixed exception with setting channels and added usage instructions
- Added debug capability to print libraries ad-hoc

[Guild (X)]
- Left click will start a whisper with a member of same faction or BNet friend
- Right click will give drop down menu with a member of same faction or BNet friend
- Shift-right click will invite player to your party if same faction or BNet friend
- Control-right click will request to join player's party if same faction or BNet friend