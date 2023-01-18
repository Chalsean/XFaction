local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XFG.ChangeLog['3.4.6'] = {
    Improvements = {
        order = 1,
        type = 'group',
        name = XFG.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed race condition with ElvUI.',
            },
        }
    },			
}