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
		error('Received nil for friend [%d]', inID)
	elseif(not accountInfo.isFriend) then
		return
	end

    self:Key(accountInfo.bnetAccountID)
    self:ID(inID)
    self:AccountID(accountInfo.bnetAccountID)
    self:GameID(accountInfo.gameAccountInfo.gameAccountID)
    self:AccountName(accountInfo.accountName)
    self:Tag(accountInfo.battleTag)
    self:CanLink(false)
	
    -- Torghast/Plunderstorm are realm 0
    if(accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.clientProgram == 'WoW' and accountInfo.gameAccountInfo.realmID ~= 0) then
        self:Name(accountInfo.gameAccountInfo.characterName)
        self:GUID(accountInfo.gameAccountInfo.playerGuid)

        local realm = XFO.Realms:Get(accountInfo.gameAccountInfo.realmID)
        local faction = XFO.Factions:Get(accountInfo.gameAccountInfo.factionName)
        if(realm ~= nil and XFO.Targets:Contains(realm, faction)) then
            local target = XFO.Targets:Get(realm, faction)
            self:Target(target)
            if(accountInfo.isFriend and not self:Target():Faction():IsNeutral() and not target:IsMyTarget()) then
                self:CanLink(true)
            end
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
    assert(type(inTag) == 'string' or inTag == nil, 'argument must be string or nil')
    if(inTag ~= nil) then
        self.tag = inTag
    end
    return self.tag
end

function XFC.Friend:GUID(inGUID)
    assert(type(inGUID) == 'string' or inGUID == nil, 'argument must be string or nil')
    if(inGUID ~= nil) then
        self.guid = inGUID
    end
    return self.guid
end

function XFC.Friend:Target(inTarget)
    assert(type(inTarget) == 'table' and inTarget.__name == 'Target' or inTarget == nil, 'argument must be Target object or nil')
    if(inTarget ~= nil) then
        self.target = inTarget
    end
    return self.target
end

function XFC.Friend:AccountID(inID)
    assert(type(inID) == 'number' or inID == nil, 'argument must be number or nil')
    if(inID ~= nil) then
        self.accountID = inID
    end
    return self.accountID
end

function XFC.Friend:AccountName(inName)
    assert(type(inName) == 'string' or inName == nil, 'argument must be string or nil')
    if(inName ~= nil) then
        self.accountName = inName
    end
    return self.accountName
end

function XFC.Friend:GameID(inID)
    assert(type(inID) == 'number' or inID == nil, 'argument must be number or nil')
    if(inID ~= nil) then
        self.gameID = inID
    end
    return self.gameID
end

function XFC.Friend:CanLink(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.canLink = inBoolean
    end
    return self.canLink
end

function XFC.Friend:IsLinked(inBoolean)
    assert(inBoolean == nil or type(inBoolean) == 'boolean', 'argument must be nil or boolean')
    if(inBoolean ~= nil) then
        self.canLink = inBoolean
    end
    return self.canLink
end
--#endregion

--#region Methods
function XFC.Friend:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  accountID (' .. type(self.accountID) .. '): ' .. tostring(self.accountID))
    XF:Debug(self:ObjectName(), '  accountName (' .. type(self.accountName) .. '): ' .. tostring(self.accountName))
    XF:Debug(self:ObjectName(), '  gameID (' .. type(self.gameID) .. '): ' .. tostring(self.gameID))
    XF:Debug(self:ObjectName(), '  tag (' .. type(self.tag) .. '): ' .. tostring(self.tag))
    XF:Debug(self:ObjectName(), '  canLink (' .. type(self.canLink) .. '): ' .. tostring(self.canLink))
    XF:Debug(self:ObjectName(), '  isLinked (' .. type(self.isLinked) .. '): ' .. tostring(self.isLinked))
    XF:Debug(self:ObjectName(), '  guid (' .. type(self.canguidLink) .. '): ' .. tostring(self.guid))
    if(self:HasTarget()) then self:Target():Print() end
end

function XFC.Friend:HasTarget()
    return self.target ~= nil
end
--#endregion