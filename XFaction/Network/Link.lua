local XFG, G = unpack(select(2, ...))
local ObjectName = 'Link'

local ServerTime = GetServerTime

Link = Object:newChildConstructor()

function Link:new()
    local object = Link.parent.new(self)
    object.__name = ObjectName
    object.fromNode = nil
    object.toNode = nil
    object.epochTime = 0
    return object
end

-- Key is important here because it helps us avoid duplicate entries when both nodes broadcast the link
function XFG:GetLinkKey(inFromName, inToName)
	assert(type(inFromName) == 'string')
    assert(type(inToName) == 'string')
    -- The string < check keeps uniqueness
    local key = (inFromName < inToName) and inFromName .. ':' .. inToName or inToName .. ':' .. inFromName
	return key
end

function Link:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:SetTimeStamp(ServerTime())
        if(self:HasFromNode() and self:HasToNode()) then
            self:SetKey(XFG:GetLinkKey(self:GetFromNode():GetName(), self:GetToNode():GetName()))
        end
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end

function Link:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
        if(self:HasFromNode()) then self:GetFromNode():Print() end
        if(self:HasToNode()) then self:GetToNode():Print() end
    end
end

function Link:IsMyLink()
    return (self:HasFromNode() and self:GetFromNode():IsMyNode()) or 
           (self:HasToNode() and self:GetToNode():IsMyNode())
end

function Link:HasFromNode()
    return self.fromNode ~= nil
end

function Link:GetFromNode()
    return self.fromNode
end

function Link:SetFromNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    self.fromNode = inNode
end

function Link:HasToNode()
    return self.toNode ~= nil
end

function Link:GetToNode()
    return self.toNode
end

function Link:SetToNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    self.toNode = inNode
end

function Link:GetString()
    return self:GetFromNode():GetString() .. ';' .. self:GetToNode():GetString()
end

function Link:SetObjectFromString(inLinkString)
    assert(type(inLinkString) == 'string')

    local _Nodes = string.Split(inLinkString, ';')
    local fromNode = XFG.Nodes:SetNodeFromString(_Nodes[1])
    self:SetFromNode(fromNode)

    local toNode = XFG.Nodes:Pop()
    toNode:SetObjectFromString(_Nodes[2])
    if(XFG.Nodes:Contains(toNode:GetKey())) then
        toNode = XFG.Nodes:Get(toNode:GetKey())
    else
        XFG.Nodes:Add(toNode)
    end
    self:SetToNode(toNode)

    self:Initialize()
end

function Link:GetTimeStamp()
    return self.epochTime
end

function Link:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self.epochTime = inEpochTime
end

function Link:FactoryReset()
    self:ParentFactoryReset()
    self.fromNode = nil
    self.toNode = nil
    self.epochTime = 0
end