local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Friend'

XFC.Friend = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Friend:new()
    local object = XFC.Friend.parent.new(self)
    object.__name = ObjectName
    object.tag = nil
    object.target = nil
    object.isActive = false
    object.isRunningAddon = false
    return object
end
--#endregion

--#region Print
function XFC.Friend:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XF:Debug(self:GetObjectName(), '  isActive (' .. type(self.isActive) .. '): ' .. tostring(self.isActive))
    XF:Debug(self:GetObjectName(), '  isRunningAddon (' .. type(self.isRunningAddon) .. '): ' .. tostring(self.isRunningAddon))
    if(self:HasTarget()) then self:GetTarget():Print() end
end

function XFC.Friend:Deconstructor()
    self:ParentDeconstructor()
    self.tag = nil
    self.target = nil
    self.isActive = false
    self.isRunningAddon = false
end
--#endregion

--#region Accessors
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

function XFC.Friend:IsActive(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.isActive = inBoolean
    end
    return self.isActive
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
                fromNode = XFO.Nodes:Pop()
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
                XFO.Nodes:Add(toNode)
            end
            link:SetToNode(toNode)

            link:Initialize()
            XFO.Links:Add(link)
        end).
        catch(function (inErrorMessage)
            XF:Warn(self:GetObjectName(), inErrorMessage)
            XFO.Links:Push(link)
        end)
    end
end
--#endregion

--#region Network
function XFC.Friend:Ping()
    XF:Debug(self:GetObjectName(), 'Sending ping to [%s]', self:GetTag())
    XF.Lib.BCTL:BNSendGameData('ALERT', XF.Enum.Tag.BNET, 'PING', _, self:GetGameID())
    XFO.Metrics:Get(XF.Enum.Metric.BNetSend):Increment() 
end
--#endregion

--#region Serialize
local function CanLink()
    if(inAccountInfo.isFriend and 
    inAccountInfo.gameAccountInfo.isOnline and 
    inAccountInfo.gameAccountInfo.clientProgram == 'WoW') then

     -- If player is in Torghast, don't link
     local realm = XFO.Realms:GetByID(inAccountInfo.gameAccountInfo.realmID)
     if(realm == nil or realm:GetID() == 0) then return false end

     -- We don't want to link to neutral faction toons
     if(inAccountInfo.gameAccountInfo.factionName == 'Neutral') then return false end
     local faction = XFO.Factions:GetByName(inAccountInfo.gameAccountInfo.factionName)

     XF:Trace(ObjectName, 'Checking friend for linkability [%s] GUID [%s] RealmID [%d] RealmName [%s]', inAccountInfo.battleTag, inAccountInfo.gameAccountInfo.playerGuid, inAccountInfo.gameAccountInfo.realmID, inAccountInfo.gameAccountInfo.realmName)

     local target = XFO.Targets:GetByRealmFaction(realm, faction)
     if(target ~= nil and not target:IsMyTarget()) then return true, target end
 end
 return false
end

function XFC.Friend:Deserialize(inAccountInfo)
    self:SetKey(inAccountInfo.gameAccountInfo.gameAccountID)
    self:SetID(inAccountInfo.bnetAccountID)
    self:SetName(inAccountInfo.battleTag)

    if(inAccountInfo.gameAccountInfo.isOnline and inAccountInfo.gameAccountInfo.clientProgram == 'WoW') then
        self:SetName(inAccountInfo.gameAccountInfo.characterName)
        local realm = XFO.Realms:GetByID(inAccountInfo.gameAccountInfo.realmID)
            -- Ignore Torghast
            if(realm ~= nil and realm:GetID() ~= 0) then
                local faction = XFO.Factions:GetByName(inAccountInfo.gameAccountInfo.factionName)
                local target = XFO.Targets:GetByRealmFaction(realm, faction)
                if(target ~= nil) then
                    self:SetTarget(target)
                end
            end
            self:IsActive(true)
        end
    end
end
--#endregion