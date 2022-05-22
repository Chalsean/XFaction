local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CSoulbind'
local LogCategory = 'U' .. ObjectName

SoulbindCollection = {}

function SoulbindCollection:new(_Argument)
    local _typeof = type(_Argument)
    local _newObject = true

	assert(_Argument == nil or 
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = _Argument
        _newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(_newObject) then
        self._Soulbinds = {}
		self._SoulbindCount = 0
		self._Initialized = false
    end

    return Object
end

function SoulbindCollection:Initialize()
	if(self:IsInitialized() == false) then
		for _, _Covenant in pairs (CON.Covenants:GetCovenants()) do
			for _, _SoulbindID in pairs (_Covenant:GetSoulbindIDs()) do
				local _Soulbind = Soulbind:new()
				_Soulbind:SetID(_SoulbindID)
				_Soulbind:Initialize()
				if(self:Contains(_Soulbind) == false) then
					self._Soulbinds[_Soulbind:GetName()] = _Soulbind
					self._SoulbindCount = self._SoulbindCount + 1
				end
			end
		end
		self:IsInitialized(true)
	end
end

function SoulbindCollection:IsInitialized(_Argument)
    assert(_Argument == nil or type(_Argument) == 'boolean', "argument needs to be nil or boolean")
    if(type(_Argument) == 'boolean') then
        self._Initialized = _Argument
    end
    return self._Initialized
end

function SoulbindCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, "SoulbindCollection Object")
	CON:Debug(LogCategory, "  _SoulbindCount (" .. type(self._SoulbindCount) .. "): ".. tostring(self._SoulbindCount))
	for _, _Soulbind in pairs (self._Soulbinds) do
		_Soulbind:Print()
	end
end

function SoulbindCollection:Contains(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or _typeof == 'number' or
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == 'Soulbind'), 
		  "argument must be string, number or Soulbind object")

	for _, _Soulbind in pairs (self._Soulbinds) do
		if(_typeof == 'number' and _Soulbind:GetID() == _Argument) then
			return true
		elseif(_typeof == 'string' and _Soulbind:GetName() == _Argument) then
			return true
		elseif(_typeof == 'table' and _Soulbind:GetID() == _Argument:GetID()) then
			return true
		end
	end

	return false
end

function SoulbindCollection:GetSoulbind(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or _typeof == 'number', "argument must be string or number")

	for _, _Soulbind in pairs (self._Soulbinds) do
		if(_typeof == 'number' and _Soulbind:GetID() == _Argument) then
			return _Soulbind
		elseif(_typeof == 'string' and _Soulbind:GetName() == _Argument) then
			return _Soulbind
		end
	end

    return nil
end

function SoulbindCollection:AddSoulbind(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'number' or
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == 'Soulbind'),
	      "argument must be number or Soulbind object")

	local _Soulbind = _Argument
	if(_typeof == 'number') then
		_Soulbind = Soulbind:new(_Argument)
		_Soulbind:Initialize()
	end

	self._Soulbinds[_Soulbind:GetID()] = _Soulbind
	self._SoulbindCount = self._SoulbindCount + 1

	return self._Soulbinds[_Soulbind:GetID()] ~= nil
end