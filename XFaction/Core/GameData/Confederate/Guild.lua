local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Guild'

XFC.Guild = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Guild:new()
    local object = XFC.Guild.parent.new(self)
    object.__name = ObjectName
    object.streamID = nil  -- Only the player's guild will have a StreamerID (this is gchat)
    object.realm = nil
    return object
end
--#endregion

--#region Properties
function XFC.Guild:StreamID(inStreamID)
    assert(type(inStreamID) == 'number' or inStreamID == nil, 'argument must be number or nil')
    if(inStreamID ~= nil) then
        self.streamID = inStreamID
    end
    return self.streamID
end

function XFC.Guild:Realm(inRealm)
    assert(type(inRealm) == 'table' and inRealm.__name == 'Realm' or inRealm == nil, 'argument must be Realm object or nil')
    if(inRealm ~= nil) then
        self.realm = inRealm
    end
    return self.realm
end
--#endregion

--#region Methods
function XFC.Guild:Print()
    self:ParentPrint()
    XF:Debug(self:ObjectName(), '  streamID (' .. type(self.streamID) .. '): ' .. tostring(self.streamID))
    if(self:Realm() ~= nil) then self:Realm():Print() end
end

function XFC.Guild:PrintAudit()
    XF:Info('Audit', 'Name,Note,Rank,LastLoginDaysAgo')
    for _, memberID in pairs (XFF.GuildGetMembers(XF.Player.Guild:ID(), XF.Player.Guild:StreamID())) do
        local unit = Unit:new()
        unit:Initialize(memberID)
        if(unit:IsInitialized()) then
            XF:Info('Audit', '%s,%s,%s,%d', unit:Name(), unit:Note(), unit:Rank(), unit:LastLogin())
        end
    end
end

function XFC.Guild:Deserialize(inString)
	assert(type(inString) == 'string')

	local realmNumber, factionID, guildName, guildInitials = inString:match('XFg:(.-):(.-):(.-):(.+)')
	local realm = XFO.Realms:Get(tonumber(realmNumber))
	
	self:Initialize()
	self:Key(guildInitials)
	self:Name(guildName)
	self:Realm(realm)
    XF:Info(self:ObjectName(), 'Initialized guild [%s:%s:%s]', self:Key(), self:Name(), self:Realm():Name())
end
--#endregion