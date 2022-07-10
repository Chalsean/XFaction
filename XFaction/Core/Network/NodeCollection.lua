local XFG, G = unpack(select(2, ...))
local ObjectName = 'NodeCollection'
local LogCategory = 'NCNode'

NodeCollection = {}

function NodeCollection:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._Nodes = {}
    self._NodeCount = 0
	self._Candidates = {}
	self._Initialized = false

    return _Object
end

function NodeCollection:Initialize()
	if(self:IsInitialized() == false) then
		self:SetKey(math.GenerateUID())
		self:IsInitialized(true)
	end
	return self:IsInitialized()
end

function NodeCollection:IsInitialized(inBoolean)
	assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
	if(inBoolean ~= nil) then
		self._Initialized = inBoolean
	end
	return self._Initialized
end

function NodeCollection:Print()
	XFG:DoubleLine(LogCategory)
	XFG:Debug(LogCategory, ObjectName .. " Object")
	XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
	XFG:Debug(LogCategory, "  _NodeCount (" .. type(self._NodeCount) .. "): ".. tostring(self._NodeCount))
	XFG:Debug(LogCategory, "  _Initialized (" .. type(self._Initialized) .. "): ".. tostring(self._Initialized))
    for _, _Node in self:Iterator() do
        _Node:Print()
    end
end

function NodeCollection:GetKey()
    return self._Key
end

function NodeCollection:SetKey(inKey)
    assert(type(inKey) == 'string')
    self._Key = inKey
    return self:GetKey()
end

function NodeCollection:Contains(inKey)
	assert(type(inKey) == 'string')
    return self._Nodes[inKey] ~= nil
end

function NodeCollection:ContainsCandidate(inKey)
	assert(type(inKey) == 'string')
	for _, _Node in ipairs (self._Candidates) do
		if(_Node:GetKey() == inKey) then
			return true
		end
	end
    return false
end

function NodeCollection:GetNode(inKey)
	assert(type(inKey) == 'string')
    return self._Nodes[inKey]
end

function NodeCollection:AddNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', "argument must be Node object")
	if(self:Contains(inNode:GetKey()) == false) then
		self._NodeCount = self._NodeCount + 1
	end
    self._Nodes[inNode:GetKey()] = inNode
	if(not inNode:IsMyNode() and XFG.Player.Realm:Equals(inNode:GetRealm()) and XFG.Player.Faction:Equals(inNode:GetFaction()) and not self:ContainsCandidate(inNode:GetKey())) then
		table.insert(self._Candidates, inNode)		
	end
    return self:Contains(inNode:GetKey())	
end

function NodeCollection:RemoveNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', "argument must be Node object")
	if(self:Contains(inNode:GetKey())) then
		self._NodeCount = self._NodeCount - 1
		self._Nodes[inNode:GetKey()] = nil
	end
	for i = 1, #self._Candidates do
		if(self._Candidates[i]:GetKey() == inNode:GetKey()) then
			table.remove(self._Candidates, i)
			break
		end
	end
    return self:Contains(inNode:GetKey()) == false
end

function NodeCollection:Iterator()
	return next, self._Nodes, nil
end

function NodeCollection:GetCount()
	return self._NodeCount
end

function NodeCollection:GetCandidateCount()
	return #self._Candidates
end

function NodeCollection:GetRandomCandidate()
	local _Count = self:GetCandidateCount()
	if(_Count == 0) then return end
	local _RandomIndex = math.random(1, _Count)
	return self._Candidates[_RandomIndex]
end

function NodeCollection:CandidateIterator()
	return next, self._Candidates, nil
end