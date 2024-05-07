local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['3.9.2'] = {
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
                name = 'Bumped toc to 90207.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Optimized performance.',
            },
            Three = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Local guild achievements are now in XFaction format.',
            },
        }
    },			
}