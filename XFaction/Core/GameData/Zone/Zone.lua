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

function XFC.Zone:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self.IDs = {}
		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties
function XFC.Zone:LocaleName(inName)
    assert(type(inName) == 'string' or inName == nil)
    if(inName ~= nil) then
        self.localeName = inName
    end
    return self.localeName
end

function XFC.Zone:Continent(inContinent)
    assert(type(inContinent) == 'table' and inContinent.__name == 'Continent' or inContinent == nil)
    if(inContinent ~= nil) then
        self.continent = inContinent
    end
    return self.continent
end

function XFC.Zone:ID(inID)
    assert(type(inID) == 'number' or inID == nil)
    if(type(inID) == 'number') then
        self.IDs[#self.IDs + 1] = inID
    end
    return self.IDs[1]
end
--#endregion

--#region Methods
function XFC.Zone:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  localeName (' .. type(self.localeName) .. '): ' .. tostring(self.localeName))
    XF:Debug(self:ObjectName(), '  IDs: ')
    XF:DataDumper(self:ObjectName(), self.IDs)
    if(self:HasContinent()) then self:Continent():Print() end
end

function XFC.Zone:IDIterator()
	return next, self.IDs, nil
end

function XFC.Zone:HasContinent()
    return self.continent ~= nil
end
--#endregion