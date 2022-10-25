local L = LibStub('AceLocale-3.0'):NewLocale('XFaction', 'enUS', true, false)

--=========================================================================
-- Generic One Word Translations
--=========================================================================
L['NAME'] = 'Name'
L['RACE'] = 'Race'
L['LEVEL'] = 'Level'
L['REALM'] = 'Realm'
L['GUILD'] = 'Guild'
L['GUILD_NAME'] = 'Guild Name'
L['TEAM'] = 'Team'
L['RANK'] = 'Rank'
L['ZONE'] = 'Zone'
L['NOTE'] = 'Note'
L['CLASS'] = 'Class'
L['CONFEDERATE'] = 'Confederate'
L['COLLECTION'] = 'Collection'
L['MOTD'] = 'MOTD'
L['FACTION'] = 'Faction'
L['PROFESSION'] = 'Profession'
L['SPEC'] = 'Spec'
L['ENABLE'] = 'Enable'
L['CHAT'] = 'Chat'
L['ACHIEVEMENT'] = 'Achievement'
L['DATATEXT'] = 'DataText'
L['SUPPORT'] = 'Support'
L['RESOURCES'] = 'Resources'
L['DISCORD'] = 'Discord'
L['GITHUB'] = 'GitHub'
L['DEV'] = 'Development'
L['DESCRIPTION'] = 'Description'
L['GENERAL'] = 'General'
L['DISCLAIMER'] = 'Disclaimer'
L['TRANSLATIONS'] = 'Translations'
L['FAQ'] = 'FAQ'
L['CHANNEL'] = 'Channel'
L['INDEX'] = 'Index'
L['DUNGEON'] = 'Mythic+'
L['ACHIEVEMENT_EARNED'] = 'has earned the achievement'
L['CHAT_LOGOUT'] = 'has gone offline.'
L['CHAT_JOIN_GUILD'] = 'has joined the guild.'
L['CHAT_JOIN_CONFEDERATE'] = 'has joined the confederate.'
L['EXPLORE'] = 'Explore'
L['VERSION'] = 'Version'
L['MAIN'] = 'Main'
L['LABEL'] = 'Label'
L['LINKS'] = 'Links'
L['PM'] = 'Project Manager'
L['USAGE'] = 'Usage'
L['EVENT'] = 'Event'
L['FRIEND'] = 'Friend'
L['LINK'] = 'Link'
L['PLAYER'] = 'Player'
L['PROFESSION'] = 'Profession'
L['SPEC'] = 'Spec'
L['TARGET'] = 'Target'
L['TEAM'] = 'Team'
L['TIMER'] = 'Timer'
L['ITEMLEVEL'] = 'iLvl'
L['CENTER'] = 'Center'
L['LEFT'] = 'Left'
L['RIGHT'] = 'Right'
L['ALIGNMENT'] = 'Justification'
L['ORDER'] = 'Order'
L['RAID'] = 'Raid'
L['PVP'] = 'PvP'
L['NODE'] = 'Node'
L['ROSTER'] = 'Roster'
L['DEBUG'] = 'Debug'
L['CONTINENT'] = 'Continent'
L['ZONE'] = 'Zone'
L['SETUP'] = 'Setup'
L['COMPRESSION'] = 'Compression'
L['SAVE'] = 'Save'
L['FACTORY'] = 'Factory'
L['VERBOSITY'] = 'Verbosity'
L['RAIDERIO'] = 'RaiderIO'
--=========================================================================
-- General (tab) Specific
--=========================================================================
L['GENERAL_DESCRIPTION'] = 'Enable roster visibility and communication between guilds of a confederation, including guilds on other realms and of a different faction.'
L['GENERAL_DISCLAIMER'] = 'This addon is recently coming out of alpha and beta testing. There are still some things rough around the edges but it continues to be actively developed. If you have any questions, please reference the Support tab.'
L['GENERAL_WHAT'] = 'What is included'
L['GENERAL_GUILD_CHAT'] = '1. Merged guild chat across guilds/realms/factions in the confederate'
L['GENERAL_GUILD_CHAT_ACHIEVEMENT'] = '2. Personal achievements forwarded to confederate members in other guilds'
L['GENERAL_SYSTEM_MESSAGES'] = 'System Messages'
L['GENERAL_SYSTEM_LOGIN'] = '1. Receive notification when player using the addon comes online/offline in the confederate'
L['GENERAL_DATA_BROKERS'] = 'Data Brokers'
L['GENERAL_DTGUILD'] = '1. Guild (X): Full roster visibility in the confederate'
L['GENERAL_DTLINKS'] = '2. Links (X): Visibility of the active BNet links in the confederate used by the addon'
L['GENERAL_DTMETRICS'] = '3. Metrics (X): Displays statistical information about addon performance'
L['GENERAL_DTTOKEN'] = '4. WoW Token (X): View current market price of WoW tokens'
--=========================================================================
-- Channel Specific
--=========================================================================
L['CHANNEL_LAST'] = 'Addon Channel Last'
L['CHANNEL_LAST_TOOLTIP'] = 'XFaction will ensure its channel is always last in the channel list. It will ignore community channels, as there is a bug with Blizz API.'
L['CHANNEL_COLOR'] = 'Color Channels By Name'
L['CHANNEL_COLOR_TOOLTIP'] = 'Switches from Blizzard default of coloring by # to ID'
--=========================================================================
-- Chat Specific
--=========================================================================
L['CHAT_CCOLOR'] = 'Customize Color'
L['CHAT_CCOLOR_TOOLTIP'] = 'Customize XFaction chat colors.'
L['CHAT_GUILD_DESCRIPTION'] = 'These options control how the guild chat messages are displayed to the chat frame.'
L['CHAT_GUILD'] = 'Guild Chat'
L['CHAT_GUILD_TOOLTIP'] = 'See cross realm/faction guild chat'
L['CHAT_FACTION'] = 'Show Faction'
L['CHAT_FACTION_TOOLTIP'] = 'Show the faction icon for the sender'
L['CHAT_FCOLOR'] = 'Factionize Color'
L['CHAT_FCOLOR_TOOLTIP'] = 'Render XFaction chat in faction colors.'
L['CHAT_GUILD_NAME'] = 'Show Guild Name'
L['CHAT_GUILD_NAME_TOOLTIP'] = 'Show the guild short name for the sender'
L['CHAT_MAIN'] = 'Show Main Name'
L['CHAT_MAIN_TOOLTIP'] = 'Show the senders main name if it is an alt'
L['CHAT_FONT_COLOR'] = 'Font Color'
L['CHAT_FONT_ACOLOR'] = 'Alliance Color'
L['CHAT_FONT_HCOLOR'] = 'Horde Color'
L['CHAT_ACHIEVEMENT_DESCRIPTION'] = 'These options control how the guild achievement messages are displayed to the chat frame.'
L['CHAT_ACHIEVEMENT_TOOLTIP'] = 'See cross realm/faction individual achievements'
L['CHAT_ONLINE'] = 'Online/Offline'
L['CHAT_ONLINE_DESCRIPTION'] = 'These options control the guild members login/logout system messages.'
L['CHAT_ONLINE_TOOLTIP'] = 'Show message for players logging in/out on other realms/faction'
L['CHAT_ONLINE_SOUND'] = 'Play Sound'
L['CHAT_ONLINE_SOUND_TOOLTIP'] = 'Play sound when any confederate member comes online'
L['CHAT_LOGIN'] = 'has come online.'
L['CHAT_LOGOUT'] = 'has gone offline.'
L['CHAT_ACHIEVEMENT'] = 'has earned the achievement'
L['CHAT_NO_PLAYER_FOUND'] = 'No player named '
L['CHAT_CHANNEL_DESCRIPTION'] = 'These options control the addon custom channel behaviours.'
--=========================================================================
-- Nameplates Specific
--=========================================================================
L['NAMEPLATES'] = 'Nameplates'
L['CONFEDERATE_INITIALS'] = 'Confederate Initials'
L['CONFEDERATE_NAME'] = 'Confederate Name'
L['GUILD_INITIALS'] = 'Guild Initials'
L['NAMEPLATE_GUILD_NAME_TOOLTIP'] = 'Replace guild name with the selected option if the guild is in the confederate'
L['ELVUI'] = 'ElvUI'
L['NAMEPLATE_ELVUI_DESCRIPTION'] = 'Add oUF tags that can be used in ElvUI UnitFrames. Note the other player needs to be running XFaction in order for this to work properly.'
L['NAMEPLATE_ELVUI_CONFEDERATE'] = 'Name of the confederate'
L['NAMEPLATE_ELVUI_CONFEDERATE_INITIALS'] = 'Initials of the confederate'
L['NAMEPLATE_ELVUI_GUILD_INITIALS'] = 'Initials of the guild within the confederate'
L['NAMEPLATE_ELVUI_MAIN'] = "Name of the player's main raiding character"
L['NAMEPLATE_ELVUI_MAIN_PARENTHESIS'] = "Name of the player's main raiding character in (parenthesis)"
L['NAMEPLATE_ELVUI_TEAM'] = "Name of the player's raid team"
L['NAMEPLATE_ELVUI_MEMBER_ICON'] = 'Icon to represent whether the player is a member of the confederate'
L['KUI'] = 'Kui'
L['NAMEPLATE_KUI_DESCRIPTION'] = 'Options to change Kui nameplates information. Upon selection, you will need to reload your UI to see the changes.'
L['NAMEPLATE_ICON'] = 'Member Icon'
L['NAMEPLATE_ICON_TOOLTIP'] = 'Display an icon next to confederate members name'
L['NAMEPLATE_PLAYER_MAIN'] = 'Main Name'
L['NAMEPLATE_PLAYER_MAIN_TOOLTIP'] = "Append player's main raiding name to unit name"
L['NAMEPLATE_GUILD_HIDE'] = 'Hide Non-Confederate'
L['NAMEPLATE_GUILD_HIDE_TOOLTIP'] = 'Hide non-confederate guild tags'
--=========================================================================
-- DataText Specific
--=========================================================================
L['DT_HEADER_CONFEDERATE'] = 'Confederate: |cffffffff%s|r'
L['DT_HEADER_GUILD'] = 'Guild: |cffffffff%s|r'
L['DT_CONFIG_BROKER'] = 'Show Broker Fields'
L['DT_CONFIG_LABEL_TOOLTIP'] = 'Show broker label'
L['DT_CONFIG_FACTION_TOOLTIP'] = 'Show faction counts in broker label'
L['DT_CONFIG_FONT'] = 'Font'
L['DT_CONFIG_FONT_SIZE'] = 'Font Size'
L['DT_CONFIG_FONT_TOOLTIP'] = 'Select font style'
L['DT_CONFIG_FONT_SIZE_TOOLTIP'] = 'Select font size'
L['DTGENERAL_DESCRIPTION'] = 'Settings that will apply to all XFaction data brokers'
-------------------------
-- DTGuild (X)
-------------------------
-- Broker name
L['DTGUILD_NAME'] = 'Guild (X)'
L['DTGUILD_DESCRIPTION'] = 'Guild data broker displays complete confederate roster.'
-- Config
L['DTGUILD_BROKER_HEADER'] = 'Broker Settings'
L['DTGUILD_SELECT_COLUMN'] = 'Select Column'
L['DTGUILD_SELECT_COLUMN_TOOLTIP'] = 'Select column from list to make adjustments to'
L['DTGUILD_CONFIG_SORT'] = 'Default Sort Column'
L['DTGUILD_CONFIG_HEADER'] = 'Header Settings'
L['DTGUILD_CONFIG_SIZE'] = 'Window Size'
L['DTGUILD_CONFIG_CONFEDERATE_TOOLTIP'] = 'Show name of the confederate'
L['DTGUILD_CONFIG_CONFEDERATE_DISABLED'] = 'Must have at least five columns enabled'
L['DTGUILD_CONFIG_GUILD_TOOLTIP'] = 'Show name of the current guild'
L['DTGUILD_CONFIG_MOTD_TOOLTIP'] = 'Show guild message-of-the-day'
L['DTGUILD_CONFIG_COLUMN_HEADER'] = 'Column Settings'
L['DTGUILD_CONFIG_COLUMN_ENABLE_MAIN'] = 'Append Main To Name'
L['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_TOOLTIP'] = 'Show player total achievement points'
L['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_ORDER_TOOLTIP'] = 'Column number the achievement points will be displayed in'
L['DTGUILD_CONFIG_COLUMN_ACHIEVEMENT_ALIGNMENT_TOOLTIP'] = 'Achievement points text justification'
L['DTGUILD_CONFIG_COLUMN_DUNGEON_TOOLTIP'] = 'Show player mythic+ score'
L['DTGUILD_CONFIG_COLUMN_DUNGEON_ORDER_TOOLTIP'] = 'Column number the mythic+ rating will be displayed in'
L['DTGUILD_CONFIG_COLUMN_DUNGEON_ALIGNMENT_TOOLTIP'] = 'Mythic+ rating text justification'
L['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'] = 'Show player faction icon'
L['DTGUILD_CONFIG_COLUMN_FACTION_ORDER_TOOLTIP'] = 'Column number the faction icon will be displayed in'
L['DTGUILD_CONFIG_COLUMN_FACTION_ALIGNMENT_TOOLTIP'] = 'Faction icon alignment within the column'
L['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'] = 'Show player guild name'
L['DTGUILD_CONFIG_COLUMN_GUILD_ORDER_TOOLTIP'] = 'Column number the guild name will be displayed in'
L['DTGUILD_CONFIG_COLUMN_GUILD_ALIGNMENT_TOOLTIP'] = 'Guild name text justification'
L['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_TOOLTIP'] = 'Show player max item level'
L['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_ORDER_TOOLTIP'] = 'Column number the max item level will be displayed in'
L['DTGUILD_CONFIG_COLUMN_ITEMLEVEL_ALIGNMENT_TOOLTIP'] = 'Item level text justification'
L['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'] = 'Show player level'
L['DTGUILD_CONFIG_COLUMN_LEVEL_ORDER_TOOLTIP'] = 'Column number the players level will be displayed in'
L['DTGUILD_CONFIG_COLUMN_LEVEL_ALIGNMENT_TOOLTIP'] = 'Player level text justification'
L['DTGUILD_CONFIG_COLUMN_MAIN_TOOLTIP'] = 'Show player main name if on alt'
L['DTGUILD_CONFIG_COLUMN_NAME_ORDER_TOOLTIP'] = 'Column number the player name will be displayed in'
L['DTGUILD_CONFIG_COLUMN_NAME_ALIGNMENT_TOOLTIP'] = 'Player name text justification'
L['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'] = 'Show player note'
L['DTGUILD_CONFIG_COLUMN_NOTE_ORDER_TOOLTIP'] = 'Column number the player note will be displayed in'
L['DTGUILD_CONFIG_COLUMN_NOTE_ALIGNMENT_TOOLTIP'] = 'Player note text justification'
L['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'] = 'Show player profession icons'
L['DTGUILD_CONFIG_COLUMN_PROFESSION_ORDER_TOOLTIP'] = 'Column number the profession icons will be displayed in'
L['DTGUILD_CONFIG_COLUMN_PROFESSION_ALIGNMENT_TOOLTIP'] = 'Profession icons alignment within the column'
L['DTGUILD_CONFIG_COLUMN_PVP_TOOLTIP'] = 'Show player highest PvP score'
L['DTGUILD_CONFIG_COLUMN_PVP_ORDER_TOOLTIP'] = 'Column number the PvP score will be displayed in'
L['DTGUILD_CONFIG_COLUMN_PVP_ALIGNMENT_TOOLTIP'] = 'PvP score text justification'
L['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'] = 'Show player race'
L['DTGUILD_CONFIG_COLUMN_RACE_ORDER_TOOLTIP'] = 'Column number the player race will be displayed in'
L['DTGUILD_CONFIG_COLUMN_RACE_ALIGNMENT_TOOLTIP'] = 'Player race text justification'
L['DTGUILD_CONFIG_COLUMN_RAID_TOOLTIP'] = 'Show player highest raid progress'
L['DTGUILD_CONFIG_COLUMN_RAID_ORDER_TOOLTIP'] = 'Column number the player raid progress will be displayed in'
L['DTGUILD_CONFIG_COLUMN_RAID_ALIGNMENT_TOOLTIP'] = 'Player raid progress text justification'
L['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'] = 'Show player rank'
L['DTGUILD_CONFIG_COLUMN_RANK_ORDER_TOOLTIP'] = 'Column number the player rank will be displayed in'
L['DTGUILD_CONFIG_COLUMN_RANK_ALIGNMENT_TOOLTIP'] = 'Player rank text justification'
L['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'] = 'Show player realm name'
L['DTGUILD_CONFIG_COLUMN_REALM_ORDER_TOOLTIP'] = 'Column number the player realm name will be displayed in'
L['DTGUILD_CONFIG_COLUMN_REALM_ALIGNMENT_TOOLTIP'] = 'Player realm name text justification'
L['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'] = 'Show player spec icon'
L['DTGUILD_CONFIG_COLUMN_SPEC_ORDER_TOOLTIP'] = 'Column number the spec icon will be displayed in'
L['DTGUILD_CONFIG_COLUMN_SPEC_ALIGNMENT_TOOLTIP'] = 'Spec icon alignment within the column'
L['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'] = 'Show player team name'
L['DTGUILD_CONFIG_COLUMN_TEAM_ORDER_TOOLTIP'] = 'Column number the player team name will be displayed in'
L['DTGUILD_CONFIG_COLUMN_TEAM_ALIGNMENT_TOOLTIP'] = 'Player team name text justification'
L['DTGUILD_CONFIG_COLUMN_VERSION_TOOLTIP'] = 'Show player XFaction version'
L['DTGUILD_CONFIG_COLUMN_VERSION_ORDER_TOOLTIP'] = 'Column number the player XFaction version will be displayed in'
L['DTGUILD_CONFIG_COLUMN_VERSION_ALIGNMENT_TOOLTIP'] = 'Player XFaction version text justification'
L['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'] = 'Show player current zone'
L['DTGUILD_CONFIG_COLUMN_ZONE_ORDER_TOOLTIP'] = 'Column number the player zone will be displayed in'
L['DTGUILD_CONFIG_COLUMN_ZONE_ALIGNMENT_TOOLTIP'] = 'Player zone text justification'
L['DTGUILD_CONFIG_SORT_TOOLTIP'] = 'Select the default sort column'
L['DTGUILD_CONFIG_SIZE_TOOLTIP'] = 'Select the maximum height of the window before it starts scrolling'
--=========================================================================
-- Confederate Specific
--=========================================================================
L['CONFEDERATE_CONFIG_BUILDER'] = 'Config Builder'
L['CONFEDERATE_GENERATE'] = 'Generate'
L['CONFEDERATE_LOAD'] = 'Load'
-------------------------
-- DTLinks (X)
-------------------------
-- Broker name
L['DTLINKS_NAME'] = 'Links (X)'
L['DTLINKS_DESCRIPTION'] = 'Links data broker displays all active BNet links the addon is currently using.'
-- Header
L['DTLINKS_HEADER_LINKS'] = 'Active BNet Links: |cffffffff%d|r'
-------------------------
-- DTToken (X)
-------------------------
-- Broker name
L['DTTOKEN_NAME'] = 'WoW Token (X)'
-------------------------
-- DTMetrics
-------------------------
L['DTMETRICS_NAME'] = 'Metrics (X)'
L['DTMETRICS_DESCRIPTION'] = 'Metrics data broker displays statistical information about XFaction performance.'
L['DTMETRICS_HEADER'] = 'Metrics Since: |cffffffff%02d:%02d|r (Server)'
L['DTMETRICS_RATE'] = 'Average Rate'
L['DTMETRICS_RATE_TOOLTIP'] = '1 is average per second, 60 is average per minute, etc.'
L['DTMETRICS_HEADER_METRIC'] = 'Metric'
L['DTMETRICS_HEADER_TOTAL'] = 'Total'
L['DTMETRICS_HEADER_AVERAGE'] = 'Average'
L['DTMETRICS_MESSAGES'] = 'Total Received'
L['DTMETRICS_BNET_FORWARD'] = 'BNet Forward'
L['DTMETRICS_BNET_SEND'] = 'BNet Send'
L['DTMETRICS_BNET_RECEIVE'] = 'BNet Receive'
L['DTMETRICS_CHANNEL_RECEIVE'] = 'Local Receive'
L['DTMETRICS_CHANNEL_SEND'] = 'Local Send'
L['DTMETRICS_CHANNEL_FORWARD'] = 'Local Forward'
L['DTMETRICS_WARNING'] = 'Warning'
L['DTMETRICS_ERROR'] = 'Error'
L['DTMETRICS_CONFIG_TOTAL'] = 'Total Messages'
L['DTMETRICS_CONFIG_TOTAL_TOOLTIP'] = 'Display the total # of messages received'
L['DTMETRICS_CONFIG_AVERAGE'] = 'Average Messages'
L['DTMETRICS_CONFIG_AVERAGE_TOOLTIP'] = 'Display the average # of messages received'
L['DTMETRICS_CONFIG_ERROR'] = 'Total Errors'
L['DTMETRICS_CONFIG_ERROR_TOOLTIP'] = 'Display the total # of errors encountered'
L['DTMETRICS_CONFIG_WARNING'] = 'Total Warnings'
L['DTMETRICS_CONFIG_WARNING_TOOLTIP'] = 'Display the total # of warnings encountered'
--=========================================================================
-- Support Specific
--=========================================================================
L['SUPPORT_UAT'] = 'User Acceptance Testing'
L['DEBUG_PRINT'] = 'Click any button to ad-hoc print that datacollection to _DebugLog'
L['DEBUG_ROSTER_TOOLTIP'] = 'Whether all confederate members send roster information'
L['NEW_VERSION'] = '%s: A newer version is available, please consider updating'
L['DEBUG_LOG'] = 'Debug Logging'
L['DEBUG_LOG_ENABLE'] = 'Enable/Disable logging output to _DebugLog addon'
L['FACTORY_MESSAGE'] = 'Factory (Message)'
L['FACTORY_GUILD_MESSAGE'] = 'Factory (GMessage)'
L['FACTORY_NODE'] = 'Factory (Node)'
L['FACTORY_UNIT'] = 'Factory (Unit)'
L['FACTORY_LINK'] = 'Factory (Link)'
L['FACTORY_FRIEND'] = 'Factory (Friend)'
L['DEBUG_VERBOSITY_TOOLTIP'] = 'Level of verbosity addon will log at'
L['DEBUG_LOG_INSTANCE'] = 'Log Instance'
L['DEBUG_LOG_INSTANCE_TOOLTIP'] = 'Unchecked means it will disable logging while player is in an instance'