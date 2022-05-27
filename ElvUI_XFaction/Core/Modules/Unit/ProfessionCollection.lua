local EKX, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'ProfessionCollection'
local LogCategory = 'UCProfession'

local _ProfessionIDs = { 182, 186, 197, 202, 171, 773, 165, 333, 164, 755, 393 }
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
		for _, _ProfessionID in pairs (C_TradeSkillUI.GetAllProfessionTradeSkillLines()) do
			local _NewProfession = Profession:new()
			_NewProfession:SetID(_ProfessionID)
			_NewProfession:Initialize()
			self:AddProfession(_NewProfession)
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
	EKX:DoubleLine(LogCategory)
	EKX:Debug(LogCategory, ObjectName .. " Object")
	EKX:Debug(LogCategory, "  _ProfessionCount (" .. type(self._ProfessionCount) .. "): ".. tostring(self._ProfessionCount))
	EKX:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
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