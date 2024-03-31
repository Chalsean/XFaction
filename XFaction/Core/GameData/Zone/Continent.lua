local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Continent'

XFC.Continent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Continent:new()
    local object = XFC.Continent.parent.new(self)
    object.__name = ObjectName
    object.IDs = nil
    object.localeName = nil
    return object
end
--#endregion

--#region Initializers
function XFC.Continent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self.IDs = {}
		self:IsInitialized(true)
	end
end
--#endregion

--#region Print
function XFC.Continent:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  localeName (' .. type(self.localeName) .. '): ' .. tostring(self.localeName))
    XF:Debug(self:GetObjectName(), '  IDs: ')
    XF:DataDumper(self:GetObjectName(), self.IDs)
end
--#endregion

--#region Array
function XFC.Continent:HasID(inID)
    assert(type(inID) == 'number')
    for _, ID in ipairs(self.IDs) do
        if(ID == inID) then
            return true
        end
    end
    return false
end

function XFC.Continent:GetID()
    if(#self.IDs > 0) then
        return self.IDs[1]
    end
end

function XFC.Continent:AddID(inID)
    assert(type(inID) == 'number')
    self.IDs[#self.IDs + 1] = inID
end
--#endregion

--#region Accessors
function XFC.Continent:GetLocaleName()
    return self.localeName or self:GetName()
end

function XFC.Continent:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self.localeName = inName
end
--#endregion