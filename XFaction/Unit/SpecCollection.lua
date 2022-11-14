local XFG, G = unpack(select(2, ...))
local ObjectName = 'SpecCollection'
local GetSpecForClass = GetSpecializationInfoForClassID

SpecCollection = ObjectCollection:newChildConstructor()

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
		for _, class in XFG.Classes:Iterator() do
			for i = 1, GetNumSpecializationsForClassID(class:GetID()) do
				local specID, specName, _, iconID = GetSpecForClass(class:GetID(), i)
				if(specID) then
					local spec = Spec:new()
					spec:Initialize()
					spec:SetKey(specID)
					spec:SetID(specID)
					spec:SetName(specName)
					spec:SetIconID(iconID)
					self:Add(spec)
					XFG:Info(ObjectName, 'Initialized spec [%d:%s]', spec:GetID(), spec:GetName())
				end
			end
		end
		self:IsInitialized(true)
	end
end
--#endregion