local XFG, G = unpack(select(2, ...))
local ObjectName = 'RankCollection'
local LogCategory = 'CCRank'

RankCollection = {}

function RankCollection:new()
    Object = {}
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

	self._Key = nil
    self._Ranks = {}
	self._RankCount = 0
	self._Initialized = false
    
    return Object
end

function RankCollection:IsInitialized(inBoolean)
    assert(inInitialized == nil or type(inInitialized) == 'boolean', 'argument needs to be nil or boolean')
    if(inInitialized ~= nil) then
        self._Initialized = inInitialized
    end
	return self._Initialized
end

function RankCollection:Initialize()
	if(self:IsInitialized() == false) then
        self:SetKey(math.GenerateUID())
		for _RankIndex, _RankName in pairs (XFG.Settings.Ranks) do
            local _NewRank = Rank:new()
			_NewRank:SetKey(tonumber(_RankIndex))
			_NewRank:SetID(tonumber(_RankIndex))
			_NewRank:SetName(_RankName)
			if(XFG.Config.Rank[_NewRank:GetID()] ~= nil) then
				_NewRank:SetAltName(XFG.Config.Rank[_NewRank:GetID()])
			end
			self:AddRank(_NewRank)
			XFG.Settings.DataText.Guild.Ranks[tonumber(_RankIndex)] = _RankIndex .. ' - ' .. _NewRank:GetName()
			XFG:Debug(LogCategory, 'Initialized confederate rank [%s]', XFG.Settings.DataText.Guild.Ranks[_RankIndex])
        end
		XFG.Options.args.DataText.args.Guild.args.Rank.values = XFG.Settings.DataText.Guild.Ranks
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function RankCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. ' Object')
	XFG:Debug(LogCategory, '  _Key (' .. type(self._Key) .. '): ' .. tostring(self._Key))
	XFG:Debug(LogCategory, '  _RankCount (' .. type(self._RankCount) .. '): ' .. tostring(self._RankCount))
	XFG:Debug(LogCategory, '  _Initialized (' .. type(self._Initialized) .. '): ' .. tostring(self._Initialized))
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

function RankCollection:GetRankByName(inName)
	assert(type(inName) == 'string')
	for _, _Rank in self:Iterator() do
		if(_Rank:GetName() == inName) then
			return _Rank
		end
	end
end

function RankCollection:AddRank(inRank)
    assert(type(inRank) == 'table' and inRank.__name ~= nil and inRank.__name == 'Rank', 'argument must be Rank object')
	if(self:Contains(inRank:GetKey()) == false) then
		self._RankCount = self._RankCount + 1
	end
	self._Ranks[inRank:GetKey()] = inRank
	return self:Contains(inRank:GetKey())
end

function RankCollection:Iterator()
	return next, self._Ranks, nil
end

function RankCollection:GetCount()
	return self._RankCount
end