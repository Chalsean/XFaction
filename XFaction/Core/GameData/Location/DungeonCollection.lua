local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object

--#region Abbreviated Names
-- https://wago.tools/db2/MapChallengeMode
local NameData = {
	[168] = "EB",
    [198] = "DHT",
    [199] = "BRH",
    [244] = "AD",
    [247] = "ML",
    [248] = "WM",
    [353] = "SB",
    [370] = "OMW",
    [375] = "MTS",
    [376] = "NW",
    [382] = "TP",
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
    [499] = "PSF",
    [500] = "ROOK",
    [501] = "SV",
    [502] = "CT",
    [503] = "AK",
    [504] = "DC",
    [505] = "DB",
    [506] = "CM",
    [507] = "GB",
    [508] = "OF"
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