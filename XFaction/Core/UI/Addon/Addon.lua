local XF, G = unpack(select(2, ...))
local ObjectName = 'Addon'

Addon = Object:newChildConstructor()

--#region Constructors
function Addon:new()
    local object = Addon.parent.new(self)
    object.__name = ObjectName
    object.isLoaded = false
    object.api = nil
    return object
end

function Addon:newChildConstructor()
    local object = Addon.parent.new(self)
    object.__name = ObjectName
    object.parent = self
    object.isLoaded = false
    object.api = nil
    return object
end
--#endregion

--#region Initializers
function Addon:OnLoad(inAPI)
    assert(type(inAPI) == 'table')
    if(not self:IsLoaded()) then
        self:SetAPI(inAPI)
        self:IsLoaded(true)
    end
end
--#endregion

--#region Print
function Addon:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  isLoaded (' .. type(self.isLoaded) .. '): ' .. tostring(self.isLoaded))
end
--#endregion

--#region Accessors
function Addon:HasAPI()
    return self.api ~= nil
end

function Addon:GetAPI()
    return self.api
end

function Addon:SetAPI(inAPI)
    assert(type(inAPI) == 'table')
    self.api = inAPI
end

function Addon:IsLoaded(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isLoaded = inBoolean
    end
    return self.isLoaded
end
--#endregion