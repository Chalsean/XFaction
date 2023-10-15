local XF, G = unpack(select(2, ...))
local ObjectName = 'Config.ChangeLog'

XF.ChangeLog['3.5.2'] = {
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
                name = 'Recognizes legacy EK notes.',
            },
            Two = {
                order = 2,
                type = 'description',
                name = 'RaiderIO defaults to main.',
                fontSize = 'medium',
            },
            Three = {
                order = 3,
                type = 'description',
                name = 'Switched compression library for BNet communication.',
                fontSize = 'medium',
            },
            Four = {
                order = 4,
                type = 'description',
                name = 'Refactored BNet messaging to reduce redundant overhead in message packets.',
                fontSize = 'medium',
            },
            Five = {
                order = 5,
                type = 'description',
                name = 'Better granularity on controlling packet size.',
                fontSize = 'medium',
            },
            Six = {
                order = 6,
                type = 'description',
                name = 'Randomizes BNet forwarding if above a threshold.',
                fontSize = 'medium',
            },
            Seven = {
                order = 7,
                type = 'description',
                name = 'Cleaned up achievement message formatting (Zoombara).',
                fontSize = 'medium',
            },
        }
    },	
    Improvements = {
        order = 2,
        type = 'group',
        name = XF.Lib.Locale['IMPROVEMENTS'],
        guiInline = true,
        args = {
            One = {
                order = 1,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed bug preventing decoding of packets.',
            },
            Two = {
                order = 2,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed ENK team association.',
            },
            Three = {
                order = 3,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed exception handling if RaiderIO throws.',
            },
            Four = {
                order = 4,
                type = 'description',
                fontSize = 'medium',
                name = 'Fixed support button lua exception (Zoombara).',
            },
        }
    },		
}