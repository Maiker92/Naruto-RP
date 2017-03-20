// Anime Fantasy: Naruto World #08 script: user
#define function<%1> forward user_%1; public user_%1
function<OnGameModeInit()>
{
	// Count total players
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Players)));
	totalPlayers = sqlite_NumRows();
	sqlite_FreeResults();
	// User dialogs
	dialog_Create(d_CharacterSelect,DIALOG_STYLE_TABLIST_HEADERS,@c(DIALOG_DHEADER) "Select your character","Select","Cancel",d_Null);
	dialog_AddLine("Character\tLevel");
	dialog_AddLine("{1}");
	dialog_Create(d_Logout,DIALOG_STYLE_LIST,@c(DIALOG_DHEADER) "Logout options","Select","Cancel",d_Null);
	dialog_AddLine(@c(LIST_ITEMS) "Change character");
	dialog_AddLine(@c(LIST_ITEMS) "Log out to startup menu");
	dialog_AddLine(@c(LIST_ITEMS) "Log out and exit game");
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	if(str_startswith(player_GetNickname(playerid),"user_"))
	{
		new id[MAX_PLAYER_NAME];
		format(id,sizeof(id),player_GetNickname(playerid));
		strdel(id,0,strfind(id,"_"));
		PlayerInfo[playerid][pUserID] = !strlen(id) || !str_isnum(id) ? 0 : strval(id);
		if(!user_Exist(PlayerInfo[playerid][pUserID])) PlayerInfo[playerid][pUserID] = 0;
	}
	else PlayerInfo[playerid][pUserID] = user_GetID(player_GetNickname(playerid));
	if(!PlayerInfo[playerid][pUserID])
	{
		chat_Send(playerid,CC_CHAT_TEXT,"The nickname you've connected with is not recognized as registered to the server.");
		chat_Send(playerid,CC_CHAT_TEXT,"Please register first in our site (" @c(CHAT_LINK) WEBURL @c(CHAT_TEXT) "), and then reconnect.");
		Kick(playerid);
		return 0;
	}
	else
	{
		if(ConnectionInfo[PlayerInfo[playerid][pConnectionID]][conAutoLogin])
		{
			chat_Send(playerid,CC_CHAT_TEXT,f("You've been recognized as user ID " @c(CHAT_VALUE) "%03d" @c(CHAT_TEXT) " and automatically been logged in.",PlayerInfo[playerid][pUserID]));
			user_Login(playerid,PlayerInfo[playerid][pUserID]);
			intro_GoLast(playerid);
		}
		else chat_Send(playerid,CC_CHAT_TEXT,f("You've been recognized as user ID " @c(CHAT_VALUE) "%03d" @c(CHAT_TEXT) ". Please log in using the command " @c(CHAT_BOLDKEY) "/login",PlayerInfo[playerid][pUserID]));
	}
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	if(PlayerInfo[playerid][pLogged] && PlayerInfo[playerid][pStatus] == player_status_playing && PlayerInfo[playerid][pCharacter] != INVALID_CHARACTER) user_SaveData(playerid);
	return 1;
}
function<OnPlayerText(playerid,text[])>
{
	if(!PlayerInfo[playerid][pLogged]) return 0;
	return 1;
}
function<OnPlayerRequestClass(playerid,classid)>
{
	SpawnPlayer(playerid);
	return 0;
}
function<OnPlayerSpawn(playerid)>
{
	if(!PlayerInfo[playerid][pLogged])
	{
		camera_ToggleSpectating(playerid,true);
		vworld_Set(playerid,VW_LOGIN);
		return 0;
	}
	if(PlayerInfo[playerid][pSpawned]) PlayerInfo[playerid][pSpawned] = false;
	else
	{
		health_Kill(playerid);
		chat_Error(playerid,"Spawn error");
		return 0;
	}
	camera_ToggleSpectating(playerid,false);
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
 	command(register,cmdtext);
 	command(login,cmdtext);
 	command(changepass,cmdtext);
 	command(changename,cmdtext);
 	command(logout,cmdtext);
	return 0;
}
function<OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])>
{
	if(dialogid == _:d_CharacterSelect && response)
	{
		new sc = chars_GetAssignedCharacter(PlayerInfo[playerid][pUserID],listitem), Float:p[4];
		PlayerInfo[playerid][pPlayerID] = player_FindID(PlayerInfo[playerid][pUserID],CharacterInfo[sc][cUID]);
		chars_Set(playerid,sc,true);
		user_LoadData(playerid);
		chat_Send(playerid,CC_CHAT_TEXT,f("You're now playing as " @c(CHAT_BOLD) "%s" @c(CHAT_TEXT) " of the " @c(CHAT_BOLD) "%s" @c(CHAT_TEXT) ".",PlayerInfo[playerid][pDisplayName],TeamInfo[PlayerInfo[playerid][pTeam]][tName]));
		chat_Send(playerid,CC_CHAT_TEXT,"Please use " @c(CHAT_BOLDKEY) "/help" @c(CHAT_TEXT) " for any kind of issue. Have fun :)");
		if(PlayerInfo[playerid][pLastPos][0] == 0.0) teams_GetRandomSpawnPoint(chars_GetTeam(sc),p[0],p[1],p[2],p[3]);
		else for(new i = 0; i < sizeof(p); i++) p[i] = PlayerInfo[playerid][pLastPos][i];
		player_SetSpawnInfo(playerid,NO_TEAM,CharacterInfo[sc][cSkin],p[0],p[1]+WORLD_Y_OFFSET,p[2]+SPAWN_Z_OFFSET,p[3]);
		player_Spawn(playerid);
		PlayerInfo[playerid][pStatus] = e_PlayerStatus:player_status_playing;
	}
	if(dialogid == _:d_Logout && response)
	{
		chars_Remove(playerid);
		player_Close(playerid);
		player_ResetCharacterInfo(playerid);
		if(PlayerInfo[playerid][pLogged] && PlayerInfo[playerid][pStatus] == player_status_playing && PlayerInfo[playerid][pCharacter] != INVALID_CHARACTER) user_SaveData(playerid);
		chat_Send(playerid,CC_CHAT_TEXT,"You've been logged out from your character.");
		gtd_Hide(playerid,e_GlobalTD:gtd_menu);
		ptd_HideAll(playerid);
		switch(listitem)
		{
			case 0:
			{
				camera_ToggleSpectating(playerid,true);
				vworld_Set(playerid,VW_LOGIN);
				user_SelectCharacter(playerid);
			}
			case 1: intro_GoLast(playerid);
			case 2: QuitFromGame(playerid);
		}
	}
	return 1;
}
#undef function
// User
@f(_,user.GetID(name[])) return sqlite_FindID(serverDatabase,e_SQLiteTable:st_Accounts,"name",name);
@f(_,user.GetPlayer(id))
{
	Loop(player,i) if(PlayerInfo[i][pUserID] == id) return i;
	return INVALID_PLAYER_ID;
}
@f(_,user.Register(name[],password[])) return sqlite_Add(serverDatabase,e_SQLiteTable:st_Accounts,"sss","name",name,"password",password,"code",str_generate(8,.nums=true,.ABC=true));
@f(_,user.Login(playerid,userid))
{
	if(sqlite_IsExist(serverDatabase,e_SQLiteTable:st_Admins,userid))
	{
		// Load admin data
		PlayerInfo[playerid][pAdmin] = sqlite_GetInt(serverDatabase,e_SQLiteTable:st_Admins,userid,"level");
		// Logged in
		chat_Send(playerid,CC_CHAT_TEXT,f("Your admin level is: " @c(CHAT_VALUE) "%d",PlayerInfo[playerid][pAdmin]));
		onlineAdmins++;
	}
	PlayerInfo[playerid][pLogged] = true;
}
@f(_,user.LoadData(playerid))
{
	// Last position
	new Float:p[4], str[M_S_DB];
	format(str,sizeof(str),player_GetInfo(playerid,"lastpos"));
	str_loadxyza(str,p);
	PlayerInfo[playerid][pLastPos] = p;
	// Last chakra
	chakra_Set(playerid,strval(player_GetInfo(playerid,"lastchakra")));
	// Team
	PlayerInfo[playerid][pTeam] = strval(player_GetInfo(playerid,"team"));
	// Level
	level_Set(playerid,strval(player_GetInfo(playerid,"level")));
	xp_Set(playerid,strval(player_GetInfo(playerid,"xp")));
	// Permissions
	perm_LoadAll(playerid);
}
@f(_,user.SaveData(playerid))
{
	// check if he's inside his village
	// Last position
	player_GetPosition(playerid);
	player_GetAngle(playerid);
	player_SetInfo(playerid,"lastpos",str_joinf(PlayerInfo[playerid][pPosition],4,","));
	// Last chakra
	player_SetInfo(playerid,"lastchakra",tostring(floatround(PlayerInfo[playerid][pChakra])));
	// Team
	player_SetInfo(playerid,"team",tostring(PlayerInfo[playerid][pTeam]));
	// Permissions
	perm_SaveAll(playerid);
}
@f(_,user.Exist(userid))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `id` = %d",sqlite_TableName(e_SQLiteTable:st_Accounts),userid));
	return sqlite_NumRows() > 0;
}
@f(_,user.SetKey(userid,key[],value[])) sqlite_Query(serverDatabase,f("UPDATE `%s` SET `%s` = '%s' WHERE `id` = %d'",sqlite_TableName(e_SQLiteTable:st_Accounts),key,value,userid));
@f(_,user.GetKey(userid,key[]))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `id` = %d",sqlite_TableName(e_SQLiteTable:st_Accounts),userid));
	new ret[M_S_DB];
	if(sqlite_NumRows() == 1) format(ret,sizeof(ret),sqlite_GetField(key));
	sqlite_FreeResults();
	return ret;
}
@f(_,user.SetPlayerInfo(pid,key[],value[])) sqlite_Query(serverDatabase,f("UPDATE `%s` SET `%s` = '%s' WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Players),key,value,pid));
@f(_,user.GetPlayerInfo(pid,key[]))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Players),pid));
	new ret[M_S_DB];
	if(sqlite_NumRows() == 1) format(ret,sizeof(ret),sqlite_GetField(key));
	sqlite_FreeResults();
	return ret;
}
@f(_,user.GetPlayerName(pid))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Players),pid));
	new ret[M_S_DB];
	if(sqlite_NumRows() == 1) format(ret,sizeof(ret),user_GetKey(strval(sqlite_GetField("uid")),"name"));
	sqlite_FreeResults();
	return ret;
}
@f(_,user.GetPlayerCharacter(pid))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Players),pid));
	new id = INVALID_CHARACTER;
	if(sqlite_NumRows() == 1) id = chars_Index(sqlite_GetField("cuid"));
	sqlite_FreeResults();
	return id;
}
@f(_,user.SelectCharacter(playerid))
{
	player_ResetCharacterInfo(playerid);
	power_ClearPowers(playerid);
	perm_Clear(playerid);
	new list[128], mx = chars_GetAssignedCharacters(PlayerInfo[playerid][pUserID]);
	for(new i = 0; i < mx; i++) str_add(list,f("{%s}%s\t%02d",color_ToString(i % 2 == 0 ? CC_LIST_FIRST : CC_LIST_SECOND),chars_GetName(chars_GetAssignedCharacter(PlayerInfo[playerid][pUserID],i)),chars_GetAssignedCharacter(PlayerInfo[playerid][pUserID],i,"level")),"\n");
	dialog_Show(playerid,d_CharacterSelect,"s",list);
}
// Player
@f(_,player.Add(userid,cuid[]))
{
	new c = chars_Index(cuid);
	sqlite_Add(serverDatabase,e_SQLiteTable:st_Players,"iisisiiis","pid",++totalPlayers,"uid",userid,"cuid",CharacterInfo[c][cUID],"type",0,"dna","","status",1,"xp",0,"level",1,"lastpos","0.0,0.0,0.0,0.0","lastchakra",0,"team",chars_GetTeam(c));
	return 1;
}
@f(_,player.SetInfo(playerid,key[],value[])) user_SetPlayerInfo(PlayerInfo[playerid][pPlayerID],key,value);
@f(_,player.GetInfo(playerid,key[]))
{
	new ret[M_S_DB]; // in order to fix runtime error 5 I must store the result in a string variable...
	format(ret,sizeof(ret),user_GetPlayerInfo(PlayerInfo[playerid][pPlayerID],key));
	return ret;
}
@f(_,player.FindID(userid,cuid[]))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `uid` = %d AND `cuid` = '%s'",sqlite_TableName(e_SQLiteTable:st_Players),userid,cuid));
	if(sqlite_NumRows() == 1) return strval(sqlite_GetField("pid"));
	return 0;
}
// Commands
cmd.register(playerid,params[])
{
	if(!strval(misc_Setting("REGISTRATION"))) chat_Send(playerid,CC_CHAT_TEXT,"To register and enjoy the server, please visit our website: " @c(CHAT_LINK) WEBURL);
	else
	{
		if(PlayerInfo[playerid][pLogged]) return chat_Error(playerid,"You're already logged in.");
		if(!strlen(params)) return chat_Usage(playerid,"/register","password","character id");
		idx = 0, cmdt = str_tok(params,idx);
		new selectedChar = strval(str_tok(params,idx));
		if(!chars_IsValidCharacter(selectedChar)) return chat_Error(playerid,"Invalid character ID.");
		user_Register(player_GetName(playerid),cmdt);
		new uid = user_GetID(player_GetName(playerid));
		chars_AssignTo(selectedChar,uid);
		chat_Send(playerid,CC_CHAT_NEW,f("User added (User ID: %03d | Nickname: %s / user_%d | Character: %s)",uid,player_GetName(playerid),uid,chars_GetName(selectedChar)));
	}
	return 1;
}
cmd.login(playerid,params[])
{
	if(PlayerInfo[playerid][pUserID] < 1) return chat_Error(playerid,"You must have a user ID.");
	if(PlayerInfo[playerid][pLogged]) return chat_Error(playerid,"You're already logged in.");
	if(!strlen(params)) return chat_Usage(playerid,"/login","password");
	if(strlen(params) < 3 || strlen(params) > 15) return chat_Error(playerid,"The password is too short or too long.");
	if(!strcmp(params,user_GetKey(PlayerInfo[playerid][pUserID],"password")))
	{
		chat_Send(playerid,CC_CHAT_NEW,"You've successfully logged in.");
		user_Login(playerid,PlayerInfo[playerid][pUserID]);
		intro_GoLast(playerid);
	}
	else
	{
		PlayerInfo[playerid][pFailedLogins]++;
		chat_Error(playerid,f("Login failed [%d/3]",PlayerInfo[playerid][pFailedLogins]));
		if(PlayerInfo[playerid][pFailedLogins] >= 3) admin_Kick(playerid,"Login failed");
	}
	return 1;
}
cmd.changepass(playerid,params[])
{
	if(PlayerInfo[playerid][pUserID] < 1) return chat_Error(playerid,"You must have a user ID.");
	if(!PlayerInfo[playerid][pLogged]) return chat_Error(playerid,"You have to be logged in to use this command.");
	if(!strlen(params)) return chat_Usage(playerid,"/changepass","password");
	if(strlen(params) < 3 || strlen(params) > 15) return chat_Error(playerid,"The password is too short or too long.");
	if(!strcmp(params,user_GetKey(PlayerInfo[playerid][pUserID],"password"))) return chat_Error(playerid,"You've written the same password that you had.");
	user_SetKey(PlayerInfo[playerid][pUserID],"password",params);
	chat_Send(playerid,CC_CHAT_NEW,f("Your password have been changed to: " @c(CHAT_NEW_VALUE) "%s",params));
	return 1;
}
cmd.changename(playerid,params[])
{
	if(PlayerInfo[playerid][pUserID] < 1) return chat_Error(playerid,"You must have a user ID.");
	if(!PlayerInfo[playerid][pLogged]) return chat_Error(playerid,"You have to be logged in to use this command.");
	if(!strlen(params)) return chat_Usage(playerid,"/changename","name");
	if(strlen(params) < 3 || strlen(params) > 20) return chat_Error(playerid,"The name is too short or too long.");
	if(!strcmp(params,user_GetKey(PlayerInfo[playerid][pUserID],"name"))) return chat_Error(playerid,"You've written the same nickname that you had.");
	user_SetKey(PlayerInfo[playerid][pUserID],"name",params);
	if(PlayerInfo[playerid][pCharacter] != INVALID_CHARACTER) SetPlayerName(playerid,params);
	chat_Send(playerid,CC_CHAT_NEW,f("Your nickname have been changed to: " @c(CHAT_NEW_VALUE) "%s",params));
	return 1;
}
cmd.logout(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][pUserID] < 1) return chat_Error(playerid,"You must have a user ID.");
	if(!PlayerInfo[playerid][pLogged]) return chat_Error(playerid,"You're not logged in.");
	dialog_Show(playerid,d_Logout);
	return 1;
}
