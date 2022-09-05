local XFG, G = unpack(select(2, ...))
local ObjectName = 'ExpansionCollection'

ExpansionCollection = ObjectCollection:newChildConstructor()

function ExpansionCollection:new()
    local object = ExpansionCollection.parent.new(self)
	object.__name = ObjectName
    object.currentExpansion = nil
    return object
end

function ExpansionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        for expansionID, iconID in pairs(XFG.Settings.Expansions) do
            local expansion = Expansion:new()
            expansion:SetKey(expansionID)
            expansion:SetID(expansionID)
            expansion:SetIconID(iconID)
            if(expansionID == WOW_PROJECT_MAINLINE) then
                expansion:SetName('Retail')
            elseif(expansionID == WOW_PROJECT_CLASSIC) then
                expansion:SetName('Classic')
            end
            self:Add(expansion)
            XFG:Info(ObjectName, 'Initialized expansion [%s:%s]', expansion:GetKey(), expansion:GetName())

            if(WOW_PROJECT_ID == expansionID) then
                self:SetCurrent(expansion)
                local wowVersion = GetBuildInfo()
                local version = Version:new()
                version:SetKey(wowVersion)
                expansion:SetVersion(version)
            end
        end       

		self:IsInitialized(true)
	end
end

function ExpansionCollection:SetCurrent(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name == 'Expansion', 'argument must be Expansion object')
	self.currentExpansion = inExpansion
end

function ExpansionCollection:GetCurrent()
	return self.currentExpansion
end