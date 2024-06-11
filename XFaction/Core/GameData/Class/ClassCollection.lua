local XF, G = unpack(select(2, ...))
local ObjectName = 'ClassCollection'

ClassCollection = ObjectCollection:newChildConstructor()

--#region Constructors
function ClassCollection:new()
	local object = ClassCollection.parent.new(self)
	object.__name = ObjectName
    return object
end
--#endregion

--#region Initializers
function ClassCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		for i = 1, GetNumClasses() do
			local name, apiName, ID = GetClassInfo(i)
			local class = Class:new()
			class:Initialize()
			class:SetKey(ID)
			class:SetID(ID)
			class:SetName(name)
			class:SetAPIName(apiName)
			local mixin = C_ClassColor.GetClassColor(apiName)
			class:SetRGB(mixin.r * 255, mixin.g * 255, mixin.b * 255)
			class:SetHex(mixin:GenerateHexColor())
			self:Add(class)
			XF:Info(ObjectName, 'Initialized class [%d:%s]', class:GetID(), class:GetName())
		end
		self:IsInitialized(true)
	end
end
--#endregion