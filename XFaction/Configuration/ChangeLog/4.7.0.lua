local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XFG.ChangeLog['4.7.0'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XFG.Lib.Locale['NEW'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Added notifications for guild/personal crafting orders. Both sender and receiver must be running XFaction and in the same confederate. These can be enabled/disabled under Options, XFaction, Chat, Crafting.',
            },
        },
    },			
}