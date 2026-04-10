local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.2.16'] = {
    New = {
        order = 1,
        type = 'group',
        name = XF.Lib.Locale['NEW'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Added memberID to DATA packet for future enhancement work.',
            },
        }
    },
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed exception thrown when changing font and/or font size in the config menu.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Altered XFaction metrics gathering regarding messages, it was including traffic from all add-ons and causing confusion.',
            },
        }
    },			
}