local XFG, G = unpack(select(2, ...))
local LogCategory = 'Config'

function XFG:ProfileConfig()
	XFG.Lib.Config:RegisterOptionsTable('XFaction Profiles', XFG.Lib.Profiler:GetOptionsTable(XFG.Config))
    XFG.Lib.ConfigDialog:AddToBlizOptions('XFaction Profiles', 'Profiles', 'XFaction')
end