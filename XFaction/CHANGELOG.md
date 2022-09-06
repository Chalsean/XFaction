### Version 4.0
[XFaction]
- Removed covenant/soulbind logic
- Removed Soulbind (X) data broker
- Fixed or replaced several Blizz API calls that changed with DF
- Reworked channel communication logic to match bnet for performance boost
- Smarter caching for performance boost during a reloadui
- Increased compression level to send less data packets
- Refreshed LibRealm listing of connected realms (US/EU regions only)
- Replaced most libraries with own logic as several were not working with DF in beta:
  - Ace3 Addon, Bucket, Comm, Console, Event, GUI, Hook, Serializer, Tab, Timer
  - LibBabble
  - LibClass
  - LibProfession
  - LibRace
  - LibSpec