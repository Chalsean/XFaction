local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Defaults = {
    profile = {  
        Channels = {},      
        Chat = {
            GChat = {
                Enable = true,
                Faction = true,
                Guild = true,
                Main = true,
                FColor = false,
                CColor = false,
                Color = {
                    Red = 0.251,
                    Green = 1,
                    Blue = 0.251,
                },
                AColor = {
                    Red = 0.216,
                    Green = 0.553,
                    Blue = 0.937,
                },
                HColor = {
                    Red = 0.878,
                    Green = 0,
                    Blue = 0.051,
                },
            },
            Achievement = {
                Enable = true,
                Faction = true,
                Guild = true,
                Main = true,
                FColor = false,
                CColor = false,
                Color = {
                    Red = 0.251,
                    Green = 1,
                    Blue = 0.251,
                },
                AColor = {
                    Red = 0.216,
                    Green = 0.553,
                    Blue = 0.937,
                },
                HColor = {
                    Red = 0.878,
                    Green = 0,
                    Blue = 0.051,
                },
            },
            Login = {
                Enable = true,
                Sound = true,
                Faction = true,
                Guild = true,
                Main = true,
            },
            Channel = {
                Last = true,
                Color = true,
            },
        },
        Nameplates = {
            ElvUI = {
                Enable = true,
                ConfederateTag = '[confederate]',
                ConfederateInitialsTag = '[confederate:initials]',
                GuildInitialsTag = '[guild:initials]',
                MainTag = '[main]',
                MainParenthesisTag = '[main:parenthesis]',
                TeamTag = '[team]',
                MemberIcon = '[confederate:icon]',
            },
            Kui = {
                Enable = true,
                Icon = true,
                GuildName = 'Confederate',
                Hide = false,
            },
        },
        DataText = {
            Font = XFG.Lib.LSM:GetDefault('font'),
            FontSize = 10,
            Guild = {
                Column = '',
                Label = false,
                GuildName = true,
                Confederate = true,
                MOTD = true,
                Main = true,
                Enable = {                    
                    Achievement = false,
                    Dungeon = false,
                    Faction = true,
                    Guild = true,
                    Level = true,
                    Name = true,
                    Note = false,
                    Profession = true,
                    PvP = false,
                    Race = true,
                    Rank = true,
                    Realm = false,
                    Spec = true,
                    Team = true,
                    Zone = true,
                    Raid = true,
                    Version = false,
                    ItemLevel = false,
                },
                Order = {
                    AchievementOrder = 0,
                    DungeonOrder = 0,
                    FactionOrder = 1,
                    GuildOrder = 6,
                    ItemLevelOrder = 0,
                    LevelOrder = 2,
                    NameOrder = 4,
                    NoteOrder = 0,
                    ProfessionOrder = 11,
                    PvPOrder = 0,
                    RaceOrder = 5,
                    RaidOrder = 8,
                    RankOrder = 9,
                    RealmOrder = 0,
                    SpecOrder = 3,
                    TeamOrder = 7,
                    VersionOrder = 0,
                    ZoneOrder = 10,
                },
                Alignment = {
                    AchievementAlignment = 'Center',
                    FactionAlignment = 'Center',
                    GuildAlignment = 'Left',
                    ItemLevelAlignment = 'Center',
                    LevelAlignment = 'Center',
                    DungeonAlignment = 'Center',
                    NameAlignment = 'Left',
                    NoteAlignment = 'Left',
                    ProfessionAlignment = 'Center',
                    PvPAlignment = 'Center',
                    RaceAlignment = 'Left',
                    RaidAlignment = 'Center',
                    RankAlignment = 'Left',
                    RealmAlignment = 'Left',
                    SpecAlignment = 'Center',
                    TeamAlignment = 'Left',
                    VersionAlignment = 'Center',
                    ZoneAlignment = 'Center',
                },                
                Sort = 'Team',
                Size = 350,
            },
            Link = {
                Label = false,
                Faction = true,
            },
            Metric = {
                Rate = 60,
                Total = false,
                Average = true,
                Error = true,
                Warning = true,
            },
        },
        Debug = {
            Enable = false,
            Verbosity = 4,
            Instance = false,
        },
    }
}

function XFG:LoadConfigs()
    -- Get AceDB up and running as early as possible, its not available until addon is loaded
    XFG.ConfigDB = LibStub('AceDB-3.0'):New('XFConfigDB', XFG.Defaults)
    XFG.Config = XFG.ConfigDB.profile
    XFG.DebugFlag = XFG.Config.Debug.Enable

    -- Cache it because on shutdown, XFG.Config gets unloaded while we're still logging
    XFG.Cache.Verbosity = XFG.Config.Debug.Verbosity

    XFG.ConfigDB.RegisterCallback(self, 'OnProfileChanged', 'InitProfile')
    XFG.ConfigDB.RegisterCallback(self, 'OnProfileCopied', 'InitProfile')
    XFG.ConfigDB.RegisterCallback(self, 'OnProfileReset', 'InitProfile')

    XFG.Options.args.Profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(XFG.ConfigDB)
    XFG.Lib.Config:RegisterOptionsTable(XFG.Name, XFG.Options)
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, XFG.Name, nil, 'General')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Chat', XFG.Name, 'Chat')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Nameplates', XFG.Name, 'Nameplates')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'DataText', XFG.Name, 'DataText')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Support', XFG.Name, 'Support')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Debug', XFG.Name, 'Debug')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Name, 'Profile', XFG.Name, 'Profile')
end
    
function XFG:InitProfile()
    -- When DB changes namespace (profile) the XFG.Config becomes invalid and needs to be reset
    XFG.Config = XFG.ConfigDB.profile
end