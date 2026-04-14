local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['6.2.6'] = {
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            Channel = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed class colouring for BNet friends guild chat',
            },
        },
    },		
}