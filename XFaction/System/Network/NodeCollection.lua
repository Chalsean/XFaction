local XF, G = unpack(select(2, ...))
local ObjectName = 'NodeCollection'

NodeCollection = Factory:newChildConstructor()

--#region Constructors
function NodeCollection:new()
    local object = NodeCollection.parent.new(self)
	object.__name = ObjectName
	object.targetCount = {}
    return object
end

function NodeCollection:NewObject()
	return Node:new()
end
--#endregion

--#region Print
function NodeCollection:Print()
	self:ParentPrint()
	XF:Debug(ObjectName, '  targetCount (' .. type(self.targetCount) .. '): ')
	XF:DataDumper(ObjectName, self.targetCount)
end
--#endregion

--#region Hash
function NodeCollection:Add(inNode)
    assert(type(inNode) == 'table' and inNode.__name == 'Node', 'argument must be Node object')
	self.parent.Add(self, inNode)
	if(self.targetCount[inNode:GetTarget():GetKey()] == nil) then
		self.targetCount[inNode:GetTarget():GetKey()] = 0
	end
	self.targetCount[inNode:GetTarget():GetKey()] = self.targetCount[inNode:GetTarget():GetKey()] + 1
	XF.DataText.Links:RefreshBroker()
end

function NodeCollection:Remove(inNode)
    assert(type(inNode) == 'table' and inNode.__name == 'Node', 'argument must be Node object')
	try(function ()
		self.parent.Remove(self, inNode:GetKey())
		if(self.targetCount[inNode:GetTarget():GetKey()] ~= nil) then
			self.targetCount[inNode:GetTarget():GetKey()] = self.targetCount[inNode:GetTarget():GetKey()] - 1
		end
		for _, link in XF.Links:Iterator() do
			if(link:GetFromNode():Equals(inNode) or link:GetToNode():Equals(inNode)) then
				XF.Links:Remove(link)
			end
		end
		XF.DataText.Links:RefreshBroker()
	end).
	finally(function ()
		self:Push(inNode)
	end)
end

function NodeCollection:RemoveAll()
	try(function ()
		if(self:IsInitialized()) then
			for _, node in self:Iterator() do
				self:Remove(node)
			end
		end
	end).
	catch(function (inErrorMessage)
		XF:Error(ObjectName, inErrorMessage)
	end)
end
--#endregion

--#region Accessors
function NodeCollection:GetTargetCount(inTarget)
	return self.targetCount[inTarget:GetKey()] or 0
end
--#endregion

--#region DataSet
function NodeCollection:SetNodeFromString(inNodeString)
    assert(type(inNodeString) == 'string')
    local nodeData = string.Split(inNodeString, ':') 
	if(self:Contains(nodeData[1])) then
		return self:Get(nodeData[1])
	end
	local node = self:Pop()
    node:SetKey(nodeData[1])
    node:SetName(nodeData[1])
    local realm = XF.Realms:GetByID(tonumber(nodeData[2]))
    local faction = XF.Factions:Get(tonumber(nodeData[3]))
    node:SetTarget(XF.Targets:GetByRealmFaction(realm, faction))
	self:Add(node)
	return node
end
--#endregion