local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'VersionCollection'

VersionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Contructors
function VersionCollection:new()
    local object = VersionCollection.parent.new(self)
	object.__name = ObjectName
	object.currentVersion = nil
	object.defaultVersion = nil
    return object
end
--#endregion

--#region Initializers
function VersionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        local currentVersion = Version:new()
        currentVersion:Key(XF.Version)
        self:Add(currentVersion)   
        self:SetCurrent(currentVersion)

		local defaultVersion = Version:new()
        defaultVersion:Key('0.0.0')
        self:Add(defaultVersion)
		self:SetDefault(defaultVersion)

		self:IsInitialized(true)
	end
end
--#endregion

--#region Iterators
function VersionCollection:SortedIterator()
	return PairsByKeys(self.objects, function(a, b) return self:Get(a):IsNewer(self:Get(b), true) end)
end

function VersionCollection:ReverseSortedIterator()
	return PairsByKeys(self.objects, function(a, b) return not self:Get(a):IsNewer(self:Get(b), true) end)
end
--#endregion

--#region Hash
function VersionCollection:AddVersion(inKey)
	assert(type(inKey) == 'string')
	if(not self:Contains(inKey)) then
		local version = Version:new()
		version:Initialize()
		version:Key(inKey)
		self.parent.Add(self, version)
	end
end
--#endregion

--#region Accessors
function VersionCollection:SetCurrent(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
	self.currentVersion = inVersion
end

function VersionCollection:GetCurrent()
	return self.currentVersion
end

function VersionCollection:SetDefault(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
	self.defaultVersion = inVersion
end

function VersionCollection:GetDefault()
	return self.defaultVersion
end
--#endregion