local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, Engine = ...
local LogCategory = 'Initialize'

local CON = E.Libs.AceAddon:NewAddon(addon, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceTimer-3.0")

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
CON.Handlers = {}

function CON:Init()
	self.initialized = true
	
	CON.Confederate = Confederate:new()
	CON.Confederate:SetName('Eternal Kingdom')
	CON.Confederate:SetKey('EK')
	CON.Confederate:SetMainRealmName('Proudmoore')
	CON.Confederate:SetMainGuildName('Eternal Kingdom')
	
	CON.Player = {}
	CON.Player.GUID = UnitGUID('player')

	CON.Network = {}
	CON.Network.ChannelName = 'EKConfederate'
	CON.Network.Message = {}
	CON.Network.Message.Tag = 'EKCon'
	CON.Network.Message.Subject = {
		DATA = 'DATA',
		REQUEST = 'REQUEST'
	}
	CON.Network.Message.EncodeKey = {
		GI = "GuildIndex",
		N = "Name",
		GN = "GuildName",
		GR = "GuildRank",
		L = "Level",
		C = "Class",
		No = "Note",
		O = "Online",
		S = "Status",
		IM = "IsMobile",
		G = "GUID",
		TS = "TimeStamp",
		T = "Team",
		A = "Alt",
		RA = "RunningAddon",
		U = "Unit",
		RI = "RealmID",
		Z = "Zone"
	}
	CON.Network.Type = {
		BROADCAST = 'BROADCAST',
		WHISPER = 'WHISPER',
		BNET = 'BNET'
	}	
	CON.Network.Sender = Sender:new()
	CON.Network.Receiver = Receiver:new(); CON.Network.Receiver:Initialize()
	CON.Network.Channels = ChannelCollection:new(); CON.Network.Channels:Initialize()

	-- This handler will register additional handlers
	CON.Handlers.TimerEvent = TimerEvent:new(); CON.Handlers.TimerEvent:Initialize()

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

		if(_UnitData:IsPlayer()) then
			CON.Player.Unit = _UnitData
			CON.Player.Unit:Print()

			-- If player is on main realm/guild, this guild is source for motd
			if(CON.Confederate:GetMainRealmName() == CON.Player.Unit:GetRealmName() and 
			   CON.Confederate:GetMainGuildName() == CON.Player.Unit:GetGuildName()) then
				CON.Confederate:SetMOTD(GetGuildRosterMOTD())
			end

			local _Message = Message:new(); _Message:Initialize()
			_Message:SetType(CON.Network.Type.BROADCAST)
			_Message:SetSubject(CON.Network.Message.Subject.DATA)
			_Message:SetData(CON.Player.Unit)
			CON.Network.Sender:SendMessage(_Message)
		end
	end

	-- These event handlers have a dependency on player data being populated
	CON.Handlers.SpecEvent = SpecEvent:new(); CON.Handlers.SpecEvent:Initialize()
	CON.Handlers.CovenantEvent = CovenantEvent:new(); CON.Handlers.CovenantEvent:Initialize()
	CON.Handlers.SoulbindEvent = SoulbindEvent:new(); CON.Handlers.SoulbindEvent:Initialize()
	CON.Handlers.ProfessionEvent = ProfessionEvent:new(); CON.Handlers.ProfessionEvent:Initialize()
	CON.Handlers.GuildEvent = GuildEvent:new(); CON.Handlers.GuildEvent:Initialize()

	EP:RegisterPlugin(addon, CON.ConfigCallback)
end

E.Libs.EP:HookInitialize(CON, CON.Init)