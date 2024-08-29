local XF, G = unpack(select(2, ...))
local XFF = XF.Function

-- Time
XFF.TimeCurrent = GetServerTime
XFF.TimeLocal = C_DateAndTime.GetServerTimeLocal
XFF.TimeCalendar = C_DateAndTime.GetCurrentCalendarTime

-- Timer
XFF.TimerStart = C_Timer.NewTimer
XFF.RepeatTimerStart = C_Timer.NewTicker

-- Chat / Channel
XFF.ChatFrameFilter = ChatFrame_AddMessageEventFilter
XFF.ChatChannelColor = ChangeChatColor
XFF.ChatSwapChannels = C_ChatInfo.SwapChatChannelsByChannelIndex
XFF.ChatChannels = GetChannelList
XFF.ChatChannelInfo = C_ChatInfo.GetChannelInfoFromIdentifier
XFF.ChatJoinChannel = JoinChannelByName
XFF.ChatGetWindow = GetChatWindowMessages
XFF.ChatHandler = ChatFrame_MessageEventHandler
XFF.ChatRegister = C_ChatInfo.RegisterAddonMessagePrefix

-- Guild
XFF.GuildMembers = C_Club.GetClubMembers
XFF.GuildQueryServer = C_GuildInfo.GuildRoster
XFF.GuildInfo = C_Club.GetClubInfo
XFF.GuildStreams = C_Club.GetStreams
XFF.GuildMemberInfo = C_Club.GetMemberInfo
XFF.GuildMyInfo = C_Club.GetMemberInfoForSelf
XFF.GuildMyPermissions = C_GuildInfo.GuildControlGetRankFlags
XFF.GuildID = C_Club.GetGuildClubId
XFF.GuildFrame = ToggleGuildFrame
XFF.GuildMOTD = GetGuildRosterMOTD
XFF.GuildEditPermission = CanEditGuildInfo

-- Realm
XFF.RealmAPIName = GetNormalizedRealmName
XFF.RealmID = GetRealmID
XFF.RealmName = GetRealmName

-- Region
XFF.RegionCurrent = GetCurrentRegion

-- Spec
XFF.SpecGroupID = GetSpecialization
XFF.SpecID = GetSpecializationInfo
XFF.SpecHeroID = C_ClassTalents.GetActiveHeroTalentSpec

-- Player
XFF.PlayerIlvl = GetAverageItemLevel
XFF.PlayerAchievement = GetAchievementInfo
XFF.PlayerAchievementLink = GetAchievementLink
XFF.PlayerGUID = UnitGUID
XFF.PlayerIsInGuild = IsInGuild
XFF.PlayerIsInCombat = InCombatLockdown
XFF.PlayerIsInInstance = IsInInstance
XFF.PlayerFaction = UnitFactionGroup
XFF.PlayerPvPRating = GetPersonalRatedInfo
XFF.PlayerGuild = GetGuildInfo
XFF.PlayerZone = GetZoneText
XFF.PlayerSpellKnown = IsPlayerSpell
XFF.PlayerLocationID = C_Map.GetBestMapForUnit
XFF.LocationInfo = C_Map.GetMapInfo
XFF.PlayerName = UnitName
XFF.PlayerIsIgnored = C_FriendList.IsIgnoredByGuid

-- BNet
XFF.BNetPlayerInfo = BNGetInfo
XFF.BNetFriendCount = BNGetNumFriends
XFF.BNetFriendInfoByID = C_BattleNet.GetFriendAccountInfo
XFF.BNetFriendInfoByGUID = C_BattleNet.GetAccountInfoByGUID

-- Client
XFF.ClientVersion = GetBuildInfo
XFF.ClientAddonCount = C_AddOns.GetNumAddOns
XFF.ClientAddonInfo = C_AddOns.GetAddOnInfo
XFF.ClientIsAddonLoaded = C_AddOns.IsAddOnLoaded
XFF.ClientAddonState = C_AddOns.GetAddOnEnableState

-- UI
XFF.UIOptionsFrame = InterfaceOptionsFrame
XFF.UIOptionsFrameCategory = InterfaceOptionsFrame_OpenToCategory
XFF.UIIsMouseOver = MouseIsOver
XFF.UICreateLink = SetItemRef
XFF.UICreateFont = CreateFont
XFF.UIIsShiftDown = IsShiftKeyDown
XFF.UIIsCtrlDown = IsControlKeyDown
XFF.UISystemMessage = SendSystemMessage
XFF.UISystemSound = PlaySound
XFF.UICreateFont = CreateFont
XFF.UIToggleGuild = ToggleGuildFrame

-- Party
XFF.PartySendInvite = C_PartyInfo.InviteUnit
XFF.PartyRequestInvite = C_PartyInfo.RequestInviteFromUnit

-- Crafting
XFF.CraftingGetItem = C_TooltipInfo.GetRecipeResultItem

-- M+
XFF.MythicRequestMaps = C_MythicPlus.RequestMapInfo
XFF.MythicLevel = C_MythicPlus.GetOwnedKeystoneLevel
XFF.MythicMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID