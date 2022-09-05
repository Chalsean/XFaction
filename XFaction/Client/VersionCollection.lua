local XFG, G = unpack(select(2, ...))
local ObjectName = 'VersionCollection'

VersionCollection = ObjectCollection:newChildConstructor()

function VersionCollection:new()
    local object = VersionCollection.parent.new(self)
	object.__name = ObjectName
	object.currentVersion = nil
	object.defaultVersion = nil
    return object
end

function VersionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        local currentVersion = Version:new()
        currentVersion:SetKey(XFG.Version)
        self:Add(currentVersion)   
        self:SetCurrent(currentVersion)

		local defaultVersion = Version:new()
        defaultVersion:SetKey('0.0.0')
        self:Add(defaultVersion)
		self:SetDefault(defaultVersion)

		self:IsInitialized(true)
	end
end

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