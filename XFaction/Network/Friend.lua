local XFG, G = unpack(select(2, ...))
local ObjectName = 'Friend'

Friend = Object:newChildConstructor()

function Friend:new()
    local _Object = Friend.parent.new(self)
    _Object.__name = ObjectName

    _Object._ID = nil         -- This the "friend index" you use to look things up
    _Object._AccountID = nil  -- This is the only constant ID
    _Object._GameID = nil     -- This is the game ID you use to send whispers
    _Object._AccountName = nil
    _Object._Tag = nil
    _Object._Target = nil
    _Object._IsRunningAddon = false
    _Object._DateTime = 0  -- Last time we heard from them via addon
    _Object._MyLink = false

    return _Object
end

function Friend:Print()
    if(XFG.DebugFlag) then
        self:ParentPrint()
        XFG:Debug(ObjectName, "  _ID (" .. type(self._ID) .. "): ".. tostring(self._ID))
        XFG:Debug(ObjectName, "  _AccountID (" .. type(self._AccountID) .. "): ".. tostring(self._AccountID))
        XFG:Debug(ObjectName, "  _GameID (" .. type(self._GameID) .. "): ".. tostring(self._GameID))
        XFG:Debug(ObjectName, "  _AccountName (" ..type(self._AccountName) .. "): ".. tostring(self._AccountName))
        XFG:Debug(ObjectName, "  _Tag (" ..type(self._Tag) .. "): ".. tostring(self._Tag))
        XFG:Debug(ObjectName, "  _IsRunningAddon (" ..type(self._IsRunningAddon) .. "): ".. tostring(self._IsRunningAddon))
        XFG:Debug(ObjectName, "  _MyLink (" ..type(self._MyLink) .. "): ".. tostring(self._MyLink))
        if(self:HasTarget()) then self:GetTarget():Print() end
    end
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
        local _NewLink = nil
        try(function ()
            _NewLink = XFG.Links:Pop()
            local _FromNode = XFG.Nodes:Get(XFG.Player.Unit:GetName())
            if(_FromNode == nil) then
                _FromNode = XFG.Nodes:Pop()
                _FromNode:Initialize()
                XFG.Nodes:Add(_FromNode)
            end
            _NewLink:SetFromNode(_FromNode)

            local _ToNode = XFG.Nodes:Get(self:GetName())
            if(_ToNode == nil) then
                _ToNode = XFG.Nodes:Pop()
                _ToNode:SetKey(self:GetName())
                _ToNode:SetName(self:GetName())
                _ToNode:SetTarget(self:GetTarget())
                XFG.Nodes:Add(_ToNode)
            end
            _NewLink:SetToNode(_ToNode)

            _NewLink:Initialize()
            XFG.Links:Add(_NewLink)
        end).
        catch(function (inErrorMessage)
            XFG:Warn(ObjectName, inErrorMessage)
            XFG.Links:Push(_NewLink)
        end)
    end
end

function Friend:IsMyLink(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self._MyLink = inBoolean
    end
    return self._MyLink
end

function Friend:FactoryReset()
    self:ParentFactoryReset()
    self._ID = nil         
    self._AccountID = nil  
    self._GameID = nil     
    self._AccountName = nil
    self._Tag = nil
    self._Target = nil
    self._IsRunningAddon = false
    self._DateTime = 0  
    self._MyLink = false
    self:Initialize()
end

function Friend:Ping()
    if(XFG.DebugFlag) then
        XFG:Debug(ObjectName, 'Sending ping to [%s]', self:GetTag())
    end
    BCTL:BNSendGameData('ALERT', XFG.Settings.Network.Message.Tag.BNET, 'PING', _, self:GetGameID())
    XFG.Metrics:Get(XFG.Settings.Metric.BNetSend):Increment() 
end