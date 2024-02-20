local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'NodeCollection'

XFC.NodeCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.NodeCollection:new()
    local object = XFC.NodeCollection.parent.new(self)
	object.__name = ObjectName
	object.targetCount = {}
    return object
end

function XFC.NodeCollection:NewObject()
	return XFC.Node:new()
end
--#endregion

--#region Print
function XFC.NodeCollection:Print()
	self:ParentPrint()
	XF:Debug(self:GetObjectName(), '  targetCount (' .. type(self.targetCount) .. '): ')
	XF:DataDumper(self:GetObjectName(), self.targetCount)
end
--#endregion

--#region Hash
function XFC.NodeCollection:Add(inNode)
    assert(type(inNode) == 'table' and inNode.__name == 'Node', 'argument must be Node object')
	self.parent.Add(self, inNode)
	self:IncrementTargetCount(inNode:GetTarget():GetKey())
end

function XFC.NodeCollection:Remove(inKey)
    assert(type(inKey) == 'string')
	local node = self:Get(inKey)
	try(function ()
		self.parent.Remove(self, inKey)
		self:DecrementTargetCount(node:GetTarget():GetKey())
		for _, link in XFO.Links:Iterator() do
			if(link:GetFromNode():Equals(node) or link:GetToNode():Equals(node)) then
				XFO.Links:Remove(link:GetKey())
			end
		end
	end).
	finally(function ()
		self:Push(node)
	end)
end
--#endregion

--#region Accessors
function XFC.NodeCollection:GetTargetCount(inTargetKey)
	return self.targetCount[inTargetKey] or 0
end

function XFC.NodeCollection:IncrementTargetCount(inTargetKey)
	if(self.targetCount[inTargetKey] == nil) then
		self.targetCount[inTargetKey] = 0
	end
	self.targetCount[inTargetKey] = self.targetCount[inTargetKey] + 1
end

function XFC.NodeCollection:DecrementTargetCount(inTargetKey)
	if(self.targetCount[inTargetKey] > 0) then
		self.targetCount[inTargetKey] = self.targetCount[inTargetKey] - 1
	else
		self.targetCount[inTargetKey] = 0	
	end
end
--#endregion