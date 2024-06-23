local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'HeroCollection'

XFC.HeroCollection = XFC.ObjectCollection:newChildConstructor()

--#region Hero List
local HeroData =
{
	-- [SpecID] = "EnglishName,IconID,ClassID"
--	[1473] = "Augmentation,5198700,13",
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
			self:Add(hero)
			XF:Info(self:ObjectName(), 'Initialized hero [%d:%s:%s]', hero:ID(), hero:Name(), hero:Class():Name())
		end

		XF.Events:Add({
			name = 'Spec', 
			event = 'ACTIVE_TALENT_GROUP_CHANGED', 
			callback = XFO.Specs.CallbackSpecChanged, 
			instance = true
		})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.HeroCollection:GetInitialClassSpec(inClassID)
	assert(type(inClassID) == 'number')
	for _, spec in self:Iterator() do
		if(spec:Class():ID() == inClassID and spec:Name() == 'Initial') then
			return spec
		end
	end
end

function XFC.HeroCollection:CallbackSpecChanged()
	try(function ()
        XF.Player.Unit:Initialize(XF.Player.Unit:ID())
        XF.Player.Unit:Broadcast()
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion