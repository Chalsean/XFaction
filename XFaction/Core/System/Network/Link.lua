local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Link'
local ServerTime = GetServerTime

XFC.Link = Object:newChildConstructor()

--#region Constructors
function XFC.Link:new()
    local object = XFC.Link.parent.new(self)
    object.__name = ObjectName
    object.fromNode = nil
    object.toNode = nil
    object.epochTime = 0
    return object
end

function XFC.Link:Deconstructor()
    self:ParentDeconstructor()
    self.fromNode = nil
    self.toNode = nil
    self.epochTime = 0
end
--#endregion

--#region Initializers
function XFC.Link:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self:SetTimeStamp(ServerTime())
        if(self:HasFromNode() and self:HasToNode()) then
            self:SetKey(XF:GetLinkKey(self:GetFromNode():GetName(), self:GetToNode():GetName()))
        end
        self:IsInitialized(true)
    end
    return self:IsInitialized()
end
--#endregion

--#region Print
function XFC.Link:Print()
    self:ParentPrint()
    XF:Debug(ObjectName, '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
    if(self:HasFromNode()) then self:GetFromNode():Print() end
    if(self:HasToNode()) then self:GetToNode():Print() end
end
--#endregion

--#region Accessors
-- Key is important here because it helps us avoid duplicate entries when both nodes broadcast the link
function XF:GetLinkKey(inFromName, inToName)
	assert(type(inFromName) == 'string')
    assert(type(inToName) == 'string')
    -- The string < check keeps uniqueness
    local key = (inFromName < inToName) and inFromName .. ':' .. inToName or inToName .. ':' .. inFromName
	return key
end

function XFC.Link:IsMyLink()
    return (self:HasFromNode() and self:GetFromNode():IsMyNode()) or 
           (self:HasToNode() and self:GetToNode():IsMyNode())
end

function XFC.Link:HasFromNode()
    return self.fromNode ~= nil
end

function XFC.Link:GetFromNode()
    return self.fromNode
end

function XFC.Link:SetFromNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    self.fromNode = inNode
end

function XFC.Link:HasToNode()
    return self.toNode ~= nil
end

function XFC.Link:GetToNode()
    return self.toNode
end

function XFC.Link:SetToNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    self.toNode = inNode
end

function XFC.Link:GetTimeStamp()
    return self.epochTime
end

function XFC.Link:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self.epochTime = inEpochTime
end
--#endregion

--#region DataSet
function XFC.Link:GetString()
    return self:GetFromNode():GetString() .. ';' .. self:GetToNode():GetString()
end

function XFC.Link:SetObjectFromString(inLinkString)
    assert(type(inLinkString) == 'string')

    local _Nodes = string.Split(inLinkString, ';')
    local fromNode = XFO.Nodes:SetNodeFromString(_Nodes[1])
    self:SetFromNode(fromNode)

    local toNode = XFO.Nodes:Pop()
    toNode:SetObjectFromString(_Nodes[2])
    if(XFO.Nodes:Contains(toNode:GetKey())) then
        toNode = XF.Nodes:Get(toNode:GetKey())
    else
        XFO.Nodes:Add(toNode)
    end
    self:SetToNode(toNode)

    self:Initialize()
end
--#endregion