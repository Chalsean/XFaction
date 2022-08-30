local XFG, G = unpack(select(2, ...))
local ObjectName = 'NodeCollection'

NodeCollection = Factory:newChildConstructor()

function NodeCollection:new()
    local _Object = NodeCollection.parent.new(self)
	_Object.__name = ObjectName
	_Object._TargetCount = {}
    return _Object
end

function NodeCollection:NewObject()
	return Node:new()
end

function NodeCollection:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, '  _TargetCount (' .. type(self._TargetCount) .. '): ')
		XFG:DataDumper(ObjectName, self._TargetCount)
	end
end

function NodeCollection:Add(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
	self.parent.Add(self, inNode)
	if(self._TargetCount[inNode:GetTarget():GetKey()] == nil) then
		self._TargetCount[inNode:GetTarget():GetKey()] = 0
	end
	self._TargetCount[inNode:GetTarget():GetKey()] = self._TargetCount[inNode:GetTarget():GetKey()] + 1
end

function NodeCollection:Remove(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
	try(function ()
		self.parent.Remove(self, inNode:GetKey())
		if(self._TargetCount[inNode:GetTarget():GetKey()] ~= nil) then
			self._TargetCount[inNode:GetTarget():GetKey()] = self._TargetCount[inNode:GetTarget():GetKey()] - 1
		end
		for _, _Link in XFG.Links:Iterator() do
			if(_Link:GetFromNode():Equals(inNode) or _Link:GetToNode():Equals(inNode)) then
				XFG.Links:Remove(_Link)
			end
		end
	end).
	finally(function ()
		self:Push(inNode)
	end)
end

function NodeCollection:GetTargetCount(inTarget)
	return self._TargetCount[inTarget:GetKey()] or 0
end

function NodeCollection:SetNodeFromString(inNodeString)
    assert(type(inNodeString) == 'string')
    local _NodeData = string.Split(inNodeString, ':') 
	if(self:Contains(_NodeData[1])) then
		return self:Get(_NodeData[1])
	end
	local _Node = self:Pop()
    _Node:SetKey(_NodeData[1])
    _Node:SetName(_NodeData[1])
    local _Realm = XFG.Realms:GetByID(tonumber(_NodeData[2]))
    local _Faction = XFG.Factions:Get(tonumber(_NodeData[3]))
    _Node:SetTarget(XFG.Targets:GetByRealmFaction(_Realm, _Faction))
	self:Add(_Node)
	return _Node
end