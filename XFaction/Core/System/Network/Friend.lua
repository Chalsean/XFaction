local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Friend'

XFC.Friend = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Friend:new()
    local object = XFC.Friend.parent.new(self)
    object.__name = ObjectName
    object.accountID = nil
    object.accountName = nil
    object.gameID = nil
    object.tag = nil
    object.target = nil
    object.unit = nil
    object.canLink = false
    object.isLinked = false
    object.guid = nil
    return object
end

function XFC.Friend:Deconstructor()
    self:ParentDeconstructor()
    self.accountID = nil
    self.accountName = nil
    self.gameID = nil
    self.tag = nil
    self.target = nil
    self.unit = nil
    self.canLink = false
    self.isLinked = false
    self.guid = nil
end

function XFC.Friend:Initialize(inID)
    assert(type(inID) == 'number')

    local accountInfo = XFF.BNetGetFriendInfo(inID)
	if(accountInfo == nil) then
        XF:Warn(self:ObjectName(), 'Failed to get friend status from BNet: [%d]', inID)
		return
    -- Torghast/Plunderstorm are realm 0
	elseif(not accountInfo.isFriend or not accountInfo.gameAccountInfo.isOnline or accountInfo.gameAccountInfo.clientProgram ~= 'WoW' or accountInfo.gameAccountInfo.realmID == 0) then
		return
	end

    self:Key(inID)
    self:ID(inID)
    self:AccountID(accountInfo.bnetAccountID)
    self:GameID(accountInfo.gameAccountInfo.gameAccountID)
    self:AccountName(accountInfo.accountName)
    self:Tag(accountInfo.battleTag)
    self:Name(accountInfo.gameAccountInfo.characterName)
    self:GUID(accountInfo.gameAccountInfo.playerGuid)

    local realm = XFO.Realms:Get(accountInfo.gameAccountInfo.realmID)
    local faction = XFO.Factions:Get(accountInfo.gameAccountInfo.factionName)
    if(realm ~= nil and faction ~= nil and not faction:Equals(XF.Player.Faction)) then
        local target = XF.Targets:GetByRealmFaction(realm, faction)
        if(target ~= nil) then
            self:Target(target)
        end
    end
end
--#endregion

--#region Properties
function XFC.Friend:IsOnline()
    return self:GUID() ~= nil
end

function XFC.Friend:IsOffline()
    return not self:IsOnline()
end

function XFC.Friend:Tag(inTag)
    assert(type(inTag) == 'string' or inTag == nil)
    if(inTag ~= nil) then
        self.tag = inTag
    end
    return self.tag
end

function XFC.Friend:GUID(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil)
    if(inGUID ~= nil) then
        self.guid = inGUID
    end
    return self.guid
end

function XFC.Friend:Target(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target' or inTarget == nil)
    if(inTarget ~= nil) then
        self.target = inTarget
    end
    return self.target
end

function XFC.Friend:AccountID(inID)
    assert(type(inID) == 'number' or inID == nil)
    if(inID ~= nil) then
        self.accountID = inID
    end
    return self.accountID
end

function XFC.Friend:AccountName(inName)
    assert(type(inName) == 'string' or inName == nil)
    if(inName ~= nil) then
        self.accountName = inName
    end
    return self.accountName
end

function XFC.Friend:GameID(inID)
    assert(type(inID) == 'number' or inID == nil)
    if(inID ~= nil) then
        self.gameID = inID
    end
    return self.gameID
end

function XFC.Friend:IsLinked(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean')
    if(inBoolean ~= nil) then
        self.isLinked = inBoolean
    end
    return self.isLinked
end
--#endregion

--#region Methods
function XFC.Friend:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  accountID (' .. type(self.accountID) .. '): ' .. tostring(self.accountID))
    XF:Debug(self:ObjectName(), '  accountName (' .. type(self.accountName) .. '): ' .. tostring(self.accountName))
    XF:Debug(self:ObjectName(), '  gameID (' .. type(self.gameID) .. '): ' .. tostring(self.gameID))
    XF:Debug(self:ObjectName(), '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XF:Debug(self:ObjectName(), '  isLinked (' .. type(self.isLinked) .. '): ' .. tostring(self.isLinked))
    XF:Debug(self:ObjectName(), '  guid (' .. type(self.guid) .. '): ' .. tostring(self.guid))
    if(self:HasTarget()) then self:Target():Print() end
end

function XFC.Friend:HasTarget()
    return self.target ~= nil
end

function XFC.Friend:CanLink()
    return self:IsOnline() and self:HasTarget()
end

function XFC.Friend:HasGUID()
    return self.guid ~= nil
end
--#endregion