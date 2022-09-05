local XFG, G = unpack(select(2, ...))
local ObjectName = 'SpecCollection'
local GetSpecForClass = GetSpecializationInfoForClassID

SpecCollection = ObjectCollection:newChildConstructor()

function SpecCollection:new()
    local object = SpecCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function SpecCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		if(not XFG.Cache.UIReload or XFG.Cache.Specs == nil) then
			XFG.Cache.Specs = {}
			for _, class in XFG.Classes:Iterator() do
				for i = 1, GetNumSpecializationsForClassID(class:GetID()) do
					local specID, specName, _, iconID = GetSpecForClass(class:GetID(), i)
					if(specID) then
						XFG.Cache.Specs[#XFG.Cache.Specs + 1] = {
							ID = specID,
							Name = specName,
							Icon = iconID,
						}
					end
				end
			end
		else
			XFG:Debug(ObjectName, 'Spec information found in cache')
		end

		for _, data in ipairs(XFG.Cache.Specs) do
			local spec = Spec:new()
			spec:Initialize()
			spec:SetKey(data.ID)
			spec:SetID(data.ID)
			spec:SetName(data.Name)
			spec:SetIconID(data.Icon)
			self:Add(spec)
			XFG:Info(ObjectName, 'Initialized spec [%d:%s]', spec:GetID(), spec:GetName())
		end

		self:IsInitialized(true)
	end
end