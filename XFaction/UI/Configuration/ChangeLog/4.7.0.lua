local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.7.0'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['NEW'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Added notifications for guild/personal crafting orders. Both sender and receiver must be running XFaction and in the same confederate.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Crafting notifications can be enabled/disabled under Options, XFaction, Chat, Crafting.',
            },
            Three = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Bumped TOC to 100107.',
            },
        },
    },			
}