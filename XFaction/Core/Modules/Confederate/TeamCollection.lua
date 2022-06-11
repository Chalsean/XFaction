local XFG, G = unpack(select(2, ...))
local ObjectName = 'TeamCollection'
local LogCategory = 'CCTeam'

TeamCollection = {}
_AltNames = {
	GM = 'Guild Master',
	Chancellor = 'Guild Lead',
	Ambassador = 'Raid Lead',
	Templar = 'Team Admin',
	Squire = 'Trial',
	Veteran = 'Retired Raider',
}	
_AltNames["Royal Emissary"] = 'Team Lead'
_AltNames["Master of Coin"] = 'Bank'
_AltNames["Grand Alt"] = 'Raider Alt'
_AltNames["Noble Citizen"] = 'Non-Raider'
_AltNames["Grand Army"] = 'Raider'
_AltNames["Cat Herder"] = 'Guild Master Alt'

function TeamCollection:new(inObject)
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

    if(_newObject == true) then
		self._Key = nil
        self._Teams = {}
		self._TeamCount = 0
		self._Initialized = false
    end

    return Object
end

function TeamCollection:IsInitialized(inBoolean)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', "argument needs to be nil or boolean")
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function TeamCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		for _ShortName, _Name in pairs (XFG.Cache.Teams) do
			local _NewTeam = Team:new()
			_NewTeam:SetName(_Name)
			_NewTeam:SetShortName(_ShortName)
			_NewTeam:Initialize()
			self:AddTeam(_NewTeam)
			table.RemoveKey(XFG.Cache.Teams, _ShortName)
		end
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function TeamCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _TeamCount (" .. type(self._TeamCount) .. "): ".. tostring(self._TeamCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Team in pairs (self._Teams) do
		_Team:Print()
	end
end

function TeamCollection:GetKey()
    return self._Key
end

function TeamCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function TeamCollection:Contains(inKey)
	assert(type(inKey) == 'string')
	return self._Teams[inKey] ~= nil
end

function TeamCollection:GetTeam(inKey)
	assert(type(inKey) == 'string')
	return self._Teams[inKey]
end

function TeamCollection:AddTeam(inTeam)
    assert(type(inTeam) == 'table' and inTeam.__name ~= nil and inTeam.__name == 'Team', "argument must be Team object")
	if(self:Contains(inTeam:GetKey()) == false) then
		self._TeamCount = self._TeamCount + 1
	end
	self._Teams[inTeam:GetKey()] = inTeam
	return self:Contains(inTeam:GetKey())
end

function TeamCollection:Iterator()
	return next, self._Teams, nil
end