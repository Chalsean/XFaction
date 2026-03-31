local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'MythicKeyCollection'

--#region Constructors
function XFC.MythicKeyCollection:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()

        -- Far as can tell does not fire event, so call and pray it loads before we query for the data
		XFF.MythicRequestMaps()

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
--#endregion