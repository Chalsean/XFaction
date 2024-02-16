local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Decode'
local Deflate = XF.Lib.Deflate
local ServerTime = GetServerTime
local RaiderIO = _G.RaiderIO

-- FIX: Move to Message class
local function DeserializeMessage(inObject, inCompressedData)
	local decompressed = Deflate:DecompressDeflate(inCompressedData)
	local messageData = unpickle(decompressed)
	inObject:Initialize()

	local unit = nil
	try(function()
		unit = XFO.Confederate:Pop()
		unit:Deserialize(messageData.F)
		inObject:SetFrom(unit)
	end).
	catch(function(inErrorMessage)
		XF:Warn(ObjectName, inErrorMessage)
		XFO.Confederate:Push(unit)
	end)

	if(messageData.K ~= nil) then inObject:SetKey(messageData.K)	end
	if(messageData.T ~= nil) then inObject:SetTo(messageData.T)	end
	if(messageData.S ~= nil) then inObject:SetSubject(messageData.S) end
	if(messageData.Y ~= nil) then inObject:SetType(messageData.Y) end	
	if(messageData.I ~= nil) then inObject:SetTimeStamp(messageData.I) end	
	if(messageData.A ~= nil) then inObject:SetRemainingTargets(messageData.A) end
	if(messageData.P ~= nil) then inObject:SetPacketNumber(messageData.P) end
	if(messageData.Q ~= nil) then inObject:SetTotalPackets(messageData.Q) end
	if(messageData.V ~= nil) then 
		local version = XF.Versions:Get(messageData.V)
		if(version == nil) then
			version = Version:new()
			version:SetKey(messageData.V)
			XF.Versions:Add(version)
		end
		inObject:SetVersion(version)
	end

	if(messageData.M ~= nil) then inObject:SetMainName(messageData.M) end
	if(messageData.U ~= nil) then inObject:SetUnitName(messageData.U) end
	if(messageData.N ~= nil) then 
		inObject:SetName(messageData.N) 
	elseif(messageData.U ~= nil) then
		inObject:SetName(inObject:GetUnitName())
	end
	if(messageData.H ~= nil and XF.Guilds:Contains(messageData.H)) then
		inObject:SetGuild(XF.Guilds:Get(messageData.H))
	elseif(messageData.R ~= nil and messageData.G ~= nil) then
		-- Remove this deprecated logic after everyone on 4.4
		inObject:SetGuild(XF.Guilds:GetByRealmGuildName(XF.Realms:GetByID(messageData.R), messageData.G))
	end		

	-- Leave any UnitData serialized for now
	inObject:SetData(messageData.D)
	return inObject
end