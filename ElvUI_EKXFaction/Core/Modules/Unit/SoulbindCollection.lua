local EKX, E, L, V, P, G = unpack(select(2, ...))
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
		for _, _Covenant in pairs (EKX.Covenants:GetCovenants()) do
			for _, _SoulbindID in pairs (_Covenant:GetSoulbindIDs()) do
				local _Soulbind = Soulbind:new()
				_Soulbind:SetKey(_SoulbindID)
				_Soulbind:SetID(_SoulbindID)
				_Soulbind:Initialize()
				if(self:Contains(_Soulbind:GetKey()) == false) then
					self._Soulbinds[_Soulbind:GetKey()] = _Soulbind
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
	EKX:DoubleLine(LogCategory)
	EKX:Debug(LogCategory, "SoulbindCollection Object")
	EKX:Debug(LogCategory, "  _SoulbindCount (" .. type(self._SoulbindCount) .. "): ".. tostring(self._SoulbindCount))
	for _, _Soulbind in pairs (self._Soulbinds) do
		_Soulbind:Print()
	end
end

function SoulbindCollection:Contains(inKey)
	assert(type(inKey) == 'number')
	return self._Soulbinds[inKey] ~= nil
end

function SoulbindCollection:GetSoulbind(inKey)
	assert(type(inKey) == 'number')
	return self._Soulbinds[inKey]
end

function SoulbindCollection:AddSoulbind(inSoulbind)
	assert(type(inSoulbind) == 'table' and inSoulbind.__name ~= nil and inSoulbind.__name == 'Soulbind', "argument must be Soulbind object")

	if(self:Contains(inSoulbind:GetKey()) == false) then
		self._SoulbindCount = self._SoulbindCount + 1
	end

	self._Soulbinds[inSoulbind:GetKey()] = inSoulbind

	return self:Contains(inSoulbind:GetKey())
end