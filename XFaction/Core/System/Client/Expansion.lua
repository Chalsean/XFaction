local XF, G = unpack(select(2, ...))
local XFC, XFO = XF.Class, XF.Object
local ObjectName = 'Expansion'

XFC.Expansion = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Expansion:new()
    local object = XFC.Expansion.parent.new(self)
    object.__name = ObjectName
    object.iconID = nil
    object.version = nil
    return object
end
--#endregion

--#region Print
function XFC.Expansion:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    if(self:HasVersion()) then self:GetVersion():Print() end
end
--#endregion

--#region Accessors
function XFC.Expansion:GetIconID()
    return self.iconID
end

function XFC.Expansion:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end

function XFC.Expansion:IsRetail()
    return WOW_PROJECT_MAINLINE == self:GetID()
end

function XFC.Expansion:HasVersion()
	return self.version ~= nil
end

function XFC.Expansion:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
	self.version = inVersion
end

function XFC.Expansion:GetVersion()
	return self.version
end
--#endregion