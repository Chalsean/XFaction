local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
local LogCategory = 'Config'

XFG.Config = {
    Shard = {
        order = 101,
        name = "Shard",
        desc = "Identify which shard you are on for rare farming",
        args = {}
    },
	Soulbind = {
        order = 102,
        name = "Soulbind",
        desc = "Make it easier to bind souls to your will",
        args = {}
    },
	WoW_Token = {
        order = 103,
        name = "WoW Token",
        desc = "Current marketprice of WoW tokens",
        args = {}
    }
}

local tempString = strrep("Z", 11)
local tempString =
    E:TextGradient(tempString, 0.910, 0.314, 0.357, 0.976, 0.835, 0.431, 0.953, 0.925, 0.761, 0.078, 0.694, 0.671)

function XFG:ConfigCallback()

    E.Options.args.Confederation = {
        type = "group",
        childGroups = "tree",
        name = XFG.Title,
        args = {}
    }

    for category, info in pairs(XFG.Config) do
        E.Options.args.Confederation.args[category] = {
            order = info.order,
            type = "group",
            childGroups = "tab",
            name = info.name,
            desc = info.desc,
            icon = info.icon,
            args = info.args
        }
    end
end
