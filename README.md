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

### Planned enhancements

> Add configuration dashboard.

> Forward guild message of the day (MOTD).

> Remove ElvUI dependencies for non-ElvUI users.

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

## Testing Status

| ID  | Part | Title | Description | Status | # Testers | Tester A | Tester B | Tester C | Tester D |
|-----|------|-------|-------------|--------|-----------|----------|----------|----------|----------|
| 001 | XFaction | Exceptions | Ensure BugGrabber/BugSack have no exceptions from XFaction | Not Assigned | 1 | | | |
| 002 | XFaction | Logging | Ensure addon is successfully logging to DebugLog | Not Assigned | 1 | | | |
| 003 | Guild (X) | Confederate Name | Shows the confederate name at the top (Eternal Kingdom) when logged into Eternal Kingdom guild Area 52. | Not Assigned | 1 ||||
| 004 | Guild (X) | Confederate Name | Shows the confederate name at the top (Eternal Kingdom) when logged into Eternal Kingdom guild Proudmoore. | Not Assigned | 1 ||||
| 005 | Guild (X) | Confederate Name | Shows the confederate name at the top (Eternal Kingdom) when logged into Alternal Kingdom guild Proudmoore. | Not Assigned | 1 ||||
| 006 | Guild (X) | Confederate Name | Shows the confederate name at the top (Eternal Kingdom) when logged into Endless Kingdom guild Proudmoore. | Not Assigned | 1 ||||
| 007 | Guild (X) | Action Buttons | Left clicking on any of the column headers (i.e. Name) should sort the guild roster by that column. A-Z first. If clicked again, Z-A. Validate you can sort forwards/reverse by any of the columns. | Not Assigned | 1 ||||
| 008 | Guild (X) | Action Buttons | Left clicking on anyone of the same faction should start a whisper dialogue. | Not Assigned | 1 ||||
| 009 | Guild (X) | Action Buttons | Right clicking on anyone should open a standard character menu. | Not Assigned | 1 ||||
| 010 | Guild (X) | Action Buttons | Shift right clicking on anyone should invite them to your party/raid. | Not Assigned | 1 ||||

### XFaction
> Guild Chat

> System Messages

> Achievements

### Bridges (X) 
- Shows your currently active bridges.
- Shows your btag in the appropriate column. If your character is on Alliance Proudmoore, your btag should show up in Alliance Proudmoore column.
- Friends running addon logged into same faction/realm should not show up.
- Friends running addon logged into same realm but different faction (Horde Proudmoore), their btag should show up in appropriate column.
- Friends running addon logged into different realm and different faction (Horde Area 52), their btag should show up in appropriate column.
- Friends running addon logged into different realm and same faction (Horde Proudmoore/Area 52), their btag should show up in appropriate column.
- The number of friend rows should match the number shown by the DT.
### Guild (X) 
- 
- 
> Local Guild Roster
- For this section of tests, ignore any character not logged into the same guild as you.
- The communication for this scenario is (invisible) local channel, so BNet friendship should not make a difference.
- Compare the list of logged in characters to a known good guild source (Blizz Guild UI, another Guild DT, etc.) Every logged in character should be accounted for.
- Validate all the information is accurate for the local guild members: name, race, if it's an alt that the correct alt name is shown, correct team name is shown, etc.
- Characters not running the addon will show up without spec, covenant or profession icons. These 2-4 icons help identify who is (not) running the addon because in the example of spec or covenant, Blizzard API only lets you query for your own. So if you are showing spec or covenenat information for characters not your own, that means that player's addon shared the information with you.
- BNet friends that are running the addon should show spec, covenant and profession icons. 
- Non-BNet friends that are running the addon should still show spec, covenant and profession icons.
> Same Realm/Faction But Not Same Guild
- For this section of tests, ignore any character logged into the same guild as you and any character from different realm or different faction.
- The communication for this scenario is (invisible) local channel, so BNet friendship should not make a difference.
- BNet friends that are running the addon should show spec, covenant and profession icons. 
- Non-BNet friends that are running the addon should still show spec, covenant and profession icons.
- Players not running the addon on same realm/faction but not same guild will not show up in Guild Roster view.
- Validate all the information is accurate: name, race, if it's an alt that the correct alt name is shown, correct team name is shown, etc.
> Two-way BNet Testing
- BNet communication is used whenever participants are on different factions or different realms. It is "invisible" to the participants much like the channels.
- This testing requires at least two testing participants.
- Your BNet friends that are running the addon should always show spec, covenant and profession icons if you are both logged into supported guilds.
- Test when you're both logged into the same realm but different factions.
- Test when you're both logged into same faction but different realms.
- Test when you're both logged into different faction and different realms.
- Non-BNet fall into the three and four way testing.
> Three-way BNet Testing
- This testing requires at least three testing participants.
1) You (person A) have a BNet friend (person B) logged into the same guild as the non-BNet friend (person C). You are not logged into that realm/faction.

        Person A is friends with Person B. Person A is logged into say EDK.
    
        Person B and Person C are logged into say EK.
    
        Person A is not friends with Person C.
        
        Test both Person B and C being friends, as well as Person B and C not being friends.
    
    Expected Outcome: All three participants should still see each other's characters in the guild roster view with spec, covenant and profession icons.
    
