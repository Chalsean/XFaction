![xfaction_logo_light_1](https://user-images.githubusercontent.com/45693161/204025849-dbafe9e5-d533-4897-a3a3-d522085eef3b.png)

Enable roster visibility and communication between guilds of a confederation, including guilds on other realms and of a different faction.

## Notice for The War Within
XFaction has a [new support server](https://discord.gg/PaNZ8TmM3Z) for timely support and more up-to-date documentation to reflect the TWW overhaul of XFaction.

## Feature Updates for The War Within
- Addon version number lookup in Guild(X) datatext: Addon admins can check the player's addon version during troubleshooting if the option is enabled in Guild(X).
- Guild crafting order notifications: XFaction will provide visual notification in the gchat when guild crafting orders are placed by any player in the confederate. The notification will specify which guild the crafting order was placed for.

![image](https://github.com/user-attachments/assets/bff01290-df06-43a6-b357-7556c0a11be1)

- Revamped Link(X) datatext: It now shows a breakdown of the XFaction mesh across the confederate using a combination of colors and numbers. See the Links (X) DT section for more information.

## Core Features
The addon should provide the following functionalities:
> Merged guild chat across guilds/realms/factions in the confederate
<img src="https://user-images.githubusercontent.com/45693161/175836814-c326335a-786d-4be7-9547-5e31c594390c.png" width=400>

- Personal achievements forwarded to confederate members in other guilds
<img src="https://user-images.githubusercontent.com/45693161/175836417-dde29267-b00e-4eda-8506-52ef2a24d7e4.png" width=500>

> Merged system messages across guilds/realms/factions in the confederate
- When another player using the addon comes online/offline, you should see a system message as if they were a local guild member.\
<img src="https://user-images.githubusercontent.com/45693161/175836164-9aa7c46c-5b7c-4056-8d3f-ed5487b4debf.png" width=300>


> ElvUI oUF tags
- Confederate name/initials, guild initials, player's main raiding name/team and confederate member icon oUF tags added for use in ElvUI UnitFrames
<img src="https://user-images.githubusercontent.com/45693161/183232611-6c568877-2e0f-4d6b-910e-b51510a9a424.png" width=150>
<img src="https://user-images.githubusercontent.com/45693161/184562768-6c9bf138-d924-40d4-9bf9-1a68cfa6e040.png" width=150>


> Guild roster "Guild (X)" datatext (DT) that provides the following:
- Full guild roster view across guilds/realms/factions
- View guild members' faction, level, spec, class, name, covenant, race, realm, guild, team, guild rank, zone, professions, pvp rating, raid progress, max item level and M+ score
- View guild members' team affiliation
- View guild members' addon version (must be enabled in Settings)
- If on an alt, displays the main character name as well
<img src="https://user-images.githubusercontent.com/45693161/175836288-82855e04-0200-4d4c-964c-387675975f29.png" width=700>


> Links (X) DT
- This shows a breakdown of the XFaction mesh across the confederate using a combination of colors and numbers. 
  
For color:
  - Green: guild chat 
  - Blue/Red: faction+realm addon chat channel
  - Yellow: BNet

The number indicates the number of people the player's addon sees running the addon in that guild, with each row representing what that player's addon sees. It's a priority system that mimics the communication logic. If guild > 0, it will show green that guild count.  Else if channel > 0, it will show blue/red; else if BNet friends are in the guild it will show how many BNet links there are to that guild.

In the example, Rysael is in EKA and has 62 guild chat connections with other XFaction users, while they have no direct connections to AK4. The rest are covered by the addon chat channel.
Note: Even though Rysael does not have direct connections, AK4 is covered by another player as seen in the larger table.
 
![Links(X)](https://github.com/user-attachments/assets/d6d0a29d-d6a1-49ca-90d5-abf0b2ef743f)


> Metrics (X) DT
- This will show various metrics about XFaction performance
![image](https://github.com/user-attachments/assets/869f0e5e-c55d-4b38-bbf1-ebc5d9adefd7)


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
