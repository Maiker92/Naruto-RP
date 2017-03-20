// Anime Fantasy: Naruto World #14 script: admin
#define function<%1> forward admin_%1; public admin_%1
new AdminCommandList[][data_AdminCommands] =
{
	{"/ahelp",1,			"List of admin commands per level / information about specific admin command."},
	{"/adduser",4,			"Add a new user account."},
	{"/assign",4,			"Assign a character into user account."},
	{"/remove",4,			"Remove an assigned character from user account."},
	{"/activate",3,			"Activate character (allow player to use it if you deactivated it before)."},
	{"/deactivate",3,		"Deactivate character (disable his option to use it)."},
	{"/id",1,				"Find user ID by name or name by user ID."},
	{"/setadmin",5,			"Change the admin level of player."},
	{"/play",1,				"Play audio stream from URL."},
	{"/goto",2,				"Teleport to an in-game player."},
	{"/get",2,				"Teleport an in-game player to you."},
	//{"/removebuilding",5,	"Removes an object from the map."}, deprecated (used for tests)
	{"/setworld",5,			"Set a player's virtual world."},
	{"/getworld",5,			"Find out which virtual world a player is in."},
	{"/setint",5,			"Set a player's interior."},
	{"/getint",5,			"Find out which interior a player is in."},
	{"/setskin",4,			"Set the skin of an in-game player."},
	{"/skinid",4,			"Search for skin ID by character name."},
	{"/skinlist",4,			"Show the full skin list (names and IDs)."},
	{"/counts",2,			"Technical information about object counts."},
	{"/toggledownfall",2,	"Make it rain!"},
	{"/jetpack",1,			"Give jetpack to an in-game player or remove it if he already has."},
	{"/sjetpack",5,			"Give a flying ability based on jetpack and gravity (or remove it)."},
	{"/route",5,			"Technical information about existing routes."},
	{"/cc",1,				"Clear the chat for everyone in the server."},
	{"/settime",2,			"Set the world time."},
	{"/setweather",2,		"Set the world weather."},
	{"/camera",2,			"Give or take a camera."},
	{"/jumpheight",4,		"Modify a player's jump height."},
	{"/debuganim",5,		"Enable or disable debugging for player's animations."},
	{"/focusvill",5,		"Focus a villager to debug his movement."},
	{"/pathcoords",5,		"Finds path coordinates."}
};
new AdminTime[][data_AdminOptions] =
{
	{"Morning",8},
	{"Afternoon",14},
	{"Evening",19},
	{"Night",23}
};
new AdminWeather[][data_AdminOptions] =
{
	{"Sunny",1},
	{"Cloudy",4},
	{"Rainy",8},
	{"Foggy",9},
	{"Extra Sunny",13},
	{"Sandstorm",19}
};
function<OnGameModeInit()>
{
	// Loading admin commands
	admin_UpdateCommands();
	// /skinlist dialog
	dialog_Create(d_SkinList,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Skin list","Close","",d_Null);
	for(new i = 0; i < sizeof(SkinList); i += 2)
	{
		if(sizeof(SkinList) % 2 != 0 && i == sizeof(SkinList)-1) dialog_AddLine(f("%03d) %s - %d",i+1,SkinList[i][skName],SkinList[i][skID]));
		else dialog_AddLine(f("%03d) %s - %d || %03d) %s - %d",i+1,SkinList[i][skName],SkinList[i][skID],i+2,SkinList[i+1][skName],SkinList[i+1][skID]));
	}
	// /settime /setweather dialogs
	dialog_Create(d_SetTime,DIALOG_STYLE_TABLIST_HEADERS,@c(DIALOG_DHEADER) "Set Time","Set","Cancel",d_Null);
	dialog_AddLine("Name\tHour");
	for(new i = 0; i < sizeof(AdminTime); i++) dialog_AddLine(f("{%s}%s\t%02d:00",color_ToString(i % 2 == 0 ? CC_LIST_FIRST : CC_LIST_SECOND),AdminTime[i][admoptName],AdminTime[i][admoptValue]));
	dialog_AddLine(@c(LIST_SPECIAL) "Default\t{1}:00");
	dialog_Create(d_SetWeather,DIALOG_STYLE_TABLIST_HEADERS,@c(DIALOG_DHEADER) "Set Weather","Set","Cancel",d_Null);
	dialog_AddLine("Name\tWeather ID");
	for(new i = 0; i < sizeof(AdminWeather); i++) dialog_AddLine(f("{%s}%s\t%d",color_ToString(i % 2 == 0 ? CC_LIST_FIRST : CC_LIST_SECOND),AdminWeather[i][admoptName],AdminWeather[i][admoptValue]));
	dialog_AddLine(@c(LIST_SPECIAL) "Default\t{1}");
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	if(PlayerInfo[playerid][pAdmin] > 0) onlineAdmins--;
	if(PlayerInfo[playerid][pFocusDebugVillager] > -1) villager_PlayerDebug(playerid,PlayerInfo[playerid][pFocusDebugVillager],false);
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
 	command(admins,cmdtext);
	if(admin_IsAdmin(playerid))
	{
		if(cmdtext[1] == '/') return chat_Group(playerid,e_Chats:chat_admins,cmdtext[2]), 1;
		else
		{
			idx = 0, cmdt = str_tok(cmdtext,idx);
			for(new i = 0; i < sizeof(AdminCommandList); i++)
			{
				if(equal(cmdt,AdminCommandList[i][acCommand]))
				{
					if(PlayerInfo[playerid][pAdmin] < AdminCommandList[i][acLevel]) return chat_Error(playerid,f("You must be at admin level %d or above to use that command.",AdminCommandList[i][acLevel]));
					cmdt = str_rest(cmdtext,idx);
					return CallLocalFunction(f("admincmd_%s",AdminCommandList[i][acCommand][1]),"is",playerid,str_space(cmdt));
				}
			}
	 	}
 	}
	return 0;
}
function<OnPlayerUpdate(playerid)>
{
	if(PlayerInfo[playerid][pKick]) return 0;
	return 1;
}
function<OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])>
{
	if(dialogid == _:d_SetTime) world_SetTime(listitem == sizeof(AdminTime) ? worldDefault[1] : AdminTime[listitem][admoptValue]);
	if(dialogid == _:d_SetWeather) world_SetWeather(listitem == sizeof(AdminWeather) ? worldDefault[0] : AdminWeather[listitem][admoptValue]);
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_halfsec))
	{
		if(PlayerInfo[playerid][pKick])
		{
			PlayerInfo[playerid][pKick]--;
			if(!PlayerInfo[playerid][pKick]) Kick(playerid);
		}
	}
	return 1;
}
function<OnPlayerTargetPlayer(playerid,oldtargetid,newtargetid)>
{
	if(PlayerInfo[playerid][pFocusDebugVillager] == -2 && IsPlayerConnected(newtargetid))
	{
		new n = PlayerInfo[newtargetid][pNPCIndex];
		if(n != INVALID_PLAYER_ID)
		{
			if(NPCInfo[n][npcUsage] == e_NPCUsage:npcusage_villager)
			{
				new vid = NPCInfo[n][npcUsageID];
				if(vid != -1)
				{
					PlayerInfo[playerid][pFocusDebugVillager] = vid;
					villager_PlayerDebug(playerid,vid,true);
					chat_Send(playerid,CC_CHAT_INFO,f("Now focusing villager " @c(CHAT_BOLD) "%s" @c(CHAT_INFO) " [to stop: /focusvill].",VillagerInfo[vid][vgrName]));
				}
			}
		}
	}
	return 1;
}
function<OnPlayerKeyStateChange(playerid,newkeys,oldkeys)>
{
	if(PlayerInfo[playerid][pSavingPathCoords])
	{
		if(PRESSED(KEY_YES))
		{
			PlayerInfo[playerid][pSavingPathDistance][0] = math_min(PlayerInfo[playerid][pSavingPathDistance][0]+(HOLDING(KEY_SPRINT) ? (-0.1) : 0.1),50.0);
			SetPlayerAttachedObject(playerid,AOSLOT_PATHSELECT1,19133,1,-1.0820,0.0000,PlayerInfo[playerid][pSavingPathDistance][0],0.0,0.0,0.0);
		}
		if(PRESSED(KEY_NO))
		{
			PlayerInfo[playerid][pSavingPathDistance][1] = math_min(PlayerInfo[playerid][pSavingPathDistance][1]-(HOLDING(KEY_SPRINT) ? (-0.1) : 0.1),0.1);
			SetPlayerAttachedObject(playerid,AOSLOT_PATHSELECT2,19133,1,-1.0820,0.0000,-PlayerInfo[playerid][pSavingPathDistance][1],0.0,0.0,0.0);
		}
	}
	return 1;
}
#undef function
// Admin
@f(_,admin.IsAdmin(playerid)) return PlayerInfo[playerid][pAdmin] >= 1 && PlayerInfo[playerid][pAdmin] <= ADMIN_MAX_LEVEL;
@f(_,admin.SetLevel(userid,level))
{
	assert user_Exist(userid);
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `id` = %d",sqlite_TableName(e_SQLiteTable:st_Admins),userid));
	new bool:update = sqlite_NumRows() > 0, playerid = INVALID_PLAYER_ID;
	sqlite_FreeResults();
	if(update) sqlite_SetInt(serverDatabase,e_SQLiteTable:st_Admins,userid,"level",level);
	else sqlite_Add(serverDatabase,e_SQLiteTable:st_Admins,"ii","id",userid,"level",level);
	if((playerid = user_GetPlayer(userid)) != INVALID_PLAYER_ID) PlayerInfo[playerid][pAdmin] = level;
}
@f(_,admin.UpdateCommands())
{
	new bool:newest[sizeof(AdminCommandList)] = {false,...};
	for(new i = 0; i < sizeof(AdminCommandList); i++) if(!sqlite_IsExistS(serverDatabase,e_SQLiteTable:st_AdminCommands,AdminCommandList[i][acCommand],"cmdtext"))
	{
		sqlite_Add(serverDatabase,e_SQLiteTable:st_AdminCommands,"si","cmdtext",AdminCommandList[i][acCommand],"level",AdminCommandList[i][acLevel]);
		newest[i] = true;
	}
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_AdminCommands)));
	new m = sqlite_NumRows();
	for(new i = 0, index = -1, c[16]; i < m; i++)
	{
		//property_IntSet(sqlite_GetField("cmdtext"),strval(sqlite_GetField("level")));
		idx = -1;
		format(c,sizeof(c),sqlite_GetField("cmdtext"));
		for(new j = 0; j < sizeof(AdminCommandList) && idx == -1; j++) if(equal(AdminCommandList[j][acCommand],c)) index = j;
		if(index != -1) if(!newest[index]) AdminCommandList[idx][acLevel] = strval(sqlite_GetField("level"));
		sqlite_NextRow();
	}
	//sqlite_FreeResults();
}
@f(_,admin.Kick(playerid,reason[],adminid = INVALID_PLAYER_ID))
{
	if(!IsPlayerConnected(playerid)) return 1;
	PlayerInfo[playerid][pKick] = 2;
	new str[M_S];
	format(str,sizeof(str)," * " @c(CHAT_IMPNOTICE_BOLD) "%s" @c(CHAT_IMPNOTICE) " has been kicked",player_GetName(playerid));
	if(adminid != INVALID_PLAYER_ID) format(str,sizeof(str),"%s by " @c(CHAT_IMPNOTICE_BOLD) "%s" @c(CHAT_IMPNOTICE),str,player_GetName(adminid));
	format(str,sizeof(str),"%s (" @c(CHAT_IMPNOTICE_BOLD) "%s" @c(CHAT_IMPNOTICE) ")",str,reason);
	Loop(player,i) if(playerid != i) chat_Send(i,CC_CHAT_IMPNOTICE,str);
	format(str,sizeof(str)," * You have been kicked for " @c(CHAT_IMPNOTICE_BOLD) "%s" @c(CHAT_IMPNOTICE),reason);
	if(adminid != INVALID_PLAYER_ID) format(str,sizeof(str),"%s by admin " @c(CHAT_IMPNOTICE_BOLD) "%s" @c(CHAT_IMPNOTICE) " (" @c(CHAT_IMPNOTICE_BOLD) "%s" @c(CHAT_IMPNOTICE) ")",str,player_GetName(adminid),player_GetNickname(adminid));
	chat_Send(playerid,CC_CHAT_IMPNOTICE,str);
	chat_Send(playerid,CC_CHAT_IMPNOTICE," * You can reconnect to the server after you exit the game.");
	chat_Send(playerid,CC_CHAT_IMPNOTICE," * For any further help, contact us in our website: " @c(CHAT_LINK) WEBURL);
	return 1;
}
// Commands
cmd.admins(playerid,params[])
{
	#pragma unused params
	if(!onlineAdmins) return chat_Send(playerid,CC_CHAT_NOTICE,"There are no online admins right now.");
	chat_Send(playerid,CC_CHAT_HEADER,f("Online Admins [" @c(CHAT_VALUE) "%d" @c(CHAT_HEADER) "]",onlineAdmins));
	new c = 0;
	Loop(player,i) if(admin_IsAdmin(i)) chat_Send(playerid,c % 2 == 0 ? CC_LIST_FIRST : CC_LIST_SECOND,f("%d) %s" @c(CHAT_INFO) " [" @c(CHAT_INFO_VALUE) "%s" @c(CHAT_INFO) " | ID: " @c(CHAT_INFO_VALUE) "%03d" @c(CHAT_INFO) " | Admin Level: " @c(CHAT_INFO_VALUE) "%d" @c(CHAT_INFO) "]",++c,player_GetNickname(i),player_GetName(i),i,PlayerInfo[i][pAdmin]));
	return 1;
}
// Admin Commands
#define emptycmd(%1) (!strlen(%1) || equal(%1," "))
acmd.ahelp(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/ahelp","admin level 1 - " #ADMIN_MAX_LEVEL " / command name");
	if(str_isnum(params))
	{
		new lvl = strval(params), c = 0;
		if(lvl < 1 || lvl > ADMIN_MAX_LEVEL) return chat_Error(playerid,"Wrong admin level.");
		fstring = "";
		for(new i = 0; i < sizeof(AdminCommandList); i++)
		{
			if(AdminCommandList[i][acLevel] == lvl)
			{
				if(!c)
				{
					chat_Send(playerid,CC_CHAT_HEADER,f("Admin commands for level " @c(CHAT_VALUE) "%d" @c(CHAT_HEADER) ":",lvl));
					fstring = "";
				}
				format(fstring,sizeof(fstring),!strlen(fstring) ? (" • %s%s") : ("%s, %s"),fstring,AdminCommandList[i][acCommand]);
				c++;
			}
			if((c % 6 == 0 || i == sizeof(AdminCommandList)-1) && strlen(fstring) > 0)
			{
				chat_Send(playerid,CC_LIST_ITEMS,fstring);
				fstring = "";
			}
		}
		if(!c) return chat_Error(playerid,"Not found any admin commands for this admin level.");
	}
	else
	{
		new cmdid = -1;
		for(new i = 0; i < sizeof(AdminCommandList) && cmdid == -1; i++) if(equal(params,AdminCommandList[i][acCommand]) || equal(params,AdminCommandList[i][acCommand][1])) cmdid = i;
		if(cmdid == -1) chat_Error(playerid,"Command name not found.");
		else chat_Send(playerid,CC_CHAT_INFO,f("Command \"%s\" (%d): %s",AdminCommandList[cmdid][acCommand],AdminCommandList[cmdid][acLevel],AdminCommandList[cmdid][acHelp]));
	}
	return 1;
}
acmd.adduser(playerid,params[])
{
	new nickname[64], password[64];
	idx = 0;
	str_set(nickname,str_tok(params,idx),64);
	str_set(password,str_tok(params,idx),64);
	if(!strlen(nickname)) return chat_Usage(playerid,"/adduser","*user name","password");
	if(!strlen(password)) return chat_Usage(playerid,"/adduser","user name","*password");
	if(user_GetID(nickname) > 0) return chat_Error(playerid,"This nickname is already exist.");
	user_Register(nickname,password);
	new uid = user_GetID(nickname);
	chat_Send(playerid,CC_CHAT_NEW,f("User added (User ID: " @c(CHAT_NEW_VALUE) "%03d" @c(CHAT_NEW) " | Nickname: " @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) " / " @c(CHAT_NEW_VALUE) "user_%d" @c(CHAT_NEW) ")",uid,nickname,uid));
	return 1;
}
acmd.assign(playerid,params[])
{
	new user[64], uid, character;
	idx = 0;
	str_set(user,str_tok(params,idx),64);
	cmdt = str_tok(params,idx);
	if(!strlen(user)) return chat_Usage(playerid,"/assign","*user id","character");
	if(!strlen(cmdt)) return chat_Usage(playerid,"/assign","user id","*character");
	uid = strval(user), character = chars_Find(cmdt);
	if(!user_Exist(uid)) return chat_Error(playerid,"Invalid user ID.");
	if(!chars_IsValidCharacter(character)) return chat_Error(playerid,"Invalid character.");
	if(chars_IsAssigned(character)) return chat_Error(playerid,"This character is already assigned.");
	if(CharacterInfo[character][cStatus] != 1) return chat_Error(playerid,"You can't assign this character.");
	chars_AssignTo(character,uid);
	chat_Send(playerid,CC_CHAT_NEW,f("Character " @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) " assigned to user ID " @c(CHAT_NEW_VALUE) "%03d" @c(CHAT_NEW) ".",chars_GetName(character),uid));
	return 1;
}
acmd.remove(playerid,params[])
{
	new user[64], uid, character;
	idx = 0;
	str_set(user,str_tok(params,idx),64);
	cmdt = str_tok(params,idx);
	if(!strlen(user)) return chat_Usage(playerid,"/remove","*user id","character");
	if(!strlen(cmdt)) return chat_Usage(playerid,"/remove","user id","*character");
	uid = strval(user), character = chars_Find(cmdt);
	if(!user_Exist(uid)) return chat_Error(playerid,"Invalid user ID.");
	if(!chars_IsValidCharacter(character)) return chat_Error(playerid,"Invalid character.");
	if(!chars_IsAssigned(character)) return chat_Error(playerid,"This character is not assigned to anybody.");
	if(!chars_IsAssignedTo(character,uid)) return chat_Error(playerid,"This character is not assigned to this user.");
	chars_RemoveFrom(character,uid);
	chat_Send(playerid,CC_CHAT_NEW,f("Character " @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) " removed from user ID " @c(CHAT_NEW_VALUE) "%03d" @c(CHAT_NEW) ".",chars_GetName(character),uid));
	return 1;
}
acmd.activate(playerid,params[])
{
	new user[64], uid, character;
	idx = 0;
	str_set(user,str_tok(params,idx),64);
	cmdt = str_tok(params,idx);
	if(!strlen(user)) return chat_Usage(playerid,"/activate","*user id","character");
	if(!strlen(cmdt)) return chat_Usage(playerid,"/activate","user id","*character");
	uid = strval(user), character = chars_Find(cmdt);
	if(!user_Exist(uid)) return chat_Error(playerid,"Invalid user ID.");
	if(!chars_IsValidCharacter(character)) return chat_Error(playerid,"Invalid character.");
	if(!chars_IsAssigned(character)) return chat_Error(playerid,"This character is not assigned to anybody.");
	if(!chars_IsAssignedTo(character,uid)) return chat_Error(playerid,"This character is not assigned to this user.");
	if(chars_GetStatus(character,uid) > 0) return chat_Error(playerid,"This character is already active.");
	chars_Activate(character,uid,true);
	chat_Send(playerid,CC_CHAT_NEW,f("Character " @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) " of user ID " @c(CHAT_NEW_VALUE) "%03d" @c(CHAT_NEW) " has been activated.",chars_GetName(character),uid));
	return 1;
}
acmd.deactivate(playerid,params[])
{
	new user[64], uid, character;
	idx = 0;
	str_set(user,str_tok(params,idx),64);
	cmdt = str_tok(params,idx);
	if(!strlen(user)) return chat_Usage(playerid,"/deactivate","*user id","character");
	if(!strlen(cmdt)) return chat_Usage(playerid,"/deactivate","user id","*character");
	uid = strval(user), character = chars_Find(cmdt);
	if(!user_Exist(uid)) return chat_Error(playerid,"Invalid user ID.");
	if(!chars_IsValidCharacter(character)) return chat_Error(playerid,"Invalid character.");
	if(!chars_IsAssigned(character)) return chat_Error(playerid,"This character is not assigned to anybody.");
	if(!chars_IsAssignedTo(character,uid)) return chat_Error(playerid,"This character is not assigned to this user.");
	if(!chars_GetStatus(character,uid)) return chat_Error(playerid,"This character is not active.");
	chars_Activate(character,uid,false);
	chat_Send(playerid,CC_CHAT_NEW,f("Character " @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) " of user ID " @c(CHAT_NEW_VALUE) "%03d" @c(CHAT_NEW) " has been deactivated.",chars_GetName(character),uid));
	return 1;
}
acmd.id(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/id","user id / name");
	new uid = str_isnum(params) ? strval(params) : user_GetID(params);
	if(!user_Exist(uid)) return chat_Error(playerid,"Invalid user ID.");
	chat_Send(playerid,CC_CHAT_INFO,f("User ID %03d nickname: " @c(CHAT_INFO_VALUE) "%s",uid,user_GetKey(uid,"name")));
	return 1;
}
acmd.setadmin(playerid,params[])
{
	new user[64], lvl, playa, uid;
	idx = 0;
	str_set(user,str_tok(params,idx),64);
	cmdt = str_tok(params,idx);
	if(!strlen(user)) return chat_Usage(playerid,"/setadmin","*user id","admin level 0-" #ADMIN_MAX_LEVEL);
	if(!strlen(cmdt)) return chat_Usage(playerid,"/setadmin","user id","*admin level 0-" #ADMIN_MAX_LEVEL);
	uid = strval(user), lvl = strval(cmdt);
	if(!user_Exist(uid)) return chat_Error(playerid,"Invalid user ID.");
	if(lvl < 0 || lvl > 5) return chat_Error(playerid,"Invalid admin level.");
	chat_Send(playerid,CC_CHAT_NEW,f("The admin level of user ID " @c(CHAT_NEW_VALUE) "%03d" @c(CHAT_NEW) " has been set to " @c(CHAT_NEW_VALUE) "%d" @c(CHAT_NEW) ".",uid,lvl));
	playa = user_GetPlayer(uid);
	if(player_IsConnected(playa)) chat_Send(playa,CC_CHAT_NEW,f("Your admin level has been changed to " @c(CHAT_NEW_VALUE) "%d" @c(CHAT_NEW) ".",lvl));
	admin_SetLevel(uid,lvl);
	PlayerInfo[playa][pAdmin] = lvl;
	return 1;
}
acmd.play(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/play","url");
	Loop(player,i) audio_Stream(i,params);
	return 1;
}
acmd.goto(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/goto","player");
	new id = convert_playerid(params,playerid);
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	player_GetPosition(id);
	math_xyinfront(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][3],5.0);
	player_SetPosition(playerid,PlayerInfo[id][pPosition][0],PlayerInfo[id][pPosition][1],PlayerInfo[id][pPosition][2]);
	return 1;
}
acmd.get(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/get","player");
	new id = convert_playerid(params,playerid);
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	if(PlayerInfo[id][pAdmin] > PlayerInfo[playerid][pAdmin]) return chat_Error(playerid,"You can't use this command on that player.");
	player_GetPosition(playerid);
	math_xyinfront(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][3],5.0);
	player_SetPosition(id,PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2]);
	return 1;
}
/*acmd.removebuilding(playerid,params[])
{
	const COUNT = 2;
	new m[64], models[COUNT] = {0,0};
	idx = 0;
	for(new i = 0; i < COUNT; i++)
	{
		str_set(m,str_tok(params,idx),64);
		if(!strlen(m)) return chat_Usage(playerid,"/removebuilding",!i ? ("*from id") : ("from id"),!i ? ("to id") : ("*toid"));
		models[i] = strval(m);
	}
	for(new i = models[0]; i <= models[1]; i++) RemoveBuildingForPlayer(playerid,i,0.0,0.0,0.0,10000.0);
	return 1;
}*/
acmd.setworld(playerid,params[])
{
	idx = 0, cmdt = str_tok(params,idx);
	if(emptycmd(cmdt)) return chat_Usage(playerid,"/setworld","*player","world id");
	new id = convert_playerid(cmdt,playerid);
	cmdt = str_tok(params,idx);
	if(emptycmd(cmdt)) return chat_Usage(playerid,"/setworld","player","*world id");
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	vworld_Set(id,strval(cmdt));
	return 1;
}
acmd.getworld(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/getworld","player");
	new id = convert_playerid(cmdt,playerid);
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	chat_Send(playerid,CC_CHAT_INFO,f("%s's world is " @c(CHAT_INFO_VALUE) "%d",player_GetName(id),vworld_Get(id)));
	return 1;
}
acmd.setint(playerid,params[])
{
	idx = 0, cmdt = str_tok(params,idx);
	if(emptycmd(cmdt)) return chat_Usage(playerid,"/setint","*player","interior id");
	new id = convert_playerid(cmdt,playerid);
	cmdt = str_tok(params,idx);
	if(emptycmd(cmdt)) return chat_Usage(playerid,"/setint","player","*interior id");
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	SetPlayerInterior(id,strval(cmdt));
	return 1;
}
acmd.getint(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/getint","player");
	new id = convert_playerid(cmdt,playerid);
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	chat_Send(playerid,CC_CHAT_INFO,f("%s's interior is " @c(CHAT_INFO_VALUE) "%d",player_GetName(id),GetPlayerInterior(id)));
	return 1;
}
acmd.setskin(playerid,params[])
{
	idx = 0, cmdt = str_tok(params,idx);
	if(emptycmd(cmdt)) return chat_Usage(playerid,"/setskin","*player","skin id");
	new id = convert_playerid(cmdt,playerid);
	cmdt = str_tok(params,idx);
	if(emptycmd(cmdt)) return chat_Usage(playerid,"/setskin","player","*skin id");
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	new s = strval(cmdt);
	if(!skin_IsValid(s)) return chat_Error(playerid,"Invalid skin ID.");
	skin_Set(id,strval(cmdt));
	chat_Send(playerid,CC_CHAT_NEW,f("%s's skin has been changed to skin ID " @c(CHAT_NEW_VALUE) "%d" @c(CHAT_NEW) " (" @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) ")",player_GetName(id),s,skin_GetName(s)));
	return 1;
}
acmd.skinid(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/skinid","character name");
	if(strlen(params) > MAX_NAME_LENGTH) return chat_Error(playerid,"Skin name is too long (maximum characters: " #MAX_NAME_LENGTH ").");
	chat_Send(playerid,CC_CHAT_HEADER,f("Search results for skin ID named " @c(CHAT_VALUE) "%s" @c(CHAT_HEADER) ":",params));
	new str[64], c = 0;
	for(new i = 0; i < sizeof(SkinList); i++) if(strfind(SkinList[i][skName],params,true) != -1)
	{
		format(str,sizeof(str)," %d) %s - %d",++c,SkinList[i][skName],SkinList[i][skID]);
		strins(str,@c(LIST_ITEMS),strfind(str,params,true)+strlen(params));
		strins(str,@c(CHAT_BOLD),strfind(str,params,true));
		chat_Send(playerid,CC_LIST_ITEMS,str);
	}
	if(!c) chat_Send(playerid,CC_LIST_ITEMS,"No skins found.");
	return 1;
}
acmd.skinlist(playerid,params[]) return dialog_Show(playerid,d_SkinList);
acmd.counts(playerid,params[]) return chat_Send(playerid,-1,f("Objects: %d / %d (Visible: %d / %d)",CountDynamicObjects(),MAX_STREAMED_OBJECTS,Streamer_CountVisibleItems(playerid,STREAMER_TYPE_OBJECT),Streamer_GetVisibleItems(STREAMER_TYPE_OBJECT)));
acmd.toggledownfall(playerid,params[]) return chat_Send(playerid,CC_CHAT_TOGGLE,f("Rain is %s.",(isRainy = !isRainy) ? ("enabled") : ("disabled")));
acmd.jetpack(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/jetpack","player");
	new id = convert_playerid(params,playerid);
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	if(GetPlayerSpecialAction(id) == SPECIAL_ACTION_USEJETPACK) player_Stop(id); // remove his jetpack
	else SetPlayerSpecialAction(id,SPECIAL_ACTION_USEJETPACK);
	return 1;
}
acmd.sjetpack(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/sjetpack","player");
	new id = convert_playerid(params,playerid);
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	PlayerInfo[id][pSuperJetpack] = !PlayerInfo[id][pSuperJetpack];
	if(PlayerInfo[id][pSuperJetpack])
	{
		SetPlayerSpecialAction(id,SPECIAL_ACTION_USEJETPACK);
		SetPlayerGravity(id,1.0);
	}
	else
	{
		player_Stop(id);
		SetPlayerGravity(id,0.008);
	}
	return 1;
}
acmd.route(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/route","route id");
	new id = strval(params);
	if(id < 0 || id >= MAX_ROUTES || !RouteInfo[id][rtValid]) return chat_Error(playerid,"");
	chat_Send(playerid,CC_CHAT_INFO,f("Route Owner Type = %d",_:route_GetOwnerType(id)));
	chat_Send(playerid,CC_CHAT_INFO,f("Route Owner ID = %d",_:route_GetOwnerID(id)));
	return 1;
}
acmd.cc(playerid,params[])
{
	Loop(player,i) chat_Clear(i,true);
	return 1;
}
acmd.settime(playerid,params[]) return dialog_Show(playerid,d_SetTime,"s",f("%02d",worldDefault[1]));
acmd.setweather(playerid,params[]) return dialog_Show(playerid,d_SetWeather,"s",f("%02d",worldDefault[0]));
acmd.camera(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/camera","player");
	new id = convert_playerid(params,playerid), wd[2];
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	GetPlayerWeaponData(id,9,wd[0],wd[1]);
	if(wd[0] == WEAPON_CAMERA) ResetPlayerWeapons(id);
	else GivePlayerWeapon(id,WEAPON_CAMERA,9999);
	return 1;
}
acmd.jumpheight(playerid,params[])
{
	idx = 0, cmdt = str_tok(params,idx);
	if(emptycmd(cmdt)) return chat_Usage(playerid,"/jumpheight","*player","height / default");
	new id = convert_playerid(cmdt,playerid);
	cmdt = str_tok(params,idx);
	if(emptycmd(cmdt)) return chat_Usage(playerid,"/jumpheight","player","*height / default");
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	if(equal(cmdt,"default"))
	{
		if(PlayerInfo[id][pModifiedJump] == -999.0) return chat_Error(playerid,"This player have no modified jump height value.");
		PlayerInfo[id][pModifiedJump] = -999.0;
		chat_Send(playerid,CC_CHAT_NEW,f("%s's custom jump height is now the default value based on his stats.",player_GetName(id)));
	}
	else
	{
		PlayerInfo[id][pModifiedJump] = floatstr(cmdt);
		chat_Send(playerid,CC_CHAT_NEW,f("%s's custom jump height is now " @c(CHAT_NEW_VALUE) "%.2f" @c(CHAT_NEW) " (reset to default using " @c(CHAT_BOLDKEY) "/jumpheight %d default" @c(CHAT_NEW) ")",player_GetName(id),PlayerInfo[id][pModifiedJump],id));
	}
	return 1;
}
acmd.debuganim(playerid,params[])
{
	if(emptycmd(params)) return chat_Usage(playerid,"/debuganim","player");
	new id = convert_playerid(params,playerid);
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player ID.");
	chat_Send(playerid,CC_CHAT_TOGGLE,f("Debugging animations for player %s is %s.",player_GetName(id),(PlayerInfo[id][pDebugAnimations] = !PlayerInfo[id][pDebugAnimations]) ? ("enabled") : ("disabled")));
	return 1;
}
acmd.focusvill(playerid,params[])
{
	if(PlayerInfo[playerid][pFocusDebugVillager] == -1)
	{
		PlayerInfo[playerid][pFocusDebugVillager] = -2;
		chat_Send(playerid,CC_CHAT_INFO,"Just target the villager you want to debug. Use this command again to stop.");
	}
	else
	{
		villager_PlayerDebug(playerid,PlayerInfo[playerid][pFocusDebugVillager],false);
		PlayerInfo[playerid][pFocusDebugVillager] = -1;
		chat_Send(playerid,CC_CHAT_INFO,"Villager debugging disabled.");
	}
	return 1;
}
acmd.pathcoords(playerid,params[])
{
	PlayerInfo[playerid][pSavingPathCoords] = !PlayerInfo[playerid][pSavingPathCoords];
	if(PlayerInfo[playerid][pSavingPathCoords])
	{
		for(new i = 0; i < 2; i++) if(PlayerInfo[playerid][pSavingPathDistance][i] == 0.0) PlayerInfo[playerid][pSavingPathDistance][i] = 2.3;
		SetPlayerAttachedObject(playerid,AOSLOT_PATHSELECT1,19133,1,-1.0820,0.0000,PlayerInfo[playerid][pSavingPathDistance][0],0.0,0.0,0.0);
		SetPlayerAttachedObject(playerid,AOSLOT_PATHSELECT2,19133,1,-1.0820,0.0000,-PlayerInfo[playerid][pSavingPathDistance][1],0.0,0.0,0.0);
		chat_Send(playerid,CC_CHAT_TOGGLE,"Click Y or N to increase distance. Hold SPRINT to decrease. Use this command again once you have finished.");
	}
	else
	{
		if(emptycmd(params)) return chat_Usage(playerid,"/pathcoords","path name");
		if(!file_IsValidName(params)) return chat_Error(playerid,"Invalid path name. Can only contain letters and numbers.");
		RemovePlayerAttachedObject(playerid,AOSLOT_PATHSELECT1);
		RemovePlayerAttachedObject(playerid,AOSLOT_PATHSELECT2);
		player_GetPosition(playerid);
		player_GetAngle(playerid);
		new data[128], Float:p[4];
		math_xyinleft(p[0],p[1],PlayerInfo[playerid][pPosition][3],PlayerInfo[playerid][pSavingPathDistance][0]);
		math_xyinright(p[2],p[3],PlayerInfo[playerid][pPosition][3],PlayerInfo[playerid][pSavingPathDistance][1]);
		format(data,sizeof(data),"Creator: %s\nPos: %.4f,%.4f,%.4f\nMin X: %.2f\nMax X: %.2f\nMin Y: %.2f\nMax Y: %.2f",player_GetName(playerid),PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],math_min(p[0],p[2]),math_max(p[0],p[2]),math_min(p[1],p[3]),math_max(p[1],p[3]));
		file_WriteAllText(f(DIR_DEBUG "/pathcoords_%s_%s_%s.txt",params,time_GetDateAsString('_'),time_GetTimeAsString(true,'_')),data);
		chat_Send(playerid,CC_CHAT_TOGGLE,"Data of this path position has been wrote to the debug directory.");
	}
	return 1;
}
#undef emptycmd
