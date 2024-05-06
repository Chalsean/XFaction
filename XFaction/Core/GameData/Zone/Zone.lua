local XF, G = unpack(select(2, ...))
local ObjectName = 'Zone'

Zone = Object:newChildConstructor()

--#region Constructors
function Zone:new()
    local object = Zone.parent.new(self)
    object.__name = ObjectName
    object.IDs = nil
    object.localeName = nil
    object.continent = nil
    return object
end
--#endregion

--#region Initializers
function Zone:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self.IDs = {}
		self:IsInitialized(true)
	end
end
--#endregion

--#region Print
function Zone:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  localeName (' .. type(self.localeName) .. '): ' .. tostring(self.localeName))
    XF:Debug(ObjectName, '  IDs: ')
    XF:DataDumper(ObjectName, self.IDs)
    if(self:HasContinent()) then self:GetContinent():Print() end
end
--#endregion

--#region Hash
function Zone:HasID()
    return #self.IDs > 0
end

function Zone:GetID()
    if(self:HasID()) then
        return self.IDs[1]
    end
end

function Zone:AddID(inID)
    assert(type(inID) == 'number')
    self.IDs[#self.IDs + 1] = inID
end
--#endregion

--#region Accessors
function Zone:GetLocaleName()
    return self.localeName or self:GetName()
end

function Zone:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self.localeName = inName
end

function Zone:HasContinent()
    return self.continent ~= nil
end


function Zone:GetContinent()
    return self.continent
end

function Zone:SetContinent(inContinent)
    assert(type(inContinent) == 'table' and inContinent.__name == 'Continent', 'argument must be Continent object')
    self.continent = inContinent
end
--#endregion

--#region Iterators
function Zone:IDIterator()
	return next, self.IDs, nil
end
--#endregion