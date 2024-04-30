local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'NodeCollection'

XFC.NodeCollection = XFC.Factory:newChildConstructor()

--#region Constructors
function XFC.NodeCollection:new()
    local object = XFC.NodeCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.NodeCollection:NewObject()
	return XFC.Node:new()
end
--#endregion

--#region Methods
function XFC.NodeCollection:Remove(inNode)
    assert(type(inNode) == 'table' and inNode.__name == 'Node', 'argument must be Node object')
    self.parent.Remove(self, inNode:Key())
    self:Push(inNode)
end

function XFC.NodeCollection:Deserialize(inNodeString)
    assert(type(inNodeString) == 'string')
    local node = nil
    try(function()
        node = self:Pop()
        node:Deserialize(inNodeString)
        if(self:Contains(node:Key())) then
            local key = node:Key()
            self:Push(node)
            node = self:Get(key)
        else
            self:Add(node)
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
        self:Push(node)
    end)
    return node
end

local function DeserializeLink(inData)
    local nodes = string.Split(inData, ';')

    
    local fromNode = self:Deserialize(nodes[1])
    local toNode = self:Deserialize(nodes[2])

    node:Key(nodeData[1])
    node:Name(nodeData[1])

    local realm = XFO.Realms:Get(tonumber(nodeData[2]))
    local faction = XFO.Factions:Get(tonumber(nodeData[3]))
end

-- A link message is a reset of the links for that node
function XFC.NodeCollection:ProcessMessage(inMessage)
	assert(type(inMessage) == 'table' and inMessage.__name ~= nil and inMessage.__name == 'Message', 'argument must be Message object')
	local linkStrings = string.Split(inMessage:Data(), '|')
	local links = {}
	-- Add new links
    for _, linkString in pairs (linkStrings) do
        local nodes = string.Split(inData, ';')
        local fromNode = self:Deserialize(nodes[1])
        local toNode = self:Deserialize(nodes[2])
        if(not fromNode:ContainsLink(toNode:Key())) then
            toNode:AddLink()
    end
	-- Remove stale links and update datetimes
	for _, link in self:Iterator() do
		-- Consider that we may have gotten link information from the other node
		if(link:From():Name() == sourceKey or link:To():Name() == sourceKey) then
			if(not link:IsMyLink() and linkKeys[link:Key()] == nil) then
				self:Remove(link)
				XF:Debug(self:ObjectName(), 'Removed link due to node broadcast [%s]', link:Key())
			else
				-- Update datetime for janitor process
				link:TimeStamp(XFF.TimeGetCurrent())
			end
		end
	end
end
--#endregion