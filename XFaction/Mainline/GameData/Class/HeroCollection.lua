local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function

--#region Hero List
local HeroData =
{
	[18] = "Voidweaver,26682",
	[19] = "Archon,27430",
	[20] = "Oracle,26934",
	[21] = "Druid of the Claw,26675",
	[22] = "Wildstalker,26677",
	[23] = "Keeper of the Grove,26686",
	[24] = "Elune's Chosen,26685",
	[31] = "San'layn,26673",
	[32] = "Rider of the Apocalypse,27222",
	[33] = "Deathbringer,26672",
	[34] = "Fel-Scarred,27066",
	[35] = "Aldrachi Reaver,27132",
	[36] = "Scalecommander,27067",
	[37] = "Flameshaper,27223",
	[38] = "Chronowarden,26678",
	[39] = "Sunfury,27133",
	[40] = "Spellslinger,27429",
	[41] = "Frostfire,27017",
	[42] = "Sentinel,27529",
	[43] = "Pack Leader,27068",
	[44] = "Dark Ranger,26679",
	[45] = "Shado-Pan,27070",
	[46] = "Master of Harmony,12063",
	[47] = "Conduit of the Celestials,27069",
	[48] = "Templar,26681",
	[49] = "Lightsmith,26680",
	[50] = "Herald of the Sun,26702",
	[51] = "Trickster,27018",
	[52] = "Fatebound,27433",
	[53] = "Deathstalker,27432",
	[54] = "Totemic,26703",
	[55] = "Stormbringer,26683",
	[56] = "Farseer,27019",
	[57] = "Soul Harvester,27530",
	[58] = "Hellcaller,12068",
	[59] = "Diabolist,26935",
	[60] = "Slayer,26704",
	[61] = "Mountain Thane,26684",
	[62] = "Colossus,26765",
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