local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'VersionCollection'

XFC.VersionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Contructors
function XFC.VersionCollection:new()
    local object = XFC.VersionCollection.parent.new(self)
	object.__name = ObjectName
	object.currentVersion = nil
	object.defaultVersion = nil
    return object
end
--#endregion

--#region Initializers
function XFC.VersionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

		self:Add(XF.Version)
		self:SetCurrent(self:Get(XF.Version))

		self:Add('0.0.0')
		self:SetDefault(self:Get('0.0.0'))

		self:IsInitialized(true)
	end
end
--#endregion

--#region Iterators
function XFC.VersionCollection:SortedIterator()
	return PairsByKeys(self.objects, function(a, b) return self:Get(a):IsNewer(self:Get(b), true) end)
end

function XFC.VersionCollection:ReverseSortedIterator()
	return PairsByKeys(self.objects, function(a, b) return not self:Get(a):IsNewer(self:Get(b), true) end)
end
--#endregion

--#region Hash
function XFC.VersionCollection:Add(inKey)
	assert(type(inKey) == 'string')
	if(not self:Contains(inKey)) then
		local version = XFC.Version:new()
		version:Initialize()
		version:SetKey(inKey)
		self.parent.Add(self, version)
	end
end
--#endregion

--#region Accessors
function XFC.VersionCollection:SetCurrent(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
	self.currentVersion = inVersion
end

function XFC.VersionCollection:GetCurrent()
	return self.currentVersion
end

function XFC.VersionCollection:SetDefault(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
	self.defaultVersion = inVersion
end

function XFC.VersionCollection:GetDefault()
	return self.defaultVersion
end
--#endregion