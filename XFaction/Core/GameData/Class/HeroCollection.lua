local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'HeroCollection'

XFC.HeroCollection = XFC.ObjectCollection:newChildConstructor()

--#region Hero List
local HeroData =
{
	[18] = "Voidweaver,26682,5,447444",
	[19] = "Archon,27430,5,453109",
	[20] = "Oracle,26934,5,428924",
	[21] = "Druid of the Claw,26675,11",
	[22] = "Wildstalker,26677,11",
	[23] = "Keeper of the Grove,26686,11",
	[24] = "Elune's Chosen,26685,11",
	[31] = "San'layn,26673,6",
	[32] = "Rider of the Apocalypse,27222,6",
	[33] = "Deathbringer,26672,6",
	[34] = "Fel-Scarred,27066,12",
	[35] = "Aldrachi Reaver,27132,12",
	[36] = "Scalecommander,27067,13",
	[37] = "Flameshaper,27223,13",
	[38] = "Chronowarden,26678,13",
	[39] = "Sunfury,27133,8",
	[40] = "Spellslinger,27429,8",
	[41] = "Frostfire,27017,8",
	[42] = "Sentinel,27529,3",
	[43] = "Pack Leader,27068,3",
	[44] = "Dark Ranger,26679,3",
	[45] = "Shado-Pan,27070,10",
	[46] = "Master of Harmony,12063,10",
	[47] = "Conduit of the Celestials,27069,10",
	[48] = "Templar,26681,2",
	[49] = "Lightsmith,26680,2",
	[50] = "Herald of the Sun,26702,2",
	[51] = "Trickster,27018,4",
	[52] = "Fatebound,27433,4",
	[53] = "Deathstalker,27432,4",
	[54] = "Totemic,26703,7",
	[55] = "Stormbringer,26683,7",
	[56] = "Farseer,27019,7",
	[57] = "Soul Harvester,27530,9",
	[58] = "Hellcaller,12068,9",
	[59] = "Diabolist,26935,9",
	[60] = "Slayer,26704,1",
	[61] = "Mountain Thane,26684,1",
	[62] = "Colossus,26765,1",
}
--#endregion

--#region Constructors
function XFC.HeroCollection:new()
    local object = XFC.HeroCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

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
			hero:Class(XFO.Classes:Get(tonumber(heroData[3])))
			hero:SpellID(tonumber(heroData[4]))
			self:Add(hero)
			XF:Info(self:ObjectName(), 'Initialized hero [%d:%s]', hero:ID(), hero:Name())
		end

		XF.Events:Add({
			name = 'Hero', 
			event = 'SPELLS_CHANGED', 
			callback = XFO.Heros.CallbackHeroChanged, 
			instance = true
		})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.HeroCollection:CallbackHeroChanged(inID)
	local self = XFO.Heros
	try(function ()
		for _, hero in self:Iterator() do
			if(hero:Class():Equals(XF.Player.Unit:Class()) and XFF.PlayerSpellKnown(hero:SpellID())) then
				hero:Print()
			end
		end
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion