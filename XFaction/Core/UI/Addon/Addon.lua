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

--#region Properties
function XFC.Addon:IsLoaded(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil, 'argument must be boolean or nil')
    if(inBoolean ~= nil) then
        self.isLoaded = inBoolean
    end
    return self.isLoaded
end

function XFC.Addon:API(inAPI)
    assert(type(inAPI) == 'table' or inAPI == nil, 'argument must be addon api or nil')
    if(inAPI ~= nil) then
        self.api = inAPI
    end
    return self.api
end
--#endregion

--#region Methods
function XFC.Addon:OnLoad(inAPI)
    assert(type(inAPI) == 'table')
    if(not self:IsLoaded()) then
        self:API(inAPI)
        self:IsLoaded(true)
    end
end

function XFC.Addon:Print()
	self:ParentPrint()
	XF:Debug(self:ObjectName(), '  isLoaded (' .. type(self.isLoaded) .. '): ' .. tostring(self.isLoaded))
end
--#endregion