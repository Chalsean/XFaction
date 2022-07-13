local XFG, G = unpack(select(2, ...))
local ObjectName = 'Friend'
local LogCategory = 'NFriend'

Friend = {}

function Friend:new()
    _Object = {}
    setmetatable(_Object, self)
    self.__index = self
    self.__name = ObjectName

    self._Key = nil
    self._ID = nil         -- This the "friend index" you use to look things up
    self._AccountID = nil  -- This is the only constant ID
    self._GameID = nil     -- This is the game ID you use to send whispers
    self._AccountName = nil
    self._Tag = nil
    self._Target = nil
    self._Name = nil
    self._IsRunningAddon = false
    self._DateTime = 0  -- Last time we heard from them via addon
    self._MyLink = false

    return _Object
end

function Friend:Print()
    XFG:SingleLine(LogCategory)
    XFG:Debug(LogCategory, ObjectName .. " Object")
    XFG:Debug(LogCategory, "  _Key (" .. type(self._Key) .. "): ".. tostring(self._Key))
    XFG:Debug(LogCategory, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
    XFG:Debug(LogCategory, "  _AccountID (" .. type(self._AccountID) .. "): ".. tostring(self._AccountID))
    XFG:Debug(LogCategory, "  _GameID (" .. type(self._GameID) .. "): ".. tostring(self._GameID))
    XFG:Debug(LogCategory, "  _AccountName (" ..type(self._AccountName) .. "): ".. tostring(self._AccountName))
    XFG:Debug(LogCategory, "  _Tag (" ..type(self._Tag) .. "): ".. tostring(self._Tag))
    XFG:Debug(LogCategory, "  _Name (" ..type(self._Name) .. "): ".. tostring(self._Name))
    XFG:Debug(LogCategory, "  _IsRunningAddon (" ..type(self._IsRunningAddon) .. "): ".. tostring(self._IsRunningAddon))
    XFG:Debug(LogCategory, "  _MyLink (" ..type(self._MyLink) .. "): ".. tostring(self._MyLink))
    if(self:HasTarget()) then
        self._Target:Print()
    end
end

function Friend:GetKey()
    return self._Key
end

function Friend:SetKey(inKey)
    assert(type(inKey) == 'number')
    self._Key = inKey
    return self:GetKey()
end

function Friend:GetID()
    return self._ID
end

function Friend:SetID(inID)
    assert(type(inID) == 'number')
    self._ID = inID
    return self:GetID()
end

function Friend:GetAccountID()
    return self._AccountID
end

function Friend:SetAccountID(inAccountID)
    assert(type(inAccountID) == 'number')
    self._AccountID = inAccountID
    return self:GetAccountID()
end

function Friend:GetGameID()
    return self._GameID
end

function Friend:SetGameID(inGameID)
    assert(type(inGameID) == 'number')
    self._GameID = inGameID
    return self:GetGameID()
end

function Friend:GetAccountName()
    return self._AccountName
end

function Friend:SetAccountName(inAccountName)
    assert(type(inAccountName) == 'string')
    self._AccountName = inAccountName
    return self:GetAccountName()
end

function Friend:GetTag()
    return self._Tag
end

function Friend:SetTag(inTag)
    assert(type(inTag) == 'string')
    self._Tag = inTag
    return self:GetTag()
end

function Friend:HasTarget()
    return self._Target ~= nil
end

function Friend:GetTarget()
    return self._Target
end

function Friend:SetTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name ~= nil and inTarget.__name == 'Target', "argument must be Target object")
    self._Target = inTarget
    return self:GetTarget()
end

function Friend:GetName()
    return self._Name
end

function Friend:SetName(inName)
    assert(type(inName) == 'string')
    self._Name = inName
    return self:GetName()
end

function Friend:IsRunningAddon(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._IsRunningAddon = inBoolean
    end
    return self._IsRunningAddon
end

function Friend:GetDateTime()
    return self._DateTime
end

function Friend:SetDateTime(inDateTime)
    assert(type(inDateTime) == 'number')
    self._DateTime = inDateTime
    return self:GetDateTime()
end

function Friend:CreateLink()
    if(self:IsRunningAddon() and self:HasTarget()) then
        local _NewLink = Link:new()
        local _FromNode = XFG.Nodes:GetNode(XFG.Player.Unit:GetName())
        if(_FromNode == nil) then
            _FromNode = Node:new(); _FromNode:MyInitialize()
            XFG.Nodes:AddNode(_FromNode)
        end
        _NewLink:SetFromNode(_FromNode)

        local _ToNode = XFG.Nodes:GetNode(self:GetName())
        if(_ToNode == nil) then
            _ToNode = Node:new()
            _ToNode:SetKey(self:GetName())
            _ToNode:SetName(self:GetName())
            _ToNode:SetTarget(self:GetTarget())
            XFG.Nodes:AddNode(_ToNode)
        end
        _NewLink:SetToNode(_ToNode)

        _NewLink:Initialize()
        XFG.Links:AddLink(_NewLink)
        XFG.DataText.Links:RefreshBroker()
    end
end

function Friend:IsMyLink(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._MyLink = inBoolean
    end
    return self._MyLink
end