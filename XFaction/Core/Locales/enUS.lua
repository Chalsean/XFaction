local L = LibStub('AceLocale-3.0'):NewLocale('XFaction', 'enUS', true, false)

--=========================================================================
-- Generic One Word Translations
--=========================================================================
L['NAME'] = 'Name'
L['RACE'] = 'Race'
L['LEVEL'] = 'Level'
L['REALM'] = 'Realm'
L['GUILD'] = 'Guild'
L['TEAM'] = 'Team'
L['RANK'] = 'Rank'
L['ZONE'] = 'Zone'
L['NOTE'] = 'Note'
L['COVENANT'] = 'Covenant'
L['CONFEDERATE'] = 'Confederate'
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
--=========================================================================
-- General (tab) Specific
--=========================================================================
L['GENERAL_DESCRIPTION'] = 'Enable roster visibility and communication between guilds of a confederation, including guilds on other realms and of a different faction.'
L['GENERAL_DISCLAIMER'] = 'This addon is in alpha stage and currently only Eternal Kingdom (EK) is being supported:'
L['GENERAL_WHAT'] = 'What is included'
L['GENERAL_GUILD_CHAT'] = '1. Merged guild chat across guilds/realms/factions in the confederate'
L['GENERAL_GUILD_CHAT_ACHIEVEMENT'] = '2. Personal achievements forwarded to confederate members in other guilds'
L['GENERAL_SYSTEM_MESSAGES'] = 'System Messages'
L['GENERAL_SYSTEM_LOGIN'] = '1. Receive notification when player using the addon comes online/offline in the confederate'
L['GENERAL_DATA_BROKERS'] = 'Data Brokers'
L['GENERAL_DTGUILD'] = '1. Guild (X): Full roster visibility in the confederate'
L['GENERAL_DTLINKS'] = '2. Links (X): Visibility of the active BNet links in the confederate used by the addon'
L['GENERAL_DTSOULBIND'] = '3. Soulbind (X): View and change your active soulbind'
L['GENERAL_DTTOKEN'] = '4. WoW Token (X): View current market price of WoW tokens'
--=========================================================================
-- Chat Specific
--=========================================================================
L['CHAT_GUILD'] = 'Guild Chat'
L['CHAT_GUILD_TOOLTIP'] = 'See cross realm/faction guild chat'
L['CHAT_FACTION'] = 'Show Faction'
L['CHAT_FACTION_TOOLTIP'] = 'Show the faction icon for the sender'
L['CHAT_GUILD_NAME'] = 'Show Guild Name'
L['CHAT_GUILD_NAME_TOOLTIP'] = 'Show the guild short name for the sender'
L['CHAT_MAIN'] = 'Show Main Name'
L['CHAT_MAIN_TOOLTIP'] = 'Show the senders main name if it is an alt'
L['CHAT_FONT_COLOR'] = 'Font Color'
L['CHAT_OFFICER'] = 'Officer Chat'
L['CHAT_OFFICER_TOOLTIP'] = 'See cross realm/faction officer chat'
L['CHAT_ACHIEVEMENT_TOOLTIP'] = 'See cross realm/faction individual achievements'
L['CHAT_ONLINE'] = 'Online/Offline'
L['CHAT_ONLINE_TOOLTIP'] = 'Show message for players logging in/out on other realms/faction'
--=========================================================================
-- DataText Specific
--=========================================================================
L['DT_HEADER_CONFEDERATE'] = 'Confederate: |cffffffff%s|r'
L['DT_HEADER_GUILD'] = 'Guild: |cffffffff%s|r'
-------------------------
-- DTGuild (X)
-------------------------
-- Broker name
L['DTGUILD_NAME'] = 'Guild (X)'
-- Config
L['DTGUILD_CONFIG_SORT'] = 'Default Sort Column'
L['DTGUILD_CONFIG_HEADER'] = 'Show Header Fields'
L['DTGUILD_CONFIG_CONFEDERATE_TOOLTIP'] = 'Show name of the confederate'
L['DTGUILD_CONFIG_GUILD_TOOLTIP'] = 'Show name of the current guild'
L['DTGUILD_CONFIG_MOTD_TOOLTIP'] = 'Show guild message-of-the-day'
L['DTGUILD_CONFIG_COLUMN_HEADER'] = 'Show Columns'
L['DTGUILD_CONFIG_COLUMN_COVENANT_TOOLTIP'] = 'Show players covenant icon'
L['DTGUILD_CONFIG_COLUMN_FACTION_TOOLTIP'] = 'Show players faction icon'
L['DTGUILD_CONFIG_COLUMN_GUILD_TOOLTIP'] = 'Show players guild name'
L['DTGUILD_CONFIG_COLUMN_LEVEL_TOOLTIP'] = 'Show players level'
L['DTGUILD_CONFIG_COLUMN_NOTE_TOOLTIP'] = 'Show players note'
L['DTGUILD_CONFIG_COLUMN_PROFESSION_TOOLTIP'] = 'Show players profession icons'
L['DTGUILD_CONFIG_COLUMN_RACE_TOOLTIP'] = 'Show players race'
L['DTGUILD_CONFIG_COLUMN_RANK_TOOLTIP'] = 'Show players rank'
L['DTGUILD_CONFIG_COLUMN_REALM_TOOLTIP'] = 'Show players realm name'
L['DTGUILD_CONFIG_COLUMN_SPEC_TOOLTIP'] = 'Show players spec icon'
L['DTGUILD_CONFIG_COLUMN_TEAM_TOOLTIP'] = 'Show players team name'
L['DTGUILD_CONFIG_COLUMN_ZONE_TOOLTIP'] = 'Show players current zone'
-------------------------
-- DTLinks (X)
-------------------------
-- Broker name
L['DTLINKS_NAME'] = 'Links (X)'
-- Header
L['DTLINKS_HEADER_LINKS'] = 'Active BNet Links: |cffffffff%d|r'
-- Config
L['DTLINKS_CONFIG_ONLY_YOURS'] = 'Show Only Yours'
L['DTLINKS_CONFIG_ONLY_YOURS_TOOLTIP'] = 'Show only your active links'
-------------------------
-- DTShard (X)
-------------------------
-- Broker name
L['DTSHARD_NAME'] = 'Shard (X)'
-- Broker text
L['DTSHARD_SHARD_ID'] = 'Shard: %d'
-- Config
L['DTSHARD_CONFIG_FORCE_CHECK'] = 'Force Check'
L['DTSHARD_CONFIG_FORCE_CHECK_TOOLTIP'] = 'Seconds between non-event shard checks'
-------------------------
-- DTSoulbind (X)
-------------------------
-- Broker name
L['DTSOULBIND_NAME'] = 'Soulbind (X)'
-- Broker text
L['DTSOULBIND_NO_COVENANT'] = 'No Covenant'
L['DTSOULBIND_NO_SOULBIND'] = '%s No Soulbind'
-- Header
L['DTSOULBIND_ACTIVE'] = '|cffFFFFFF%s: |cff00FF00Active|r'
L['DTSOULBIND_INACTIVE'] = '|cffFFFFFF%s: |cffFF0000Inactive|r'
-- Config
L['DTSOULBIND_CONFIG_CONDUIT'] = 'Show Conduits'
L['DTSOULBIND_CONFIG_CONDUIT_TOOLTIP'] = 'Show active conduit icons'
-- Footer
L['DTSOULBIND_LEFT_CLICK'] = '|cffFFFFFFLeft Click:|r Open Soulbind Frame'
L['DTSOULBIND_RIGHT_CLICK'] = '|cffFFFFFFRight Click:|r Change Soulbind'
-------------------------
-- DTToken (X)
-------------------------
-- Broker name
L['DTTOKEN_NAME'] = 'WoW Token (X)'
--=========================================================================
-- Support Specific
--=========================================================================
L['SUPPORT_UAT'] = 'User Acceptance Testing'