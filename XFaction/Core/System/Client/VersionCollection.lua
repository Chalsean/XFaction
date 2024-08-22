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

function XFC.VersionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

		self:Add(XF.Version)
		self:Current(self:Get(XF.Version))

		self:Add('0.0.0')
		self:Default(self:Get('0.0.0'))

		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties
function XFC.VersionCollection:Current(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version' or inVersion == nil)
	if(inVersion ~= nil) then
		self.currentVersion = inVersion
	end
	return self.currentVersion
end

function XFC.VersionCollection:Default(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version' or inVersion == nil)
	if(inVersion ~= nil) then
		self.defaultVersion = inVersion
	end
	return self.defaultVersion
end
--#endregion

--#region Methods
function XFC.VersionCollection:SortedIterator()
	return PairsByKeys(self.objects, function(a, b) return self:Get(a):IsNewer(self:Get(b), true) end)
end

function XFC.VersionCollection:ReverseSortedIterator()
	return PairsByKeys(self.objects, function(a, b) return not self:Get(a):IsNewer(self:Get(b), true) end)
end

function XFC.VersionCollection:Add(inVersion)
	assert(type(inVersion) == 'table' and inVersion.__name == 'Version' or type(inVersion) == 'string')
	if(type(inVersion) == 'table') then
		self.parent.Add(self, inVersion)
	elseif(not self:Contains(inVersion)) then
		local version = XFC.Version:new()
		version:Initialize()
		version:Key(inVersion)
		self.parent.Add(self, version)
	end
end
--#endregion