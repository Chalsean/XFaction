local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local GetMapIDs = C_ChallengeMode.GetMapTable
local GetMapInfo = C_ChallengeMode.GetMapUIInfo

--#region Abbreviated Names
local NameData = {
	[168] = "EB",
    [198] = "DHT",
    [199] = "BRH",
    [244] = "AD",
    [248] = "WM",
    [456] = "TotT",
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

        local mapIDs = GetMapIDs()
        for _, mapID in ipairs (mapIDs) do
            local name = GetMapInfo(mapID)
            
            if(name ~= nil) then
                local dungeon = XFC.Dungeon:new()
                dungeon:Initialize()
                dungeon:SetKey(mapID)
                dungeon:SetID(mapID)
                dungeon:SetName(name)
                if(NameData[dungeon:GetID()] ~= nil) then
                    dungeon:SetShortName(NameData[dungeon:GetID()])
                end
                self:Add(dungeon)
                XF:Info(self:GetObjectName(), "Initialized dungeon [%d:%s:%s]", dungeon:GetID(), dungeon:GetShortName(), dungeon:GetName())
            end
        end

		self:IsInitialized(true)
	end
end
--#endregion