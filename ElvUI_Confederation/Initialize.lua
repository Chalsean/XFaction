local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, Engine = ...
local LogCategory = 'Initialize'

local CON = E.Libs.AceAddon:NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0")

Engine[1] = CON
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[addon] = Engine

CON.Category = 'Confederation'
CON.Config = {}
CON.Title = format('|cff33ccff%s|r', 'Confederation')
CON["RegisteredModules"] = {}
CON.Version = tonumber(GetAddOnMetadata(addon, "Version"))

function CON:Init()
	self.initialized = true
	
	CON.Confederate = Confederate:new()
	CON.Confederate:SetName('Eternal Kingdom')
	CON.Confederate:SetKey('EK')
	CON.PlayerGUID = UnitGUID('player')

	-- Lua doesn't have static variables, so need global caches to reduce memory footprint
	CON.Races = RaceCollection:new(); CON.Races:Initialize()	
	CON.Classes = ClassCollection:new(); CON.Classes:Initialize()
	CON.Specs = SpecCollection:new(); CON.Specs:Initialize()
	CON.Covenants = CovenantCollection:new(); CON.Covenants:Initialize()
	CON.Soulbinds = SoulbindCollection:new(); CON.Soulbinds:Initialize()
	CON.Professions = ProfessionCollection:new(); CON.Professions:Initialize()	

	CON:Info(LogCategory, "Initializing local guild roster cache")
	local _TotalMembers, _, _OnlineMembers = GetNumGuildMembers()
	
	for i = 1, _TotalMembers do
		-- Until I can figure out how to hook the constructors, will have to call init explicitly
		local _UnitData = Unit:new()
		_UnitData:Initialize(i)
		CON.Confederate:AddUnit(_UnitData)
	end

	--CON.Confederate:ShallowPrint()
	CON.Confederate:PrintTeam()

	--CON:GuildInitialize()

	--E.db.Confederation.Data.CurrentRealm.Name = GetRealmName()	
	--E.db.Confederation.Data.PlayerGUID = UnitGUID('player')

	--if(E.db.Confederation.Data.CurrentRealm.Name == 'Proudmoore') then
	--	E.db.Confederation.Data.CurrentRealm.ID = 5
	--elseif(E.db.Confederation.Data.CurrentRealm.Name == 'Area 52') then
		-- this bnet realm id does not match in-game realm id, no idea why
		-- its forcing some hardcoding until i can find a solution
	--	E.db.Confederation.Data.CurrentRealm.ID = 3676
	--end

	EP:RegisterPlugin(addon, CON.ConfigCallback)
end

E.Libs.EP:HookInitialize(CON, CON.Init)