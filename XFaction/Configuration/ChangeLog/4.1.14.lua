local XFG, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XFG.ChangeLog['4.1.14'] = {
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
                name = 'Reintroduced optional compressed guild info settings.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed Guild (X) bug.',
            },
        }
    },			
}