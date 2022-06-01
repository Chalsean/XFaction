local XFG, E, L, V, P, G = unpack(select(2, ...))
local LogCategory = 'NDecode'

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
		if(_MessageData.GSN ~= nil) then _Message:SetGuildShortName(_MessageData.GSN) end
		if(_MessageData.MN ~= nil) then	_Message:SetMainName(_MessageData.MN) end
	end

	if(_Message:GetSubject() == XFG.Network.Message.Subject.DATA or _Message:GetSubject() == XFG.Network.Message.Subject.LOGIN) then
		local _UnitData = XFG:ExtractTarball(_MessageData)
		_Message:SetData(_UnitData)
	else
		_Message:SetData(_MessageData.Y)
	end

	return _Message
end

function XFG:ExtractTarball(inTarball)
	local _UnitData = Unit:new()	
	_UnitData:SetGuildIndex(inTarball.GI)
	_UnitData:SetName(inTarball.N)	
	_UnitData:SetLevel(inTarball.L)
	_UnitData:SetNote(inTarball.No)
	_UnitData:IsOnline(inTarball.O == 1)
	_UnitData:IsMobile(inTarball.M == 1)
	_UnitData:SetGUID(inTarball.G)
	_UnitData:SetKey(inTarball.G)
	_UnitData:SetTimeStamp(inTarball.TS)
	_UnitData:SetTeam(XFG.Teams:GetTeam(inTarball.T))
	_UnitData:IsAlt(inTarball.A == 1)
	_UnitData:IsRunningAddon(inTarball.RA == 1)
	_UnitData:SetUnitName(inTarball.U)	
	_UnitData:SetZone(inTarball.Z)
	_UnitData:SetFaction(XFG.Factions:GetFaction(inTarball.Fa))
	_UnitData:SetClass(XFG.Classes:GetClass(inTarball.C))
	_UnitData:SetRace(XFG.Races:GetRace(inTarball.R))
	_UnitData:SetRealm(XFG.Realms:GetRealm(inTarball.RN))
	_UnitData:SetGuild(XFG.Guilds:GetGuildByFactionGuildName(_UnitData:GetFaction(), inTarball.GN))
	
	if(inTarball.MN ~= nil) then 
		_UnitData:SetMainName(inTarball.MN)
	end
	if(inTarball.Co ~= nil) then
		_UnitData:SetCovenant(XFG.Covenants:GetCovenant(inTarball.Co))
	end
	if(inTarball.So ~= nil) then
		_UnitData:SetSoulbind(XFG.Soulbinds:GetSoulbind(inTarball.So))
	end
	if(inTarball.P1 ~= nil) then
		_UnitData:SetProfession1(XFG.Professions:GetProfession(inTarball.P1))
	end
	if(inTarball.P2 ~= nil) then
		_UnitData:SetProfession2(XFG.Professions:GetProfession(inTarball.P2))
	end
	if(inTarball.X ~= nil) then
		_UnitData:SetSpec(XFG.Specs:GetSpec(inTarball.X))
	end

	-- There is no API to query for all guild ranks+names, so have to add them as you see them
	if(inTarball.GR) then
		if(XFG.Ranks:Contains(inTarball.GR) == false) then
        		local _NewRank = Rank:new()
        		_NewRank:SetKey(inTarball.GR)
        		_NewRank:SetID(inTarball.GR)
        		_NewRank:SetName(inTarball.GRN)
        		XFG.Ranks:AddRank(_NewRank)
    		end
		_UnitData:SetRank(XFG.Ranks:GetRank(inTarball.GR))
	end

	return _UnitData
end
