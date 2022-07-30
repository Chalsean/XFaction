local XFG, G = unpack(select(2, ...))
local ObjectName = 'GuildEvent'
local LogCategory = 'HEGuild'

GuildEvent = {}

function GuildEvent:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Initialized = false

    return Object
end

function GuildEvent:Initialize()
	if(not self:IsInitialized()) then
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
        try(function ()
            local _UnitData = Unit:new()
            _UnitData:Initialize(_MemberID)

            if(_UnitData:IsOnline()) then
                -- If cache doesn't have unit, process
                if(not XFG.Confederate:Contains(_UnitData:GetKey())) then
                    XFG.Confederate:AddUnit(_UnitData)
                    -- Don't notify if first time seeing unit
                    if(XFG.Cache.FirstScan[_MemberID]) then
                        XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGIN, _UnitData:GetName(), _UnitData:GetUnitName(), _UnitData:GetMainName(), _UnitData:GetGuild(), _UnitData:GetRealm())
                    end
                else
                    local _CachedUnitData = XFG.Confederate:GetUnit(_UnitData:GetKey())
                    -- If the player is running addon, do not process
                    if(not _CachedUnitData:IsRunningAddon() and not _CachedUnitData:Equals(_UnitData)) then         
                        XFG.Confederate:AddUnit(_UnitData)
                    end
                end
            -- They went offline and we saw them before doing so
            elseif(XFG.Confederate:Contains(_UnitData:GetKey())) then
                local _CachedUnitData = XFG.Confederate:GetUnit(_UnitData:GetKey())
                if(not _CachedUnitData:IsPlayer()) then
                    XFG.Confederate:RemoveUnit(_CachedUnitData:GetKey())
                    XFG.Frames.System:Display(XFG.Settings.Network.Message.Subject.LOGOUT, _CachedUnitData:GetName(), _CachedUnitData:GetUnitName(), _CachedUnitData:GetMainName(), _CachedUnitData:GetGuild(), _CachedUnitData:GetRealm())
                end
            end

            if(_UnitData:IsInitialized() and XFG.Cache.FirstScan[_MemberID] == nil) then
                XFG.Cache.FirstScan[_MemberID] = true
            end
        end).
        catch(function (inErrorMessage)
            XFG:Warn(LogCategory, 'Failed to scan unit information [%d]: ' .. inErrorMessage, _MemberID)
        end)
    end
end