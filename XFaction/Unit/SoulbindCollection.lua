local XFG, G = unpack(select(2, ...))
local ObjectName = 'CSoulbind'
local LogCategory = 'UCSoulbind'

SoulbindCollection = {}

function SoulbindCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Soulbinds = {}
	self._SoulbindCount = 0
	self._Initialized = false

    return Object
end

function SoulbindCollection:Initialize()
	if(not self:IsInitialized() and XFG.WoW:IsRetail()) then
		for _, _Covenant in pairs (XFG.Covenants:GetCovenants()) do
			for _, _SoulbindID in pairs (_Covenant:GetSoulbindIDs()) do
				local _Soulbind = Soulbind:new()
				_Soulbind:SetKey(_SoulbindID)
				_Soulbind:SetID(_SoulbindID)
				_Soulbind:Initialize()
				self:AddSoulbind(_Soulbind)
				XFG:Debug(LogCategory, 'Initialized soulbind [%s]', _Soulbind:GetName())
			end
		end
		self:IsInitialized(true)
	end
end

function SoulbindCollection:IsInitialized(_Argument)
    assert(_Argument == nil or type(_Argument) == 'boolean', 'argument needs to be nil or boolean')
    if(type(_Argument) == 'boolean') then
        self._Initialized = _Argument
    end
    return self._Initialized
end

function SoulbindCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, "  _SoulbindCount (" .. type(self._SoulbindCount) .. "): ".. tostring(self._SoulbindCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Soulbind in self:Iterator() do
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
	assert(type(inSoulbind) == 'table' and inSoulbind.__name ~= nil and inSoulbind.__name == 'Soulbind', 'argument must be Soulbind object')
	if(self:Contains(inSoulbind:GetKey()) == false) then
		self._SoulbindCount = self._SoulbindCount + 1
	end
	self._Soulbinds[inSoulbind:GetKey()] = inSoulbind
	return self:Contains(inSoulbind:GetKey())
end

function SoulbindCollection:Iterator()
	return next, self._Soulbinds, nil
end