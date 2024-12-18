local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
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

function XFC.Addon:OnLoad(inAPI)
    assert(type(inAPI) == 'table')
    if(not self:IsLoaded()) then
        self:API(inAPI)
        self:IsLoaded(true)
    end
end
--#endregion

--#region Properties
function XFC.Addon:API(inAPI)
    assert(type(inAPI) == 'table' or inAPI == nil)
    if(inAPI ~= nil) then
        self.api = inAPI
    end
    return self.api
end

function XFC.Addon:IsLoaded(inBoolean)
    assert(type(inBoolean) == 'boolean' or inBoolean == nil)
    if(inBoolean ~= nil) then
        self.isLoaded = inBoolean
    end
    return self.isLoaded
end
--#endregion

--#region Methods
function XFC.Addon:Print()
	self:ParentPrint()
	XF:Debug(self:ObjectName(), '  isLoaded (' .. type(self.isLoaded) .. '): ' .. tostring(self.isLoaded))
end

function XFC.Addon:HasAPI()
    return self:API() ~= nil
end
--#endregion