local XFG, G = unpack(select(2, ...))
local ObjectName = 'NodeCollection'

NodeCollection = ObjectCollection:newChildConstructor()

function NodeCollection:new()
    local _Object = NodeCollection.parent.new(self)
	_Object.__name = ObjectName
	_Object._TargetCount = {}
    return _Object
end

function NodeCollection:Print()
	if(XFG.DebugFlag) then
		self:ParentPrint()
		XFG:Debug(ObjectName, '  _TargetCount (' .. type(self._TargetCount) .. '): ')
		XFG:DataDumper(ObjectName, self._TargetCount)
	end
end

function NodeCollection:AddNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
	self:AddObject(inNode)
	if(self._TargetCount[inNode:GetTarget():GetKey()] == nil) then
		self._TargetCount[inNode:GetTarget():GetKey()] = 0
	end
	self._TargetCount[inNode:GetTarget():GetKey()] = self._TargetCount[inNode:GetTarget():GetKey()] + 1
    return self:Contains(inNode:GetKey())	
end

function NodeCollection:RemoveNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
	self:RemoveObject(inNode:GetKey())
	if(self._TargetCount[inNode:GetTarget():GetKey()] ~= nil) then
		self._TargetCount[inNode:GetTarget():GetKey()] = self._TargetCount[inNode:GetTarget():GetKey()] - 1
	end
	for _, _Link in XFG.Links:Iterator() do
		if(_Link:GetFromNode():Equals(inNode) or _Link:GetToNode():Equals(inNode)) then
			XFG.Links:RemoveLink(_Link)
		end
	end
    return not self:Contains(inNode:GetKey())
end

function NodeCollection:GetTargetCount(inTarget)
	return self._TargetCount[inTarget:GetKey()] or 0
end