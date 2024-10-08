local XF, G = unpack(select(2, ...))
local XFC, XFO, XFF = XF.Class, XF.Object, XF.Function
local ObjectName = 'RealmCollection'

XFC.RealmCollection = XFC.ObjectCollection:newChildConstructor()

--#region Realm list
-- Places that Blizzard API considers a realm
local DefaultRealms = {
	[0] = 'Torghast',
}
-- This data originally came from LibRealmInfo, it seems no longer supported as the data is quite stale and the library had bugs nobody was fixing
-- There is a blizz web api that provides this data
local RealmData = {
	[1] = "Lightbringer;us;3694;retail",
        [2] = "Cenarius;us;1168;retail",
        [3] = "Uther;us;151;retail",
        [4] = "Kilrogg;us;4;retail",
        [5] = "Proudmoore;us;5;retail",
        [6] = "Hyjal;us;3661;retail",
        [7] = "Frostwolf;us;127;retail",
        [8] = "Ner'zhul;us;1168;retail",
        [9] = "Kil'jaeden;us;9;retail",
        [10] = "Blackrock;us;121;retail",
        [11] = "Tichondrius;us;11;retail",
        [12] = "Silver Hand;us;12;retail",
        [13] = "Doomhammer;us;1190;retail",
        [14] = "Icecrown;us;104;retail",
        [15] = "Deathwing;us;155;retail",
        [16] = "Kel'Thuzad;us;3693;retail",
        [47] = "Eitrigg;us;47;retail",
        [51] = "Garona;us;104;retail",
        [52] = "Alleria;us;52;retail",
        [53] = "Hellscream;us;53;retail",
        [54] = "Blackhand;us;54;retail",
        [55] = "Whisperwind;us;55;retail",
        [56] = "Archimonde;us;1129;retail",
        [57] = "Illidan;us;57;retail",
        [58] = "Stormreaver;us;58;retail",
        [59] = "Mal'Ganis;us;3684;retail",
        [60] = "Stormrage;us;60;retail",
        [61] = "Zul'jin;us;61;retail",
        [62] = "Medivh;us;52;retail",
        [63] = "Durotan;us;63;retail",
        [64] = "Bloodhoof;us;64;retail",
        [65] = "Khadgar;us;52;retail",
        [66] = "Dalaran;us;3683;retail",
        [67] = "Elune;us;67;retail",
        [68] = "Lothar;us;1175;retail",
        [69] = "Arthas;us;69;retail",
        [70] = "Mannoroth;us;77;retail",
        [71] = "Warsong;us;71;retail",
        [72] = "Shattered Hand;us;157;retail",
        [73] = "Bleeding Hollow;us;73;retail",
        [74] = "Skullcrusher;us;96;retail",
        [75] = "Argent Dawn;us;75;retail",
        [76] = "Sargeras;us;76;retail",
        [77] = "Azgalor;us;77;retail",
        [78] = "Magtheridon;us;78;retail",
        [79] = "Destromath;us;77;retail",
        [80] = "Gorgonnash;us;71;retail",
        [81] = "Dethecus;us;154;retail",
        [82] = "Spinebreaker;us;53;retail",
        [83] = "Bonechewer;us;1136;retail",
        [84] = "Dragonmaw;us;84;retail",
        [85] = "Shadowsong;us;86;retail",
        [86] = "Silvermoon;us;86;retail",
        [87] = "Windrunner;us;113;retail",
        [88] = "Cenarion Circle;us;125;retail",
        [89] = "Nathrezim;us;1138;retail",
        [90] = "Terenas;us;86;retail",
        [91] = "Burning Blade;us;104;retail",
        [92] = "Gorefiend;us;53;retail",
        [93] = "Eredar;us;53;retail",
        [94] = "Shadowmoon;us;154;retail",
        [95] = "Lightning's Blade;us;104;retail",
        [96] = "Eonar;us;96;retail",
        [97] = "Gilneas;us;67;retail",
        [98] = "Kargath;us;1129;retail",
        [99] = "Llane;us;99;retail",
        [100] = "Earthen Ring;us;100;retail",
        [101] = "Laughing Skull;us;67;retail",
        [102] = "Burning Legion;us;1129;retail",
        [103] = "Thunderlord;us;77;retail",
        [104] = "Malygos;us;104;retail",
        [105] = "Thunderhorn;us;1129;retail",
        [106] = "Aggramar;us;106;retail",
        [107] = "Crushridge;us;1138;retail",
        [108] = "Stonemaul;us;1185;retail",
        [109] = "Daggerspine;us;1136;retail",
        [110] = "Stormscale;us;127;retail",
        [111] = "Dunemaul;us;1185;retail",
        [112] = "Boulderfist;us;1185;retail",
        [113] = "Suramar;us;113;retail",
        [114] = "Dragonblight;us;114;retail",
        [115] = "Draenor;us;115;retail",
        [116] = "Uldum;us;84;retail",
        [117] = "Bronzebeard;us;117;retail",
        [118] = "Feathermoon;us;118;retail",
        [119] = "Bloodscalp;us;1185;retail",
        [120] = "Darkspear;us;120;retail",
        [121] = "Azjol-Nerub;us;121;retail",
        [122] = "Perenolde;us;1168;retail",
        [123] = "Eldre'Thalas;us;84;retail",
        [124] = "Spirestone;us;127;retail",
        [125] = "Shadow Council;us;125;retail",
        [126] = "Scarlet Crusade;us;118;retail",
        [127] = "Firetree;us;127;retail",
        [128] = "Frostmane;us;1168;retail",
        [129] = "Gurubashi;us;1136;retail",
        [130] = "Smolderthorn;us;1138;retail",
        [131] = "Skywall;us;86;retail",
        [151] = "Runetotem;us;151;retail",
        [153] = "Moonrunner;us;1175;retail",
        [154] = "Detheroc;us;154;retail",
        [155] = "Kalecgos;us;155;retail",
        [156] = "Ursin;us;96;retail",
        [157] = "Dark Iron;us;157;retail",
        [158] = "Greymane;us;158;retail",
        [159] = "Wildhammer;us;53;retail",
        [160] = "Staghelm;us;160;retail",
        [162] = "Emerald Dream;us;162;retail",
        [163] = "Maelstrom;us;163;retail",
        [164] = "Twisting Nether;us;163;retail",
        [201] = "Burning Legion;kr;210;retail",
        [205] = "Azshara;kr;205;retail",
        [207] = "Dalaran;kr;2116;retail",
        [210] = "Durotan;kr;210;retail",
        [211] = "Norgannon;kr;2116;retail",
        [212] = "Garona;kr;2116;retail",
        [214] = "Windrunner;kr;214;retail",
        [215] = "Gul'dan;kr;2116;retail",
        [258] = "Alexstrasza;kr;214;retail",
        [264] = "Malfurion;kr;2116;retail",
        [293] = "Hellscream;kr;2116;retail",
        [500] = "Aggramar;eu;1325;retail",
        [501] = "Arathor;eu;1587;retail",
        [502] = "Aszune;eu;3666;retail",
        [503] = "Azjol-Nerub;eu;1396;retail",
        [504] = "Bloodhoof;eu;1080;retail",
        [505] = "Doomhammer;eu;1402;retail",
        [506] = "Draenor;eu;1403;retail",
        [507] = "Dragonblight;eu;1596;retail",
        [508] = "Emerald Dream;eu;2074;retail",
        [509] = "Garona;eu;509;retail",
        [510] = "Vol'jin;eu;510;retail",
        [511] = "Sunstrider;eu;1598;retail",
        [512] = "Arak-arahm;eu;512;retail",
        [513] = "Twilight's Hammer;eu;1091;retail",
        [515] = "Zenedar;eu;3657;retail",
        [516] = "Forscherliga;eu;1405;retail",
        [517] = "Medivh;eu;1331;retail",
        [518] = "Agamaggan;eu;1091;retail",
        [519] = "Al'Akir;eu;3713;retail",
        [521] = "Bladefist;eu;3657;retail",
        [522] = "Bloodscalp;eu;1091;retail",
        [523] = "Burning Blade;eu;1092;retail",
        [524] = "Burning Legion;eu;3713;retail",
        [525] = "Crushridge;eu;1091;retail",
        [526] = "Daggerspine;eu;1598;retail",
        [527] = "Deathwing;eu;1596;retail",
        [528] = "Dragonmaw;eu;3656;retail",
        [529] = "Dunemaul;eu;1597;retail",
        [531] = "Dethecus;eu;531;retail",
        [533] = "Sinstralis;eu;1621;retail",
        [535] = "Durotan;eu;578;retail",
        [536] = "Argent Dawn;eu;3702;retail",
        [537] = "Kirin Tor;eu;1127;retail",
        [538] = "Dalaran;eu;1621;retail",
        [539] = "Archimonde;eu;1302;retail",
        [540] = "Elune;eu;1315;retail",
        [541] = "Illidan;eu;1624;retail",
        [542] = "Hyjal;eu;1390;retail",
        [543] = "Kael'thas;eu;512;retail",
        [544] = "Ner'zhul;eu;509;retail",
        [545] = "Cho'gall;eu;1621;retail",
        [546] = "Sargeras;eu;509;retail",
        [547] = "Runetotem;eu;1587;retail",
        [548] = "Shadowsong;eu;3666;retail",
        [549] = "Silvermoon;eu;3391;retail",
        [550] = "Stormrage;eu;1417;retail",
        [551] = "Terenas;eu;2074;retail",
        [552] = "Thunderhorn;eu;1313;retail",
        [553] = "Turalyon;eu;1402;retail",
        [554] = "Ravencrest;eu;1329;retail",
        [556] = "Shattered Hand;eu;633;retail",
        [557] = "Skullcrusher;eu;3713;retail",
        [558] = "Spinebreaker;eu;3656;retail",
        [559] = "Stormreaver;eu;3656;retail",
        [560] = "Stormscale;eu;2073;retail",
        [561] = "Earthen Ring;eu;1096;retail",
        [562] = "Alexstrasza;eu;3696;retail",
        [563] = "Alleria;eu;1099;retail",
        [564] = "Antonidas;eu;3686;retail",
        [565] = "Baelgun;eu;570;retail",
        [566] = "Blackhand;eu;3691;retail",
        [567] = "Gilneas;eu;612;retail",
        [568] = "Kargath;eu;604;retail",
        [569] = "Khaz'goroth;eu;1406;retail",
        [570] = "Lothar;eu;570;retail",
        [571] = "Madmortem;eu;3696;retail",
        [572] = "Malfurion;eu;1098;retail",
        [573] = "Zuluhed;eu;1105;retail",
        [574] = "Nozdormu;eu;1401;retail",
        [575] = "Perenolde;eu;1401;retail",
        [576] = "Die Silberne Hand;eu;1121;retail",
        [577] = "Aegwynn;eu;3679;retail",
        [578] = "Arthas;eu;578;retail",
        [579] = "Azshara;eu;570;retail",
        [580] = "Blackmoore;eu;580;retail",
        [581] = "Blackrock;eu;581;retail",
        [582] = "Destromath;eu;612;retail",
        [583] = "Eredar;eu;3692;retail",
        [584] = "Frostmourne;eu;1105;retail",
        [585] = "Frostwolf;eu;3703;retail",
        [586] = "Gorgonnash;eu;612;retail",
        [587] = "Gul'dan;eu;1104;retail",
        [588] = "Kel'Thuzad;eu;578;retail",
        [589] = "Kil'jaeden;eu;1104;retail",
        [590] = "Mal'Ganis;eu;3691;retail",
        [591] = "Mannoroth;eu;612;retail",
        [592] = "Zirkel des Cenarius;eu;1405;retail",
        [593] = "Proudmoore;eu;3696;retail",
        [594] = "Nathrezim;eu;1104;retail",
        [600] = "Dun Morogh;eu;1408;retail",
        [601] = "Aman'Thul;eu;1105;retail",
        [602] = "Sen'jin;eu;1400;retail",
        [604] = "Thrall;eu;604;retail",
        [605] = "Theradras;eu;531;retail",
        [606] = "Genjuros;eu;3657;retail",
        [607] = "Balnazzar;eu;1598;retail",
        [608] = "Anub'arak;eu;1105;retail",
        [609] = "Wrathbringer;eu;578;retail",
        [610] = "Onyxia;eu;531;retail",
        [611] = "Nera'thor;eu;612;retail",
        [612] = "Nefarian;eu;612;retail",
        [613] = "Kult der Verdammten;eu;1121;retail",
        [614] = "Das Syndikat;eu;1121;retail",
        [615] = "Terrordar;eu;531;retail",
        [616] = "Krag'jin;eu;570;retail",
        [617] = "Der Rat von Dalaran;eu;1405;retail",
        [618] = "Nordrassil;eu;1393;retail",
        [619] = "Hellscream;eu;1325;retail",
        [621] = "Laughing Skull;eu;1598;retail",
        [622] = "Magtheridon;eu;3681;retail",
        [623] = "Quel'Thalas;eu;1396;retail",
        [624] = "Neptulon;eu;3657;retail",
        [625] = "Twisting Nether;eu;3674;retail",
        [626] = "Ragnaros;eu;3682;retail",
        [627] = "The Maelstrom;eu;1596;retail",
        [628] = "Sylvanas;eu;1597;retail",
        [629] = "Vashj;eu;3656;retail",
        [630] = "Bloodfeather;eu;633;retail",
        [631] = "Darksorrow;eu;3657;retail",
        [632] = "Frostwhisper;eu;3657;retail",
        [633] = "Kor'gall;eu;633;retail",
        [635] = "Defias Brotherhood;eu;1096;retail",
        [636] = "The Venture Co;eu;1096;retail",
        [637] = "Lightning's Blade;eu;1596;retail",
        [638] = "Haomarush;eu;3656;retail",
        [639] = "Xavius;eu;3713;retail",
        [640] = "Khaz Modan;eu;3690;retail",
        [641] = "Drek'Thar;eu;1122;retail",
        [642] = "Rashgarroth;eu;512;retail",
        [643] = "Throk'Feroth;eu;512;retail",
        [644] = "Conseil des Ombres;eu;1127;retail",
        [645] = "Varimathras;eu;1315;retail",
        [646] = "Hakkar;eu;1091;retail",
        [647] = "Les Sentinelles;eu;1127;retail",
        [963] = "Shadowmoon;tw;963;retail",
        [964] = "Spirestone;tw;963;retail",
        [965] = "Stormscale;tw;966;retail",
        [966] = "Dragonmaw;tw;966;retail",
        [977] = "Frostmane;tw;966;retail",
        [978] = "Sundown Marsh;tw;980;retail",
        [979] = "Hellscream;tw;963;retail",
        [980] = "Skywall;tw;980;retail",
        [982] = "World Tree;tw;966;retail",
        [985] = "Crystalpine Stinger;tw;980;retail",
        [999] = "Zealot Blade;tw;963;retail",
        [1001] = "Chillwind Point;tw;963;retail",
        [1006] = "Menethil;tw;966;retail",
        [1023] = "Demon Fall Canyon;tw;980;retail",
        [1033] = "Whisperwind;tw;963;retail",
        [1037] = "Bleeding Hollow;tw;966;retail",
        [1038] = "Arygos;tw;966;retail",
        [1043] = "Nightsong;tw;966;retail",
        [1046] = "Light's Hope;tw;980;retail",
        [1048] = "Silverwing Hold;tw;980;retail",
        [1049] = "Wrathbringer;tw;980;retail",
        [1054] = "Arthas;tw;963;retail",
        [1056] = "Quel'dorei;tw;963;retail",
        [1057] = "Icecrown;tw;963;retail",
        [1067] = "Cho'gall;us;67;retail",
        [1068] = "Gul'dan;us;96;retail",
        [1069] = "Kael'thas;us;1175;retail",
        [1070] = "Alexstrasza;us;1070;retail",
        [1071] = "Kirin Tor;us;1071;retail",
        [1072] = "Ravencrest;us;1072;retail",
        [1075] = "Balnazzar;us;71;retail",
        [1080] = "Khadgar;eu;1080;retail",
        [1081] = "Bronzebeard;eu;1416;retail",
        [1082] = "Kul Tiras;eu;1082;retail",
        [1083] = "Chromaggus;eu;1598;retail",
        [1084] = "Dentarg;eu;1084;retail",
        [1085] = "Moonglade;eu;1085;retail",
        [1086] = "La Croisade écarlate;eu;1127;retail",
        [1087] = "Executus;eu;633;retail",
        [1088] = "Trollbane;eu;1598;retail",
        [1089] = "Mazrigos;eu;1388;retail",
        [1090] = "Talnivarr;eu;1598;retail",
        [1091] = "Emeriss;eu;1091;retail",
        [1092] = "Drak'thul;eu;1092;retail",
        [1093] = "Ahn'Qiraj;eu;1598;retail",
        [1096] = "Scarshield Legion;eu;1096;retail",
        [1097] = "Ysera;eu;1097;retail",
        [1098] = "Malygos;eu;1098;retail",
        [1099] = "Rexxar;eu;1099;retail",
        [1104] = "Anetheron;eu;1104;retail",
        [1105] = "Nazjatar;eu;1105;retail",
        [1106] = "Tichondrius;eu;580;retail",
        [1117] = "Steamwheedle Cartel;eu;1085;retail",
        [1118] = "Die ewige Wacht;eu;1121;retail",
        [1119] = "Die Todeskrallen;eu;1121;retail",
        [1121] = "Die Arguswacht;eu;1121;retail",
        [1122] = "Uldaman;eu;1122;retail",
        [1123] = "Eitrigg;eu;1122;retail",
        [1127] = "Confrérie du Thorium;eu;1127;retail",
        [1128] = "Azshara;us;77;retail",
        [1129] = "Agamaggan;us;1129;retail",
        [1130] = "Lightninghoof;us;163;retail",
        [1131] = "Nazjatar;us;77;retail",
        [1132] = "Malfurion;us;1175;retail",
        [1136] = "Aegwynn;us;1136;retail",
        [1137] = "Akama;us;84;retail",
        [1138] = "Chromaggus;us;1138;retail",
        [1139] = "Draka;us;113;retail",
        [1140] = "Drak'thul;us;86;retail",
        [1141] = "Garithos;us;1138;retail",
        [1142] = "Hakkar;us;1136;retail",
        [1143] = "Khaz Modan;us;121;retail",
        [1145] = "Mug'thol;us;84;retail",
        [1146] = "Korgath;us;1168;retail",
        [1147] = "Kul Tiras;us;1147;retail",
        [1148] = "Malorne;us;127;retail",
        [1151] = "Rexxar;us;1151;retail",
        [1154] = "Thorium Brotherhood;us;12;retail",
        [1165] = "Arathor;us;1138;retail",
        [1173] = "Madoran;us;160;retail",
        [1175] = "Trollbane;us;1175;retail",
        [1182] = "Muradin;us;121;retail",
        [1184] = "Vek'nilash;us;1184;retail",
        [1185] = "Sen'jin;us;1185;retail",
        [1190] = "Baelgun;us;1190;retail",
        [1258] = "Duskwood;us;64;retail",
        [1259] = "Zuluhed;us;96;retail",
        [1260] = "Steamwheedle Cartel;us;1071;retail",
        [1262] = "Norgannon;us;1129;retail",
        [1263] = "Thrall;us;3678;retail",
        [1264] = "Anetheron;us;78;retail",
        [1265] = "Turalyon;us;3685;retail",
        [1266] = "Haomarush;us;154;retail",
        [1267] = "Scilla;us;96;retail",
        [1268] = "Ysondre;us;78;retail",
        [1270] = "Ysera;us;63;retail",
        [1271] = "Dentarg;us;55;retail",
        [1276] = "Andorhal;us;96;retail",
        [1277] = "Executus;us;155;retail",
        [1278] = "Dalvengyr;us;157;retail",
        [1280] = "Black Dragonflight;us;96;retail",
        [1282] = "Altar of Storms;us;78;retail",
        [1283] = "Uldaman;us;1072;retail",
        [1284] = "Aerie Peak;us;1426;retail",
        [1285] = "Onyxia;us;104;retail",
        [1286] = "Demon Soul;us;157;retail",
        [1287] = "Gnomeregan;us;1175;retail",
        [1288] = "Anvilmar;us;71;retail",
        [1289] = "The Venture Co;us;163;retail",
        [1290] = "Sentinels;us;1071;retail",
        [1291] = "Jaedenar;us;1129;retail",
        [1292] = "Tanaris;us;158;retail",
        [1293] = "Alterac Mountains;us;71;retail",
        [1294] = "Undermine;us;71;retail",
        [1295] = "Lethon;us;154;retail",
        [1296] = "Blackwing Lair;us;154;retail",
        [1297] = "Arygos;us;99;retail",
        [1298] = "Vek'nilash;eu;1416;retail",
        [1299] = "Boulderfist;eu;1598;retail",
        [1300] = "Frostmane;eu;1303;retail",
        [1301] = "Outland;eu;1301;retail",
        [1303] = "Grim Batol;eu;1303;retail",
        [1304] = "Jaedenar;eu;1597;retail",
        [1305] = "Kazzak;eu;1305;retail",
        [1306] = "Tarren Mill;eu;1084;retail",
        [1307] = "Chamber of Aspects;eu;1307;retail",
        [1308] = "Ravenholdt;eu;1096;retail",
        [1309] = "Pozzo dell'Eternità;eu;1309;retail",
        [1310] = "Eonar;eu;1416;retail",
        [1311] = "Kilrogg;eu;1587;retail",
        [1312] = "Aerie Peak;eu;1416;retail",
        [1313] = "Wildhammer;eu;1313;retail",
        [1314] = "Saurfang;eu;633;retail",
        [1316] = "Nemesis;eu;1316;retail",
        [1317] = "Darkmoon Faire;eu;1096;retail",
        [1318] = "Vek'lor;eu;578;retail",
        [1319] = "Mug'thol;eu;531;retail",
        [1320] = "Taerar;eu;3691;retail",
        [1321] = "Dalvengyr;eu;1105;retail",
        [1322] = "Rajaxx;eu;1104;retail",
        [1323] = "Ulduar;eu;612;retail",
        [1324] = "Malorne;eu;1097;retail",
        [1326] = "Der abyssische Rat;eu;1121;retail",
        [1327] = "Der Mithrilorden;eu;1405;retail",
        [1328] = "Tirion;eu;578;retail",
        [1330] = "Ambossar;eu;604;retail",
        [1331] = "Suramar;eu;1331;retail",
        [1332] = "Krasus;eu;1122;retail",
        [1333] = "Die Nachtwache;eu;1405;retail",
        [1334] = "Arathi;eu;1624;retail",
        [1335] = "Ysondre;eu;1335;retail",
        [1336] = "Eldre'Thalas;eu;1621;retail",
        [1337] = "Culte de la Rive noire;eu;1127;retail",
        [1342] = "Echo Isles;us;115;retail",
        [1344] = "The Forgotten Coast;us;71;retail",
        [1345] = "Fenris;us;114;retail",
        [1346] = "Anub'arak;us;1138;retail",
        [1347] = "Blackwater Raiders;us;125;retail",
        [1348] = "Vashj;us;127;retail",
        [1349] = "Korialstrasz;us;84;retail",
        [1350] = "Misha;us;1151;retail",
        [1351] = "Darrowmere;us;113;retail",
        [1352] = "Ravenholdt;us;163;retail",
        [1353] = "Bladefist;us;1147;retail",
        [1354] = "Shu'halo;us;47;retail",
        [1355] = "Winterhoof;us;4;retail",
        [1356] = "Sisters of Elune;us;125;retail",
        [1357] = "Maiev;us;1185;retail",
        [1358] = "Rivendare;us;127;retail",
        [1359] = "Nordrassil;us;121;retail",
        [1360] = "Tortheldrin;us;1168;retail",
        [1361] = "Cairne;us;1168;retail",
        [1362] = "Drak'Tharon;us;127;retail",
        [1363] = "Antonidas;us;84;retail",
        [1364] = "Shandris;us;117;retail",
        [1365] = "Moon Guard;us;3675;retail",
        [1367] = "Nazgrel;us;1184;retail",
        [1368] = "Hydraxis;us;86;retail",
        [1369] = "Wyrmrest Accord;us;1171;retail",
        [1370] = "Farstriders;us;12;retail",
        [1371] = "Borean Tundra;us;86;retail",
        [1372] = "Quel'dorei;us;1185;retail",
        [1373] = "Garrosh;us;1136;retail",
        [1374] = "Mok'Nathal;us;86;retail",
        [1375] = "Nesingwary;us;1184;retail",
        [1377] = "Drenden;us;1138;retail",
        [1378] = "Dun Modr;eu;1378;retail",
        [1379] = "Zul'jin;eu;1379;retail",
        [1380] = "Uldum;eu;1379;retail",
        [1381] = "C'Thun;eu;1378;retail",
        [1382] = "Sanguino;eu;1379;retail",
        [1383] = "Shen'dralar;eu;1379;retail",
        [1384] = "Tyrande;eu;1384;retail",
        [1385] = "Exodar;eu;1385;retail",
        [1386] = "Minahonda;eu;1385;retail",
        [1387] = "Los Errantes;eu;1384;retail",
        [1388] = "Lightbringer;eu;1388;retail",
        [1389] = "Darkspear;eu;633;retail",
        [1391] = "Alonsus;eu;1082;retail",
        [1392] = "Burning Steppes;eu;633;retail",
        [1393] = "Bronze Dragonflight;eu;1393;retail",
        [1394] = "Anachronos;eu;1082;retail",
        [1395] = "Colinas Pardas;eu;1384;retail",
        [1400] = "Un'Goro;eu;1400;retail",
        [1401] = "Garrosh;eu;1401;retail",
        [1404] = "Area 52;eu;1400;retail",
        [1405] = "Todeswache;eu;1405;retail",
        [1406] = "Arygos;eu;1406;retail",
        [1407] = "Teldrassil;eu;1401;retail",
        [1408] = "Norgannon;eu;1408;retail",
        [1409] = "Lordaeron;eu;580;retail",
        [1413] = "Aggra (Português);eu;1303;retail",
        [1415] = "Terokkar;eu;633;retail",
        [1416] = "Blade's Edge;eu;1416;retail",
        [1417] = "Azuremyst;eu;1417;retail",
        [1425] = "Drakkari;us;1425;retail",
        [1427] = "Ragnaros;us;1427;retail",
        [1428] = "Quel'Thalas;us;1428;retail",
        [1549] = "Azuremyst;us;160;retail",
        [1555] = "Auchindoun;us;67;retail",
        [1556] = "Coilfang;us;157;retail",
        [1557] = "Shattered Halls;us;155;retail",
        [1558] = "Blood Furnace;us;77;retail",
        [1559] = "The Underbog;us;1129;retail",
        [1563] = "Terokkar;us;1070;retail",
        [1564] = "Blade's Edge;us;1129;retail",
        [1565] = "Exodar;us;52;retail",
        [1566] = "Area 52;us;3676;retail",
        [1567] = "Velen;us;96;retail",
        [1570] = "The Scryers;us;75;retail",
        [1572] = "Zangarmarsh;us;53;retail",
        [1576] = "Fizzcrank;us;106;retail",
        [1578] = "Ghostlands;us;1175;retail",
        [1579] = "Grizzly Hills;us;1175;retail",
        [1581] = "Galakrond;us;54;retail",
        [1582] = "Dawnbringer;us;160;retail",
        [1587] = "Hellfire;eu;1587;retail",
        [1588] = "Ghostlands;eu;1596;retail",
        [1589] = "Nagrand;eu;1587;retail",
        [1595] = "The Sha'tar;eu;1085;retail",
        [1596] = "Karazhan;eu;1596;retail",
        [1597] = "Auchindoun;eu;1597;retail",
        [1598] = "Shattered Halls;eu;1598;retail",
        [1602] = "Gordunni;eu;1602;retail",
        [1603] = "Lich King;eu;1928;retail",
        [1604] = "Soulflayer;eu;1604;retail",
        [1605] = "Deathguard;eu;1605;retail",
        [1606] = "Sporeggar;eu;1096;retail",
        [1607] = "Nethersturm;eu;3696;retail",
        [1608] = "Shattrath;eu;1401;retail",
        [1609] = "Deepholm;eu;1614;retail",
        [1610] = "Greymane;eu;1928;retail",
        [1611] = "Festung der Stürme;eu;1104;retail",
        [1612] = "Echsenkessel;eu;3691;retail",
        [1613] = "Blutkessel;eu;578;retail",
        [1614] = "Galakrond;eu;1614;retail",
        [1615] = "Howling Fjord;eu;1615;retail",
        [1616] = "Razuvious;eu;1614;retail",
        [1617] = "Deathweaver;eu;1929;retail",
        [1618] = "Die Aldor;eu;1618;retail",
        [1619] = "Das Konsortium;eu;1121;retail",
        [1620] = "Chants éternels;eu;510;retail",
        [1621] = "Marécage de Zangar;eu;1621;retail",
        [1622] = "Temple noir;eu;1624;retail",
        [1623] = "Fordragon;eu;1623;retail",
        [1624] = "Naxxramas;eu;1624;retail",
        [1625] = "Borean Tundra;eu;1929;retail",
        [1626] = "Les Clairvoyants;eu;1127;retail",
        [1922] = "Azuregos;eu;1922;retail",
        [1923] = "Ashenvale;eu;1923;retail",
        [1924] = "Booty Bay;eu;1929;retail",
        [1925] = "Eversong;eu;1925;retail",
        [1926] = "Thermaplugg;eu;1929;retail",
        [1927] = "Grom;eu;1929;retail",
        [1928] = "Goldrinn;eu;1928;retail",
        [1929] = "Blackscar;eu;1929;retail",
        [2075] = "Order of the Cloud Serpent;tw;966;retail",
        [2079] = "Wildhammer;kr;214;retail",
        [2106] = "Rexxar;kr;214;retail",
        [2107] = "Hyjal;kr;2116;retail",
        [2108] = "Deathwing;kr;214;retail",
        [2110] = "Cenarius;kr;2116;retail",
        [2111] = "Stormrage;kr;210;retail",
        [2116] = "Zul'jin;kr;2116;retail",
        [3207] = "Goldrinn;us;3207;retail",
        [3208] = "Nemesis;us;3208;retail",
        [3209] = "Azralon;us;3209;retail",
        [3210] = "Tol Barad;us;3208;retail",
        [3234] = "Gallywix;us;3234;retail",
        [3721] = "Caelestrasz;us;3721;retail",
        [3722] = "Aman'Thul;us;3726;retail",
        [3723] = "Barthilas;us;3723;retail",
        [3724] = "Thaurissan;us;3725;retail",
        [3725] = "Frostmourne;us;3725;retail",
        [3726] = "Khaz'goroth;us;3726;retail",
        [3733] = "Dreadmaul;us;3725;retail",
        [3734] = "Nagrand;us;3721;retail",
        [3735] = "Dath'Remar;us;3726;retail",
        [3736] = "Jubei'Thos;us;3725;retail",
        [3737] = "Gundrak;us;3725;retail",
        [3738] = "Saurfang;us;3721;retail",
        [4372] = "Atiesh;us;4372;classic",
        [4373] = "Myzrael;us;4373;classic",
        [4374] = "Old Blanchy;us;4374;classic",
        [4376] = "Azuresong;us;4376;classic",
        [4384] = "Mankrik;us;4384;classic",
        [4385] = "Pagle;us;4385;classic",
        [4387] = "Ashkandi;us;4387;classic",
        [4388] = "Westfall;us;4388;classic",
        [4395] = "Whitemane;us;4395;classic",
        [4408] = "Faerlina;us;4408;classic",
        [4417] = "Shimmering Flats;kr;4417;classic",
        [4419] = "Lokholar;kr;4419;classic",
        [4420] = "Iceblood;kr;4420;classic",
        [4421] = "Ragnaros;kr;4421;classic",
        [4440] = "Everlook;eu;4440;classic",
        [4441] = "Auberdine;eu;4441;classic",
        [4442] = "Lakeshire;eu;4442;classic",
        [4452] = "Chromie;eu;4452;classic",
        [4453] = "Pyrewood Village;eu;4453;classic",
        [4454] = "Mirage Raceway;eu;4454;classic",
        [4455] = "Razorfen;eu;4455;classic",
        [4456] = "Nethergarde Keep;eu;4456;classic",
        [4464] = "Sulfuron;eu;4464;classic",
        [4465] = "Golemagg;eu;4465;classic",
        [4466] = "Patchwerk;eu;4466;classic",
        [4467] = "Firemaw;eu;4467;classic",
        [4474] = "Flamegor;eu;4474;classic",
        [4476] = "Gehennas;eu;4476;classic",
        [4477] = "Venoxis;eu;4477;classic",
        [4485] = "Maraudon;tw;4485;classic",
        [4487] = "Ivus;tw;4487;classic",
        [4488] = "Wushoolay;tw;4488;classic",
        [4489] = "Zeliek;tw;4489;classic",
        [4647] = "Grobbulus;us;4647;classic",
        [4648] = "Bloodsail Buccaneers;us;4648;classic",
        [4667] = "Remulos;us;4667;classic",
        [4669] = "Arugal;us;4669;classic",
        [4670] = "Yojamba;us;4670;classic",
        [4678] = "Hydraxian Waterlords;eu;4678;classic",
        [4701] = "Mograine;eu;4701;classic",
        [4703] = "Amnennar;eu;4703;classic",
        [4725] = "Skyfury;us;4725;classic",
        [4726] = "Sulfuras;us;4726;classic",
        [4727] = "Windseeker;us;4727;classic",
        [4728] = "Benediction;us;4728;classic",
        [4731] = "Earthfury;us;4731;classic",
        [4738] = "Maladath;us;4738;classic",
        [4742] = "Ashbringer;eu;4742;classic",
        [4745] = "Transcendence;eu;4745;classic",
        [4749] = "Earthshaker;eu;4749;classic",
        [4795] = "Angerforge;us;4795;classic",
        [4800] = "Eranikus;us;4800;classic",
        [4811] = "Giantstalker;eu;4811;classic",
        [4813] = "Mandokir;eu;4813;classic",
        [4815] = "Thekal;eu;4815;classic",
        [4816] = "Jin'do;eu;4816;classic",
        [4840] = "Frostmourne;kr;4840;classic",
        [5735] = "Krol Blade;tw;5735;retail",
        [5736] = "Old Blanchy;tw;5736;retail",
        [5740] = "Arathi Basin;tw;5740;classic",
        [5741] = "Murloc;tw;5741;classic",
        [5742] = "Golemagg;tw;5742;classic",
        [5743] = "Windseeker;tw;5743;classic",
}
--#endregion

