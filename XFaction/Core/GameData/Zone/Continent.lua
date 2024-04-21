local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Continent'

XFC.Continent = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Continent:new()
    local object = XFC.Continent.parent.new(self)
    object.__name = ObjectName
    object.IDs = nil
    object.localeName = nil
    return object
end

function XFC.Continent:Initialize()
	if(not self:IsInitialized()) then
        self:ParentInitialize()
		self.IDs = {}
		self:IsInitialized(true)
	end
end
--#endregion

--#region Properties
function XFC.Continent:ID(inID)
    assert(type(inID) == 'number' or inID == nil, 'argument must be number or nil')
    if(inID == nil) then
        if(#self.IDs > 0) then
            return self.IDs[1]
        end
        return nil
    end
    for _, ID in ipairs(self.IDs) do
        if(ID == inID) then
            return true
        end
    end
    self.IDs[#self.IDs + 1] = inID
end

function XFC.Continent:LocaleName(inName)
    assert(type(inName) == 'string' or inName == nil, 'argument must be string or nil')
    if(inName ~= nil) then
        self.localeName = inName
    end
    return self.localeName
end
--#endregion

--#region Methods
function XFC.Continent:Print()
    self:ParentPrint()
    XF:Debug(self:GetObjectName(), '  localeName (' .. type(self.localeName) .. '): ' .. tostring(self.localeName))
    XF:Debug(self:GetObjectName(), '  IDs: ')
    XF:DataDumper(self:GetObjectName(), self.IDs)
end
--#endregion