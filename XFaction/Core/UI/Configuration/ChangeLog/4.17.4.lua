local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.17.4'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            TWW = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Bug fix for Blizz APIs moving namespaces.',
            },
            TOC = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Bumped toc to 11.0.2.',
            },
        },
    },		
}