local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'ExpansionCollection'

XFC.ExpansionCollection = XFC.ObjectCollection:newChildConstructor()

--#region Constructors
function XFC.ExpansionCollection:new()
    local object = XFC.ExpansionCollection.parent.new(self)
	object.__name = ObjectName
    object.currentExpansion = nil
    return object
end
--#endregion

--#region Initializers
function XFC.ExpansionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        for _, expansionID in ipairs(XF.Settings.Expansions) do
            local expansion = XFC.Expansion:new()
            expansion:Initialize()
            expansion:SetKey(expansionID)
            expansion:SetID(expansionID)
            if(expansionID == WOW_PROJECT_MAINLINE) then
                expansion:SetName('Retail')
            elseif(expansionID == WOW_PROJECT_CLASSIC) then
                expansion:SetName('Classic')
            end
            self:Add(expansion)
            XF:Info(self:GetObjectName(), 'Initialized expansion [%s:%s]', expansion:GetKey(), expansion:GetName())

            if(WOW_PROJECT_ID == expansionID) then
                self:SetCurrent(expansion)
                local wowVersion = XFF.ClientGetVersion()
                local version = XFC.Version:new()
                version:Initialize()
                version:SetKey(wowVersion)
                expansion:SetVersion(version)
            end
        end       

		self:IsInitialized(true)
	end
end
--#endregion

--#region Accessors
function XFC.ExpansionCollection:SetCurrent(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name == 'Expansion', 'argument must be Expansion object')
	self.currentExpansion = inExpansion
end

function XFC.ExpansionCollection:GetCurrent()
	return self.currentExpansion
end
--#endregion