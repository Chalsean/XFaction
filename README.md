![xfaction_logo_light_1](https://user-images.githubusercontent.com/45693161/204025849-dbafe9e5-d533-4897-a3a3-d522085eef3b.png)

Enable roster visibility and communication between guilds of a confederation, including guilds on other realms and of a different faction.

## Notice for The War Within
XFaction has a [new support server](https://discord.gg/PaNZ8TmM3Z) for timely support and more up-to-date documentation to reflect the TWW overhaul of XFaction.

## Feature Updates for The War Within
> Guild crafting order notifications

> Revamped Link(X) datatext
The Link(X) data text now shows a breakdown of the XFaction mesh across the confederate using a combination of colors and numbers. For color:
- Green: guild chat 
- Blue/Red: faction+realm addon chat channel
- Yellow: BNet

The number indicates the number of people the player's addon sees running the addon in that guild. It's a priority system that mimics the communication logic. If guild > 0, it will show green that guild count.  Else if channel > 0, it will show blue/red; else if BNet friends are in the guild it will show how many BNet links there are to that guild.

In the example, Rysael is in EKA and has 62 guild chat connections with other XFaction users, while they have no direct connections to AK4. The rest are covered by the addon chat channel.
![Links(X)](https://github.com/user-attachments/assets/d6d0a29d-d6a1-49ca-90d5-abf0b2ef743f)

## Core Features
The addon should provide the following functionalities:
> Merged guild chat across guilds/realms/factions in the confederate
<img src="https://user-images.githubusercontent.com/45693161/175836814-c326335a-786d-4be7-9547-5e31c594390c.png" width=400>

- Personal achievements forwarded to confederate members in other guilds
<img src="https://user-images.githubusercontent.com/45693161/175836417-dde29267-b00e-4eda-8506-52ef2a24d7e4.png" width=500>

> Merged system messages across guilds/realms/factions in the confederate
- When another player using the addon comes online/offline, you should see a system message as if they were local guild member
<img src="https://user-images.githubusercontent.com/45693161/175836164-9aa7c46c-5b7c-4056-8d3f-ed5487b4debf.png" width=300>


> ElvUI oUF tags
- Confederate name/initials, guild initials, player's main raiding name/team and confederate member icon oUF tags added for use in ElvUI UnitFrames
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

> LibSharedMedia

> LibStub

### Optional Dependencies

> DebugLog

> Elephant

> ElvUI

> RaiderIO

> WIM

### How It Works

Most addons use an API that goes over an invisible (to the user) channel for communication. However, channels are realm and faction isolated, which is why GreenWall only provides visiblity to other Alliance members on the same realm.

Community channels are cross-realm/faction but do not have the "invisible" API calls. Battle.Net (BNet) does though. This addon leverages BNet to send communication back-and-forth between realms/factions invisible to the user.

This dependency on BNet means users will need BNet friends online and logged into the realm(s) in question to form a bridge of communication. The addon will leverage other guild member's bridges to enable communication. You do not need to have a friend of your own logged in to the connected guild/realm, just someone online running the addon does. An important note: anyone who flags themselves as "offline" (aka incognito) cannot be used as a BNet link.

For more information please reference the [wiki](https://github.com/Chalsean/XFaction/wiki) or [faq](https://github.com/Chalsean/XFaction/wiki/FAQ).

### Logo

Special thanks to Purp#1013 for the professional logo for the addon!
