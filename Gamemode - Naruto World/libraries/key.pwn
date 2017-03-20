enum KeyInformation
{
	keyID,
	keyName[16]
}
new AvailableKeys[][KeyInformation] =
{
	{48,"0"},
	{49,"1"},
	{50,"2"},
	{51,"3"},
	{52,"4"},
	{53,"5"},
	{54,"6"},
	{55,"7"},
	{56,"8"},
	{57,"9"},
	{65,"A"},
	{66,"B"},
	{67,"C"},
	{68,"D"},
	{69,"E"},
	{70,"F"},
	{71,"G"},
	{72,"H"},
	{73,"I"},
	{74,"J"},
	{75,"K"},
	{76,"L"},
	{77,"M"},
	{78,"N"},
	{79,"O"},
	{80,"P"},
	{81,"Q"},
	{82,"R"},
	{83,"S"},
	{84,"T"},
	{85,"U"},
	{86,"V"},
	{87,"W"},
	{88,"X"},
	{89,"Y"},
	{90,"Z"},
	{112,"F1"},
	{113,"F2"},
	{114,"F3"},
	{115,"F4"},
	{116,"F5"},
	{117,"F6"},
	{118,"F7"},
	{119,"F8"},
	{120,"F9"},
	{121,"F10"},
	{122,"F11"},
	{123,"F12"}
};
@f(_,key.Bind(playerid,keyid,modifier=0))
{
	if(keyid < 0 || keyid > MAX_KEY_ID) return;
	f("bindkey-%d-%d",keyid,modifier);
	if(GetPVarType(playerid,fstring) == PLAYER_VARTYPE_NONE)
	{
		SetPVarInt(playerid,fstring,1);
		BindKey(playerid,keyid,modifier);
	}
}
@f(_,key.Unbind(playerid,keyid,modifier=0))
{
	if(keyid < 0 || keyid > MAX_KEY_ID) return;
	f("bindkey-%d-%d",keyid,modifier);
	if(GetPVarType(playerid,fstring) != PLAYER_VARTYPE_NONE)
	{
		DeletePVar(playerid,fstring);
		UnbindKey(playerid,keyid,modifier);
	}
}
@f(bool,key.IsBinded(playerid,keyid,modifier=0))
{
	if(keyid < 0 || keyid > MAX_KEY_ID) return false;
	f("bindkey-%d-%d",keyid,modifier);
	return GetPVarType(playerid,fstring) != PLAYER_VARTYPE_NONE;
}
@f(_,key.FindID(keyname[]))
{
	f("keyid_%s",keyname);
	new kIdx = -1;
	if(property_IntExist(fstring)) kIdx = property_IntGet(fstring);
	else
	{
		for(new i = 0; i < sizeof(AvailableKeys) && kIdx == -1; i++) if(equal(AvailableKeys[i][keyName],keyname)) kIdx = AvailableKeys[i][keyID];
		if(kIdx != -1) property_IntSet(fstring,kIdx);
	}
	return kIdx;
}
@f(_,key.FindName(keyid))
{
	if(keyid < 0 || keyid > MAX_KEY_ID) return;
	f("keyname_%s",keyid);
	if(property_IntExist(fstring)) return property_StrGet(fstring);
	else
	{
		new kIdx = -1;
		for(new i = 0; i < sizeof(AvailableKeys) && kIdx == -1; i++) if(AvailableKeys[i][keyID] == keyid) kIdx = i;
		if(kIdx != -1)
		{
			property_StrSet(fstring,AvilableKeys[i][keyName]);
			return AvilableKeys[i][keyName];
		}
	}
	return kIdx;
}
