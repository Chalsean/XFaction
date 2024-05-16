local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function

--#region Abbreviated Names
local NameData = {
	[168] = "EB",
    [198] = "DHT",
    [199] = "BRH",
    [244] = "AD",
    [248] = "WM",
    [399] = "RLP",
    [400] = "NO",
    [401] = "AV",
    [402] = "AA",
    [403] = "ULT",
    [404] = "NEL",
    [405] = "BH",
    [406] = "HOI",
    [456] = "TT",
    [463] = "FALL",
    [464] = "RISE",
}
--#endregion

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