2) You (person A) have a BNet friend (person B) logged into the same realm/faction as the non-BNet friend (person C). You are not logged into that realm/faction.

        Person A is friends with Person B. Person A is logged into say EDK.
    
        Person B is logged into say AK2 and Person C is logged into say AK3.
    
        Person A is not friends with Person C.
        
        Test both Person B and C being friends, as well as Person B and C not being friends.
    
    Expected Outcome: All three participants should still see each other's characters in the guild roster view with spec, covenant and profession icons.
    
3) You (person A) have a BNet friend (person B) logged into the same realm but opposite faction as the non-BNet friend (person C). You are not logged into that realm/faction.

        Person A is friends with Person B. Person A is logged into say EKH.
    
        Person B is logged into say AK2 and Person C is logged into say EDK.
    
        Person A is not friends with Person C.
        
        Person B is friends with Person C.
    
    Expected Outcome: All three participants should still see each other's characters in the guild roster view with spec, covenant and profession icons. If Person B and Person C are not friends, only Person A/B will see each other. Person C will only see themselves.
    
4) You (person A) have a BNet friend (person B) logged into the different realm same faction as the non-BNet friend (person C). You are not logged into that realm/faction.

        Person A is friends with Person B. Person A is logged into say AK2.
    
        Person B is logged into say EDK and Person C is logged into say EKH.
    
        Person A is not friends with Person C.
        
        Person B is friends with Person C.
    
    Expected Outcome: All three participants should still see each other's characters in the guild roster view with spec, covenant and profession icons. If Person B and Person C are not friends, only Person A/B will see each other. Person C will only see themselves.
    
5) You (person A) have a BNet friend (person B) logged into the different realm different faction as the non-BNet friend (person C). You are not logged into that realm/faction.

        Person A is friends with Person B. Person A is logged into say EDK.
    
        Person B is logged into say EKH and Person C is logged into say EKA.
    
        Person A is not friends with Person C.
        
        Person B is friends with Person C.
    
    Expected Outcome: All three participants should still see each other's characters in the guild roster view with spec, covenant and profession icons. If Person B and Person C are not friends, only Person A/B will see each other. Person C will only see themselves
    
> Four-way BNet Testing
- This testing requires at least four testing participants.
1) You (person A) are not friends with any of the other participants but are logged into same realm/faction as person B.  Person B is friends with Person C. They are not logged into the same realm or faction. Person D is not friends with any of the participants but is logged into same realm/faction as person C.

        Person A is not friends with Person B/C/D. Person A is logged into say AK4.
    
        Person B and Person C are friends. Person B is logged into say EDK.
    
        Person C is logged into say AK2.
        
        Person D is not friends with Person A/B/C. Person D is logged into say AK3.
        
        Test both Person B and C being friends, as well as Person B and C not being friends.
    
    Expected Outcome: All four participants should still see each other's characters in the guild roster view with spec, covenant and profession icons.
        
### Soulbind (X) DT
> DT Text
- Shows the name of your currently active soulbind.
- Should show "No Covenant" if you have no covenant yet.
- DT should auto update the text whenever you switch covenants or soulbinds.
> Hover Cursor Over DT
- Shows your currently active soulbind and the other inactive soulbinds for your covenant.
- No covenant should show nothing.
- DT should auto update the text whenever you switch covenants or soulbinds.
> On Click
- Left click opens/closes the soulbind frame.
- Right click shows a menu of soulbinds for your current covenant.
- Selecting a soulbind from the menu should switch soulbinds.
