local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.0.6'] = {
    Improvements = {
        order = 1,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Professions selectable again for Guild (X) DT.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Some were having issues with CurseForge and the addon being 10002 toc, have switched back to 10000.',
            },
        }
    },			
}