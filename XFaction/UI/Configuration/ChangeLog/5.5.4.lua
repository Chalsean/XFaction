local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['5.5.4'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Toc = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Bumped toc to 110207',
            },
            Blizzard = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Blizzard had an undocumented change to their chat API, kudos to Hyphie for finding it',
            },            
            Siren = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed timezone issue',
            },
        },
    },		
}