local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function

--#region Hero List
-- https://wago.tools/db2/TraitSubTree
local HeroData =
{
	[18] = "Voidweaver,5927657",
	[19] = "Archon,5764905",
	[20] = "Oracle,5927640",
	[21] = "Druid of the Claw,5927623",
	[22] = "Wildstalker,5927658",
	[23] = "Keeper of the Grove,5927634",
	[24] = "Elune's Chosen,5927624",
	[31] = "San'layn,5927645",
	[32] = "Rider of the Apocalypse,5927644",
	[33] = "Deathbringer,5927621",
	[34] = "Fel-Scarred,5927628",
	[35] = "Aldrachi Reaver,5927616",
	[36] = "Scalecommander,5927646",
	[37] = "Flameshaper,5927629",
	[38] = "Chronowarden,5927617",
	[39] = "Sunfury,5927654",
	[40] = "Spellslinger,5927652",
	[41] = "Frostfire,135866",
	[42] = "Sentinel,4695616",
	[43] = "Pack Leader,5927643",
	[44] = "Dark Ranger,5927620",
	[65] = "Shado-Pan,5927648",
	[66] = "Master of Harmony,5927638",
	[64] = "Conduit of the Celestials,5927619",
	[48] = "Templar,571556",
	[49] = "Lightsmith,5927636",
	[50] = "Herald of the Sun,5927633",
	[51] = "Trickster,5927656",
	[52] = "Fatebound,5927626",
	[53] = "Deathstalker,5927622",
	[54] = "Totemic,5927655",
	[55] = "Stormbringer,5927653",
	[56] = "Farseer,5927625",
	[57] = "Soul Harvester,5927650",
	[58] = "Hellcaller,5927632",
	[59] = "Diabolist,1121021",
	[60] = "Slayer,5927649",
	[61] = "Mountain Thane,5927639",
	[62] = "Colossus,5927618",
}
--#endregion

--#region Constructors
function XFC.HeroCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		for id, data in pairs (HeroData) do
			local heroData = string.Split(data, ',')
			local hero = XFC.Hero:new()
			hero:Initialize()
			hero:Key(tonumber(id))
			hero:ID(tonumber(id))
			hero:Name(heroData[1])
			hero:IconID(tonumber(heroData[2]))
			self:Add(hero)
			XF:Info(self:ObjectName(), 'Initialized hero [%d:%s]', hero:ID(), hero:Name())
		end

		XFO.Events:Add({
			name = 'Hero', 
			event = 'TRAIT_SUB_TREE_CHANGED', 
			callback = XFO.Heros.CallbackHeroChanged, 
			instance = true
		})

		self:IsInitialized(true)
	end
end
--#endregion