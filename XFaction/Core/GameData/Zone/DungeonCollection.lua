local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'DungeonCollection'

--#region Abbreviated Names
local NameData = {
	[168] = "EB",
    [198] = "DHT",
    [199] = "BRH",
    [244] = "AD",
    [248] = "WM",
    [456] = "TT",
    [463] = "FALL",
    [464] = "RISE",
}
--#endregion

XFC.DungeonCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.DungeonCollection:new()
    local object = XFC.DungeonCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.DungeonCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

        for id, name in pairs (NameData) do
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