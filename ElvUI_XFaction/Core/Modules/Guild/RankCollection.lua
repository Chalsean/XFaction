local XFG, E, L, V, P, G = unpack(select(2, ...))
local ObjectName = 'RankCollection'
local LogCategory = 'GCRank'

RankCollection = {}
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

function RankCollection:new(inObject)
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
        self._Ranks = {}
		self._RankCount = 0
		self._Initialized = false
    end

    return Object
end

function RankCollection:IsInitialized(inBoolean)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', "argument needs to be nil or boolean")
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function RankCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function RankCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _RankCount (" .. type(self._RankCount) .. "): ".. tostring(self._RankCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
	for _, _Rank in pairs (self._Ranks) do
		_Rank:Print()
	end
end

function RankCollection:GetKey()
    return self._Key
end

function RankCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function RankCollection:Contains(inKey)
	assert(type(inKey) == 'number')
	return self._Ranks[inKey] ~= nil
end

function RankCollection:GetRank(inKey)
	assert(type(inKey) == 'number')
	return self._Ranks[inKey]
end

function RankCollection:AddRank(inRank)
    assert(type(inRank) == 'table' and inRank.__name ~= nil and inRank.__name == 'Rank', "argument must be Rank object")
	if(self:Contains(inRank:GetKey()) == false) then
		self._RankCount = self._RankCount + 1
	end
	if(inRank:HasAltName() == false and _AltNames[inRank:GetName()] ~= nil) then
		inRank:SetAltName(_AltNames[inRank:GetName()])
	end
	self._Ranks[inRank:GetKey()] = inRank
	return self:Contains(inRank:GetKey())
end