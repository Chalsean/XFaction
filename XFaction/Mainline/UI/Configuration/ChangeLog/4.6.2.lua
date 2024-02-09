local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['4.6.2'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['NEW'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Works with Blizzards new addon compartment.',
            },
        },
    },			
}