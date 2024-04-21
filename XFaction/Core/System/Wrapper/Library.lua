local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'Library'

XFC.Library = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.Library:new()
    local object = XFC.Event.parent.new(self)
    object.__name = ObjectName
    object.lib = nil
    object.env = nil
    return object
end
--#endregion

--#region Initializers
function XFC.Library:Initialize()
    if(not self:IsInitialized()) then
        self:ParentInitialize()
        self.env = {}
        for key, value in pairs(_G) do
            self.env[key] = value
        end
        self:IsInitialized(true)
    end
end
--#endregion

--#region Sandbox
function XFC.Library:Sandbox(inLibrary)
    assert(type(inLibrary) == 'table')
    self.lib = inLibrary    
end

-- Sandboxing allows XFaction to overwrite global variables/functions, like determining which WoW version it is
function XFC.Library:Execute(inFunctionName, ...)
    local _G = self.env
    return self.lib[inFunctionName](self.lib, ...)
end
--#endregion

--#region Accessors
function XFC.Library:Get(inKey)
    return self.env[inKey]
end

function XFC.Library:Set(inKey, inValue)
    self.env[inKey] = value
end
--#endregion