# XFaction
Enable roster visibility and communication between guilds of a confederation, including guilds on other realms and of a different faction.

## Disclaimer

This addon is in early stages of development (beta) and currently only Eternal Kingdom (EK) is being supported. Thus only the following guilds are supported at this time:

> Proudmoore
- Eternal Kingdom (EKA)
- Eternal Kingdom Horde (EKH)
- Endless Kingdom (ENK)
- Alternal Kingdom (AK)
- Alternal Kingdom Two (AK2)
- Alternal Kingdom Three (AK3)
- Alternal Kingdom Four (AK4)
 
## What is included
The addon should provide the following functionalities:
> Merged guild chat across guilds/realms/factions in the confederate

- As of 2.5.3, the merged guild chat is routed to guild chat, similar to GreenWall
- Personal achievements forwarded to confederate members in other guilds
<img src="https://user-images.githubusercontent.com/45693161/175836417-dde29267-b00e-4eda-8506-52ef2a24d7e4.png" width=500>

> Merged system messages across guilds/realms/factions in the confederate
- When another player using the addon comes online/offline, you should see a system message as if they were local guild member
<img src="https://user-images.githubusercontent.com/45693161/175836164-9aa7c46c-5b7c-4056-8d3f-ed5487b4debf.png" width=300>


> Guild roster "Guild (X)" datatext (DT) that provides the following:
- Full guild roster view across guilds/realms/factions
- View guild members' faction, level, spec, class, name, covenant, race, realm, guild, team, guild rank, zone and professions
- View guild members' team affiliation
- If on an alt, displays the main character name as well
- The DT frame should be scrollable and sortable by column headers, with team being the default sort
- Left click performs "who", shift left click performs "whisper" (not working for cross faction yet), right click performs "menu dropdown", and shift right click performs "invite"
<img src="https://user-images.githubusercontent.com/45693161/175836288-82855e04-0200-4d4c-964c-387675975f29.png" width=650>


> Links (X) DT
- This will show all the active BNet links within the confederate

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

### Known bugs and planned enhancements

https://github.com/Chalsean/XFaction/issues

## Testers

I greatly appreciate your personal time and effort in testing out my idea. Please keep in mind that this is still an alpha build. I am definitely looking forward to and open to your ideas on how to make this better! The better I can make this addon work for you, the better the adoption rate will be. You do not need to test the misc DTs, they are included because they are dependent upon the addon framework and thus I don't want to deploy separately. But you are free to use them if you wish.

You can log your bugs/enhancement ideas here: https://github.com/Chalsean/XFaction/issues. You can also Discord DM me (Chalsean#7679) or in-game (Chalsean#1172). There is also a discussion board here: https://github.com/Chalsean/XFaction/discussions

### Installing

The easiest way is to use WowUp client.

1. Go to "Get Addons"
2. Click on "Install from URL"
3. Enter the following URL: https://github.com/Chalsean/XFaction

Like any other addon displayed in WowUp, the application will recognize when a new build is made available via Github. To install a newer version, you will only need to click on "Upgrade". If not using WowUp client, you can download the .zip file from the repository and install manually to your Addons folder.

### Debugging Addons - NOT Needed for 2.5.3 Testing

Three addons will be critical for collecting meaningful information to troubleshoot issues. 

>BugSack/BugGrabber

Although technically two different addons (and installed separately), they function as essentially one addon. They will grab any/all Lua exceptions and store the call stack. This will look like a bag icon on your world map. Green means no exceptions, red means an exception. However, be aware that other addons will throw exceptions as well. If red, look for entries where XFaction is in the filepath. If so, you can send to me by copy/paste all or clicking the Send Bug button.

>_DebugLog

This is a logging utility leveraged by XFaction. (XFaction will not log or throw errors if _DebugLog is not installed.)  This will look like a yellow fist after install. When you launch the UI, you should see a XFaction tab that contains all log information from the addon. Currently the utility appears to have an issue with exporting logs, but I may ask for information in the logs to help diagnose an issue if I cannot reproduce on my own.

By default, this addon will log at a verbosity level of 6. Most useful development information is at level 9. Right click on the yellow fist and set the max verbosity level to 9.

### How It Works

Most addons use an API that goes over an invisible (to the user) channel for communication. However, channels are realm and faction isolated, which is why GreenWall only provides visiblity to other Alliance members on the same realm.

Community channels are cross-realm/faction but do not have the "invisible" API calls. Battle.Net (BNet) does though. This addon leverages BNet to send communication back-and-forth between realms/factions invisible to the user.

This dependency on BNet means users will need BNet friends online and logged into the realm(s) in question to form a bridge of communication. The addon will leverage other guild member's bridges to enable communication. You do not need to have a friend of your own logged in to the connected guild/realm, just someone online running the addon does. An important note: anyone who flags themselves as "offline" (aka incognito) cannot be used as a BNet link.

For the addon to "work" from an EK member perspective, there needs to be a user actively logged onto a guild representing each faction on a given realm, e.g., AK3-Proudmoore (A Proudmoore), AK4-Proudmoore (H Proudmoore), ENK (A Proudmoore). These three online users will need to be Bnet friends with at least one of the three. Anyone running the addon (without being friends with the three "bridge" users) will then see messages regardless of what EK guild toon they are currently logged into.

A lot of the test cases are going to focus on validating this BNet communication works as intended, which is going to require coordination between the testers.

Testing is being coordinated on the guild discord server, channel #xfaction-addon-testing.
