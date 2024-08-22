
using System.Text.RegularExpressions;

try
{
    List<Realm> realms = new();
    Regex realmRegex = new("\'(\\w+)\': (\'|\")(.+)(\'|\")}?$", RegexOptions.Compiled);
    Console.WriteLine("[RealmID] = \"RootRealmID, RegionName, GameVersion, en_US.RealmName, es_MX.RealmName, pt_BR.RealmName, de_DE.RealmName, en_GB.RealmName, es_ES.RealmName, fr_FR.RealmName, it_IT.RealmName, ru_RU.RealmName, ko_KR.RealmName, zh_TW.RealmName, zh_CN.RealmName\"");

    using(StreamReader reader = new("realms.csv"))
    using(StreamWriter writer = new("realms.lua"))
    {
        string? line = reader.ReadLine();
        do
        {
            line = reader.ReadLine();
            string[]? values = line?.Split(',');
            if(values != null)
            {
                List<string> names = new();
                foreach (string language in values[1..13])
                {
                    Match match = realmRegex.Match(language);
                    if (match.Success && match.Groups.Count == 5)
                    {
                        string name = match.Groups[3].Value.Replace("}", "").Replace("\"", "");
                        names.Add(name);
                    }
                }

                Realm realm = new()
                {
                    RootRealmID = Int32.Parse(values[values.Length - 2]),
                    RealmID = Int32.Parse(values[0]),
                    RegionName = values[values.Length - 3].ToUpper(),
                    GameVersion = values[values.Length - 1]
                };

                string _names = String.Join(@",", names);
                writer.WriteLine("\t[{0}] = \"{1},{2},{3},{4}\",", realm.RealmID.ToString(), realm.RootRealmID.ToString(), realm.RegionName, realm.GameVersion, _names.Substring(0, _names.Length-1));
            }
        }
        while(line != null);
    }
}
catch(Exception e)
{
    Console.WriteLine(e.ToString());
}