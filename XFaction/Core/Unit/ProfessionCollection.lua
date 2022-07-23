local XFG, G = unpack(select(2, ...))
local ObjectName = 'ProfessionCollection'
local LogCategory = 'UCProfession'

ProfessionCollection = {}

function ProfessionCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Professions = {}
	self._ProfessionCount = 0
	self._Initialized = false

    return Object
end

function ProfessionCollection:Initialize()
	if(self:IsInitialized() == false) then
		for _ProfessionName, _ProfessionIDs in pairs (XFG.Settings.Professions) do
			local _NewProfession = Profession:new()
			_NewProfession:SetID(_ProfessionIDs.ID)
			_NewProfession:SetIconID(_ProfessionIDs.Icon)
			if(_ProfessionIDs.SpellID ~= nil) then
				_NewProfession:SetSpellID(_ProfessionIDs.SpellID)
			end
			_NewProfession:Initialize()
			self:AddProfession(_NewProfession)
			XFG:Info(LogCategory, 'Initialized profession [%s]', _NewProfession:GetName())
		end	
		self:IsInitialized(true)
	end
end

function ProfessionCollection:IsInitialized(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument needs to be nil or boolean')
    if(type(inBoolean) == 'boolean') then
        self._Initialized = inBoolean
    end
    return self._Initialized
end

function ProfessionCollection:Print()
	XFG:SingleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _ProfessionCount (' .. type(self._ProfessionCount) .. '): ' .. tostring(self._ProfessionCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
	for _, _Profession in self:Iterator() do
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
	assert(type(inProfession) == 'table' and inProfession.__name ~= nil and inProfession.__name == 'Profession', 'argument must be Profession object')
	if(self:Contains(inProfession:GetKey()) == false) then
		self._ProfessionCount = self._ProfessionCount + 1
	end
	self._Professions[inProfession:GetKey()] = inProfession
	return self:Contains(inProfession:GetKey())
end

function ProfessionCollection:Iterator()
	return next, self._Professions, nil
end

