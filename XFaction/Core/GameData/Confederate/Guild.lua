local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Guild'

XFC.Guild = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.Guild:new()
    local object = XFC.Guild.parent.new(self)
    object.__name = ObjectName
    object.initials = nil
    object.region = nil
    return object
end
--#endregion

--#region Properties
function XFC.Guild:Initials(inInitials)
    assert(type(inInitials) == 'string' or inInitials == nil)
    if(inInitials ~= nil) then
        self.initials = inInitials
    end
    return self.initials
end

function XFC.Guild:Region(inRegion)
    assert(type(inRegion) == 'table' and inRegion.__name == 'Region' or inRegion == nil)
    if(inRegion ~= nil) then
        self.region = inRegion
    end
    return self.region
end
--#endregion

--#region Methods
function XFC.Guild:Print()
    XF:Debug(self:ObjectName(), '  key (' .. type(self.key) .. '): ' .. tostring(self.key))
    XF:Debug(self:ObjectName(), '  id (' .. type(self.id) .. '): ' .. tostring(self.id))
    XF:Debug(self:ObjectName(), '  name (' .. type(self.name) .. '): ' .. tostring(self.name))
    XF:Debug(self:ObjectName(), '  initials (' .. type(self.initials) .. '): ' .. tostring(self.initials))
    if(self:HasRegion()) then self:Region():Print() end
end

function XFC.Guild:HasRegion()
    return self:Region() ~= nil
end

function XFC.Guild:PrintAudit()
    XF:Info('Audit', 'Name,Note,Rank,LastLoginDaysAgo')
    for _, memberID in pairs (XFF.GuildGetMembers(XF.Player.Guild:ID(), XF.Player.Guild:StreamID())) do
        local unit = XFC.Unit:new()
        unit:Initialize(memberID)
        if(unit:IsInitialized()) then
            XF:Info('Audit', '%s,%s,%s,%d', unit:Name(), unit:Note(), unit:Rank(), unit:LastLogin())
        end
    end
end

function XFC.Guild:Deserialize(inString)
	assert(type(inString) == 'string')

	local regionName, guildID, guildName, guildInitials = inString:match('XFg:(.-):(.-):(.-):(.+)')
	local region = XFO.Regions:Get(regionName)
	
	self:Initialize()
	self:Key(tonumber(guildID))
    self:ID(tonumber(guildID))
    self:Initials(guildInitials)
	self:Name(guildName)
	self:Region(region)
    XF:Info(self:ObjectName(), 'Initialized guild [%s:%s:%s]', self:Key(), self:Name(), self:Region():Name())
end
--#endregion