local CON, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ProfessionCollection'
local LogCategory = 'UCProfession'

local _ProfessionIDs = { 794, 171, 164, 184, 333, 202, 129, 356, 182, 773, 755, 165, 186, 393, 197 }
ProfessionCollection = {}

function ProfessionCollection:new(inObject)
    local _typeof = type(inObject)
    local _newObject = true

	assert(inObject == nil or 
	      (_typeof == 'table' and inObject.__name ~= nil and inObject.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(_typeof == 'table') then
        Object = inObject
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
			_Profession:SetKey(_ProfessionID)
			_Profession:SetID(_ProfessionID)
			_Profession:SetIconID(_IconID)
			_Profession:SetName(_ProfessionName)
			self:AddProfession(_Profession)
		end
		self:IsInitialized(true)
	end
end

function ProfessionCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument needs to be nil or boolean")
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function ProfessionCollection:Print()
	CON:DoubleLine(LogCategory)
	CON:Debug(LogCategory, ObjectName .. " Object")
	CON:Debug(LogCategory, "  _ProfessionCount (" .. type(self._ProfessionCount) .. "): ".. tostring(self._ProfessionCount))
	CON:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Profession in pairs (self._Professions) do
		_Profession:Print()
	end
end

function ProfessionCollection:Contains(inKey)
	assert(type(inKey) == 'number')
	return self._Professions[inKey] ~= nil
end

function ProfessionCollection:GetProfession(inKey)
	assert(type(inKey) == 'number')
	return self._Professions[inKey]
end

function ProfessionCollection:AddProfession(inProfession)
	assert(type(inProfession) == 'table' and inProfession.__name ~= nil and inProfession.__name == 'Profession', "argument must be Profession object")

	if(self:Contains(inProfession:GetKey()) == false) then
		self._Professions[inProfession:GetKey()] = inProfession
		self._ProfessionCount = self._ProfessionCount + 1
	end

	return self:Contains(inProfession:GetKey())
end