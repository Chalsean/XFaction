local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CClass'
local LogCategory = 'O' .. ObjectName
local MaxRaces = 37

ClassCollection = {}

function ClassCollection:new(_Argument)
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

    if(_newObject == true) then
        self._Classes = {}
		self._ClassCount = 0
		self._Initialized = false
    end

    return Object
end

function ClassCollection:Initialize()
	if(self._Initialized == false) then
		for i = 1, GetNumClasses() do
			local _ClassInfo = C_CreatureInfo.GetClassInfo(i)
			local _Class = Class:new()
			_Class:SetID(_ClassInfo.classID)
			_Class:SetName(_ClassInfo.className)
			self._ClassCount = self._ClassCount + 1
			self._Classes[_Class:GetName()] = _Class
		end
		self._Initialized = true
	end
	return self._Initialized
end

function ClassCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, "ClassCollection Object")
	CON:Debug(LogCategory, "  _ClassCount (" .. type(self._ClassCount) .. "): ".. tostring(self._ClassCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Class in pairs (self._Classes) do
		_Class:Print()
	end
end

function ClassCollection:Contains(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or 
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == 'Class'), 
		  "argument must be string or Class object")

	local _ClassName = _Argument
	if(_typeof == 'table') then
		_ClassName = _Argument:GetName()
	end

	return self._Classes[_ClassName] ~= nil
end

function ClassCollection:GetClass(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string', "argument must be string")

	if(_typeof == 'string') then
		for _ClassName, _Class in pairs (self._Classes) do
			if(_ClassName == _Argument) then
				return _Class
			end
		end
	end
	
    return self._Classes[_Argument]
end

function ClassCollection:AddClass(_Class)
    assert(type(_Class) == 'table' and _Class.__name ~= nil and _Class.__name == 'Class', "argument must be Class object")
	if(self:Contains(_Class) == false) then
		self._ClassCount = self._ClassCount + 1
	end
	self._Classes[_Class:GetName()] = _Class
	return self:Contains(_Class)
end