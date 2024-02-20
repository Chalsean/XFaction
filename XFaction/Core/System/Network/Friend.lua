local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Friend'

XFC.Friend = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Friend:new()
    local object = XFC.Friend.parent.new(self)
    object.__name = ObjectName

    object.accountID = nil  -- This is the only constant ID
    object.gameID = nil     -- This is the game ID you use to send whispers
    object.accountName = nil
    object.tag = nil
    object.target = nil
    object.isRunningAddon = false
    object.myLink = false

    return object
end
--#endregion

--#region Print
function XFC.Friend:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  accountID (' .. type(self.accountID) .. '): ' .. tostring(self.accountID))
    XF:Debug(self:GetObjectName(), '  gameID (' .. type(self.gameID) .. '): ' .. tostring(self.gameID))
    XF:Debug(self:GetObjectName(), '  accountName (' .. type(self.accountName) .. '): ' .. tostring(self.accountName))
    XF:Debug(self:GetObjectName(), '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XF:Debug(self:GetObjectName(), '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    XF:Debug(self:GetObjectName(), '  myLink (' .. type(self.myLink) .. '): ' .. tostring(self.myLink))
    if(self:HasTarget()) then self:GetTarget():Print() end
end

function XFC.Friend:Deconstructor()
    self:ParentDeconstructor()
    self.accountID = nil  
    self.gameID = nil     
    self.accountName = nil
    self.tag = nil
    self.target = nil
    self.isRunningAddon = false
    self.myLink = false
    self:Initialize()
end
--#endregion

--#region Accessors
function XFC.Friend:GetAccountID()
    return self.accountID
end

function XFC.Friend:SetAccountID(inAccountID)
    assert(type(inAccountID) == 'number')
    self.accountID = inAccountID
end

function XFC.Friend:GetGameID()
    return self.gameID
end

function XFC.Friend:SetGameID(inGameID)
    assert(type(inGameID) == 'number')
    self.gameID = inGameID
end

function XFC.Friend:GetAccountName()
    return self.accountName
end

function XFC.Friend:SetAccountName(inAccountName)
    assert(type(inAccountName) == 'string')
    self.accountName = inAccountName
end

function XFC.Friend:GetTag()
    return self.tag
end

function XFC.Friend:SetTag(inTag)
    assert(type(inTag) == 'string')
    self.tag = inTag
end

function XFC.Friend:HasTarget()
    return self.target ~= nil
end

function XFC.Friend:GetTarget()
    return self.target
end

function XFC.Friend:SetTarget(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target', 'argument must be Target object')
    self.target = inTarget
end

function XFC.Friend:IsRunningAddon(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isRunningAddon = inBoolean
    end
    return self.isRunningAddon
end
--#endregion

--#region Link
function XFC.Friend:CreateLink()
    if(self:IsRunningAddon() and self:HasTarget()) then
        local link = nil
        try(function ()
            link = XFO.Links:Pop()
            local fromNode = XFO.Nodes:Get(XF.Player.Unit:GetName())
            if(fromNode == nil) then
                fromNode = XF.Nodes:Pop()
                fromNode:Initialize()
                XFO.Nodes:Add(fromNode)
            end
            link:SetFromNode(fromNode)

            local toNode = XFO.Nodes:Get(self:GetName())
            if(toNode == nil) then
                toNode = XFO.Nodes:Pop()
                toNode:SetKey(self:GetName())
                toNode:SetName(self:GetName())
                toNode:SetTarget(self:GetTarget())
                XF.Nodes:Add(toNode)
            end
            link:SetToNode(toNode)

            link:Initialize()
            XFO.Links:Add(link)
        end).
        catch(function (inErrorMessage)
            XF:Warn(self:GetObjectName(), inErrorMessage)
            XF.Links:Push(link)
        end)
    end
end

function XFC.Friend:IsMyLink(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', "argument must be nil or boolean")
    if(inBoolean ~= nil) then
        self.myLink = inBoolean
    end
    return self.myLink
end
--#endregion

--#region Network
function XFC.Friend:Ping()
    XF:Debug(self:GetObjectName(), 'Sending ping to [%s]', self:GetTag())
    XF.Lib.BCTL:BNSendGameData('ALERT', XF.Enum.Tag.BNET, 'PING', _, self:GetGameID())
    XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment() 
end
--#endregion

--#region DataSet
function XFC.Friend:SetFromAccountInfo(inAccountInfo)
    self:SetKey(inAccountInfo.bnetAccountID)
    self:SetID(inAccountInfo.ID)
    self:SetAccountID(inAccountInfo.bnetAccountID)
    self:SetGameID(inAccountInfo.gameAccountInfo.gameAccountID)
    self:SetAccountName(inAccountInfo.accountName)
    self:SetTag(inAccountInfo.battleTag)
    self:SetName(inAccountInfo.gameAccountInfo.characterName)

    local realm = XFO.Realms:GetByID(inAccountInfo.gameAccountInfo.realmID)
    local faction = XFO.Factions:GetByName(inAccountInfo.gameAccountInfo.factionName)
    local target = XFO.Targets:GetByRealmFaction(realm, faction)
    self:SetTarget(target)
end
--#endregion