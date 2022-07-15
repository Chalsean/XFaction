### Version 3.4 [ 07.24.2022 ]

[XFaction]
- Fixed exception handling if RaiderIO throws
- RaiderIO defaults to main

### Version 3.3 [ 07.17.2022 ]

[XFaction]
- Switched compression library for BNet communication
- Refactored BNet messaging to reduce redundant overhead in message packets
- Better granularity on controlling packet size
- Randomizes BNet forwarding if above a threshold
- Cleaned up achievement message formatting (Zoombara)
- Fixed support button lua exception (Zoombara)