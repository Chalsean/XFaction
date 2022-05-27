local XFG, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'NDecode'
local Initialized = false

-- Reconstruct a Unit object from the message
function XFG:DecodeMessage(inMessage)	
	
	local _Decoded = XFG.Lib.Encode:Decode(inMessage)
	local _Decompressed = XFG.Lib.Compress:DecompressHuffman(_Decoded)
	local _, _MessageData = XFG:Deserialize(_Decompressed)

	local _Message
	if(_MessageData.FG ~= nil) then
		_Message = GuildMessage:new()
	else
		_Message = Message:new()
	end	
	_Message:Initialize()
	
	if(_MessageData.K ~= nil) then	_Message:SetKey(_MessageData.K)	end
	if(_MessageData.To ~= nil) then	_Message:SetTo(_MessageData.To)	end
	if(_MessageData.F ~= nil) then _Message:SetFrom(_MessageData.F)	end	
	if(_MessageData.S ~= nil) then _Message:SetSubject(_MessageData.S) end
	if(_MessageData.Ty ~= nil) then	_Message:SetType(_MessageData.Ty) end	
	if(_MessageData.TS ~= nil) then	_Message:SetTimeStamp(_MessageData.TS) end	

	if(_Message.__name == 'GuildMessage') then
		if(_MessageData.FG ~= nil) then _Message:SetFromGUID(_MessageData.FG) end
		if(_MessageData.FN ~= nil) then _Message:SetFaction(XFG.Factions:GetFaction(_MessageData.FN)) end
		if(_MessageData.Fl ~= nil) then	_Message:SetFlags(_MessageData.Fl) end
		if(_MessageData.LI ~= nil) then	_Message:SetLineID(_MessageData.LI) end
	end

	if(_Message:GetSubject() == XFG.Network.Message.Subject.DATA) then
		local _UnitData = Unit:new()
		_UnitData:SetKey(_Message:GetFrom())
		_UnitData:SetGuildIndex(_MessageData.GI)
		_UnitData:SetName(_MessageData.N)
		_UnitData:SetGuildName(_MessageData.GN)
		_UnitData:SetLevel(_MessageData.L)
		_UnitData:SetNote(_MessageData.No)
		_UnitData:IsOnline(_MessageData.O == 1)
		_UnitData:IsMobile(_MessageData.M == 1)
		_UnitData:SetGUID(_MessageData.G)
		_UnitData:SetTimeStamp(_MessageData.TS)
		_UnitData:SetTeam(XFG.Teams:GetTeam(_MessageData.T))
		_UnitData:IsAlt(_MessageData.A == 1)
		_UnitData:IsRunningAddon(_MessageData.RA == 1)
		_UnitData:SetUnitName(_MessageData.U)
		_UnitData:SetRealmName(_MessageData.RN)
		_UnitData:SetZone(_MessageData.Z)
		_UnitData:SetFaction(XFG.Factions:GetFaction(_MessageData.Fa))
		_UnitData:SetClass(XFG.Classes:GetClass(_MessageData.C))
		_UnitData:SetRace(XFG.Races:GetRace(_MessageData.R))
		
		if(_MessageData.MN ~= nil) then 
			_UnitData:SetMainName(_MessageData.MN)
		end
		if(_MessageData.Co ~= nil) then
			_UnitData:SetCovenant(XFG.Covenants:GetCovenant(_MessageData.Co))
		end
		if(_MessageData.So ~= nil) then
			_UnitData:SetSoulbind(XFG.Soulbinds:GetSoulbind(_MessageData.So))
		end
		if(_MessageData.P1 ~= nil) then
			_UnitData:SetProfession1(XFG.Professions:GetProfession(_MessageData.P1))
		end
		if(_MessageData.P2 ~= nil) then
			_UnitData:SetProfession2(XFG.Professions:GetProfession(_MessageData.P2))
		end
		if(_MessageData.X ~= nil) then
			_UnitData:SetSpec(XFG.Specs:GetSpec(_MessageData.X))
		end
		-- if(_MessageData.GR ~= nil) then
		-- 	XFG:DataDumper(LogCategory, _MessageData.GR)
		-- 	if(XFG.Ranks:Contains(_MessageData.GR:GetKey()) == false) then
		-- 		XFG.Ranks:AddRank(_MessageData.GR)
		-- 	end
		-- 	_UnitData:SetRank(_MessageData.GR)
		-- end
		_Message:SetData(_UnitData)
	else
		_Message:SetData(_MessageData.Y)
	end

	return _Message
end