local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['5.4.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Keys = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Added season 3 M+ keys',
            },
            Siren = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Bumped toc to 110200',
            },
        },
    },		
}