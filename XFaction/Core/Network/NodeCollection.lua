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
    self._Initialized = false
	self._TargetCount = {}

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
	XFG:Debug(LogCategory, '  _TargetCount (' .. type(self._TargetCount) .. '): ')
	XFG:DataDumper(LogCategory, self._TargetCount)
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

function NodeCollection:GetNode(inKey)
	assert(type(inKey) == 'string')
    return self._Nodes[inKey]
end

function NodeCollection:AddNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
	if(not self:Contains(inNode:GetKey())) then
		self._NodeCount = self._NodeCount + 1
	end
    self._Nodes[inNode:GetKey()] = inNode
	if(self._TargetCount[inNode:GetTarget():GetKey()] == nil) then
		self._TargetCount[inNode:GetTarget():GetKey()] = 0
	end
	self._TargetCount[inNode:GetTarget():GetKey()] = self._TargetCount[inNode:GetTarget():GetKey()] + 1
    return self:Contains(inNode:GetKey())	
end

function NodeCollection:RemoveNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Link object')
	if(self:Contains(inNode:GetKey())) then
		self._NodeCount = self._NodeCount - 1
		self._Nodes[inNode:GetKey()] = nil
	end
	if(self._TargetCount[inNode:GetTarget():GetKey()] ~= nil) then
		self._TargetCount[inNode:GetTarget():GetKey()] = self._TargetCount[inNode:GetTarget():GetKey()] - 1
	end
	for _, _Link in XFG.Links:Iterator() do
		if(_Link:GetFromNode():Equals(inNode) or _Link:GetToNode():Equals(inNode)) then
			self:RemoveLink(_Link)
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

function NodeCollection:GetTargetCount(inTarget)
	return self._TargetCount[inTarget:GetKey()] or 0
end