### Version 3.9
[XFaction]
- Optimized performance
- Local guild achievements are now in XFaction format
- Option to enable/disable debug logging within instances

### Version 3.7
[XFaction]
- Better randomization algorithm on message forwards to reduce traffic
- Added the following oUF tags for ElvUI NamePlates:
  - Confederate name, initials
  - Guild initials
  - Player's main raiding character
  - Team name
  - Member icon

### Version 3.6
[XFaction]
- Local guild logins are now in XFaction format

### Version 3.5
[XFaction]
- Fixed spaces in channel listing causing addon to break
- Fixed exception caused by friend playing neutral faction on same realm
- Fixed random exception on initial login
- Fixed receiving local guild logoff messages if login/logoff option unchecked
- Fixed race condition with ElvUI chat handler
- Fixed Guild right-click menu showing behind the tooltip (Zoombara)
- Readjust channel colors based on ID after Blizzard sets them by #
- Implemented try/catch/finally exception handling for all timers/events/inputs
- Some refactoring to old non-C APIs for Classic support (incomplete)
- Added Evoker/Dracthyr support, awaiting icons for specs
- Prompts user when it detects a newer version available
- Localized zone text
- Reduced message size by sending zone IDs instead of full text
- Added Metrics (X) DT that displays the following total/average values:
  - Total messages received
  - BNet messages received
  - BNet messages sent
  - Local messages received
  - Local messages sent
  - Errors encountered
  - Warnings encountered

### Version 3.4
[XFaction]
- Local guild logouts and gchat are now in XFaction format
- Configurable team names (Zoombara)
- Respects guild rank gchat speak/listen permissions

### Version 3.3
[XFaction]
- Fixed ENK team association
- Recognizes legacy EK notes
- Fixed exception handling if RaiderIO throws
- RaiderIO defaults to main
- Switched compression library for BNet communication
- Refactored BNet messaging to reduce redundant overhead in message packets
- Better granularity on controlling packet size
- Randomizes BNet forwarding if above a threshold
- Cleaned up achievement message formatting (Zoombara)
- Fixed support button lua exception (Zoombara)