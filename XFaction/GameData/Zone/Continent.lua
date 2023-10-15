local XF, G = unpack(select(2, ...))
local ObjectName = 'Continent'

Continent = Object:newChildConstructor()

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

function Continent:GetID()
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
    return self.localeName or self:GetName()
end

function Continent:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self.localeName = inName
end
--#endregion