# XFaction
Enable roster visibility and communication between guilds of a confederation, including guilds on other realms and of a different faction.

## Disclaimer

This addon is recently coming out of alpha and beta testing. There are still some things rough around the edges. To setup, you will need to be able to edit your guild information tab. The setup can be somewhat tricky, so any questions, feel free to reach out.
 
## What is included
The addon should provide the following functionalities:
> Merged guild chat across guilds/realms/factions in the confederate
<img src="https://user-images.githubusercontent.com/45693161/175836814-c326335a-786d-4be7-9547-5e31c594390c.png" width=400>

- Personal achievements forwarded to confederate members in other guilds
<img src="https://user-images.githubusercontent.com/45693161/175836417-dde29267-b00e-4eda-8506-52ef2a24d7e4.png" width=500>

> Merged system messages across guilds/realms/factions in the confederate
- When another player using the addon comes online/offline, you should see a system message as if they were local guild member
<img src="https://user-images.githubusercontent.com/45693161/175836164-9aa7c46c-5b7c-4056-8d3f-ed5487b4debf.png" width=300>


> ElvUI uOF tags
- Confederate name/initials, guild initials, player's main raiding name/team and confederate member icon uOF tags added for use in ElvUI UnitFrames
<img src="https://user-images.githubusercontent.com/45693161/183232611-6c568877-2e0f-4d6b-910e-b51510a9a424.png" width=150>
<img src="https://user-images.githubusercontent.com/45693161/184562768-6c9bf138-d924-40d4-9bf9-1a68cfa6e040.png" width=150>


> Guild roster "Guild (X)" datatext (DT) that provides the following:
- Full guild roster view across guilds/realms/factions
- View guild members' faction, level, spec, class, name, covenant, race, realm, guild, team, guild rank, zone, professions, pvp rating, raid progress, max item level and M+ score
- View guild members' team affiliation
- If on an alt, displays the main character name as well
<img src="https://user-images.githubusercontent.com/45693161/175836288-82855e04-0200-4d4c-964c-387675975f29.png" width=700>


> Links (X) DT
- This will show all the active BNet links within the confederate
<img src="https://user-images.githubusercontent.com/45693161/175842217-b00a8966-d6fd-4ad2-9cfb-2f821933fcee.png" width=200>


> Metrics (X) DT
- This will show various metrics about XFaction performance
<img src="https://user-images.githubusercontent.com/45693161/181374308-c82a3fb4-7e9f-4cb3-85a2-e7252296d36d.png" width=200>


> 2 miscellaneous DTs: Soulbind (X), WoW Token (X)
- Soulbind: left click opens Soulbind frame, right click to change Soulbinds
<img src="https://user-images.githubusercontent.com/45693161/175836356-80c30337-bf55-471c-b54b-f18f01e0b02c.png" width=200>

- WoW Token: Simply displays the current WoW token market price
<img src="https://user-images.githubusercontent.com/45693161/175836370-d6a40a6f-0356-4e47-9461-2f554ea3d7d4.png" width=200>

## Misc

### Dependencies

> Ace3
- Config
- DB
- DBOptions
- Locale

> AceGUI-3.0-SharedMediaWidgets

> ChatThrottleLib (*modified for BNet)

> LibDataBroker

> LibDeflate

> LibQTip

> LibRealmInfo (*modified)

> LibSharedMedia

> LibStub

> LibTourist

### Optional Dependencies

> _DebugLog

> RaiderIO

### How It Works

Most addons use an API that goes over an invisible (to the user) channel for communication. However, channels are realm and faction isolated, which is why GreenWall only provides visiblity to other Alliance members on the same realm.

Community channels are cross-realm/faction but do not have the "invisible" API calls. Battle.Net (BNet) does though. This addon leverages BNet to send communication back-and-forth between realms/factions invisible to the user.

This dependency on BNet means users will need BNet friends online and logged into the realm(s) in question to form a bridge of communication. The addon will leverage other guild member's bridges to enable communication. You do not need to have a friend of your own logged in to the connected guild/realm, just someone online running the addon does. An important note: anyone who flags themselves as "offline" (aka incognito) cannot be used as a BNet link.

For more information please reference the [wiki](https://github.com/Chalsean/XFaction/wiki) or [faq](https://github.com/Chalsean/XFaction/wiki/FAQ).
