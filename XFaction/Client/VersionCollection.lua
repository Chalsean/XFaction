local XFG, G = unpack(select(2, ...))
local ObjectName = 'VersionCollection'
local LogCategory = 'CCVersion'

VersionCollection = {}

function VersionCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Versions = {}
	self._VersionCount = 0
    self._CurrentVersion = nil
	self._DefaultVersion = nil
	self._Initialized = false

    return Object
end

function VersionCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
	return self._Initialized
end

function VersionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:SetKey(math.GenerateUID())

        local _CurrentVersion = Version:new()
        _CurrentVersion:SetKey(XFG.Version)
        self:AddVersion(_CurrentVersion)   
        self:SetCurrent(_CurrentVersion)

		local _DefaultVersion = Version:new()
        _DefaultVersion:SetKey('0.0.0')
        self:AddVersion(_DefaultVersion)
		self:SetDefault(_DefaultVersion)

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function VersionCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _VersionCount (' .. type(self._VersionCount) .. '): ' .. tostring(self._VersionCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Version in self:Iterator() do
		_Version:Print()
	end
end

function VersionCollection:GetKey()
    return self._Key
end

function VersionCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function VersionCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Versions[inKey] ~= nil
end

function VersionCollection:GetVersion(inKey)
	assert(type(inKey) == 'string')
	return self._Versions[inKey]
end

function VersionCollection:AddVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name ~= nil and inVersion.__name == 'Version', 'argument must be Version object')
	if(not self:Contains(inVersion:GetKey())) then
		self._VersionCount = self._VersionCount + 1
	end
	self._Versions[inVersion:GetKey()] = inVersion
	return self:Contains(inVersion:GetKey())
end

function VersionCollection:Iterator()
	return next, self._Versions, nil
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