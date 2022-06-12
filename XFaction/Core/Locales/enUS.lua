local L = LibStub('AceLocale-3.0'):NewLocale('XFaction', 'enUS', true, false)

L['LANGUAGE'] = 'English'

--=========================================================================
-- Generic
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

--=========================================================================
-- DataText Specific
--=========================================================================
L['DT_HEADER'] = 'XFaction - DataText'
L['DT_HEADER_CONFEDERATE'] = 'Confederate: |cffffffff%s|r'
L['DT_HEADER_GUILD'] = 'Guild: |cffffffff%s|r'
-------------------------
-- DTGuild (X)
-------------------------
-- Broker name
L['DTGUILD_NAME'] = 'Guild (X)'
-- Config
L['DTGUILD_CONFIG_HEADER'] = '     Show Header Fields'
L['DTGUILD_CONFIG_CONFEDERATE_TOOLTIP'] = 'Show name of the confederate'
L['DTGUILD_CONFIG_GUILD_TOOLTIP'] = 'Show name of the current guild'
L['DTGUILD_CONFIG_MOTD_TOOLTIP'] = 'Show guild message-of-the-day'
L['DTGUILD_CONFIG_COLUMN_HEADER'] = '     Show Columns'
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
L['DTLINKS_CONFIG_FORCE_CHECK'] = 'Show Only Yours'
L['DTLINKS_CONFIG_FORCE_CHECK_TOOLTIP'] = 'Show only your active links'
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