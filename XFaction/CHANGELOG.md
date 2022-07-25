### Version 3.4 [ 07.20.2022 ]
[XFaction]
- Local guild logouts and gchat are now in XFaction format
- Configurable team names (Zoombara)
- Respects guild rank gchat speak/listen permissions

### Version 3.3 [ 07.17.2022 ]
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