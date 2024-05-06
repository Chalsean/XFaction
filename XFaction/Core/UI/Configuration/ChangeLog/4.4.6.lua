local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.4.6'] = {
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
                name = 'Custom channel is no longer required if there are not multiple guilds on the same realm/faction, defaults to using GUILD channel.',
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
                name = 'More robust custom channel maintenance.',
            },
            Bar1 = {
                order = 2,
                name = '',
                type = 'header'
            },
            Two = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Bug fix for confederates with Alliance/Horde guilds that have the same name on the same realm.',
            },
        },
    },			
}