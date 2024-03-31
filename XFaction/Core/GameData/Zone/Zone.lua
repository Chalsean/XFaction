local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Zone'

XFC.Zone = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Zone:new()
    local object = XFC.Zone.parent.new(self)
    object.__name = ObjectName
    object.IDs = nil
    object.localeName = nil
    object.continent = nil
    return object
end
--#endregion

--#region Initializers
function XFC.Zone:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self.IDs = {}
		self:IsInitialized(true)
	end
end
--#endregion

--#region Print
function XFC.Zone:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  localeName (' .. type(self.localeName) .. '): ' .. tostring(self.localeName))
    XF:Debug(self:GetObjectName(), '  IDs: ')
    XF:DataDumper(self:GetObjectName(), self.IDs)
    if(self:HasContinent()) then self:GetContinent():Print() end
end
--#endregion

--#region Hash
function XFC.Zone:HasID()
    return #self.IDs > 0
end

function XFC.Zone:GetID()
    if(self:HasID()) then
        return self.IDs[1]
    end
end

function XFC.Zone:AddID(inID)
    assert(type(inID) == 'number')
    self.IDs[#self.IDs + 1] = inID
end
--#endregion

--#region Accessors
function XFC.Zone:GetLocaleName()
    return self.localeName or self:GetName()
end

function XFC.Zone:SetLocaleName(inName)
    assert(type(inName) == 'string')
    self.localeName = inName
end

function XFC.Zone:HasContinent()
    return self.continent ~= nil
end

function XFC.Zone:GetContinent()
    return self.continent
end

function XFC.Zone:SetContinent(inContinent)
    assert(type(inContinent) == 'table' and inContinent.__name == 'Continent', 'argument must be Continent object')
    self.continent = inContinent
end
--#endregion

--#region Iterators
function XFC.Zone:IDIterator()
	return next, self.IDs, nil
end
--#endregion