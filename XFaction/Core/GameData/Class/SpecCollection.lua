local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'SpecCollection'

XFC.SpecCollection = XFC.ObjectCollection:newChildConstructor()

--#region Spec List
-- https://wago.tools/db2/ChrSpecialization
local SpecData =
{
	-- [SpecID] = "EnglishName,IconID,ClassID"
	[62] = "Arcane,135932,8",
	[63] = "Fire,135810,8",
	[64] = "Frost,135846,8",
	[65] = "Holy,135920,2",
	[66] = "Protection,236264,2",
	[70] = "Retribution,135873,2",
	[71] = "Arms,132355,1",
	[72] = "Fury,132347,1",
	[73] = "Protection,132341,1",
	[102] = "Balance,136096,11",
	[103] = "Feral,132115,11",
	[104] = "Guardian,132276,11",
	[105] = "Restoration,136041,11",
	[250] = "Blood,135770,6",
	[251] = "Frost,135773,6",
	[252] = "Unholy,135775,6",
	[253] = "Beast Mastery,461112,3",
	[254] = "Marksmanship,236179,3",
	[255] = "Survival,461113,3",
	[256] = "Discipline,135940,5",
	[257] = "Holy,237542,5",
	[258] = "Shadow,136207,5",
	[259] = "Assassination,236270,4",
	[260] = "Outlaw,236286,4",
	[261] = "Subtlety,132320,4",
	[262] = "Elemental,136048,7",
	[263] = "Enhancement,237581,7",
	[264] = "Restoration,136052,7",
	[265] = "Affliction,136145,9",
	[266] = "Demonology,136172,9",
	[267] = "Destruction,136186,9",
	[268] = "Brewmaster,608951,10",
	[269] = "Windwalker,608953,10",
	[270] = "Mistweaver,608952,10",	
	[577] = "Havoc,1247264,12",
	[581] = "Vengeance,1247265,12",
	[1444] = "Initial,0,7",
	[1446] = "Initial,0,1",
	[1447] = "Initial,0,11",
	[1448] = "Initial,0,3",
	[1449] = "Initial,0,8",
	[1450] = "Initial,0,10",
	[1451] = "Initial,0,2",
	[1452] = "Initial,0,5",
	[1453] = "Initial,0,4",
	[1454] = "Initial,0,9",
	[1455] = "Initial,0,6",
	[1456] = "Initial,0,12",
	[1465] = "Initial,0,13",
	[1467] = "Devastation,4511811,13",
	[1468] = "Preservation,4511812,13",
	[1473] = "Augmentation,5198700,13",
}
--#endregion

--#region Constructors
function XFC.SpecCollection:new()
    local object = XFC.SpecCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function XFC.SpecCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()

		for id, data in pairs (SpecData) do
			local specData = string.Split(data, ',')
			local spec = XFC.Spec:new()
			spec:Initialize()
			spec:Key(tonumber(id))
			spec:ID(tonumber(id))
			spec:Name(specData[1])
			spec:IconID(tonumber(specData[2]))
			spec:Class(XFO.Classes:Get(tonumber(specData[3])))
			self:Add(spec)
			XF:Info(self:ObjectName(), 'Initialized spec [%d:%s:%s]', spec:ID(), spec:Name(), spec:Class():Name())
		end

		XFO.Events:Add({
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
function XFC.SpecCollection:GetInitialClassSpec(inClassID)
	assert(type(inClassID) == 'number')
	for _, spec in self:Iterator() do
		if(spec:Class():ID() == inClassID and spec:Name() == 'Initial') then
			return spec
		end
	end
end

function XFC.SpecCollection:CallbackSpecChanged()
	local self = XFO.Specs
	try(function ()
        XF.Player.Unit:Initialize(XF.Player.Unit:ID())
		XFO.Mailbox:SendDataMessage()
    end).
    catch(function (err)
        XF:Warn(self:ObjectName(), err)
    end)
end
--#endregion