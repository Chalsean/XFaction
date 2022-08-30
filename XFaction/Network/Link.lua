local XFG, G = unpack(select(2, ...))
local ObjectName = 'Link'

local ServerTime = GetServerTime

Link = Object:newChildConstructor()

function Link:new()
    local _Object = Link.parent.new(self)
    _Object.__name = ObjectName
    _Object._FromNode = nil
    _Object._ToNode = nil
    _Object._EpochTime = 0
    return _Object
end

-- Key is important here because it helps us avoid duplicate entries when both nodes broadcast the link
function XFG:GetLinkKey(inFromName, inToName)
	assert(type(inFromName) == 'string')
    assert(type(inToName) == 'string')
    local _Key = (inFromName < inToName) and inFromName .. ':' .. inToName or inToName .. ':' .. inFromName
	return _Key
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
        XFG:Debug(ObjectName, "  _EpochTime (" .. type(self._EpochTime) .. "): ".. tostring(self._EpochTime))
        if(self:HasFromNode()) then self:GetFromNode():Print() end
        if(self:HasToNode()) then self:GetToNode():Print() end
    end
end

function Link:IsMyLink()
    return (self:HasFromNode() and self:GetFromNode():IsMyNode()) or 
           (self:HasToNode() and self:GetToNode():IsMyNode())
end

function Link:HasFromNode()
    return self._FromNode ~= nil
end

function Link:GetFromNode()
    return self._FromNode
end

function Link:SetFromNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    self._FromNode = inNode
end

function Link:HasToNode()
    return self._ToNode ~= nil
end

function Link:GetToNode()
    return self._ToNode
end

function Link:SetToNode(inNode)
    assert(type(inNode) == 'table' and inNode.__name ~= nil and inNode.__name == 'Node', 'argument must be Node object')
    self._ToNode = inNode
end

function Link:GetString()
    return self:GetFromNode():GetString() .. ';' .. self:GetToNode():GetString()
end

function Link:SetObjectFromString(inLinkString)
    assert(type(inLinkString) == 'string')

    local _Nodes = string.Split(inLinkString, ';')
    local _FromNode = XFG.Nodes:SetNodeFromString(_Nodes[1])
    self:SetFromNode(_FromNode)

    local _ToNode = XFG.Nodes:Pop()
    _ToNode:SetObjectFromString(_Nodes[2])
    if(XFG.Nodes:Contains(_ToNode:GetKey())) then
        _ToNode = XFG.Nodes:Get(_ToNode:GetKey())
    else
        XFG.Nodes:Add(_ToNode)
    end
    self:SetToNode(_ToNode)

    self:Initialize()
end

function Link:GetTimeStamp()
    return self._EpochTime
end

function Link:SetTimeStamp(inEpochTime)
    assert(type(inEpochTime) == 'number')
    self._EpochTime = inEpochTime
end

function Link:FactoryReset()
    self:ParentFactoryReset()
    self._FromNode = nil
    self._ToNode = nil
    self._EpochTime = 0
end