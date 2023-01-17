local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XFG.ChangeLog['4.3.1'] = {
    New = {
        order = 1,
        type = 'group',
        name = XFG.Lib.Locale['NEW'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Moved About, Setup, Support, Debug configuration menu items as tabs under General.',
            },
            Two = {
                order = 2,
                type = 'description',
                name = 'Implemented Change Log tab under General.',
                fontSize = 'medium',
            },
        }
    },			
}