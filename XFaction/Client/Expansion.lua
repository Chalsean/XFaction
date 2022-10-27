local XFG, G = unpack(select(2, ...))
local ObjectName = 'Expansion'

Expansion = Object:newChildConstructor()

--#region Constructors
function Expansion:new()
    local object = Expansion.parent.new(self)
    object.__name = ObjectName
    object.ID = nil
    object.iconID = nil
    object.version = nil
    return object
end
--#endregion

--#region Print
function Expansion:Print()
    self:ParentPrint()
    XFG:Debug(ObjectName, '  ID (' .. type(self.ID) .. '): ' .. tostring(self.ID))
    XFG:Debug(ObjectName, '  iconID (' .. type(self.iconID) .. '): ' .. tostring(self.iconID))
    if(self:HasVersion()) then self:GetVersion():Print() end
end
--#endregion

--#region Accessors
function Expansion:GetID()
    return self.ID
end

function Expansion:SetID(inID)
    assert(type(inID) == 'number')
    self.ID = inID
end

function Expansion:GetIconID()
    return self.iconID
end

function Expansion:SetIconID(inIconID)
    assert(type(inIconID) == 'number')
    self.iconID = inIconID
end

function Expansion:IsRetail()
    return WOW_PROJECT_MAINLINE == self:GetID()
end

function Expansion:HasVersion()
	return self.version ~= nil
end

function Expansion:SetVersion(inVersion)
    assert(type(inVersion) == 'table' and inVersion.__name == 'Version', 'argument must be Version object')
	self.version = inVersion
end

function Expansion:GetVersion()
	return self.version
end
--#endregion