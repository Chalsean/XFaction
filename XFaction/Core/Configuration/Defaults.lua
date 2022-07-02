local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

XFG.Defaults = {
    profile = {
        Channel = {
            Enable = false,
            Channels = {},
        },
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
            }
        },
        DataText = {
            Guild = {
                Label = false,
                GuildName = true,
                Confederate = true,
                MOTD = true,
                Achievement = false,
                Covenant = true,
                Dungeon = false,
                Faction = true,
                Guild = true,
                Level = true,
                Main = true,
                Note = false,
                Profession = true,
                Race = true,
                Rank = true,
                Realm = false,
                Spec = true,
                Team = true,
                Zone = true,
                Rank = true,
                Version = false,
                Sort = 'Team',
                Size = 350
            },
            Link = {
                Label = false,
                Faction = true
            }
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
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'Channel', XFG.Category, 'Channel')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'Chat', XFG.Category, 'Chat')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'DataText', XFG.Category, 'DataText')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'Support', XFG.Category, 'Support')
    XFG.Lib.ConfigDialog:AddToBlizOptions(XFG.Category, 'Profile', XFG.Category, 'Profile')

    XFG.Lib.Cmd:CreateChatCommand('xfaction', XFG.Category)
end

function XFG:InitProfile()
    -- When DB changes namespace (profile) the XFG.Config becomes invalid and needs to be reset
    XFG.Config = XFG.DataDB.profile
end