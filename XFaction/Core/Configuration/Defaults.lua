local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Defaults = {
    profile = {        
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
                    Blue = 0.251
                },
                AColor = {
                    Red = 0.216,
                    Green = 0.553,
                    Blue = 0.937
                },
                HColor = {
                    Red = 0.878,
                    Green = 0,
                    Blue = 0.051
                }
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
                    Blue = 0.251
                },
                AColor = {
                    Red = 0.216,
                    Green = 0.553,
                    Blue = 0.937
                },
                HColor = {
                    Red = 0.878,
                    Green = 0,
                    Blue = 0.051
                }
            },
            Login = {
                Enable = true,
                Sound = true,
                Faction = true,
                Guild = true,
                Main = true
            },
            ChannelLast = {
                Enable = true,
            },
        },
        DataText = {
            Guild = {
                Column = '',
                Label = false,
                GuildName = true,
                Confederate = true,
                MOTD = true,
                Main = true,
                Enable = {                    
                    Achievement = false,
                    Covenant = true,
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
                    CovenantOrder = 5,
                    DungeonOrder = 0,
                    FactionOrder = 1,
                    GuildOrder = 7,
                    ItemLevelOrder = 0,
                    LevelOrder = 2,
                    NameOrder = 4,
                    NoteOrder = 0,
                    ProfessionOrder = 12,
                    PvPOrder = 0,
                    RaceOrder = 6,
                    RaidOrder = 9,
                    RankOrder = 10,
                    RealmOrder = 0,
                    SpecOrder = 3,
                    TeamOrder = 8,
                    VersionOrder = 0,
                    ZoneOrder = 11,
                },
                Alignment = {
                    AchievementAlignment = 'Center',
                    CovenantAlignment = 'Center',
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
                Faction = true
            },
        }
    }
}
    
function XFG:LoadConfigs()
    XFG.DataDB.RegisterCallback(self, 'OnProfileChanged', 'InitProfile')
	XFG.DataDB.RegisterCallback(self, 'OnProfileCopied', 'InitProfile')
	XFG.DataDB.RegisterCallback(self, 'OnProfileReset', 'InitProfile')

    XFG.Options.args.Profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(XFG.DataDB)
    XFG.Lib.Config:RegisterOptionsTable(XFG.Category, XFG.Options)
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, XFG.Category, nil, 'General')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'Chat', XFG.Category, 'Chat')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'DataText', XFG.Category, 'DataText')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'Support', XFG.Category, 'Support')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'Debug', XFG.Category, 'Debug')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'Profile', XFG.Category, 'Profile')

    XFG.Lib.Cmd:CreateChatCommand('xfaction', XFG.Category)
end

function XFG:InitProfile()
    -- When DB changes namespace (profile) the XFG.Config becomes invalid and needs to be reset
    XFG.Config = XFG.DataDB.profile
end