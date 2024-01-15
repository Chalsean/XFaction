local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'NameplateEvent'
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates

NameplateEvent = Object:newChildConstructor()

--#region Constructors
function PlayerEvent:new()
    local object = NameplateEvent.parent.new(self)
    object.__name = ObjectName
    object.first = true
    return object
end
--#endregion

--#region Initializers
function NameplateEvent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        XF.Events:Add({name = 'NameplateAdded', 
                        event = 'NAME_PLATE_UNIT_ADDED', 
                        callback = XF.Handlers.NameplateEvent.CallbackNameplateAdded, 
                        instance = true})
        XF.Events:Add({name = 'NameplateCreated', 
                        event = 'NAME_PLATE_CREATED', 
                        callback = XF.Handlers.NameplateEvent.CallbackNameplateCreated, 
                        instance = true})

        XF.Events:Add({name = 'ForbiddenNameplateAdded', 
                        event = 'FORBIDDEN_NAME_PLATE_UNIT_ADDED', 
                        callback = XF.Handlers.NameplateEvent.CallbackForbiddenNameplateAdded, 
                        instance = true})

        XF.Events:Add({name = 'ForbiddenNameplateCreated', 
                        event = 'FORBIDDEN_NAME_PLATE_CREATED', 
                        callback = XF.Handlers.NameplateEvent.CallbackNameplateCreated, 
                        instance = true})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Callbacks
function NameplateEvent:CallbackNameplateAdded(inEvent, inUnitToken) 
    local self = XF.Handlers.NameplateEvent
    try(function ()
        XF:Info(self:GetObjectName(), 'NameplateAdded [%s]', inUnitToken)
        local namePlates = C_NamePlate_GetNamePlates(true)
        if #namePlates > 0 then
            for _, namePlate in ipairs(namePlates) do
                if(namePlate ~= nil) then
                    print('nameplate: ' .. namePlate.unit)
                end
            end
        end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function NameplateEvent:CallbackNameplateCreated(inEvent, inFrame) 
    local self = XF.Handlers.NameplateEvent
    try(function ()
        XF:Info(self:GetObjectName(), 'NameplateCreated')
        -- XF:DataDumper(self:GetObjectName(), inFrame)

        -- if(self.first) then
        --     local plates = C_NamePlate.GetNamePlates(true)
        --     for _, plate in ipairs(plates) do
        --         XF:DataDumper(self:GetObjectName(), plate)
        --     end
        --     self.first = false
        -- end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function NameplateEvent:CallbackForbiddenNameplateAdded(inEvent, inFrame) 
    local self = XF.Handlers.NameplateEvent
    try(function ()
        XF:Info(self:GetObjectName(), 'ForbiddenNameplateAdded [%s]', inFrame)

        -- if(self.first) then
        --     local plates = C_NamePlate.GetNamePlates(true)
        --     for _, plate in ipairs(plates) do
        --         XF:DataDumper(self:GetObjectName(), plate)
        --     end
        --     self.first = false
        -- end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end

function NameplateEvent:CallbackForbiddenNameplateCreated(inEvent, inFrame) 
    local self = XF.Handlers.NameplateEvent
    try(function ()
        XF:Info(self:GetObjectName(), 'ForbiddenNameplateCreated')
        -- XF:DataDumper(self:GetObjectName(), inFrame)

        -- if(self.first) then
        --     local plates = C_NamePlate.GetNamePlates(true)
        --     for _, plate in ipairs(plates) do
        --         XF:DataDumper(self:GetObjectName(), plate)
        --     end
        --     self.first = false
        -- end
    end).
    catch(function (inErrorMessage)
        XF:Warn(ObjectName, inErrorMessage)
    end)
end
--#endregion