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

--#region Properties
function XFC.Expansion:IconID(inIconID)
    assert(type(inIconID) == 'number' or inIconID == nil)
    if(inIconID ~= nil) then
        self.iconID = inIconID
    end
    return self.iconID
end

function XFC.Expansion:Version(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version' or inVersion == nil)
    if(inVersion ~= nil) then
	    self.version = inVersion
    end
    return self.version
end

function XFC.Expansion:IsRetail()
    return WOW_PROJECT_MAINLINE == self:ID()
end
--#endregion

--#region Methods
function XFC.Expansion:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    if(self:HasVersion()) then self:Version():Print() end
end

function XFC.Expansion:HasVersion()
    return self.version ~= nil
end
--#endregion