local XFG, G = unpack(select(2, ...))
local ObjectName = 'ProfessionCollection'
local LogCategory = 'UCProfession'

local _ProfessionData = { 
	Herbalism = {
		ID = 182,
		Icon = 136065
	}, 
	Mining = {
		ID = 186,
		Icon = 136248
	}, 
	Tailoring = {
		ID = 197,
		Icon = 136249
	}, 
	Engineering = {
		ID = 202,
		Icon = 136243
	}, 
	Alchemy = {
		ID = 171,
		Icon = 136240
	}, 
	Inscription = {
		ID = 773,
		Icon = 237171
	}, 
	Leatherworking = {
		ID = 165,
		Icon = 133611
	}, 
	Enchanting = {
		ID = 333,
		Icon = 136244
	}, 
	Blacksmithing = {
		ID = 164,
		Icon = 136241
	}, 
	Jewelcrafting = {
		ID = 755,
		Icon = 134071
	}, 
	Skinning = {
		ID = 393,
		Icon = 134366
	}
}

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
		for _ProfessionName, _ProfessionIDs in pairs (_ProfessionData) do
			local _NewProfession = Profession:new()
			_NewProfession:SetID(_ProfessionIDs.ID)
			_NewProfession:SetIconID(_ProfessionIDs.Icon)
			_NewProfession:Initialize()
			self:AddProfession(_NewProfession)
			XFG:Debug(LogCategory, 'Initialized profession [%s]', _NewProfession:GetName())
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
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _ProfessionCount (" .. type(self._ProfessionCount) .. "): ".. tostring(self._ProfessionCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
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

function ProfessionCollection:Iterator()
	return next, self._Professions, nil
end

