local XFG, E, L, V, P, G = unpack(select(2, ...))
local DT = E:GetModule('DataTexts')
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
        XFG:RegisterEvent('GUILD_ROSTER_UPDATE', self.CallbackRosterUpdate)
        XFG:Info(LogCategory, "Registered for GUILD_ROSTER_UPDATE events")
        XFG:RegisterEvent('PLAYER_GUILD_UPDATE', self.CallbackGQuit)
        XFG:Info(LogCategory, "Registered for PLAYER_GUILD_UPDATE events")
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
    local _TotalMembers, _, _OnlineMembers = GetNumGuildMembers()
    for i = 1, _TotalMembers do
        local _UnitData = Unit:new()
		_UnitData:Initialize(i)	
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
    DT:ForceUpdate_DataText(XFG.DataText.Guild.Name)
end

-- Fired when a player gets gkicked, gquits, etc.
function GuildEvent:CallbackGQuit()
    -- Notify users that you are "offline"
    local _NewMessage = LogoutMessage:new()
    _NewMessage:Initialize()
    _NewMessage:SetType(XFG.Network.Type.BROADCAST)
    _NewMessage:SetSubject(XFG.Network.Message.Subject.LOGOUT)
    if(XFG.Player.Unit:IsAlt() and XFG.Player.Unit:HasMainName()) then
        _NewMessage:SetMainName(XFG.Player.Unit:GetMainName())
    end
    _NewMessage:SetGuildID(XFG.Player.Guild:GetID())
    _NewMessage:SetUnitName(XFG.Player.Unit:GetUnitName())
    _NewMessage:SetData(' ')
    XFG.Network.Outbox:Send(_NewMessage)

    -- Lockdown addon
    XFG:CancelAllTimers()
    XFG.Network.Outbox:CanBroadcast(false)
    XFG.Network.BNet.Comm:CanBNet(false)
    XFG.Confederate:OfflineUnits(9999999999)
    XFG.Initialized = false
end