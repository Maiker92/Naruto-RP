// Anime Fantasy: Naruto World #24 script: control
#define function<%1> forward control_%1; public control_%1
function<OnGameModeInit()>
{
	// Player selection dialogs
	dialog_Create(d_SelectPlayer,DIALOG_STYLE_LIST,@c(DIALOG_DHEADER) "Player selection","Select","Cancel",d_Null);
	dialog_AddLine(@c(LIST_ITEMS) "Enter name, character or player ID");
	dialog_AddLine(@c(LIST_ITEMS) "Select from player list (TAB)");
	dialog_AddLine(@c(LIST_ITEMS) "In-game target selection");
	dialog_AddLine(@c(LIST_ITEMS) "Select yourself");
	dialog_Create(d_SelectPlayer_Text,DIALOG_STYLE_INPUT,@c(DIALOG_DHEADER) "Player selection > Text","Select","Back",d_SelectPlayer);
	dialog_AddLine(@c(DIALOG_EXPLAIN) "This feature will find the first player based on one of the following criteria: (syntax / example)");
	dialog_AddLine(@c(DIALOG_INFO) " • Player ID" @c(DIALOG_INFO_VALUE) " (### / 0)");
	dialog_AddLine(@c(DIALOG_INFO) " • User ID" @c(DIALOG_INFO_VALUE) " (user_### / user_1)");
	dialog_AddLine(@c(DIALOG_INFO) " • User name" @c(DIALOG_INFO_VALUE) " (### / Amit)");
	dialog_AddLine(@c(DIALOG_INFO) " • Character name" @c(DIALOG_INFO_VALUE) " (### / Naruto)");
	dialog_AddLine(@c(DIALOG_ERROR) "{1}");
	dialog_Create(d_SelectPlayer_Tab,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Player selection > Tab","Back","",d_SelectPlayer);
	dialog_AddLine(@c(DIALOG_EXPLAIN) "Click TAB now and select the player you want.");
	dialog_Create(d_SelectPlayer_Accept,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Confirm player selection","Yes","No",d_SelectPlayer);
	dialog_AddLine(@c(DIALOG_INFO) "Selected player " @c(DIALOG_INFO_VALUE) "{1}" @c(DIALOG_INFO) " (" @c(DIALOG_INFO_VALUE) "{2}" @c(DIALOG_INFO) "),");
	dialog_AddLine("for " @c(DIALOG_INFO_VALUE) "{3}" @c(DIALOG_INFO) ".");
	dialog_AddLine("Is this the player you want?");
	dialog_Create(d_SelectPlayer_Cancel,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Cancel player selection","Yes","No",d_SelectPlayer);
	dialog_AddLine(@c(DIALOG_ERROR) "Player not found!");
	dialog_AddLine("Do you want to try again?");
	// Stats dialogs
	dialog_Create(d_PlayerInfo,DIALOG_STYLE_LIST,"Player Info","Select","Cancel",d_Null);
	for(new i = 0; i < sizeof(PInfoTypes); i++) dialog_AddLine(f(@c(LIST_ITEMS) "%s",PInfoTypes[i]));
	dialog_Create(d_Stats,DIALOG_STYLE_MSGBOX,"X","Player Info","Close",d_PlayerInfo);
	dialog_AddLine(@c(DIALOG_HEADER) "PLAYER {1}: {2}\n" @c(DIALOG_TEXT) "{3}");
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	// Switch between items
	key_Bind(playerid,KEYID_Q);
	key_Bind(playerid,KEYID_E);
	// Power selection
	for(new i = KEYID_1; i <= KEYID_9; i++) key_Bind(playerid,i);
	// Allow cursor
	key_Bind(playerid,KEYID_M);
	// Side Menu Control
	key_Bind(playerid,KEYID_N); // NPCs side menu
	//key_Bind(playerid,KEYID_X); // Close side menu (Removed, as it's only being used when a menu is visible, also built-in as basic button in sidemenus)
	return 1;
}
function<OnPlayerDeath(playerid,killerid,reason)>
{
	if(PlayerInfo[playerid][pPowerPrepare][0] != -1) power_Cancel(playerid,PowerInfo[PlayerInfo[playerid][pPowerPrepare][0]][pwCode]);
	return 1;
}
function<OnPlayerClickTD(playerid,Text:clickedid)>
{
	// GTD: Map
	if(clickedid == map)
	{
		gtd_Hide(playerid,e_GlobalTD:gtd_map);
		return 1;
	}
	// GTD: Menu
	for(new i = 0; i <= sizeof(MenuOptions); i++) if(clickedid == menuButtons[i])
	{
		switch(i)
		{
			case 0: // Menu
			{
				if(gtd_IsVisible(playerid,e_GlobalTD:gtd_menu,1)) gtd_Hide(playerid,e_GlobalTD:gtd_menu,1);
				else gtd_Show(playerid,e_GlobalTD:gtd_menu,1);
			}
			case 1: // Stats
			{
				PlayerInfo[playerid][pDialogSelect] = playerid;
				dialog_SetHeader(d_PlayerInfo,@c(DIALOG_DHEADER) "Player Info: Yourself");
				dialog_Show(playerid,d_PlayerInfo);
			}
			case 2: // Friends
			{
				dialog_Show(playerid,d_Soon,"s","Friends Menu");
			}
			case 3: // Party
			{
				dialog_Show(playerid,d_Soon,"s","Party Menu");
			}
			case 4: // Map
			{
				if(gtd_IsVisible(playerid,e_GlobalTD:gtd_map)) gtd_Hide(playerid,e_GlobalTD:gtd_map);
				else gtd_Show(playerid,e_GlobalTD:gtd_map);
			}
			case 5: // Options
			{
				dialog_Show(playerid,d_Soon,"s","Options Menu");
			}
			case 6: // Logout/Quit
			{
				command_logout(playerid,"");
			}
		}
		return 1;
	}
	return 0;
}
function<OnPlayerClickPTD(playerid,PlayerText:playertextid)>
{
	new id = -1;
	for(new i = 0; i < MAX_PTD && id == -1; i++) if(PlayerInfo[playerid][pPTD][i] == playertextid) id = i;
	if(id != -1)
	{
		switch(id)
		{
			// ptd_stats
			case 0, 1, 4:
			{
				// Health log?
			}
			case 2, 3, 5:
			{
				// Chakra log?
			}
			case 6:
			{
				// Money log?
			}
			case 7: // Avatar
			{
				control_ShowStats(e_PlayerInfoType:pinfotype_character,playerid,playerid);
			}
			case 8..11:
			{
				// Level / XP log?
			}
			// ptd_powers
			case 12..20:
			{
				// Open category
				new cat = id-11;
				if(ptd_IsVisible(playerid,e_PlayerTD:ptd_powers,1,cat))
				{
					ptd_Hide(playerid,e_PlayerTD:ptd_powers,1,cat);
					PlayerInfo[playerid][pPowerSelection] = {0,0};
					//SendClientMessage(playerid,-1,f("cat: %d, pow: %d",PlayerInfo[playerid][pPowerSelection][0],PlayerInfo[playerid][pPowerSelection][1]));
				}
				else
				{
					ptd_Show(playerid,e_PlayerTD:ptd_powers,1,cat);
					PlayerInfo[playerid][pPowerSelection][0] = cat;
					//SendClientMessage(playerid,-1,f("cat: %d, pow: %d",PlayerInfo[playerid][pPowerSelection][0],PlayerInfo[playerid][pPowerSelection][1]));
					control_ClosePowers(playerid,cat);
				}
			}
			case 30..38:
			{
				// Category powers summary
				new cat = id-29, catName[MAX_NAME_LENGTH], overview[M_D_L / 3], pidx = -1;
				GetPVarString(playerid,power_Var(cat,0,"name"),catName,sizeof(catName));
				dialog_SetHeader(d_PowerCategory,f(@c(DIALOG_DHEADER) "Power Category: %s",catName));
				for(new i = 1; i <= MAX_POWERS_PER_CATEGORY; i++)
				{
					pidx = power_IndexAtPos(playerid,cat,i);
					if(pidx == -1) break;
					str_add(overview,f("%d) %s [%s / %s]",i,PowerInfo[pidx][pwName],power_TypeAsString(PowerInfo[pidx][pwType]),power_UseAsString(PowerInfo[pidx][pwUse])),"\n");
				}
				dialog_Show(playerid,d_PowerCategory,"ss",str_upper(catName),overview);
			}
			case 39..83:
			{
				// Power description
				new cat = ((id-39)/MAX_POWERS_PER_CATEGORY+1), pow = ((id-39+MAX_POWERS_PER_CATEGORY)%MAX_POWERS_PER_CATEGORY)+1, pidx = power_IndexAtPos(playerid,cat,pow), overview[M_D_L];
				dialog_SetHeader(d_PowerDesc,f(@c(DIALOG_DHEADER) "Power: %s",PowerInfo[pidx][pwName]));
				format(overview,sizeof(overview),power_GetDescription(playerid,cat,pow));
				dialog_Show(playerid,d_PowerDesc,"s",overview);
				PlayerInfo[playerid][pPowerSelection][0] = cat, PlayerInfo[playerid][pPowerSelection][1] = pow;
				//SendClientMessage(playerid,-1,f("cat: %d, pow: %d",PlayerInfo[playerid][pPowerSelection][0],PlayerInfo[playerid][pPowerSelection][1]));
			}
			// ptd_items
			case 84, 87:
			{
				// Current item info
			}
			case 85:
			{
				// Previous item info
			}
			case 86:
			{
				// Next item info
			}
		}
		return 1;
	}
	return 0;
}
function<OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])>
{
	if(dialogid == _:d_PowerDesc && response) PowerUsage(playerid);
	if(PlayerInfo[playerid][pSelectionSource] != e_SelectionSource:selsrc_none)
	{
		if(dialogid == _:d_SelectPlayer)
		{
			if(response) switch(listitem)
			{
				case 0: dialog_Show(playerid,d_SelectPlayer_Text,"s","");
				case 1: dialog_Show(playerid,d_SelectPlayer_Tab);
				case 2: target_Start(playerid,e_TargetReason:targetreason_playerselect,e_PowerTargets:powertarget_single,CC_COLOR_WHITE,stats_GetStats(playerid,stats_vision),0.0);
				case 3: control_SelectPlayerProceed(playerid,playerid,PlayerInfo[playerid][pPlayerID],PlayerInfo[playerid][pUserID]);
			}
			return 0;
		}
		if(dialogid == _:d_SelectPlayer_Text)
		{
			if(!strlen(inputtext)) dialog_Show(playerid,d_SelectPlayer_Text,"s","Enter text to find player ID.");
			else
			{
				if(response)
				{
					new selectedplayerid = -1, bool:onlineplayerid = false, spid = -1;
					if(str_isnum(inputtext)) selectedplayerid = strval(inputtext), onlineplayerid = true;
					else if(str_startswith(inputtext,"user_"))
					{
						new id[MAX_PLAYER_NAME];
						strmid(id,inputtext,5,strlen(inputtext),sizeof(id));
						selectedplayerid = !strlen(id) || !str_isnum(id) ? 0 : strval(id);
					}
					else if((selectedplayerid = user_GetID(inputtext)) > 0) { /* nothing 2 do here */ }
					else if((selectedplayerid = chars_Find(inputtext)) != INVALID_CHARACTER) selectedplayerid = chars_GetUser(selectedplayerid), spid = chars_GetUser(selectedplayerid,true);
					else selectedplayerid = convert_playerid(inputtext,INVALID_PLAYER_ID), onlineplayerid = true;
					if(onlineplayerid && (selectedplayerid == INVALID_PLAYER_ID || !IsPlayerConnected(selectedplayerid))) dialog_Show(playerid,d_SelectPlayer_Text,"s","Player ID is not connected.");
					else if(!onlineplayerid && !selectedplayerid) dialog_Show(playerid,d_SelectPlayer_Text,"s","User can not be found.");
					else
					{
						if(spid == -1 && onlineplayerid) spid = PlayerInfo[selectedplayerid][pPlayerID];
						if(spid == -1) dialog_Show(playerid,d_SelectPlayer_Text,"s","User have been found, but a specific character is required.\nWrite his character name or find him again when he's logged in.");
						else if(!spid) dialog_Show(playerid,d_SelectPlayer_Text,"s","This character is not assigned to any user yet.");
						else
						{
							new splayerid = onlineplayerid ? selectedplayerid : user_GetPlayer(selectedplayerid);
							new suid = onlineplayerid ? PlayerInfo[splayerid][pUserID] : selectedplayerid;
							control_SelectPlayerProceed(playerid,splayerid,spid,suid);
						}
					}
				}
				else dialog_GoBack(playerid);
			}
			return 0;
		}
		if(dialogid == _:d_SelectPlayer_Tab && !response) dialog_GoBack(playerid);
		if(dialogid == _:d_SelectPlayer_Accept)
		{
			if(response)
			{
				if(OnPlayerSelect(playerid,PlayerInfo[playerid][pSelectionID][0],PlayerInfo[playerid][pSelectionID][1],PlayerInfo[playerid][pSelectionID][2]))
				{
					PlayerInfo[playerid][pSelectionID] = {-1,-1,-1};
					PlayerInfo[playerid][pSelectionSource] = e_SelectionSource:selsrc_none;
					PlayerInfo[playerid][pSelectionSourceID] = 0;
					PlayerInfo[playerid][pSelectionReason][0] = EOS;
				}
			}
			else dialog_GoBack(playerid);
			return 0;
		}
		if(dialogid == _:d_SelectPlayer_Cancel) if(response) dialog_GoBack(playerid);
	}
	if(dialogid == _:d_PlayerInfo) if(response)
	{
		control_ShowStats(e_PlayerInfoType:listitem,playerid,PlayerInfo[playerid][pDialogSelect]);
		PlayerInfo[playerid][pDialogSelect] = -1;
	}
	if(dialogid == _:d_Stats && response) dialog_GoBack(playerid);
	return 1;
}
function<OnPlayerClickPlayer(playerid,clickedplayerid,source)>
{
	if(source == CLICK_SOURCE_SCOREBOARD)
	{
		if(PlayerInfo[playerid][pSelectionSource] != e_SelectionSource:selsrc_none && PlayerInfo[playerid][pDialog] == d_SelectPlayer_Tab)
		{
			control_SelectPlayerProceed(playerid,clickedplayerid,PlayerInfo[clickedplayerid][pPlayerID],PlayerInfo[clickedplayerid][pUserID]);
			return 0;
		}
		PlayerInfo[playerid][pDialogSelect] = clickedplayerid;
		dialog_SetHeader(d_PlayerInfo,f(@c(DIALOG_DHEADER) "Player Info: %s",player_GetName(clickedplayerid)));
		dialog_Show(playerid,d_PlayerInfo);
	}
	return 1;
}
function<OnPlayerUpdate(playerid)>
{
	if(PlayerInfo[playerid][pPowerPrepare][3]) return PlayerInfo[playerid][pPowerPrepare][3] = 0;
	return 1;
}
function<OnPlayerKeyPress(playerid,keyid,modifier)>
{
	//SendClientMessage(playerid,-1,"KEY RESULT"); // used to test the speed of reading binded keys
	// Q + E to select item
	if(keyid == KEYID_Q)
	{
	}
	else if(keyid == KEYID_E)
	{
	}
	// 1-9 number keys
	else if(keyid >= KEYID_1 && keyid <= KEYID_9)
	{
		new n = keyid - KEYID_1 + 1;
		if(PlayerInfo[playerid][pDialog] != d_Null)
		{
			new dID = _:PlayerInfo[playerid][pDialog], dStyle = DialogInfo[dID][dTempType] != -1 ? DialogInfo[dID][dTempType] : DialogInfo[dID][dType];
			if(dStyle == DIALOG_STYLE_LIST || dStyle == DIALOG_STYLE_TABLIST || dStyle == DIALOG_STYLE_TABLIST_HEADERS)
			{
				// Automatically select item from list dialog throught number key
				dialog_Hide(playerid);
				OnDialogResponse(playerid,dID,1,n,"");
			}
		}
		else
		{
			// Power selection
			if(!PlayerInfo[playerid][pPowerSelection][0] && power_HaveCategory(playerid,n))
			{
				if(ptd_IsVisible(playerid,e_PlayerTD:ptd_powers,1,n))
				{
					ptd_Hide(playerid,e_PlayerTD:ptd_powers,1,n);
					PlayerInfo[playerid][pPowerSelection] = {0,0};
					//SendClientMessage(playerid,-1,f("cat: %d, pow: %d",PlayerInfo[playerid][pPowerSelection][0],PlayerInfo[playerid][pPowerSelection][1]));
				}
				else
				{
					ptd_Show(playerid,e_PlayerTD:ptd_powers,1,n);
					PlayerInfo[playerid][pPowerSelection][0] = n;
					//SendClientMessage(playerid,-1,f("cat: %d, pow: %d",PlayerInfo[playerid][pPowerSelection][0],PlayerInfo[playerid][pPowerSelection][1]));
					control_ClosePowers(playerid,n);
				}
			}
			else if(PlayerInfo[playerid][pPowerSelection][0] > 0 && n >= 1 && n <= MAX_POWERS_PER_CATEGORY && power_HavePower(playerid,n))
			{
				PlayerInfo[playerid][pPowerSelection][1] = n;
				//SendClientMessage(playerid,-1,f("cat: %d, pow: %d",PlayerInfo[playerid][pPowerSelection][0],PlayerInfo[playerid][pPowerSelection][1]));
				PowerUsage(playerid);
			}
		}
	}
	// M to use the main menu
	else if(keyid == KEYID_M) cursor_Toggle(playerid);
	// Side menu controls
	else if(keyid == KEYID_X) sidemenu_Close(playerid);
	else if(keyid == KEYID_N)
	{
		if(!npc_GetPlayerCount(playerid)) misc_Notification(playerid,NOTIFICATION_ERROR,"you dont have any npcs");
		else sidemenu_Open(playerid,e_SideMenu:sidemenu_npccontrol,0);
	}
	return 1;
}
function<OnPlayerTargetSelect(playerid,e_TargetReason:targetreason,targetid,Float:x,Float:y,Float:z)>
{
	if(targetreason == e_TargetReason:targetreason_playerselect && PlayerInfo[playerid][pSelectionSource] != e_SelectionSource:selsrc_none)
	{
		if(targetid == INVALID_PLAYER_ID) control_CancelSelectPlayer(playerid);
		else control_SelectPlayerProceed(playerid,targetid,PlayerInfo[targetid][pPlayerID],PlayerInfo[targetid][pUserID]);
	}
	return 1;
}
function<OnPlayerTargetCancel(playerid,e_TargetReason:targetreason)>
{
	if(targetreason == e_TargetReason:targetreason_playerselect && PlayerInfo[playerid][pSelectionSource] != e_SelectionSource:selsrc_none) control_CancelSelectPlayer(playerid);
	return 1;
}
#undef function
static stock PowerUsage(playerid)
{
	new use = power_CanUse(playerid,PlayerInfo[playerid][pPowerSelection][0],PlayerInfo[playerid][pPowerSelection][1]);
	new pidx = power_IndexAtPos(playerid,PlayerInfo[playerid][pPowerSelection][0],PlayerInfo[playerid][pPowerSelection][1]);
	if(pidx == -1) return;
	if(use >= 1)
	{
		if(PlayerInfo[playerid][pPowerPrepare][0] != -1) power_Cancel(playerid,PowerInfo[PlayerInfo[playerid][pPowerPrepare][0]][pwCode]);
		power_Prepare(playerid,PowerInfo[PlayerInfo[playerid][pPowerPrepare][0] = pidx][pwCode]);
		for(new i = 0; i < 2; i++) PlayerInfo[playerid][pPowerPrepare][i+1] = PlayerInfo[playerid][pPowerSelection][i];
		misc_Notification(playerid,NOTIFICATION_INFO,f("power target: %s",PowerInfo[pidx][pwName]));
	}
	else
	{
		new reason[64];
		switch(use*(-1))
		{
			case 4: reason = "game version of this power is not supported";
			case 5: reason = "can not use a passive ability";
			case 1: reason = "this power requires a higher level";
			case 6: reason = "this ability type is silenced";
			case 3: reason = "this power is on cooldown";
			case 2: reason = "you have no enough chakra";
		}
		misc_Notification(playerid,NOTIFICATION_ERROR,reason);
	}
	PlayerInfo[playerid][pPowerSelection] = {0,0};
}
// Control
@f(_,control.ClosePowers(playerid,exception = -1)) for(new i = 1; i <= MAX_POWER_CATEGORIES; i++) if(i != exception && ptd_IsVisible(playerid,e_PlayerTD:ptd_powers,1,i)) ptd_Hide(playerid,e_PlayerTD:ptd_powers,1,i);
@f(_,control.ShowStats(e_PlayerInfoType:statstype,playerid,showto))
{
	new playerStats[M_D_L];
	str_add(playerStats,f(@c(DIALOG_INFO) "[Last Update: %s %s || Player ID: %03d || Your player ID: %03d]" @c(DIALOG_TEXT),time_GetDateAsString(),time_GetTimeAsString(),playerid,showto),"\n\n");
	str_add(playerStats,"","\n");
	switch(statstype)
	{
		case pinfotype_stats:
		{
			new e_Stats:stats, e_Damage:dmg, e_Stats:exceptions[] = {stats_basicattack};
			// Details
			str_add(playerStats,f("Character Rank: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),rank_Name(rank_GetPlayerRank(playerid))),"\n");
			str_add(playerStats,f("Player Level: " @c(DIALOG_VALUE) "%d" @c(DIALOG_TEXT),level_Get(playerid)),"\n");
			str_add(playerStats,f("Player XP: " @c(DIALOG_VALUE) "%d / %d" @c(DIALOG_TEXT),xp_Get(playerid),xp_GetNextLevel(playerid)),"\n");
			str_add(playerStats,"","\n");
			// Attributes
			str_add(playerStats,f(@h(FF0000) "STR: %d\n" @h(00FF00) "AGI: %d\n" @h(0000FF) "INT: %d" @c(DIALOG_TEXT),stats_GetStr(playerid),stats_GetAgi(playerid),stats_GetInt(playerid)),"\n");
			str_add(playerStats,f("Basic Attack: " @c(DIALOG_VALUE) "%.2f" @c(DIALOG_TEXT),basicattack_GetDamage(playerid)),"\n");
			str_add(playerStats,f("Speciality: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),stats_SpecialityIntAsString(stats_GetSpeciality(playerid,true,false))),"\n");
			str_add(playerStats,"","\n");
			// Stats Types
			for(new i = 1, m = stats_GetCount(1), bool:flag = false; i <= m; i++)
			{
				stats = stats_GetStatsType(i);
				for(new j = 0; j < sizeof(exceptions) && !flag; j++) if(stats == exceptions[j]) flag = true;
				if(!flag) str_add(playerStats,f("%s: " @c(DIALOG_VALUE) "%.2f" @c(DIALOG_TEXT),stats_StatsTypeAsString(stats),stats_GetStats(playerid,stats)),"\n");
				else flag = false;
			}
			str_add(playerStats,"","\n");
			// Damage Types
			for(new i = 1, m = stats_GetCount(2); i <= m; i++)
			{
				dmg = stats_GetDamageType(i);
				str_add(playerStats,f("%s Power: " @c(DIALOG_VALUE) "%.2f" @c(DIALOG_TEXT),stats_DamageTypeAsString(dmg),stats_GetDamage(playerid,dmg)),"\n");
			}
			str_add(playerStats,"","\n");
			// Protection Types
			for(new i = 1, m = stats_GetCount(3); i <= m; i++)
			{
				dmg = stats_GetDamageType(i);
				str_add(playerStats,f("%s Protection: " @c(DIALOG_VALUE) "%.2f" @c(DIALOG_TEXT),stats_DamageTypeAsString(dmg),stats_GetProtection(playerid,dmg)),"\n");
			}
		}
		case pinfotype_character:
		{
			// Character Name
			str_add(playerStats,f(@c(DIALOG_BOLD) "%s",chars_GetDisplayName(PlayerInfo[playerid][pCharacter])),"\n");
			str_add(playerStats,@c(LIST_ITEMS),"\n");
			// Nicknames
			for(new i = 1; i <= MAX_CHARACTER_NICKNAMES; i++) if(nickname_IsValid(PlayerInfo[playerid][pCharacter],i)) str_add(playerStats,nickname_Get(PlayerInfo[playerid][pCharacter],i),"\n");
			str_add(playerStats,@c(DIALOG_TEXT),"\n");
			// Character Lore
			str_add(playerStats,description_Get("Characters",CharacterInfo[PlayerInfo[playerid][pCharacter]][cUID]),"\n");
		}
		default: return dialog_Show(showto,d_Soon,"s",f("Stats Part: %s",PInfoTypes[_:statstype]));
	}
	dialog_SetHeader(d_Stats,f(@c(DIALOG_DHEADER) "%s",PInfoTypes[_:statstype]));
	dialog_Show(showto,d_Stats,"sss",str_upper(PInfoTypes[_:statstype]),str_upper(player_GetName(playerid)),playerStats);
	return 1;
}
@f(_,control.SelectPlayer(playerid,e_SelectionSource:source,sourceid,reason[]))
{
	if(PlayerInfo[playerid][pSelectionSource] != e_SelectionSource:selsrc_none) control_CancelSelectPlayer(playerid);
	PlayerInfo[playerid][pSelectionSource] = source;
	PlayerInfo[playerid][pSelectionSourceID] = sourceid;
	format(PlayerInfo[playerid][pSelectionReason],32,reason);
	dialog_Show(playerid,d_SelectPlayer);
}
@f(_,control.SelectPlayerProceed(playerid,splayerid,spid,suid))
{
	PlayerInfo[playerid][pSelectionID][0] = splayerid;
	PlayerInfo[playerid][pSelectionID][1] = spid;
	PlayerInfo[playerid][pSelectionID][2] = suid;
	new onlinemsg[64], charmsg[64], c = user_GetPlayerCharacter(spid);
	format(charmsg,sizeof(charmsg),"%s - %s",user_GetKey(suid,"name"),chars_GetDisplayName(c));
	if(splayerid == INVALID_PLAYER_ID) format(onlinemsg,sizeof(onlinemsg),"Offline, UID %03d",suid);
	else format(onlinemsg,sizeof(onlinemsg),"Online, ID %03d, UID %03d%s",splayerid,suid,splayerid == playerid ? (" - yourself") : (""));
	dialog_Show(playerid,d_SelectPlayer_Accept,"sss",user_GetKey(suid,"name"),onlinemsg,PlayerInfo[playerid][pSelectionReason]);
}
@f(_,control.CancelSelectPlayer(playerid))
{
	// Hiding selection dialog
	new e_Dialog:selectionDialogs[] = {d_SelectPlayer,d_SelectPlayer_Tab,d_SelectPlayer_Text,d_SelectPlayer_Accept}, bool:flag = false;
	for(new i = 0; i < sizeof(selectionDialogs) && !flag; i++) if(dialog_IsVisible(playerid,selectionDialogs[i])) flag = true;
	if(flag) dialog_Hide(playerid);
	// Stopping in-game targeting
	if(target_IsTargeting(playerid) && PlayerInfo[playerid][pTargetReason] == e_TargetReason:targetreason_playerselect) target_Stop(playerid);
	// Reseting player selection information
	PlayerInfo[playerid][pSelectionID] = {-1,-1,-1};
	PlayerInfo[playerid][pSelectionSource] = e_SelectionSource:selsrc_none;
	PlayerInfo[playerid][pSelectionSourceID] = 0;
	PlayerInfo[playerid][pSelectionReason][0] = EOS;
}
