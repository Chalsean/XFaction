local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'PlayerEvent'
local GetZoneName = GetRealZoneText
local IsInInstance = IsInInstance

XFC.PlayerEvent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.PlayerEvent:new()
    local object = XFC.PlayerEvent.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function XFC.PlayerEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        -- FIX: Move to Retail
        -- XF.Events:Add({name = 'Mythic', 
        --                 event = 'CHALLENGE_MODE_COMPLETED', 
        --                 callback = XF.Handlers.PlayerEvent.CallbackPlayerChanged, 
        --                 instance = true})
        XFO.Events:Add({name = 'Spec', 
                        event = 'ACTIVE_TALENT_GROUP_CHANGED', 
                        callback = XFO.PlayerEvent.CallbackPlayerChanged, 
                        instance = true})        
        XFO.Events:Add({name = 'Instance', 
                        event = 'PLAYER_ENTERING_WORLD', 
                        callback = XFO.PlayerEvent.CallbackInstance, 
                        instance = true})
        XFO.Events:Add({name = 'Level', 
                        event = 'PLAYER_LEVEL_CHANGED', 
                        callback = XFO.PlayerEvent.CallbackPlayerChanged})
        XFO.Events:Add({name = 'Profession', 
                        event = 'SKILL_LINES_CHANGED', 
                        callback = XFO.PlayerEvent.CallbackPlayerChanged})
        XFO.Events:Add({name = 'Zone', 
                        event = 'ZONE_CHANGED_NEW_AREA', 
                        callback = XFO.PlayerEvent.CallbackZoneChanged})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function XFC.PlayerEvent:CallbackPlayerChanged(inEvent)
    local unit = nil
    try(function ()
        unit = XFO.Confederate:Pop()
        unit:Initialize(XF.Player.Unit:GetID())
        if(not unit:Equals(XF.Player.Unit)) then
            XFO.Confederate:Add(unit)
            unit:Broadcast()
        else
            XFO.Confederate:Push(unit)
        end
    end).
    catch(function (err)
        XF:Warn(self:GetObjectName(), err)
        XFO.Confederate:Push(unit)
    end)
end

-- Zone changes are kinda funky, during a zone change C_Club.GetMemberInfo returns a lot of nils
-- So use a different API, detect zone text change, only update that information and broadcast
function XFC.PlayerEvent:CallbackZoneChanged()
    if(XF.Initialized) then 
        try(function ()
            local zoneName = GetZoneName()
            if(zoneName ~= nil) then
                XFO.Zones:Add(zoneName)
                local zone = XFO.Zones:Get(zoneName)
                if(not zone:Equals(XF.Player.Unit:GetZone())) then
                    XF.Player.Unit:SetZone(zone)
                    XF.Player.Unit:Broadcast()
                end
            end
        end).
        catch(function (err)
            XF:Warn(self:GetObjectName(), err)
        end)
    end
end

function XFC.PlayerEvent:CallbackInstance()
    try(function ()
        local inInstance = IsInInstance()
        -- Enter instance for first time
        if(inInstance and not XF.Player.InInstance) then
            XF:Debug(self:GetObjectName(), 'Entering instance, disabling some event listeners and timers')
            XF.Player.InInstance = true
            XFO.Events:EnterInstance()
            XFO.Timers:EnterInstance()

        -- Just leaving instance or UI reload
        elseif(not inInstance and XF.Player.InInstance) then
            XF:Debug(self:GetObjectName(), 'Leaving instance, enabling some event listeners and timers')
            XF.Player.InInstance = false
            XFO.Events:LeaveInstance()
            XFO.Timers:LeaveInstance()            
        end
    end).
    catch(function (err)
        XF:Warn(self:GetObjectName(), err)
    end)
end
--#endregion