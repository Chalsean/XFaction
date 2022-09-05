local XFG, G = unpack(select(2, ...))
local ObjectName = 'ClassCollection'
local GetClassInfo = C_CreatureInfo.GetClassInfo
local GetClassColor = C_ClassColor.GetClassColor

ClassCollection = ObjectCollection:newChildConstructor()

function ClassCollection:new()
	local object = ClassCollection.parent.new(self)
	object.__name = ObjectName
    return object
end

function ClassCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		if(not XFG.Cache.UIReload or XFG.Cache.Classes == nil) then
			XFG.Cache.Classes = {}
			for i = 1, GetNumClasses() do
				local classInfo = GetClassInfo(i)
				if(classInfo) then
					XFG.Cache.Classes[#XFG.Cache.Classes + 1] = {
						ID = classInfo.classID,
						Name = classInfo.className,
						API = classInfo.classFile,
					}		
				end
			end
		else
			XFG:Debug(ObjectName, 'Class information found in cache')
		end

		for _, classData in ipairs(XFG.Cache.Classes) do
			local class = Class:new()
			class:Initialize()
			class:SetKey(classData.ID)
			class:SetID(classData.ID)
			class:SetName(classData.Name)
			class:SetAPIName(classData.API)

			if(not XFG.Colors:Contains(class:GetName())) then
				local mixin = GetClassColor(class:GetAPIName())
				XFG.Colors:Add(class:GetName(), mixin)
			end

			class:SetColor(XFG.Colors:Get(class:GetName()))
			self:Add(class)
			XFG:Info(ObjectName, 'Initialized class [%d:%s]', class:GetID(), class:GetName())	
		end

		self:IsInitialized(true)
	end
end