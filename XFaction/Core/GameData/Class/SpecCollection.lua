local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'SpecCollection'
local GetSpecForClass = GetSpecializationInfoForClassID

SpecCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function SpecCollection:new()
    local object = SpecCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function SpecCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for _, class in XFO.Classes:Iterator() do
			for i = 1, GetNumSpecializationsForClassID(class:ID()) do
				local specID, specName, _, iconID = GetSpecForClass(class:ID(), i)
				if(specID) then
					local spec = Spec:new()
					spec:Initialize()
					spec:Key(specID)
					spec:ID(specID)
					spec:Name(specName)
					spec:SetIconID(iconID)
					self:Add(spec)
					XF:Info(self:ObjectName(), 'Initialized spec [%d:%s]', spec:ID(), spec:Name())
				end
			end
		end
		self:IsInitialized(true)
	end
end
--#endregion