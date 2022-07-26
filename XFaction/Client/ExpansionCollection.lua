local XFG, G = unpack(select(2, ...))
local ObjectName = 'ExpansionCollection'
local LogCategory = 'CCExpansion'

ExpansionCollection = {}

local _Expansions = {
    [WOW_PROJECT_MAINLINE] = 3601566,
    [WOW_PROJECT_CLASSIC] = 630785,
--    [WOW_PROJECT_BURNING_CRUSADE_CLASSIC] = 630783,
--    [WOW_PROJECT_WRATH_OF_THE_LICH_KING_CLASSIC] = 630787,
}

function ExpansionCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Expansions = {}
	self._ExpansionCount = 0
    self._CurrentExpansion = nil
	self._Initialized = false

    return Object
end

function ExpansionCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(inBoolean ~= nil) then
        self._Initialized = inBoolean
    end
	return self._Initialized
end

function ExpansionCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())

        for _ExpansionID, _IconID in pairs(_Expansions) do
            local _NewExpansion = Expansion:new()
            _NewExpansion:SetKey(_ExpansionID)
            _NewExpansion:SetID(_ExpansionID)
            _NewExpansion:SetIconID(_IconID)
            if(_ExpansionID == WOW_PROJECT_MAINLINE) then
                _NewExpansion:SetName('Retail')
            elseif(_ExpansionID == WOW_PROJECT_CLASSIC) then
                _NewExpansion:SetName('Classic')
            end
            XFG:Info(LogCategory, 'Initializing expansion [%s:%s]', _NewExpansion:GetName(), _NewExpansion:GetKey())
            self:AddExpansion(_NewExpansion)

            if(WOW_PROJECT_ID == _ExpansionID) then
                self:SetCurrent(_NewExpansion)
                local _WoWVersion = GetBuildInfo()
                local _Version = Version:new()
                _Version:SetKey(_WoWVersion)
                _NewExpansion:SetVersion(_Version)
            end
        end       

		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function ExpansionCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _ExpansionCount (' .. type(self._ExpansionCount) .. '): ' .. tostring(self._ExpansionCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
    self._Version:Print()
	for _, _Expansion in self:Iterator() do
		_Expansion:Print()
	end
end

function ExpansionCollection:GetKey()
    return self._Key
end

function ExpansionCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function ExpansionCollection:Contains(inKey)
	assert(type(inKey) == 'number')
	return self._Expansions[inKey] ~= nil
end

function ExpansionCollection:GetExpansion(inKey)
	assert(type(inKey) == 'number')
	return self._Expansions[inKey]
end

function ExpansionCollection:AddExpansion(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name ~= nil and inExpansion.__name == 'Expansion', 'argument must be Expansion object')
	if(not self:Contains(inExpansion:GetKey())) then
		self._ExpansionCount = self._ExpansionCount + 1
	end
	self._Expansions[inExpansion:GetKey()] = inExpansion
	return self:Contains(inExpansion:GetKey())
end

function ExpansionCollection:Iterator()
	return next, self._Expansions, nil
end

function ExpansionCollection:SetCurrent(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name ~= nil and inExpansion.__name == 'Expansion', 'argument must be Expansion object')
	self._CurrentExpansion = inExpansion
	return self:GetCurrent()
end

function ExpansionCollection:GetCurrent()
	return self._CurrentExpansion
end