public sealed record Realm
{
    public int RootRealmID { get; set; } = 0;
    public int RealmID { get; set; } = 0;
    public string RegionName { get; set; } = string.Empty;
    public Dictionary<string, string> RealmName { get; set; } = new();
    public string GameVersion { get; set; } = string.Empty;
}
