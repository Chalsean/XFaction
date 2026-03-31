local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'SystemFrame'

XFC.SystemFrame = XFC.Object:newChildConstructor()

--#region Constructors
function XFC.SystemFrame:new()
    local object = XFC.SystemFrame.parent.new(self)
    object.__name = ObjectName
    return object
end
--#endregion

--#region Methods
function XFC.SystemFrame:DisplayLogin(inUnit)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inUnit) == 'table' and inUnit.__name == 'Unit')
    if(XFF.PlayerIsIgnored(inUnit:GUID())) then return end

    local text = ''
    
    if(XF.Config.Chat.Login.Faction) then  
        text = text .. format('%s ', format(XF.Icons.String, inUnit:Faction():IconID()))
    end

    text = text .. inUnit:GetLink() .. ' '
  
    if(XF.Config.Chat.Login.Main and inUnit:IsAlt()) then
        text = text .. '(' .. inUnit:MainName() .. ') '
    end

    if(XF.Config.Chat.Login.Guild) then  
        text = text .. '<' .. inUnit:Guild():Initials() .. '> '
    end
    
    text = text .. XF.Lib.Locale['CHAT_LOGIN']
    if(XF.Config.Chat.Login.Sound and not inUnit:IsSameGuild()) then
        XFF.UISystemSound(3332, 'Master')
    end

    XFF.UISystemMessage(text)
end

function XFC.SystemFrame:DisplayLogout(inName)
    if(not XF.Config.Chat.Login.Enable) then return end
    assert(type(inName) == 'string')
    local text = inName .. ' ' .. XF.Lib.Locale['CHAT_LOGOUT']
    XFF.UISystemMessage(text) 
end

function XFC.SystemFrame:DisplayOrder(inOrder)
    if(not XF.Config.Chat.Crafting.Enable) then return end
    assert(type(inOrder) == 'table' and inOrder.__name == 'Order')
    if(XFF.PlayerIsIgnored(inOrder:Customer():GUID())) then return end

    if(inOrder:IsGuild() and not XF.Config.Chat.Crafting.GuildOrder) then return end
    if(inOrder:IsPersonal() and not XF.Config.Chat.Crafting.PersonalOrder) then return end
    if(inOrder:IsPersonal() and not inOrder:IsMyOrder() and not inOrder:IsPlayerCrafter()) then return end

    local display = false
    if(not XF.Config.Chat.Crafting.Professions) then
        display = true
    elseif(inOrder:HasProfession() and inOrder:Profession():Equals(XF.Player.Unit:Profession1())) then
        display = true
    elseif(inOrder:HasProfession() and inOrder:Profession():Equals(XF.Player.Unit:Profession2())) then
        display = true
    end

    if(display) then
        local customer = inOrder:Customer()
        local text = ''
            
        if(XF.Config.Chat.Crafting.Faction) then
            text = text .. format('%s ', format(XF.Icons.String, customer:Faction():IconID()))
        end
        
        text = text .. customer:GetLink()
            
        if(XF.Config.Chat.Crafting.Main and customer:IsAlt()) then
            text = text .. '(' .. customer:MainName() .. ') '
        end
        
        if(XF.Config.Chat.Crafting.Guild) then
            text = text .. '<' .. customer:Guild():Initials() .. '> '
        end
            
        if(inOrder:IsGuild()) then
            text = text .. format(XF.Lib.Locale['NEW_GUILD_CRAFTING_ORDER'], inOrder:Link())
        else
            text = text .. format(XF.Lib.Locale['NEW_PERSONAL_CRAFTING_ORDER'], inOrder:CrafterName(), inOrder:Link())
        end

        XFF.UISystemMessage(text)
    end
end
--#endregion