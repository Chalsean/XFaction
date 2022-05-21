local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'CProfession'
local LogCategory = 'O' .. ObjectName

local _ProfessionIDs = { 794, 171, 164, 184, 333, 202, 129, 356, 182, 773, 755, 165, 186, 393, 197 }
ProfessionCollection = {}

function ProfessionCollection:new(_Argument)
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
        self._Professions = {}
		self._ProfessionCount = 0
		self._Initialized = false
    end

    return Object
end

function ProfessionCollection:Initialize()
	if(self:IsInitialized() == false) then
		-- Oddly enough there doesn't seem to be an API to get the super set of professions
		-- Best I could find is an API that tells you all the professions of online guild members
		for i = 1, GetNumGuildTradeSkill() do
			local _ProfessionID, _, _IconID, _ProfessionName = GetGuildTradeSkillInfo(i)
			local _Profession = Profession:new()
			_Profession:SetID(_ProfessionID)
			_Profession:SetIconID(_IconID)
			_Profession:SetName(_ProfessionName)
			self:AddProfession(_Profession)
		end
		self:IsInitialized(true)
	end
end

function ProfessionCollection:IsInitialized(_Argument)
    assert(_Argument == nil or type(_Argument) == 'boolean', "argument needs to be nil or boolean")
    if(type(_Argument) == 'boolean') then
        self._Initialized = _Argument
    end
    return self._Initialized
end

function ProfessionCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, "ProfessionCollection Object")
	CON:Debug(LogCategory, "  _ProfessionCount (" .. type(self._ProfessionCount) .. "): ".. tostring(self._ProfessionCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Profession in pairs (self._Professions) do
		_Profession:Print()
	end
end

function ProfessionCollection:Contains(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or _typeof == 'number' or
	      (_typeof == 'table' and _Argument.__name ~= nil and _Argument.__name == 'Profession'), 
		  "argument must be string, number or Profession object")

	for _, _Profession in pairs (self._Professions) do
		if(_typeof == 'number' and _Profession:GetID() == _Argument) then
			return true
		elseif(_typeof == 'table' and _Profession:GetID() == _Argument:GetID()) then
			return true
		elseif(_typeof == 'string' and _Profession:GetName() == _Argument:GetName()) then
			return true
		end
	end

	return false
end

function ProfessionCollection:GetProfession(_Argument)
	local _typeof = type(_Argument)
	assert(_typeof == 'string' or _typeof == 'number', "argument must be string or number")

	for _, _Profession in pairs (self._Professions) do
		if(_typeof == 'number' and _Profession:GetID() == _Argument) then
			return _Profession
		elseif(_typeof == 'table' and _Profession:GetID() == _Argument:GetID()) then
			return _Profession
		elseif(_typeof == 'string' and _Profession:GetName() == _Argument:GetName()) then
			return _Profession
		end
	end
	
    return nil
end

function ProfessionCollection:AddProfession(_Profession)
	assert(type(_Profession) == 'table' and _Profession.__name ~= nil and _Profession.__name == 'Profession', "argument must be Profession object")

	if(self:Contains(_Profession) == false) then
		self._Professions[_Profession:GetID()] = _Profession
		self._ProfessionCount = self._ProfessionCount + 1
	end

	return self:Contains(_Profession)
end