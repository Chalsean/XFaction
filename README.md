# XFaction
Enable better roster visibility and communication between guilds of a confederation, including guilds on other realms and of a different faction.

## Disclaimer

This addon is in very early stages (alpha) and currently only Eternal Kingdom (EK) is being supported. There are many hardcoded settings for EK, thus only the following guilds are supported at this time:

> Area 52
- Eternal Kingdom

> Proudmoore
- Eternal Kingdom
- Endless Kingdom
- Enduring Kingdom
- Alternal Kingdom One
- Alternal Kingdom Two
- Alternal Kingdom Three
- Alternal Kingdom Four
 
## What is included
The addon should provide the following functionalities:
> Merged guild chat across guilds/realms/factions in the confederate
- This particular build will route merged guild chat to #EKXFactionChat to prevent cluttering of guild chat for testers. The addon will automatically join testers to this channel upon loading, but you may need to enable seeing messages from the channel.
- Personal achievements forwarded to confederate members in other guilds

> Merged system messages across guilds/realms/factions in the confederate
- When another player using the addon comes online/offline, you should see a system message as if they were local guild member

> Guild roster "Guild (X)" datatext (DT) that provides the following:
- Full guild roster view across guilds/realms/factions
- View guild members' faction, level, spec, class, name, covenant, race, realm, guild, team, guild rank, zone and professions
- View guild members' team affiliation
- If on an alt, displays the main character name as well
- The DT frame should be scrollable and sortable by column headers, with team being the default sort
- Left click performs "who", shift left click performs "whisper" (not working for cross faction yet), right click performs "menu dropdown", and shift right click performs "invite"

> Bridge (X) DT that provides visibility into your active connections between realms
- This does not show all the confederate's active connections, did not want to share account information. It will only show your active connections

> 3 misc DTs: Soulbind (X), WoW Token (X), Shard (X)
- Soulbind: left click opens Soulbind frame, right click to change Soulbinds
- WoW Token: Simply displays the current WoW token market price
- Shard: Simply displays the shard # you are currently on (helpful for rare mob hunting)

## Misc

### Dependencies

> ElvUI (not included in install package)

> Ace3 (included)
- Addon
- Comm
- DB
- Event
- Hook
- Serializer
- Timer
- Stub

> LibCompress (included)

> LibQTip (included)

> LibRealmInfo (included)

### Known bugs

> Parsing ENK notes incorrectly to identify alts

> 4 & 5 way BNet communication broken due to Message constructor

### Planned enhancements

> Add configuration dashboard.

> Forward guild message of the day (MOTD).

> Remove ElvUI dependencies for non-ElvUI users.

> Find a reliable way of getting zone information.

## Testers

I greatly appreciate your personal time and effort in testing out my idea. Please keep in mind that this is still an alpha build. I am definitely looking forward to and open to your ideas on how to make this better! The better I can make this addon work for you, the better the adoption rate will be. You do not need to test the misc DTs, they are included because they are dependent upon the addon framework and thus I don't want to deploy separately. But you are free to use them if you wish.

You can log your bugs/enhancement ideas here: https://github.com/Chalsean/XFaction/issues. You can also Discord DM me (Chalsean#7679) or in-game (Chalsean#1172). There is also a discussion board here: https://github.com/Chalsean/XFaction/discussions

### Installing

The easiest way is to use WowUp client.

1. Go to "Get Addons"
2. Click on "Install from URL"
3. Enter the following URL: https://github.com/Chalsean/XFaction

Like any other addon displayed in WowUp, the application will recognize when a new build is made available via Github. To install a newer version, you will only need to click on "Upgrade". If not using WowUp client, you can download the .zip file from the repository and install manually to your Addons folder.

### Debugging addons

Three addons will be critical for collecting meaningful information to troubleshoot issues. Please install them as well.

>BugSack/BugGrabber

Although technically two different addons (and installed separately), they function as essentially one addon. They will grab any/all Lua exceptions and store the call stack. This will look like a bag icon on your world map. Green means no exceptions, red means an exception. However, be aware that other addons will throw exceptions as well. If red, look for entries where XFaction is in the filepath. If so, you can send to me by copy/paste all or clicking the Send Bug button.

>_DebugLog

This is a logging utility leveraged by XFaction. (XFaction will not log or throw errors if _DebugLog is not installed.)  This will look like a yellow fist after install. When you launch the UI, you should see a XFaction tab that contains all log information from the addon. Currently the utility appears to have an issue with exporting logs, but I may ask for information in the logs to help diagnose an issue if I cannot reproduce on my own.

By default, this addon will log at a verbosity level of 6. Most useful development information is at level 9. Right click on the yellow fist and set the max verbosity level to 9.

### How It Works

Most addons use an API that goes over an invisible (to the user) channel for communication. However, channels are realm and faction isolated, which is why GreenWall only provides visiblity to other Alliance members on the same realm.

Community channels are cross-realm/faction but do not have the "invisible" API calls. Battle.Net (BNet) does though. This addon leverages BNet to send communication back-and-forth between realms/factions invisible to the user.

This dependency on BNet means users will need BNet friends online and logged into the realm(s) in question to form a bridge of communication. The addon will leverage other guild member's bridges to enable communication. You do not need to have a friend of your own logged in to the connected guild/realm, just someone online running the addon does.

For the addon to "work" from an EK member perspective, there needs to be a user actively logged onto a guild representing each faction on a given realm, e.g., AK3-Proudmoore (A Proudmoore), AK4-Proudmoore (H Proudmoore), EK-Area52 (H Area 52). These three online users will need to be Bnet friends with at least one of the three. Anyone running the addon (without being friends with the three "bridge" users) will then see messages regardless of what EK guild toon they are currently logged into.

A lot of the test cases are going to focus on validating this BNet communication works as intended, which is going to require coordination between the testers.

Testing is being coordinated on the guild discord server, channel #addon-testing.
