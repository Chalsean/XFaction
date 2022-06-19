### Version 2.5.0 [ 06.19.2022 ]

**Enhancements**
[XFaction]
- Supports password protected channel (XFc:<channel-name>:<password>)
- Standardized rank names across the confederate

[Guild (X)]
- Supports displaying alternate confederate rank names

**Bug Fixes**
[XFaction]
- Fixed exception from Blizz spec API returning no data on initial login

### Version 2.4.2 [ 06.18.2022 ]

**Bug Fix**
[XFaction]
- Fixed quite a few bugs with Links logic
- Fixed bugs with getting server time
- Fixed bugs with QT releasing broker frames
- Fixed bug with Achievement messages creating wrong objects

### Version 2.4.1 [ 06.18.2022 ]

**Bug Fix**
[XFaction]
- Fixed bug where M+ and achievement scores were not being decoded properly in messages

### Version 2.4.0 [ 06.18.2022 ]

**Enhancements**
[XFaction]
- Switched to newer, more stable guild roster API calls

[DTGuild]
- Now shows professions for all local guild members
- Added Mythic+ score and Achievement points as column options

**Bug Fix**
[DTSoulbind]
- Fixed bug where exception was getting thrown if player did not have a covenant or soulbind

### Version 2.3.0 [ 06.17.2022 ]

**Enhancements**
[XFaction]
- Can configure order of channels in settings menu
- Better error handling when unable to decode message

**Bug Fixes**
[XFaction]
- Fixed bug around adding/removing/renaming guilds in the confederate

[Links (X)]
- Fixed bug where all friends were considered links
- Fixed bug where players name was not always highlighted

**Misc Changes**
[Guild (X)]
- Ignores mobile users