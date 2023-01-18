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
                name = 'Implemented Change Log tab under General.',
            },
        }
    },	
    Improvements = {
        order = 2,
        type = 'group',
        name = XFG.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Reorganized configuration menu items to (hopefully) be more intuitive.',
            },
        }
    },			
}