--#region Constructors
function XFC.RealmCollection:new()
	local object = XFC.RealmCollection.parent.new(self)
	object.__name = 'RealmCollection'
	object.realmsByID = nil
    object.realmsByAPI = nil
    return object
end

function XFC.RealmCollection:Initialize()
	if(not self:IsInitialized()) then
		self:ParentInitialize()
		self.realmsByID = {}
        self.realmsByAPI = {}
		-- Setup all realms in the region
		for id, data in pairs(RealmData) do
			local realmData = string.Split(data, ';')
			local realm = XFC.Realm:new()
			realm:Initialize()
			realm:Key(realmData[1])
			realm:Name(realmData[1])
			realm:ID(id)
			realm:Region(XFO.Regions:Get(string.upper(realmData[2])))
			realm:ParentID(tonumber(realmData[3]))
			self:Add(realm)
				
			if(realm:Name() == XFF.RealmName() and XF.Player.Region:Equals(realm:Region())) then
				XF.Player.Realm = realm
				XF:Info(self:ObjectName(), 'Initialized player realm [%d:%s]', realm:ID(), realm:Name())
			end
		end

		-- Sanity check
		if(XF.Player.Realm == nil) then
			error('Unable to identify player realm')
		end

		-- Setup default realms (Torghast)
		for realmID, realmName in pairs (DefaultRealms) do
			local realm = XFC.Realm:new(); realm:Initialize()
			realm:Key(realmName)
			realm:Name(realmName)
			realm:ID(realmID)
			self:Add(realm)
		end

		self:IsInitialized(true)
	end
end
--#endregion

--#region Methods
function XFC.RealmCollection:Add(inRealm)
	assert(type(inRealm) == 'table' and inRealm.__name ~= nil and inRealm.__name == 'Realm')
	self.realmsByID[inRealm:ID()] = inRealm
    self.realmsByAPI[inRealm:APIName()] = inRealm
	self.parent.Add(self, inRealm)
end

function XFC.RealmCollection:Get(inKey)
	assert(type(inKey) == 'number' or type(inKey) == 'string')
	if(type(inKey) == 'number') then
		return self.realmsByID[inKey]
	end
    if(self.realmsByAPI[inKey] ~= nil) then
        return self.realmsByAPI[inKey]
    end
	return self.parent.Get(self, inKey)
end
--#endregion