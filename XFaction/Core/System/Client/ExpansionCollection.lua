local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ExpansionCollection'

ExpansionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function ExpansionCollection:new()
    local object = ExpansionCollection.parent.new(self)
	object.__name = ObjectName
    object.currentExpansion = nil
    return object
end
--#endregion

--#region Initializers
function ExpansionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        for _, expansionID in ipairs(XF.Settings.Expansions) do
            local expansion = Expansion:new()
            expansion:Key(expansionID)
            expansion:ID(expansionID)
            if(expansionID == WOW_PROJECT_MAINLINE) then
                expansion:Name('Retail')
            elseif(expansionID == WOW_PROJECT_CLASSIC) then
                expansion:Name('Classic')
            end
            self:Add(expansion)
            XF:Info(ObjectName, 'Initialized expansion [%s:%s]', expansion:Key(), expansion:Name())

            if(WOW_PROJECT_ID == expansionID) then
                self:SetCurrent(expansion)
                local wowVersion = GetBuildInfo()
                local version = Version:new()
                version:Key(wowVersion)
                expansion:SetVersion(version)
            end
        end       

		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function ExpansionCollection:SetCurrent(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name == 'Expansion', 'argument must be Expansion object')
	self.currentExpansion = inExpansion
end

function ExpansionCollection:GetCurrent()
	return self.currentExpansion
end
--#endregion