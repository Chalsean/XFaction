local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'ProfessionCollection'

XFC.ProfessionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Profession List
-- https://wago.tools/db2/Profession
local ProfessionData =
{
	-- [SkillLineID] = "EnglishName,IconID"
	[164] = "Blacksmithing,4620670",
	[165] = "Leatherworking,4620678",
	[171] = "Alchemy,4620669",
	[182] = "Herbalism,4620675",
	[186] = "Mining,4620679",
	[197] = "Tailoring,4620681",
	[202] = "Engineering,4620673",
	[333] = "Enchanting,4620672",
	[393] = "Skinning,4620680",
	[755] = "Jewelcrafting,4620677",
	[773] = "Inscription,4620676",
}
--#endregion

--#region Constructors
function XFC.ProfessionCollection:new()
	local object = XFC.ProfessionCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.ProfessionCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		for id, data in pairs (ProfessionData) do
			local professionData = string.Split(data, ',')
			local profession = XFC.Profession:new()
			profession:ID(tonumber(id))
			profession:IconID(tonumber(professionData[2]))
			profession:Name(professionData[1])
			profession:Key(tonumber(id))
			profession:IsInitialized(true)
			self:Add(profession)
			XF:Info(self:ObjectName(), 'Initialized profession [%d:%s]', profession:ID(), profession:Name())
		end

		XFO.Events:Add({
			name = 'Profession', 
			event = 'SKILL_LINES_CHANGED', 
			callback = XFO.Professions.CallbackSkillChanged
		})

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.ProfessionCollection:Get(inKey)
	assert(type(inKey) == 'string' or type(inKey) == 'number' or inKey == nil)
	if(inKey == nil) then return nil end
	if(type(inKey) == 'string') then
		for _, profession in self:Iterator() do
			if(profession:Name() == inKey) then
				return profession
			end
		end
	else
		return self.parent.Get(self, inKey)
	end
end

function XFC.ProfessionCollection:CallbackSkillChanged()
    try(function ()
        XF.Player.Unit:Initialize(XF.Player.Unit:ID())
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion