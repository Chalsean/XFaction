local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['5.3.2'] = {
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
                name = 'Added season 2 M+ keys',
            },
            Siren = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Added Siren Isles map IDs',
            },
            Double = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed an issue where sometimes users would see a double post',
            },
            Main = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed an issue where sometimes users would see the wrong main name',
            },
        },
    },		
}