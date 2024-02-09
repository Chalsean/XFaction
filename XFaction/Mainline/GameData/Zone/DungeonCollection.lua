local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object

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

XFC.DungeonCollection = ObjectCollection:newChildConstructor()

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
            dungeon:SetKey(id)
            dungeon:SetID(id)
            dungeon:SetName(name)
            self:Add(dungeon)
            XF:Info(self:GetObjectName(), "Initialized dungeon [%d:%s]", dungeon:GetID(), dungeon:GetName())
        end

		self:IsInitialized(true)
	end
end
--#endregion