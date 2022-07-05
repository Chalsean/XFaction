# XFaction
Enable roster visibility and communication between guilds of a confederation, including guilds on other realms and of a different faction.

## Disclaimer

This addon is recently coming out of alpha and beta testing. There are still some EK specific hardcoding.
 
## What is included
The addon should provide the following functionalities:
> Merged guild chat across guilds/realms/factions in the confederate
<img src="https://user-images.githubusercontent.com/45693161/175836814-c326335a-786d-4be7-9547-5e31c594390c.png" width=400>

- Personal achievements forwarded to confederate members in other guilds
<img src="https://user-images.githubusercontent.com/45693161/175836417-dde29267-b00e-4eda-8506-52ef2a24d7e4.png" width=500>

> Merged system messages across guilds/realms/factions in the confederate
- When another player using the addon comes online/offline, you should see a system message as if they were local guild member
<img src="https://user-images.githubusercontent.com/45693161/175836164-9aa7c46c-5b7c-4056-8d3f-ed5487b4debf.png" width=300>


> Guild roster "Guild (X)" datatext (DT) that provides the following:
- Full guild roster view across guilds/realms/factions
- View guild members' faction, level, spec, class, name, covenant, race, realm, guild, team, guild rank, zone, professions, pvp rating, raid progress, max item level and M+ score
- View guild members' team affiliation
- If on an alt, displays the main character name as well
<img src="https://user-images.githubusercontent.com/45693161/175836288-82855e04-0200-4d4c-964c-387675975f29.png" width=700>


> Links (X) DT
- This will show all the active BNet links within the confederate
<img src="https://user-images.githubusercontent.com/45693161/175842217-b00a8966-d6fd-4ad2-9cfb-2f821933fcee.png" width=200>



> 2 miscellaneous DTs: Soulbind (X), WoW Token (X)
- Soulbind: left click opens Soulbind frame, right click to change Soulbinds
<img src="https://user-images.githubusercontent.com/45693161/175836356-80c30337-bf55-471c-b54b-f18f01e0b02c.png" width=200>

- WoW Token: Simply displays the current WoW token market price
<img src="https://user-images.githubusercontent.com/45693161/175836370-d6a40a6f-0356-4e47-9461-2f554ea3d7d4.png" width=200>

## Misc

### Dependencies

> Ace3
- Addon
- Bucket
- Comm
- Config
- ConfigCmd
- ConfigDialog
- Console
- DB
- DBOptions
- Event
- GUI
- Hook
- Serializer
- Timer
- Stub

> BNetChatThrottleLib

> LibCompress

> LibDataBroker

> LibQTip

> LibRealmInfo

### Optional Dependencies

> _DebugLog

> RaiderIO

### How It Works

Most addons use an API that goes over an invisible (to the user) channel for communication. However, channels are realm and faction isolated, which is why GreenWall only provides visiblity to other Alliance members on the same realm.

Community channels are cross-realm/faction but do not have the "invisible" API calls. Battle.Net (BNet) does though. This addon leverages BNet to send communication back-and-forth between realms/factions invisible to the user.

This dependency on BNet means users will need BNet friends online and logged into the realm(s) in question to form a bridge of communication. The addon will leverage other guild member's bridges to enable communication. You do not need to have a friend of your own logged in to the connected guild/realm, just someone online running the addon does. An important note: anyone who flags themselves as "offline" (aka incognito) cannot be used as a BNet link.
