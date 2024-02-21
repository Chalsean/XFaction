local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Addon'

XFC.Addon = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Addon:new()
    local object = XFC.Addon.parent.new(self)
    object.__name = ObjectName
    object.isLoaded = false
    object.api = nil
    return object
end

function XFC.Addon:newChildConstructor()
    local object = XFC.Addon.parent.new(self)
    object.__name = ObjectName
    object.parent = self
    object.isLoaded = false
    object.api = nil
    return object
end
--#endregion

--#region Initializers
function XFC.Addon:OnLoad(inAPI)
    assert(type(inAPI) == 'table')
    if(not self:IsLoaded()) then
        self:SetAPI(inAPI)
        self:IsLoaded(true)
    end
end
--#endregion

--#region Print
function XFC.Addon:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  isLoaded (' .. type(self.isLoaded) .. '): ' .. tostring(self.isLoaded))
end
--#endregion

--#region Accessors
function XFC.Addon:HasAPI()
    return self.api ~= nil
end

function XFC.Addon:GetAPI()
    return self.api
end

function XFC.Addon:SetAPI(inAPI)
    assert(type(inAPI) == 'table')
    self.api = inAPI
end

function XFC.Addon:IsLoaded(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isLoaded = inBoolean
    end
    return self.isLoaded
end
--#endregion