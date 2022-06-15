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
                Color = {
                    Red = 1,
                    Green = 1,
                    Blue = 1
                }
            },
            Achievement = {
                Enable = true,
                Faction = true,
                Guild = true,
                Main = true,
                Color = {
                    Red = 1,
                    Green = 1,
                    Blue = 1
                }
            },
            Login = {
                Enable = true,
                Sound = true
            }
        },
        DataText = {
            Guild = {
                GuildName = true,
                Confederate = true,
                MOTD = true,
                Covenant = true,
                Faction = true,
                Guild = true,
                Level = true,
                Note = false,
                Profession = true,
                Race = true,
                Rank = true,
                Realm = false,
                Spec = true,
                Team = true,
                Zone = true
            },
            Links = {
                OnlyMine = false
            },
            Shard = {
                Timer = 60
            },
            Soulbind = {
                Conduits = false
            }
        }
    }
}
    
function XFG:LoadConfigs()
    XFG.DataDB.RegisterCallback(self, 'OnProfileChanged', 'InitProfile')
	XFG.DataDB.RegisterCallback(self, 'OnProfileCopied', 'InitProfile')
	XFG.DataDB.RegisterCallback(self, 'OnProfileReset', 'InitProfile')

    XFG.Options.args.Profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(XFG.DataDB)
    XFG.Lib.Config:RegisterOptionsTable('XFaction', XFG.Options)
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction', 'XFaction', nil, 'General')
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction', 'Chat', 'XFaction', 'Chat')
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction', 'DataText', 'XFaction', 'DataText')
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction', 'Support', 'XFaction', 'Support')
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction', 'Profile', 'XFaction', 'Profile')
end

function XFG:InitProfile()
    -- When DB changes namespace (profile) the XFG.Config becomes invalid and needs to be reset
    XFG.Config = XFG.DataDB.profile
end