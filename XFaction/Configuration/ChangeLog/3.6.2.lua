local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XFG.ChangeLog['3.6.2'] = {
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
                name = 'Local guild logins are now in XFaction format.',
            },
        }
    },			
}