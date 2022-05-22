local ObjectName = 'CovenantList'
local LogCategory = 'O' .. ObjectName
local MaxRaces = 37

CovenantList = {}

function CovenantList:new(Argument)
    local typeof = type(Argument)
    local newObject = true

	assert(Argument == nil or 
	      (typeof == 'table' and Argument.__name ~= nil and Argument.__name == ObjectName),
	      "argument must be nil or " .. ObjectName .. " object")

    if(typeof == 'table') then
        Object = Argument
        newObject = false
    else
        Object = {}
    end
    setmetatable(Object, self)
    self.__index = self
    self.__name = ObjectName

    if(newObject) then
        self.Covenants = {}
		self.CovenantCount = 0

		for i = 1, table.getn(C_Covenants.GetCovenantIDs()) do
			local CovenantInfo = C_Covenants.GetCovenantData(i)
			local Covenant = Covenant:new(CovenantInfo.name)
			Covenant:SetID(CovenantInfo.ID)

			for j = 1, table.getn(CovenantInfo.soulbindIDs) do
				Covenant:AddSoulbind(CovenantInfo.soulbindIDs[j])
			end

			self.Covenants[Covenant:GetID()] = Covenant
			self.CovenantCount = self.CovenantCount + 1
		end
    end

    return Object
end

function CovenantList:GetCovenant(Argument)
	local typeof = type(Argument)
	assert(typeof == 'string' or typeof == 'number', "argument must be string or number")

	if(typeof == 'string') then
		for i = 1, self.CovenantCount do
			local Covenant = self.Covenants[i]
			if(Covenant:GetName() == Argument) then
				return Covenant
			end
		end
	end
	
    return self.Covenants[Argument]
end