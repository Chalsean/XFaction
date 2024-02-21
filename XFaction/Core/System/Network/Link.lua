local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Link'

XFC.Link = XFC.Object:newChildConstructor()

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
        self:SetTimeStamp(XFF.TimeGetCurrent())
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
    XF:Debug(self:GetObjectName(), '  epochTime (' .. type(self.epochTime) .. '): ' .. tostring(self.epochTime))
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

--#region Serialization
function XFC.Link:Serialize()
    return self:GetFromNode():Serialize() .. ';' .. self:GetToNode():Serialize()
end

local function GetNode(inSerialized)
    assert(type(inSerlialized) == 'string')
    local node = nil
    local key = nil

    try(function()
        node = XFO.Nodes:Pop()
        node:Initialize()
        node:Deserialize(inSerialized)
        key = node:GetKey()
        if(XFO.Nodes:Contains(key)) then
            XFO.Nodes:Push(node)
        else
            XFO.Nodes:Add(node)
        end
    end).
    catch(function(err)
        XF:Warn(self:GetObjectName(), err)
        XFO.Nodes:Push(node)
        throw(err)
    end)

    return XFO.Nodes:Get(key)
end

function XFC.Link:Deserialize(inSerialized)
    assert(type(inSerialized) == 'string')

    local _Nodes = string.Split(inSerialized, ';')
    self:SetFromNode(GetNode(_Nodes[1]))
    self:SetToNode(GetNode(_Nodes[2]))
    self:SetTimeStamp(XFF.TimeGetCurrent())

    self:Initialize()
end
--#endregion