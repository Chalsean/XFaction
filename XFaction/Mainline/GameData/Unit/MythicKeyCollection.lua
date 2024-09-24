local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MythicKeyCollection'

--#region Constructors
function XFC.MythicKeyCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()

        -- Far as can tell does not fire event, so call and pray it loads before we query for the data
		XFF.MythicRequestMaps()

        XFO.Events:Add({
            name = 'Mythic', 
            event = 'CHALLENGE_MODE_COMPLETED', 
            callback = XFO.Keys.CallbackKeyChanged, 
            instance = true,
            start = true
        })
        
        self:IsInitialized(true)
    end
end
--#endregion

--#region Methods
function XFC.MythicKeyCollection:GetMyKey()

    local level = XFF.MythicLevel()    
    local mapID = XFF.MythicMapID()

    if(level ~= nil and mapID ~= nil) then
        local dungeon = XFO.Dungeons:Get(mapID)
        local key = tostring(level) .. '.' .. tostring(mapID)
        if(not self:Contains(key)) then
            local mkey = XFC.MythicKey:new()
            mkey:Initialize()
            mkey:Key(key)
            mkey:ID(level)
            mkey:Dungeon(dungeon)
            self:Add(mkey)
        end

        return self:Get(key)
    end
end

function XFC.MythicKeyCollection:CallbackKeyChanged()
    local self = XFO.Keys

    try(function()
        local mkey = self:GetMyKey()
        if(mkey ~= nil) then
            XF.Player.Unit:MythicKey(mkey)
        end
    end).
    catch(function(err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion