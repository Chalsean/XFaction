local XFG, G = unpack(select(2, ...))

VersionCollection = ObjectCollection:newChildConstructor()

function VersionCollection:new()
    local _Object = VersionCollection.parent.new(self)
	_Object.__name = 'VersionCollection'
	_Object._CurrentVersion = nil
	_Object._DefaultVersion = nil
    return _Object
end

function VersionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        local _CurrentVersion = Version:new()
        _CurrentVersion:SetKey(XFG.Version)
        self:AddObject(_CurrentVersion)   
        self:SetCurrent(_CurrentVersion)

		local _DefaultVersion = Version:new()
        _DefaultVersion:SetKey('0.0.0')
        self:AddObject(_DefaultVersion)
		self:SetDefault(_DefaultVersion)

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function VersionCollection:SetCurrent(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name ~= nil and inVersion.__name == 'Version', 'argument must be Version object')
	self._CurrentVersion = inVersion
	return self:GetCurrent()
end

function VersionCollection:GetCurrent()
	return self._CurrentVersion
end

function VersionCollection:SetDefault(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name ~= nil and inVersion.__name == 'Version', 'argument must be Version object')
	self._DefaultVersion = inVersion
	return self:GetCurrent()
end

function VersionCollection:GetDefault()
	return self._DefaultVersion
end