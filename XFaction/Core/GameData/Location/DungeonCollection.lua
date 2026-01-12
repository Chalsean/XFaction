local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function

XFC.DungeonCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.DungeonCollection:new()
    local object = XFC.DungeonCollection.parent.new(self)
	object.__name = 'DungeonCollection'
    return object
end
--#endregion

--#region Initializers
function XFC.DungeonCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

        XFF.MythicRequestMaps()
        for _, id in ipairs (XFF.MythicCurrentSeasonMapIDs()) do
            local name = XFF.MythicMapInfo(id)
            local dungeon = XFC.Dungeon:new()
            dungeon:Initialize()
            dungeon:Key(id)
            dungeon:ID(id)
            dungeon:Name(name)
            self:Add(dungeon)
            XF:Info(self:ObjectName(), "Initialized dungeon [%d:%s]", dungeon:ID(), dungeon:Name())
        end

		self:IsInitialized(true)
	end
end
--#endregion