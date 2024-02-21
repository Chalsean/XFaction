local XF, G = unpack(select(2, ...))
local XFF = XF.Function

-- Time
XFF.TimeGetCurrent = GetServerTime

-- Chat
XFF.ChatFrameFilter = ChatFrame_AddMessageEventFilter

-- Guild
XFF.GuildGetMembers = C_Club.GetClubMembers
XFF.GuildQueryServer = C_GuildInfo.GuildRoster
XFF.GuildGetInfo = C_Club.GetClubInfo
XFF.GuildGetStreams = C_Club.GetStreams
XFF.GuildGetMember = C_Club.GetMemberInfo
XFF.GuildGetMyself = C_Club.GetMemberInfoForSelf
XFF.GuildGetPermissions = C_GuildInfo.GuildControlGetRankFlags

-- Realm
XFF.RealmGetAPIName = GetNormalizedRealmName
XFF.RealmGetID = GetRealmID
XFF.RealmGetName = GetRealmName

-- Region
XFF.RegionGetCurrent = GetCurrentRegion

-- Spec
XFF.SpecGetGroupID = GetSpecialization
XFF.SpecGetID = GetSpecializationInfo

-- PvP
XFF.PvPGetRating = GetPersonalRatedInfo

-- Unit
XFF.ItemGetIlvl = GetAverageItemLevel

-- BNet
XFF.BNetGetPlayerInfo = BNGetInfo