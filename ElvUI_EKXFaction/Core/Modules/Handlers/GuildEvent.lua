local EKX, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'
local LogCategory = 'HEGuild'

GuildEvent = {}

function GuildEvent:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = inObject
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject == true) then
        self._Initialized = false
    end

    return Object
end

function GuildEvent:Initialize()
	if(self:IsInitialized() == false) then
		EKX:RegisterEvent('GUILD_MOTD', self.CallbackMOTD)
        EKX:Info(LogCategory, "Registered for GUILD_MOTD events")
        EKX:RegisterEvent('GUILD_ROSTER_UPDATE', self.CallbackRosterUpdate)
        EKX:Info(LogCategory, "Registered for GUILD_ROSTER_UPDATE events")
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function GuildEvent:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function GuildEvent:Print()
    EKX:SingleLine(LogCategory)
    EKX:Debug(LogCategory, ObjectName .. " Object")
    EKX:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

function GuildEvent:CallbackMOTD(inMOTD)
    if(EKX.Guild:GetMOTD() ~= inMOTD) then
        EKX.Guild:SetMOTD(inMOTD)
    end
end

-- The event doesn't tell you what has changed, only that something has changed
function GuildEvent:CallbackRosterUpdate()
    local _TotalMembers, _, _OnlineMembers = GetNumGuildMembers()
    for i = 1, _TotalMembers do
        local _UnitData = Unit:new()
		_UnitData:Initialize(i)	

        -- If cache doesn't have unit, process
        if(EKX.Guild:Contains(_UnitData:GetKey()) == false) then
            EKX.Guild:AddUnit(_UnitData)
        else
            local _CachedUnitData = EKX.Guild:GetUnit(_UnitData:GetKey())

            -- Detect members going offline
            if(_CachedUnitData:IsOnline() and _UnitData:IsOffline()) then
                EKX.Guild:AddUnit(_UnitData)

            -- Detect members coming online
            elseif(_CachedUnitData:IsOffline() and _UnitData:IsOnline()) then
                EKX.Guild:AddUnit(_UnitData)

            -- Detect staying online, need to check for changes for broadcast to peer guilds
            elseif(_UnitData:IsPlayer() and _CachedUnitData:Equals(_UnitData) == false) then
                EKX.Guild:AddUnit(_UnitData)
                EKX.Network.Sender:BroadcastUnitData(_UnitData)

            elseif(_UnitData:IsOnline() and _UnitData:IsRunningAddon() == false and _CachedUnitData:Equals(_UnitData) == false) then         
                EKX.Guild:AddUnit(_UnitData)
            end
        end
    end
end