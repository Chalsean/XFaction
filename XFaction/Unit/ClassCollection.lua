local XFG, G = unpack(select(2, ...))
local ObjectName = 'CClass'
local LogCategory = 'UCClass'

ClassCollection = {}

function ClassCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Classes = {}
	self._ClassCount = 0
	self._Initialized = false
    
    return Object
end

function ClassCollection:Initialize()
	if(not self._Initialized) then
		for _, _Class in XFG.Lib.Class:Iterator() do
			local _NewClass = Class:new()
			_NewClass:SetKey(_Class.ID)
			_NewClass:SetID(_Class.ID)
			_NewClass:SetName(_Class.Name)
			_NewClass:SetAPIName(_Class.API)
			_NewClass:SetRGB(_Class.R, _Class.G, _Class.B)
			_NewClass:SetHex(_Class.Hex)
			self:AddClass(_NewClass)
			XFG:Info(LogCategory, 'Initialized class [%s]', _NewClass:GetName())
		end
		self._Initialized = true
	end
	return self._Initialized
end

function ClassCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _ClassCount (' .. type(self._ClassCount) .. '): ' .. tostring(self._ClassCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Class in self:Iterator() do
		_Class:Print()
	end
end

function ClassCollection:Contains(inKey)
	assert(type(inKey) == 'number')
	return self._Classes[inKey] ~= nil
end

function ClassCollection:GetClass(inKey)
	assert(type(inKey) == 'number')
	return self._Classes[inKey]
end

function ClassCollection:GetClassByAPIName(inAPIName)
	assert(type(inAPIName) == 'string')

	for _, _Class in self:Iterator() do
		if(_Class:GetAPIName() == inAPIName) then
			return _Class
		end
	end
end

function ClassCollection:GetClassByName(inName)
	assert(type(inName) == 'string')
	for _, _Class in self:Iterator() do
		if(_Class:GetName() == inName) then
			return _Class
		end
	end
end

function ClassCollection:AddClass(inClass)
    assert(type(inClass) == 'table' and inClass.__name ~= nil and inClass.__name == 'Class', 'argument must be Class object')
	if(self:Contains(inClass:GetKey()) == false) then
		self._ClassCount = self._ClassCount + 1
	end
	self._Classes[inClass:GetKey()] = inClass
	return self:Contains(inClass:GetKey())
end

function ClassCollection:Iterator()
	return next, self._Classes, nil
end