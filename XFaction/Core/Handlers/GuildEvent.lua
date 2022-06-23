local XFG, G = unpack(select(2, ...))
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
        -- This is the local guild roster scan for those not running the addon
        XFG:CreateEvent('Roster', 'GUILD_ROSTER_UPDATE', XFG.Handlers.GuildEvent.CallbackRosterUpdate, true, false)
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
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
end

-- The event doesn't tell you what has changed, only that something has changed
function GuildEvent:CallbackRosterUpdate()
    for _, _MemberID in pairs (C_Club.GetClubMembers(XFG.Player.Guild:GetID(), XFG.Player.Guild:GetStreamID())) do
        local _UnitData = Unit:new()
		_UnitData:Initialize(_MemberID)	
        if(_UnitData:IsOnline()) then

            -- If cache doesn't have unit, process
            if(XFG.Confederate:Contains(_UnitData:GetKey()) == false) then
                XFG.Confederate:AddUnit(_UnitData)
            else
                local _CachedUnitData = XFG.Confederate:GetUnit(_UnitData:GetKey())
                -- If the player is running addon, do not process
                if(_CachedUnitData:IsRunningAddon() == false and _CachedUnitData:Equals(_UnitData) == false) then         
                    XFG.Confederate:AddUnit(_UnitData)
                end
            end
        elseif(_UnitData:GetKey() ~= nil and XFG.Confederate:Contains(_UnitData:GetKey())) then
            XFG.Confederate:RemoveUnit(_UnitData:GetKey())
        end
    end
end