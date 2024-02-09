local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.1.4'] = {
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
                name = 'Replaced LibRealmInfo with own logic.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Refreshed all connected realm data.',
            },
        }
    },			
}