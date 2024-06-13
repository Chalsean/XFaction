local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Continent'

Continent = XFC.Object:newChildConstructor()

--#region Constructors
function Continent:new()
    local object = Continent.parent.new(self)
    object.__name = ObjectName
    object.IDs = nil
    object.localeName = nil
    return object
end
--#endregion

--#region Initializers
function Continent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self.IDs = {}
		self:IsInitialized(true)
	end
end
--#endregion

--#region Print
function Continent:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  localeName (' .. type(self.localeName) .. '): ' .. tostring(self.localeName))
    XF:Debug(ObjectName, '  IDs: ')
    XF:DataDumper(ObjectName, self.IDs)
end
--#endregion

--#region Array
function Continent:HasID(inID)
    assert(type(inID) == 'number')
    for _, ID in ipairs(self.IDs) do
        if(ID == inID) then
            return true
        end
    end
    return false
end

function Continent:ID()
    if(#self.IDs > 0) then
        return self.IDs[1]
    end
end

function Continent:AddID(inID)
    assert(type(inID) == 'number')
    self.IDs[#self.IDs + 1] = inID
end
--#endregion

--#region Accessors
function Continent:GetLocaleName()
    return self.localeName or self:Name()
end

function Continent:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self.localeName = inName
end
--#endregion