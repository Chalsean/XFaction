### Version 2.6.0 [ 06.23.2022 ]

**Enhancements**
[XFaction]
- Confederate name, realms/guilds involved and channel are all configurable in guild info
- Modified ChatThrottleLib from Ace3 libraries to accept BNet
    - This is a standard library used to queue or delay addon messages if nearing the disconnect threshold
    - To point out, Blizzard will not say what that threshold is, so its trial and error from the dev community
- Removed majority of network channel scanning
- Increase message size by 50% to try to reduce the number of overall packets
- Doubled the time between link broadcasts from 1min to 2min
- The following broadcast triggering event listeners will now disable/enable upon entering/exiting an instance:
  - Level up
  - Changing covenant (cant outside Oribos anyway)
  - (Un)learning profession
- The following broadcast triggering event listeners will now disable/enable upon entering/exiting combat while in instance:
  - Changing soulbind
  - Changing spec
  - Entering/exiting instance
  - Timer to ping BNet friends
  - Timer to monitor local guild roster
  - Timer to monitor links
  - Timer to broadcast player data (hearbeat)
  - Timer to broadcast players own links
  - All listeners listed above that are disabled/enabled upon entering/exiting instance apply
- The following broadcast triggering event listeners was removed entirely:
  - Changing zone
  - Achievement points increase (getting an achievement will still broadcast, this has to do with the player's point total)
  - M+ score increase
- Implemented a minimum heartbeat time, meaning regardless of triggers, player will not broadcast own data within 15s of previous broadcast
- Ignores all "Explore" achievements to avoid spam

[Guild (X)]
- Now locksdown if in combat
- Now supports any rank name on any guild

[Links (X)]
- Now locksdown if in combat

**Bug Fix**
[XFaction]
- Fixed an exception condition when player is not in a guild

[Guild (X)]
- Shift-right click now properly invites the player

[Links (X)]
- Fixed broker not refreshing the count when opposite faction link logs off

**Misc**
[XFaction]
- Removed unsupported options from options menu
- Disabled channel sort option

[Shard (X)]
- Retired (wasnt working anyway)