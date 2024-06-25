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

function XFC.ExpansionCollection:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()

        for _, expansionID in ipairs(XF.Settings.Expansions) do
            local expansion = XFC.Expansion:new()
            expansion:Initialize()
            expansion:Key(expansionID)
            expansion:ID(expansionID)
            if(expansionID == WOW_PROJECT_MAINLINE) then
                expansion:Name('Retail')
            elseif(expansionID == WOW_PROJECT_CLASSIC) then
                expansion:Name('Classic')
            end
            self:Add(expansion)
            XF:Info(self:ObjectName(), 'Initialized expansion [%s:%s]', expansion:Key(), expansion:Name())

            if(WOW_PROJECT_ID == expansionID) then
                self:Current(expansion)
                local wowVersion = XFF.ClientVersion()
                local version = XFC.Version:new()
                version:Initialize()
                version:Key(wowVersion)
                expansion:Version(version)
            end
        end       

		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties
function XFC.ExpansionCollection:Current(inExpansion)
    assert(type(inExpansion) == 'table' and inExpansion.__name == 'Expansion' or inExpansion == nil)
    if(inExpansion ~= nil) then
	    self.currentExpansion = inExpansion
    end
    return self.currentExpansion
end
--#endregion