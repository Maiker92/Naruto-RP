// Anime Fantasy: Naruto World #32 script: perms
#define function<%1> forward perms_%1; public perms_%1
static permissionsOverview[M_D_L], header[64];
function<OnGameModeInit()>
{
	dialog_Create(d_InsufficientPermission,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Insufficient permission","Close","",d_Null);
	dialog_AddLine(@c(DIALOG_ERROR) "Accessing this feature requires the following permission, which you do not have:");
	dialog_AddLine("{1} » {2}");
	dialog_Create(d_Permissions,DIALOG_STYLE_LIST,@c(DIALOG_DHEADER) "Permissions","Select","Close",d_Null);
	dialog_AddLine(@c(LIST_ITEMS) "View my permissions");
	dialog_AddLine(@c(LIST_ITEMS) "Manage permissions");
	dialog_Create(d_ManagePermissions,DIALOG_STYLE_LIST,@c(DIALOG_DHEADER) "Manage Permissions","Select","Back",d_Permissions);
	dialog_AddLine(@c(LIST_ITEMS) "View permissions by player");
	dialog_AddLine(@c(LIST_ITEMS) "View players by permissions");
	dialog_AddLine(@c(LIST_ITEMS) "Grant permission");
	dialog_AddLine(@c(LIST_ITEMS) "Revoke permission");
	dialog_AddLine(@c(LIST_ITEMS) "Grant myself village management permission");
	dialog_AddLine(@c(LIST_ITEMS) "Revoke myself village management permission");
	dialog_AddLine(@c(LIST_ITEMS) "Grant myself all village permissions");
	dialog_AddLine(@c(LIST_ITEMS) "Revoke myself all village permissions");
	dialog_Create(d_ViewPermissions,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "View Permissions","Back","",d_Permissions);
	dialog_AddLine(@c(DIALOG_HEADER) "PERMISSIONS OVERVIEW: {1}" @c(DIALOG_TEXT) "\n\n{2}");
	dialog_Create(d_ListPermissions,DIALOG_STYLE_TABLIST_HEADERS,@c(DIALOG_DHEADER) "Permission List","Select","Cancel",d_Permissions);
	dialog_AddLine("Category\tPermission");
	dialog_AddLine(@c(LIST_ITEMS) "{1}");
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
 	command(permissions,cmdtext);
 	shortcut(perms,cmdtext,permissions);
	return 0;
}
function<OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])>
{
	if(dialogid == _:d_Permissions && response)
	{
		switch(listitem)
		{
			case 0: /* view my */
			{
				permissionsOverview[0] = EOS;
				new c = 0;
				for(new i = 0; i < sizeof(Permissions); i++) if(GetPVarType(playerid,perm_Format(Permissions[i][permCode])) != PLAYER_VARTYPE_NONE) str_add(permissionsOverview,f(" %d) [%s] %s",++c,PermissionFamilies[Permissions[i][permFamily]][permfamName],Permissions[i][permName]),"\n");
				str_add(permissionsOverview,f("\n" @c(DIALOG_SUM) "Total %d permissions.",c),"\n");
				dialog_SetButtons(d_ViewPermissions,"Back","");
				dialog_Show(playerid,d_ViewPermissions,"ss",f("YOURSELF - %s",str_upper(chars_GetDisplayName(PlayerInfo[playerid][pCharacter]))),permissionsOverview);
			}
			case 1: /* manage */ dialog_Show(playerid,d_ManagePermissions);
		}
	}
	if(dialogid == _:d_ManagePermissions)
	{
		if(response)
		{
			if(listitem != 4) if(!perm_Check(playerid,"manage_village_perms")) return 1;
			const REQUIRED_RANK = 6;
			switch(listitem)
			{
				case 0: control_SelectPlayer(playerid,e_SelectionSource:selsrc_dialog,_:d_ManagePermissions,"viewing permissions");
				case 1: ShowPermissionList(playerid,"Find Players");
				case 2: ShowPermissionList(playerid,"Grant Permission");
				case 3: control_SelectPlayer(playerid,e_SelectionSource:selsrc_dialog,_:d_ManagePermissions,"revoking permission");
				case 4:
				{
					if(perm_IsGranted(playerid,"manage_village_perms")) return chat_Error(playerid,"You already got the village management permission."), 1;
					if(rank_GetPlayerRank(playerid) < REQUIRED_RANK) return chat_Error(playerid,f("You must be at least ranked as %s (%d).",rank_Name(REQUIRED_RANK),REQUIRED_RANK)), 1;
					perm_Grant(playerid,"manage_village_perms",true);
					sound_PlaySystem(playerid,e_SystemSound:syssnd_tick);
					chat_System(playerid,CC_SYSTEM_PERMS,f("Village management permission granted, you can now manage " @c(CHAT_BOLD) "%s" @c(CHAT_TEXT) " permissions using " @c(CHAT_BOLDKEY) "/perms",TeamInfo[PlayerInfo[playerid][pTeam]][tSName]));
				}
				case 5:
				{
					if(!perm_IsGranted(playerid,"manage_village_perms")) return chat_Error(playerid,"You do not have the village management permission."), 1;
					if(rank_GetPlayerRank(playerid) < REQUIRED_RANK) return chat_Error(playerid,f("You must be at least ranked as %s (%d).",rank_Name(REQUIRED_RANK),REQUIRED_RANK)), 1;
					perm_Grant(playerid,"manage_village_perms",false);
					sound_PlaySystem(playerid,e_SystemSound:syssnd_tick);
					chat_System(playerid,CC_SYSTEM_PERMS,"Village management permission revoked.");
				}
				case 6:
				{
					new counts[sizeof(PermissionFamilies)] = {0,...}, c = 0;
					for(new i = 0; i < sizeof(Permissions); i++) if(teams_ContainsPermissionFamily(PlayerInfo[playerid][pTeam],Permissions[i][permFamily]) && !perm_IsGranted(playerid,Permissions[i][permCode]))
					{
						counts[Permissions[i][permFamily]]++;
						perm_Grant(playerid,Permissions[i][permCode],true);
					}
					for(new i = 0; i < sizeof(PermissionFamilies); i++) if(counts[i] > 0) chat_System(playerid,CC_SYSTEM_PERMS,f(@c(LIST_ITEMS) "(#%d)" @c(CHAT_TEXT) " Granted " @c(CHAT_VALUE) "%d" @c(CHAT_TEXT) " permissions from category " @c(CHAT_BOLD) "%s" @c(CHAT_TEXT) ".",++c,counts[i],PermissionFamilies[i][permfamName]));
					if(!c) chat_System(playerid,CC_SYSTEM_PERMS,"Not found any permissions to grant.");
					else sound_PlaySystem(playerid,e_SystemSound:syssnd_tick);
				}
				case 7:
				{
					new counts[sizeof(PermissionFamilies)] = {0,...}, c = 0;
					for(new i = 0; i < sizeof(Permissions); i++) if(teams_ContainsPermissionFamily(PlayerInfo[playerid][pTeam],Permissions[i][permFamily]) && perm_IsGranted(playerid,Permissions[i][permCode]))
					{
						counts[Permissions[i][permFamily]]++;
						perm_Grant(playerid,Permissions[i][permCode],false);
					}
					for(new i = 0; i < sizeof(PermissionFamilies); i++) if(counts[i] > 0) chat_System(playerid,CC_SYSTEM_PERMS,f(@c(LIST_ITEMS) "(#%d)" @c(CHAT_TEXT) " Revoked " @c(CHAT_VALUE) "%d" @c(CHAT_TEXT) " permissions from category " @c(CHAT_BOLD) "%s" @c(CHAT_TEXT) ".",++c,counts[i],PermissionFamilies[i][permfamName]));
					if(!c) chat_System(playerid,CC_SYSTEM_PERMS,"Not found any permissions to revoke.");
					else sound_PlaySystem(playerid,e_SystemSound:syssnd_tick);
				}
			}
		}
		else dialog_GoBack(playerid);
	}
	if(dialogid == _:d_ListPermissions && PlayerInfo[playerid][pLastDialogInfo][0] == _:d_ManagePermissions && PlayerInfo[playerid][pLastDialogInfo][1])
	{
		if(!response)
		{
			new permid = -1;
			for(new i = 0, c = 0; i < sizeof(Permissions) && permid == -1; i++) if(Permissions[i][permFamily] == PERMISSION_FAMILY_SELF_TEAM || teams_ContainsPermissionFamily(PlayerInfo[playerid][pTeam],Permissions[i][permFamily])) if(c == listitem) permid = i; else c++;
			if(permid != -1) switch(PlayerInfo[playerid][pLastDialogInfo][2])
			{
				case 1:
				{
					permissionsOverview[0] = EOS;
					sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `perm` = '%s'",sqlite_TableName(e_SQLiteTable:st_Permissions),Permissions[permid][permCode]));
					new m = sqlite_NumRows(), c = 0;
					for(new i = 0, pid = 0; i < m; i++)
					{
						pid = strval(sqlite_GetField("pid"));
						if(strval(user_GetPlayerInfo(pid,"team")) == PlayerInfo[playerid][pTeam]) str_add(permissionsOverview,f(" %d) %s - %s",++c,user_GetPlayerName(pid),chars_GetDisplayName(user_GetPlayerCharacter(pid))),"\n");
						sqlite_NextRow();
					}
					sqlite_FreeResults();
					str_add(permissionsOverview,f("\n" @c(DIALOG_SUM) "Total %d players.",c),"\n");
					dialog_SetButtons(d_ViewPermissions,"Back","");
					dialog_Show(playerid,d_ViewPermissions,"ss",f("PERMISSION - %s",str_upper(Permissions[permid][permName])),permissionsOverview);
				}
				case 2:
				{
					PlayerInfo[playerid][pLastDialogInfo][2] = permid;
					control_SelectPlayer(playerid,e_SelectionSource:selsrc_dialog,_:d_ManagePermissions,"granting permission");
					return 0;
				}
			}
		}
		else dialog_GoBack(playerid);
	}
	if(dialogid == _:d_ViewPermissions && PlayerInfo[playerid][pSelectionReason][0] == 'r')
	{
		if(response)
		{
			if(!perm_Check(playerid,"manage_village_perms")) return 1;
			new permid = -1;
			if(!listitem)
			{
				if(PlayerInfo[playerid][pSelectionID][0] == INVALID_PLAYER_ID) sqlite_Query(serverDatabase,f("DELETE FROM `%s` WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Permissions),PlayerInfo[playerid][pSelectionID][1]));
				else perm_Clear(PlayerInfo[playerid][pSelectionID][0]);
			}
			else
			{
				new c = 0;
				if(PlayerInfo[playerid][pSelectionID][0] == INVALID_PLAYER_ID)
				{
					sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Permissions),PlayerInfo[playerid][pSelectionID][1]));
					new m = sqlite_NumRows();
					for(new i = 0; i < m && permid == -1; i++)
					{
						if(listitem == c) permid = perm_Index(sqlite_GetField("perm"));
						c++;
						sqlite_NextRow();
					}
					sqlite_FreeResults();
					if(permid != -1) sqlite_Query(serverDatabase,f("DELETE FROM `%s` WHERE `pid` = %d AND `perm` = '%s'",sqlite_TableName(e_SQLiteTable:st_Permissions),PlayerInfo[playerid][pSelectionID][1],Permissions[permid][permCode]));
				}
				else
				{
					for(new i = 0; i < sizeof(Permissions) && permid == -1; i++) if(GetPVarType(PlayerInfo[playerid][pSelectionID][0],perm_Format(Permissions[i][permCode])) != PLAYER_VARTYPE_NONE)
					{
						if(listitem == c) permid = i;
						c++;
					}
					if(permid != -1) perm_Grant(playerid,Permissions[permid][permCode],false);
				}
			}
			ViewPlayerPermissions(playerid,PlayerInfo[playerid][pSelectionID][0],PlayerInfo[playerid][pSelectionID][1],PlayerInfo[playerid][pSelectionID][2]);
			if(permid == -1) str_add(permissionsOverview,"\n" @c(DIALOG_INFO_VALUE) "All" @c(DIALOG_INFO) " permissions revoked.","\n");
			else str_add(permissionsOverview,f(@c(DIALOG_INFO) "\nRevoked permission: " @c(DIALOG_INFO_VALUE) "%s",Permissions[permid][permName]),"\n");
			dialog_SetTemporaryType(d_ViewPermissions,DIALOG_STYLE_INPUT);
			dialog_SetButtons(d_ViewPermissions,"Revoke","Back");
			dialog_Show(playerid,d_ViewPermissions,"ss",str_upper(header),permissionsOverview);
			return 0;
		}
		else dialog_GoBack(playerid);
	}
	return 1;
}
function<OnPlayerSelect(playerid,selectedid,pid,uid)>
{
	if(PlayerInfo[playerid][pSelectionSource] == e_SelectionSource:selsrc_dialog && PlayerInfo[playerid][pSelectionSourceID] == _:d_ManagePermissions)
	{
		new teamid = -1;
		if(selectedid == INVALID_PLAYER_ID) teamid = strval(user_GetPlayerInfo(pid,"team"));
		else teamid = PlayerInfo[selectedid][pTeam];
		if(teamid != PlayerInfo[playerid][pTeam]) return chat_Error(playerid,"This player is not in your team.");
		permissionsOverview[0] = EOS;
		switch(PlayerInfo[playerid][pSelectionReason][0])
		{
			case 'v', 'r':
			{
				ViewPlayerPermissions(playerid,selectedid,pid,uid);
				if(PlayerInfo[playerid][pSelectionReason][0] == 'v') dialog_Show(playerid,d_ViewPermissions,"ss",str_upper(header),permissionsOverview);
				else
				{
					str_add(permissionsOverview,@c(DIALOG_EXPLAIN) "\nIn order to remove permission, write bellow it's number.\nTo remove ALL of the permissions use 0.","\n");
					dialog_SetTemporaryType(d_ViewPermissions,DIALOG_STYLE_INPUT);
					dialog_SetButtons(d_ViewPermissions,"Revoke","Back");
					dialog_Show(playerid,d_ViewPermissions,"ss",str_upper(header),permissionsOverview);
					return 0;
				}
			}
			case 'g':
			{
				new permid = PlayerInfo[playerid][pLastDialogInfo][2], n[MAX_PLAYER_NAME], bool:flag = false;
				if(selectedid == INVALID_PLAYER_ID)
				{
					sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `pid` = %d AND `perm` = '%s'",sqlite_TableName(e_SQLiteTable:st_Permissions),pid,Permissions[permid][permCode]));
					if(sqlite_NumRows() > 0) flag = true;
					sqlite_FreeResults();
					format(n,sizeof(n),user_GetKey(uid,"name"));
					if(!flag) sqlite_Add(serverDatabase,e_SQLiteTable:st_Permissions,"is","pid",pid,"perm",Permissions[permid][permCode]);
				}
				else
				{
					format(n,sizeof(n),player_GetNickname(selectedid));
					if(perm_IsGranted(selectedid,Permissions[permid][permCode])) flag = true;
					else perm_Grant(selectedid,Permissions[permid][permCode],true);
				}
				if(flag) chat_Error(playerid,f("%s already got the permission %s.",n,Permissions[permid][permName]));
				else
				{
					sound_PlaySystem(playerid,e_SystemSound:syssnd_tick);
					chat_System(playerid,CC_SYSTEM_PERMS,f("Permission " @c(CHAT_BOLD) "%s" @c(CHAT_TEXT) " have been granted to " @c(CHAT_BOLD) "%s" @c(CHAT_TEXT) ".",Permissions[permid][permName],n));
				}
			}
		}
	}
	return 1;
}
#undef function
// Private
static stock ShowPermissionList(playerid,header_[],teamid=-1)
{
	if(teamid == -1) teamid = PlayerInfo[playerid][pTeam];
	new list_permissions[M_D_L];
	for(new i = 0; i < sizeof(Permissions); i++) if(Permissions[i][permFamily] == PERMISSION_FAMILY_SELF_TEAM || teams_ContainsPermissionFamily(teamid,Permissions[i][permFamily])) str_add(list_permissions,f("%s\t%s",PermissionFamilies[Permissions[i][permFamily]][permfamName],Permissions[i][permName]),"\n");
	dialog_SetHeader(d_ListPermissions,f("Permission List - %s",header_));
	dialog_Show(playerid,d_ListPermissions,"s",list_permissions);
}
static stock ViewPlayerPermissions(playerid,selectedid,pid,uid)
{
	new bool:perms[sizeof(Permissions)] = {false,...};
	if(selectedid == INVALID_PLAYER_ID)
	{
		sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Permissions),pid));
		new m = sqlite_NumRows();
		for(new i = 0; i < m; i++)
		{
			perms[perm_Index(sqlite_GetField("perm"))] = true;
			sqlite_NextRow();
		}
		sqlite_FreeResults();
		format(header,sizeof(header),"%s - %s [OFFLINE]",chars_GetDisplayName(user_GetPlayerCharacter(pid)),user_GetKey(uid,"name"));
	}
	else
	{
		for(new i = 0; i < sizeof(Permissions); i++) if(GetPVarType(playerid,perm_Format(Permissions[i][permCode])) != PLAYER_VARTYPE_NONE) perms[i] = true;
		format(header,sizeof(header),"%s - %s",player_GetNickname(selectedid),chars_GetDisplayName(PlayerInfo[selectedid][pCharacter]));
	}
	new c = 0;
	for(new i = 0; i < sizeof(Permissions); i++) if(perms[i]) str_add(permissionsOverview,f(" %d) [%s] %s",++c,PermissionFamilies[Permissions[i][permFamily]][permfamName],Permissions[i][permName]),"\n");
	str_add(permissionsOverview,f("\n" @c(DIALOG_SUM) "Total %d permissions.",c),"\n");
}
// Permissions
@f(_,perm.Format(permcode[]))
{
	new s[32];
	format(s,sizeof(s),"perm-%s",permcode);
	return s;
}
@f(_,perm.Clear(playerid)) for(new i = 0; i < sizeof(Permissions); i++) if(GetPVarType(playerid,perm_Format(Permissions[i][permCode])) != PLAYER_VARTYPE_NONE) DeletePVar(playerid,perm_Format(Permissions[i][permCode]));
@f(_,perm.LoadAll(playerid))
{
	sqlite_Query(serverDatabase,f("SELECT * FROM `%s` WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Permissions),PlayerInfo[playerid][pPlayerID]));
	new m = sqlite_NumRows(), permcode[32], index;
	for(new i = 0; i < m; i++)
	{
		format(permcode,sizeof(permcode),sqlite_GetField("perm"));
		index = perm_Index(permcode);
		if(index != -1) SetPVarInt(playerid,perm_Format(permcode),1);
		sqlite_NextRow();
	}
	sqlite_FreeResults();
}
@f(_,perm.SaveAll(playerid))
{
	sqlite_Query(serverDatabase,f("DELETE FROM `%s` WHERE `pid` = %d",sqlite_TableName(e_SQLiteTable:st_Permissions),PlayerInfo[playerid][pPlayerID]));
	for(new i = 0; i < sizeof(Permissions); i++) if(GetPVarType(playerid,perm_Format(Permissions[i][permCode])) != PLAYER_VARTYPE_NONE) sqlite_Add(serverDatabase,e_SQLiteTable:st_Permissions,"is","pid",PlayerInfo[playerid][pPlayerID],"perm",Permissions[i][permCode]);
}
@f(_,perm.GrantAll(playerid,bool:toggle,family = -1))
{
	if(toggle)
	{
		for(new i = 0; i < sizeof(Permissions); i++) if(GetPVarType(playerid,perm_Format(Permissions[i][permCode]) != PLAYER_VARTYPE_NONE && (family == -1 || family == Permissions[i][permFamily])) SetPVarInt(playerid,perm_Format(Permissions[i][permCode]),1);
	}
	else
	{
		for(new i = 0; i < sizeof(Permissions); i++) if(GetPVarType(playerid,perm_Format(Permissions[i][permCode]) == PLAYER_VARTYPE_NONE && (family == -1 || family == Permissions[i][permFamily])) DeletePVar(playerid,perm_Format(Permissions[i][permCode]));
	}
	perm_SaveAll(playerid);
}
@f(bool,perm.IsGranted(playerid,permcode[])) return GetPVarType(playerid,perm_Format(permcode)) != PLAYER_VARTYPE_NONE;
@f(_,perm.Grant(playerid,permcode[],bool:toggle))
{
	if(toggle) SetPVarInt(playerid,perm_Format(permcode),1);
	else DeletePVar(playerid,perm_Format(permcode));
	perm_SaveAll(playerid);
}
@f(_,perm.Index(permcode[]))
{
	new index = -1;
	if(property_IntExist(perm_Format(permcode))) index = property_IntGet(perm_Format(permcode));
	else for(new i = 0; i < sizeof(Permissions) && index == -1; i++) if(equal(Permissions[i][permCode],permcode)) index = i;
	return index;
}
@f(bool,perm.Check(playerid,permcode[]))
{
	if(perm_IsGranted(playerid,permcode)) return true;
	else
	{
		sound_PlayEffect(playerid,e_SoundEffects:snd_insperm);
		nametag_SetAdditionalText(playerid,2,@c(COLOR_RED) "Access Denied");
		new index = perm_Index(permcode);
		dialog_Show(playerid,d_InsufficientPermission,"ss",PermissionFamilies[Permissions[index][permFamily]][permfamName],Permissions[index][permName]);
		return false;
	}
}
// Commands
cmd.permissions(playerid,params[])
{
	#pragma unused params
	dialog_Show(playerid,d_Permissions);
	return 1;
}
