local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['3.4.2'] = {
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
                name = 'Local guild logouts and gchat are now in XFaction format.',
            },
            Two = {
                order = 2,
                type = 'description',
                name = 'Configurable team names for Death Jesters (Zoombara).',
                fontSize = 'medium',
            },
            Three = {
                order = 3,
                type = 'description',
                name = 'Respects guild rank gchat speak/listen permissions.',
                fontSize = 'medium',
            },
        }
    },	
}