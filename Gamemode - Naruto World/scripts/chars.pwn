// Anime Fantasy: Naruto World #06 script: chars
#define function<%1> forward chars_%1; public chars_%1
static charname[64];
function<OnGameModeInit()>
{
	// Loading Anime Characters
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Characters)));
	new m = sqlite_NumRows(), cid = 0, loadNickname[MAX_CHARACTERS] = {-1,...};
	if(m >= 1 && m <= MAX_CHARACTERS) for(new i = 0; i < m; i++)
	{
		cid = strval(sqlite_GetField("id"));
		CharacterInfo[cid][cValid] = true;
		CharacterInfo[cid][cID] = INVALID_PLAYER_ID;
		format(CharacterInfo[cid][cName],64,sqlite_GetField("name"));
		CharacterInfo[cid][cDisplayName][0] = EOS;
		CharacterInfo[cid][cFirstName][0] = EOS;
		format(CharacterInfo[cid][cUID],16,sqlite_GetField("uid"));
		property_IntSet(f("character_%s",CharacterInfo[cid][cUID]),cid);
		CharacterInfo[cid][cStatus] = strval(sqlite_GetField("status"));
		format(fstring,sizeof(fstring),sqlite_GetField("nicknames"));
		loadNickname[cid-i] = str_isnum(fstring) ? strval(fstring) : cid;
		format(CharacterInfo[cid][cAvatar],32,sqlite_GetField("avatar"));
		CharacterInfo[cid][cSkin] = strval(sqlite_GetField("skin"));
		CharacterInfo[cid][cTeam] = strval(sqlite_GetField("team"));
		CharacterInfo[cid][cTotal] = strval(sqlite_GetField("total"));
		CharacterInfo[cid][cStr] = strval(sqlite_GetField("str"));
		CharacterInfo[cid][cAgi] = strval(sqlite_GetField("agi"));
		CharacterInfo[cid][cInt] = strval(sqlite_GetField("int"));
		format(fstring,sizeof(fstring),sqlite_GetField("spc"));
		if(equal(fstring,"STR")) CharacterInfo[cid][cSpc] = 1;
		else if(equal(fstring,"AGI")) CharacterInfo[cid][cSpc] = 2;
		else if(equal(fstring,"INT")) CharacterInfo[cid][cSpc] = 3;
		CharacterInfo[cid][cRespect] = strval(sqlite_GetField("respect"));
		CharacterInfo[cid][cLevel] = strval(sqlite_GetField("level"));
		CharacterInfo[cid][cRank] = strval(sqlite_GetField("rank"));
		CharacterInfo[cid][cJinchuuriki] = strval(sqlite_GetField("jinchuuriki"));
		CharacterInfo[cid][cGender] = strval(sqlite_GetField("gender"));
		description_Check("Characters",CharacterInfo[cid][cUID]);
		printf("Loaded Character: %s",CharacterInfo[cid][cName]);
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	// Loading Character Nicknames
	for(new i = 0; i < MAX_CHARACTERS; i++) if(loadNickname[i] != -1) nickname_Load(i+1,loadNickname[i]);
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
	command(character,cmdtext);
	return 0;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	if(PlayerInfo[playerid][pCharacter] != INVALID_CHARACTER) CharacterInfo[PlayerInfo[playerid][pCharacter]][cID] = INVALID_PLAYER_ID;
	return 1;
}
function<OnPlayerKeyStateChange(playerid,newkeys,oldkeys)>
{
	if(newkeys & KEY_SECONDARY_ATTACK && gtd_IsShown(playerid,e_GlobalTD:gtd_character)) gtd_Hide(playerid,e_GlobalTD:gtd_character,gtd_GetInfo(playerid,e_GlobalTD:gtd_character),PlayerInfo[playerid][pCharacter]);
	return 1;
}
#undef function
// Characters
@f(_,chars.GetName(cid)) return (format(charname,sizeof(charname),CharacterInfo[cid][cName]), charname);
@f(_,chars.GetDisplayName(cid,bool:v=false))
{
	if(CharacterInfo[cid][cDisplayName][0] == EOS)
	{
		format(CharacterInfo[cid][cDisplayName],64,CharacterInfo[cid][cName]);
		str_repchar(CharacterInfo[cid][cDisplayName],!v ? '_' : ' ',!v ? ' ' : '_');
		if((fint = strfind(CharacterInfo[cid][cDisplayName],"(")) != -1) strdel(CharacterInfo[cid][cDisplayName],fint-1,strlen(CharacterInfo[cid][cDisplayName]));
	}
	format(charname,sizeof(charname),CharacterInfo[cid][cDisplayName]);
	return charname;
}
@f(_,chars.GetTeam(cid)) return CharacterInfo[cid][cTeam];
@f(_,chars.GetFirstName(cid))
{
	if(CharacterInfo[cid][cFirstName][0] == EOS)
	{
		format(CharacterInfo[cid][cFirstName],64,CharacterInfo[cid][cName]);
		if((fint = strfind(CharacterInfo[cid][cFirstName]," ")) != -1) strdel(CharacterInfo[cid][cFirstName],fint,strlen(CharacterInfo[cid][cFirstName]));
	}
	format(charname,sizeof(charname),CharacterInfo[cid][cFirstName]);
	return charname;
}
@f(_,chars.GetCount())
{
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Characters)));
	return sqlite_NumRows();
}
@f(_,chars.IsValidCharacter(characterid)) return characterid >= 1 && characterid <= chars_GetCount() && CharacterInfo[characterid][cValid];
@f(bool,chars.IsAssigned(characterid))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `cuid` = '%s'",sqlite_TableName(e_SQLiteTable:st_Players),CharacterInfo[characterid][cUID]));
	new m = sqlite_NumRows(), bool:ret = false;
	for(new i = 0; i < m && !ret; i++)
	{
		if(strval(sqlite_GetField("status")) > 0) ret = true;
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	return ret;
}
@f(bool,chars.IsAssignedTo(characterid,userid))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `cuid` = '%s' AND `uid` = %d",sqlite_TableName(e_SQLiteTable:st_Players),CharacterInfo[characterid][cUID],userid));
	new m = sqlite_NumRows(), bool:ret = false;
	for(new i = 0; i < m && !ret; i++)
	{
		if(strval(sqlite_GetField("status")) > 0) ret = true;
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	return ret;
}
@f(_,chars.GetUser(characterid,bool:pid = false))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `cuid` = '%s'",sqlite_TableName(e_SQLiteTable:st_Players),CharacterInfo[characterid][cUID]));
	if(!sqlite_NumRows()) return 0;
	new uid = strval(sqlite_GetField(pid ? ("pid") : ("uid")));
	sqlite_FreeResults();
	return uid;
}
@f(_,chars.GetStatus(characterid,userid))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `cuid` = '%s' AND `uid` = %d",sqlite_TableName(e_SQLiteTable:st_Players),CharacterInfo[characterid][cUID],userid));
	new status = strval(sqlite_GetField("status"));
	sqlite_FreeResults();
	return status;
}
@f(_,chars.Activate(characterid,userid,bool:active)) sqlite_Query(serverDatabase,f("UPDATE `%s` SET `status` = %d WHERE `uid` = %d AND `cuid` = '%s'",sqlite_TableName(e_SQLiteTable:st_Players),_:active,userid,CharacterInfo[characterid][cUID]));
@f(_,chars.RemoveFrom(characterid,userid)) sqlite_Query(serverDatabase,f("DELETE FROM `%s` WHERE `uid` = %d AND `cuid` = '%s'",sqlite_TableName(e_SQLiteTable:st_Players),userid,CharacterInfo[characterid][cUID]));
@f(_,chars.AssignTo(characterid,userid))
{
	player_Add(userid,CharacterInfo[characterid][cUID]);
	user_SetPlayerInfo(userid,"dna",str_generate(32,.nums=false,.abc=false,.ABC=true,.symbols=false));
}
@f(_,chars.GetAssignedCharacter(userid,index,key[]="cuid"))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `uid` = %d",sqlite_TableName(e_SQLiteTable:st_Players),userid));
	new m = sqlite_NumRows(), ret = -1, cidx = 0;
	for(new i = 0; i < m && ret == -1; i++)
	{
		if(!strval(sqlite_GetField("status"))) continue;
		if(cidx == index) ret = equal(key,"cuid") ? chars_Index(sqlite_GetField("cuid")) : strval(sqlite_GetField(key));
		cidx++;
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	return ret;
}
@f(_,chars.GetAssignedCharacters(userid))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `uid` = %d AND `status` > 0",sqlite_TableName(e_SQLiteTable:st_Players),userid));
	new m = sqlite_NumRows();
	sqlite_FreeResults();
	return m;
}
@f(_,chars.Index(uid[])) return property_IntExist(f("character_%s",uid)) ? property_IntGet(fstring) : INVALID_CHARACTER;
@f(_,chars.Find(str[]))
{
	new cid = INVALID_CHARACTER;
	if(str_isnum(str) && chars_IsValidCharacter(strval(str))) cid = strval(str);
	else for(new i = 0; i < MAX_CHARACTERS && cid == INVALID_CHARACTER; i++) if(strfind(CharacterInfo[i][cName],str,true) != -1 || strfind(chars_GetDisplayName(i,true),str,true) != -1 || strfind(chars_GetDisplayName(i),str,true) != -1) cid = i;
	return cid;
}
@f(_,chars.Set(playerid,newchar,bool:setname = true,bool:original = false,bool:ingame = false))
{
	if(PlayerInfo[playerid][pCharacter] != INVALID_CHARACTER) CharacterInfo[PlayerInfo[playerid][pCharacter]][cID] = INVALID_PLAYER_ID;
	CharacterInfo[newchar][cID] = playerid;
	PlayerInfo[playerid][pCharacter] = newchar;
	//PlayerInfo[playerid][pTeam] = CharacterInfo[newchar][cTeam];
	player_UpdateDisplayName(playerid);
	if(setname) SetPlayerName(playerid,PlayerInfo[playerid][pDisplayNickname]);
	skin_Set(playerid,CharacterInfo[newchar][cSkin]);
	SetPlayerColor(playerid,rank_Color(CharacterInfo[newchar][cRank]));
	if(ingame)
	{
		health_Set(playerid,math_min(PlayerInfo[playerid][pHealth],stats_GetStats(playerid,stats_health)));
		chakra_Set(playerid,math_min(PlayerInfo[playerid][pChakra],stats_GetStats(playerid,stats_chakra)));
		control_ClosePowers(playerid);
		if(newchar == PlayerInfo[playerid][pOriginalCharacter] || original) cooldown_Load(playerid);
		else cooldown_Save(playerid);
		ptd_Hide(playerid,e_PlayerTD:ptd_powers);
		power_ClearPowers(playerid);
		power_UpdatePowers(playerid,PlayerInfo[playerid][pCharacter]);
		new e_PlayerTD:ptds[] = {ptd_stats,ptd_powers};
		for(new i = 0; i < sizeof(ptds); i++)
		{
			ptd_Update(playerid,ptds[i]);
			ptd_Show(playerid,ptds[i]);
		}
	}
	if(original) PlayerInfo[playerid][pOriginalCharacter] = newchar;
}
@f(_,chars.Remove(playerid))
{
	if(PlayerInfo[playerid][pCharacter] != INVALID_CHARACTER)
	{
		CharacterInfo[PlayerInfo[playerid][pCharacter]][cID] = INVALID_PLAYER_ID;
		PlayerInfo[playerid][pCharacter] = INVALID_CHARACTER;
		PlayerInfo[playerid][pTeam] = 0;
	 	player_UpdateDisplayName(playerid);
		SetPlayerName(playerid,PlayerInfo[playerid][pDisplayNickname]);
		SetPlayerSkin(playerid,0);
		power_ClearPowers(playerid);
	}
}
// Rank
@f(_,rank.GetPlayerRank(playerid)) return PlayerInfo[playerid][pCharacter] == INVALID_CHARACTER ? 0 : CharacterInfo[PlayerInfo[playerid][pCharacter]][cRank];
@f(_,rank.Get(cid)) return CharacterInfo[cid][cRank];
@f(_,rank.Name(rankid))
{
	new n[24];
	switch(rankid)
	{
		case 1: n = "Academy Student";
		case 2: n = "Genin";
		case 3: n = "Chunin";
		case 4: n = "Jonin";
		case 5: n = "Special Jonin";
		case 6: n = "Kage Level";
		case 7: n = "Kage / Village Head";
		default: n = "Unknown";
	}
	return n;
}
@f(_,rank.Color(rankid))
{
	new col;
	switch(rankid)
	{
		case 1: col = 0xB0E0E6FF;
		case 2: col = 0xF5DEB3FF;
		case 3: col = 0xB8860BFF;
		case 4: col = 0x9ACD32FF;
		case 5: col = 0x556B2FFF;
		case 6: col = 0xDC143CFF;
		case 7: col = 0x8B008BFF;
		default: col = -1;
	}
	return col;
}
// Nickname
@f(_,nickname.Load(cid,from))
{
	new nickname[MAX_NAME_LENGTH];
	for(new i = 1; i <= MAX_CHARACTER_NICKNAMES; i++)
	{
		format(nickname,sizeof(nickname),sqlite_GetString(gameDatabase,e_SQLiteTable:st_Characters,from,f("nickname%d",i)));
		if(strlen(nickname) > 0) property_StrSet(nickname_Var(cid,i),nickname);
		else
		{
			CharacterInfo[cid][cNicknames] = i-1;
			break;
		}
	}
}
@f(_,nickname.IsValid(cid,nid)) return nid >= 1 && nid <= CharacterInfo[cid][cNicknames] && property_StrExist(nickname_Var(cid,nid));
@f(_,nickname.Get(cid,nid))
{
	new nickname[MAX_NAME_LENGTH];
	format(nickname,sizeof(nickname),property_StrGet(nickname_Var(cid,nid)));
	return nickname;
}
@f(_,nickname.Var(cid,nid))
{
	new var[16];
	format(var,sizeof(var),"cnickname%d-%d",cid,nid);
	return var;
}
// Skins
@f(_,skin.Set(playerid,skinid))
{
	SetPlayerSkin(playerid,skinid);
	player_Stop(playerid);
	player_GetPosition(playerid);
	player_SetPosition(playerid,PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2]);
}
@f(_,skin.Get(playerid)) return GetPlayerSkin(playerid);
@f(_,skin.SetUnknown(playerid)) return skin_Set(playerid,0);
@f(bool,skin.IsValid(skinid)) return skin_Index(skinid) != -1;
@f(_,skin.GetName(skinid))
{
	new i = skin_Index(skinid), ret[MAX_NAME_LENGTH];
	if(i != -1) format(ret,sizeof(ret),SkinList[i][skName]);
	return ret;
}
@f(_,skin.Index(skinid))
{
	new cPointer = (_:(cache_prefix)) + (_:(cache2_skinidx)) + skinid, sidx = -1;
	if(cache_exist(cPointer)) sidx = cache_get(cPointer);
	else
	{
		for(new i = 0; i < sizeof(SkinList) && sidx == -1; i++) if(SkinList[i][skID] == skinid) sidx = i;
		cache_set(cPointer,sidx);
	}
	return sidx;
}
// Command
cmd.character(playerid,params[])
{
	if(!strlen(params)) return chat_Usage(playerid,"/character","character name / id");
	new c = chars_Find(params);
	if(!chars_IsValidCharacter(c)) return chat_Error(playerid,"Invalid character.");
	if(gtd_IsShown(playerid,e_GlobalTD:gtd_character)) gtd_Hide(playerid,e_GlobalTD:gtd_character,gtd_GetInfo(playerid,e_GlobalTD:gtd_character),PlayerInfo[playerid][pCharacter]);
	gtd_Show(playerid,e_GlobalTD:gtd_character,c,playerid);
	return 1;
}
