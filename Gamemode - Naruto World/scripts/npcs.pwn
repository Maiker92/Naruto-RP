// Anime Fantasy: Naruto World #20 script: npcs
#define function<%1> forward npcs_%1; public npcs_%1
static oneSecondPassed = 0;
static const Float:MIN_CD = 1.0, Float:MAX_CD = 30.0;
enum NPCFollowDistanceData { npcfdName[MAX_NAME_LENGTH], Float:npcfdDistance }
static Float:npcFollowDistance[][NPCFollowDistanceData] =
{
	{"Minimal",NPC_MIN_DISTANCE},
	{"Average",6.0},
	{"Observe",20.0}
};
function<OnGameModeInit()>
{
	// Assign slots for incoming NPCs
	SendRconCommand(f("maxnpc %d",MAX_NPCS));
	for(new i = 0, n = -1; i < MAX_NPCS; i++)
	{
		npc_Reset(i);
		f("NPC@%03d",i);
		format(NPCInfo[i][npcCodeName],MAX_PLAYER_NAME,fstring);
		format(NPCInfo[i][npcName],MAX_PLAYER_NAME,fstring);
		//printf("Connecting #%d %s (%s)",i,fstring,NPCInfo[i][npcCodeName]);
		NPCInfo[i][npcPlayerID] = n = FCNPC_Create(fstring);
		FCNPC_Spawn(n,0,0.0,0.0,0.0);
		npc_Destroy(i,true);
	}
	FCNPC_SetUpdateRate(30);
	// NPC Control Menus
	new npcSubMenu, npcMenu = sidemenu_Create(e_SideMenu:sidemenu_npccontrol,"NPC Commands");
	sidemenu_AddButton(npcMenu,"ctrl","1","~b~Control");
	sidemenu_AddButton(npcMenu,"pcmd","2","~b~Behaviour");
	sidemenu_AddButton(npcMenu,"attk","A","Attack");
	sidemenu_AddButton(npcMenu,"defn","D","Defend");
	sidemenu_AddButton(npcMenu,"move","M","Move");
	sidemenu_AddButton(npcMenu,"folw","F","Follow");
	sidemenu_AddButton(npcMenu,"focs","S","Focus");
	sidemenu_AddButton(npcMenu,"grop","G","Group Up");
	sidemenu_AddButton(npcMenu,"canc","3","~r~Dismiss");
	npcSubMenu = sidemenu_CreateSub(npcMenu,e_SideMenu:sidemenu_npccontrol,1,"Select NPC");
	sidemenu_AddButton(npcSubMenu,"anyn","A","Any");
	sidemenu_AddButton(npcSubMenu,"spec","D","Specific");
	npcSubMenu = sidemenu_CreateSub(npcMenu,e_SideMenu:sidemenu_npccontrol,2,"Command Type");
	sidemenu_AddButton(npcSubMenu,"none","N","None");
	sidemenu_AddButton(npcSubMenu,"offn","A","Offensive");
	sidemenu_AddButton(npcSubMenu,"dfnc","D","Defensive");
	npcSubMenu = sidemenu_CreateSub(npcMenu,e_SideMenu:sidemenu_npccontrol,3,"Select Move Type");
	sidemenu_AddButton(npcSubMenu,"mov1","1","Walk");
	sidemenu_AddButton(npcSubMenu,"mov2","2","Run");
	sidemenu_AddButton(npcSubMenu,"mov3","3","Sprint");
	npcSubMenu = sidemenu_CreateSub(npcMenu,e_SideMenu:sidemenu_npccontrol,4,"Follow Options");
	sidemenu_AddButton(npcSubMenu,"folm","F","Follow Me");
	sidemenu_AddButton(npcSubMenu,"folp","G","Select Player");
	sidemenu_AddButton(npcSubMenu,"fols","S","Stop");
	sidemenu_AddButton(npcSubMenu,"fold","D","Distance");
	npcSubMenu = sidemenu_CreateSub(npcSubMenu,e_SideMenu:sidemenu_npccontrol,5,"Follow Distance");
	for(new i = 0, key[4], code[8], text[MAX_NAME_LENGTH+5]; i < sizeof(npcFollowDistance); i++)
	{
		valstr(key,i+1);
		format(code,sizeof(code),"fol%d",i);
		format(text,sizeof(text),"%s (%.0f)",npcFollowDistance[i][npcfdName],npcFollowDistance[i][npcfdDistance]);
		sidemenu_AddButton(npcSubMenu,code,key,text);
	}
	sidemenu_AddButton(npcSubMenu,"folc","D","Custom");
	// NPC Dialogs
	dialog_Create(d_NPCCustomDist,DIALOG_STYLE_INPUT,@c(DIALOG_DHEADER) "Custom follow distance","Select","Cancel",d_Null);
	dialog_AddLine(@c(DIALOG_TEXT) "Select custom distance for NPCs to follow.");
	dialog_AddLine(f("The distance is limited between " @c(DIALOG_BOLD) "%.0f - %.0f" @c(DIALOG_TEXT) ".",MIN_CD,MAX_CD));
	dialog_AddLine(@c(DIALOG_INFO) "{1}");
	return 1;
}
function<OnGameModeExit()>
{
	Loop(npc,i) Kick(NPCInfo[i][npcPlayerID]);
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	if(player_IsNPC(playerid))
	{
		new n = npc_GetIndexByPlayer(playerid);
		if(n != INVALID_PLAYER_ID)
		{
			ElementArrayAdd(npc,NPCInfo[n][npcArrayPos],n);
			NPCInfo[n][npcConnected] = true;
		}
		return 0;
	}
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	if(player_IsNPC(playerid))
	{
		new n = npc_GetIndexByPlayer(playerid);
		if(n != INVALID_PLAYER_ID)
		{
			ElementArrayDel(npc,NPCInfo[n][npcArrayPos],INVALID_PLAYER_ID);
			if(NPCInfo[n][npcTagDetails][0]) npctag_Destroy(n);
			npc_Reset(n);
		}
		return 0;
	}
	else
	{
		new m = npc_GetPlayerCount(playerid);
		if(m > 0) for(new i = 0, d = 0; i < m; i++) if((d = npc_GetPlayerIndex(playerid,i)) != INVALID_PLAYER_ID) npc_Destroy(d);
	}
	return 1;
}
public FCNPC_OnSpawn(npcid)
{
	npcs_OnPlayerSpawn(NPCInfo[PlayerInfo[npcid][pNPCIndex]][npcPlayerID]);
	return 1;
}
public FCNPC_OnRespawn(npcid)
{
	npcs_OnPlayerSpawn(NPCInfo[PlayerInfo[npcid][pNPCIndex]][npcPlayerID]);
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	if(player_IsNPC(playerid))
	{
		new n = npc_GetIndexByPlayer(playerid);
		if(n != INVALID_PLAYER_ID) if(npc_NeedsTag(n))
		{
			if(!NPCInfo[n][npcTagDetails][0]) npctag_Create(n);
			else npctag_Update(n);
		}
		return 0;
	}
	return 1;
}
function<OnPlayerDeath(playerid,killerid,reason)>
{
	if(player_IsNPC(playerid)) return 0;
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
	if(player_IsNPC(playerid)) return 1;
	if(!IsPlayerAdmin(playerid))
	{
		command(npcadd,cmdtext);
		command(mynpcadd,cmdtext);
		command(myclone,cmdtext);
		command(npcdel,cmdtext);
		command(npccmd,cmdtext);
		command(npcpid,cmdtext);
	}
	return 0;
}
function<OnPlayerStateChange(playerid,newstate,oldstate)>
{
	if(player_IsNPC(playerid))
	{
		return 0;
	}
	return 1;
}
function<OnPlayerKeyStateChange(playerid,newkeys,oldkeys)>
{
	if(player_IsNPC(playerid))
	{
		return 0;
	}
	return 1;
}
function<OnPlayerUpdate(playerid)>
{
	if(player_IsNPC(playerid))
	{
		return 0;
	}
	return 1;
}
function<OnPlayerStreamIn(playerid,forplayerid)>
{
	if(player_IsNPC(playerid))
	{
		return 0;
	}
	return 1;
}
function<OnPlayerStreamOut(playerid,forplayerid)>
{
	if(player_IsNPC(playerid))
	{
		return 0;
	}
	return 1;
}
public FCNPC_OnTakeDamage(npcid,damagerid,weaponid,bodypart,Float:health_loss)
{
	// Taijutsu (Basic Attack) on NPCs
	if(PlayerInfo[npcid][pNPCIndex] != INVALID_PLAYER_ID && !weaponid && damagerid != INVALID_PLAYER_ID) basicattack_Perform(damagerid,NPCInfo[PlayerInfo[npcid][pNPCIndex]][npcPlayerID]);
	SendClientMessageToAll(-1,f("npc %d, damager %d",PlayerInfo[npcid][pNPCIndex],damagerid));
	return 1;
}
function<OnNPCTakeDamage(npcid,damagerid,weaponid,bodypart,Float:health_loss)>
{
	new Float:d = health_loss;
	// If NPC would ever have protection, I should check it here...
	//d = math_max(d-stats_GetProtection(playerid,type),0.1);
	// Decrease the health / considering death situation
	if(d > 0.0 && NPCInfo[npcid][npcHealth] > 0.0 && NPCInfo[npcid][npcUsage] != e_NPCUsage:npcusage_none)
	{
		NPCInfo[npcid][npcHealth] -= d;
		if(NPCInfo[npcid][npcHealth] <= 0)
		{
			NPCInfo[npcid][npcHealth] = 0.0;
			OnNPCDeath(npcid,damagerid);
			npc_Destroy(npcid);
		}
	}
	// Updating the NPC name tag
	if(NPCInfo[npcid][npcTagDetails][0]) npctag_Update(npcid);
	return 1;
}
function<OnPlayerGiveDamage(playerid,damagedid,Float:amount,weaponid,bodypart)>
{
	if(player_IsNPC(playerid))
	{
		// FCNPC_ProcessDamage(playerid,damagedid,amount,weaponid,bodypart); Not required since Beta 13 of FCNPC
		return 0;
	}
	return 1;
}
function<OnSideMenuClick(playerid,e_SideMenu:menuid,subid,code[])>
{
	if(menuid == e_SideMenu:sidemenu_npccontrol)
	{
		if(!npc_GetPlayerCount(playerid))
		{
			sidemenu_Close(playerid,true);
			chat_Error(playerid,"You have no any NPC anymore, so the NPC menu have been closed.");
			return 1;
		}
		new npc_[MAX_NPCS], npcs_ = npc_GetControlled(playerid,npc_);
		//if(PlayerInfo[playerid][pNPCCommand][0] == -1) for(new i = 0; i < PlayerInfo[playerid][pNPCs]; i++) npc_[npcs_++] = PlayerInfo[playerid][pNPC][i];
		//else npc_[npcs_++] = PlayerInfo[playerid][pNPC][PlayerInfo[playerid][pNPCCommand][0]];
		switch(subid)
		{
			case 0: // Main NPC Control Menu
			{
				new cmd = -1;
				if(equal(code,"ctrl")) // Select Control NPC
					sidemenu_Open(playerid,e_SideMenu:sidemenu_npccontrol,1);
				else if(equal(code,"pcmd")) // Select Pro CMD
					sidemenu_Open(playerid,e_SideMenu:sidemenu_npccontrol,2);
				else if(equal(code,"attk")) // Attack
					cmd = NPCCMD_ATTACK;
				else if(equal(code,"defn")) // Defend
					cmd = NPCCMD_DEFEND;
				else if(equal(code,"move")) // Move
					sidemenu_Open(playerid,e_SideMenu:sidemenu_npccontrol,3);
				else if(equal(code,"folw")) // Follow
					sidemenu_Open(playerid,e_SideMenu:sidemenu_npccontrol,4);
				else if(equal(code,"focs")) // Focus
				{
					// Target player, then focus
				}
				else if(equal(code,"grop")) // Group Up
					cmd = NPCCMD_GROUPUP;
				else if(equal(code,"canc")) // Dismiss
					cmd = NPCCMD_CANCEL;
				PlayerInfo[playerid][pNPCCommand][1] = cmd;
				if(cmd != -1) for(new i = 0; i < npcs_; i++) npc_Command(npc_[i],cmd);
			}
			case 1: // Select NPC
			{
				if(equal(code,"anyn")) // Any
				{
					chat_System(playerid,CC_SYSTEM_NPCS,"Any NPC you've created will now be controlled.");
					PlayerInfo[playerid][pNPCCommand][0] = -1;
				}
				else if(equal(code,"spec")) // Specific
				{
					chat_System(playerid,CC_SYSTEM_NPCS,"SOON");
					// Show a dialog list of current NPCs, then select one to control...
				}
			}
			case 2: // Select Type
			{
				new procmd = -1, s[16];
				if(equal(code,"none")) procmd = _:npcprocmd_none, s = "None";
				else if(equal(code,"offn")) procmd = _:npcprocmd_offensive, s = "Offensive";
				else if(equal(code,"dfnc")) procmd = _:npcprocmd_defensive, s = "Defensive";
				chat_System(playerid,CC_SYSTEM_NPCS,f("Command type of " @c(CHAT_VALUE) "%d" @c(CHAT_TEXT) " NPCs is set to " @c(CHAT_VALUE) "%s" @c(CHAT_TEXT) " now.",npcs_,s));
				if(procmd != -1) for(new i = 0; i < npcs_; i++) npc_Command(npc_[i],NPCCMD_PROCMD,_:procmd);
			}
			case 3: // Select Move Type
			{
				new val[8];
				str_set(val,code,8);
				strdel(val,0,3);
				PlayerInfo[playerid][pNPCCommand][1] = NPCCMD_MOVE, PlayerInfo[playerid][pNPCCommand][2] = strval(val);
				target_Start(playerid,e_TargetReason:targetreason_sidemenu,e_PowerTargets:powertarget_point,CC_COLOR_WHITE,stats_GetStats(playerid,stats_vision),0.0);
			}
			case 4: // Follow Options
			{
				new followID = -1;
				switch(code[3])
				{
					case 'm': // Follow Me
					{
						followID = playerid;
					}
					case 'p': // Select Player
					{
						PlayerInfo[playerid][pNPCCommand][1] = NPCCMD_FOLLOW, PlayerInfo[playerid][pNPCCommand][2] = MAX_PLAYERS;
						target_Start(playerid,e_TargetReason:targetreason_sidemenu,e_PowerTargets:powertarget_single,CC_COLOR_WHITE,PLAYER_DEFAULT_VISION,0.0);
					}
					case 's': // Stop
					{
						followID = INVALID_PLAYER_ID;
					}
					case 'd': // Distance
					{
						sidemenu_Open(playerid,e_SideMenu:sidemenu_npccontrol,5);
					}
				}
				if(followID != -1) for(new i = 0; i < npcs_; i++) npc_Command(npc_[i],NPCCMD_FOLLOW,followID);
			}
			case 5: // Follow Distance
			{
				if(code[3] == 'c') // Custom
				{
					new cur[64];
					if(PlayerInfo[playerid][pNPCFollowCD] > 0.0) format(cur,sizeof(cur),"(Current follow distance is %.1f)",PlayerInfo[playerid][pNPCFollowCD]);
					dialog_Show(playerid,d_NPCCustomDist,"s",cur);
				}
				else chat_System(playerid,CC_SYSTEM_NPCS,f("NPC follow distance is set to " @c(CHAT_VALUE) "%.1f" @c(CHAT_TEXT) ".",PlayerInfo[playerid][pNPCFollowCD] = npcFollowDistance[strval(code[3])][npcfdDistance]));
			}
		}
	}
	return 1;
}
function<OnPlayerTargetSelect(playerid,e_TargetReason:targetreason,targetid,Float:x,Float:y,Float:z)>
{
	if(targetreason == e_TargetReason:targetreason_sidemenu && sidemenu_GetCurrentType(playerid) == e_SideMenu:sidemenu_npccontrol)
	{
		new allowedList[] = {NPCCMD_MOVE,NPCCMD_FOLLOW}, bool:flag = false;
		for(new i = 0; i < sizeof(allowedList) && !flag; i++) if(PlayerInfo[playerid][pNPCCommand][1] == allowedList[i]) flag = true;
		if(flag)
		{
			new npc_[MAX_NPCS], npcs_ = npc_GetControlled(playerid,npc_);
			if(PlayerInfo[playerid][pNPCCommand][2] == MAX_PLAYERS) PlayerInfo[playerid][pNPCCommand][2] = targetid;
			for(new i = 0; i < npcs_; i++) npc_Command(npc_[i],PlayerInfo[playerid][pNPCCommand][1],PlayerInfo[playerid][pNPCCommand][2]);
			PlayerInfo[playerid][pNPCCommand][1] = -1;
		}
	}
	return 1;
}
function<OnPlayerTargetCancel(playerid,e_TargetReason:targetreason)>
{
	if(targetreason == e_TargetReason:targetreason_sidemenu && sidemenu_GetCurrentType(playerid) == e_SideMenu:sidemenu_npccontrol) PlayerInfo[playerid][pNPCCommand][1] = -1, PlayerInfo[playerid][pNPCCommand][2] = 0;
	return 1;
}
function<OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])>
{
	if(dialogid == _:d_NPCCustomDist && response)
	{
		if(!str_isfloat(inputtext)) return chat_Error(playerid,"Invalid distance."), 1;
		new Float:d = floatstr(inputtext);
		if(d < MIN_CD || d > MAX_CD) return chat_Error(playerid,"Follow distance is out of limits."), 1;
		chat_System(playerid,CC_SYSTEM_NPCS,f("NPC follow distance is set to " @c(CHAT_VALUE) "custom %.1f" @c(CHAT_TEXT) ".",PlayerInfo[playerid][pNPCFollowCD] = d));
	}
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_tenth))
	{
		new bool:secondFlag = false;
		if(GetTickCount()-oneSecondPassed >= 1000)
		{
			oneSecondPassed = GetTickCount();
			secondFlag = true;
		}
		Loop(npc,i)
		{
			if(NPCInfo[i][npcConnected] && NPCInfo[i][npcUsage] != e_NPCUsage:npcusage_none)
			{
				if(NPCInfo[i][npcOnMove])
				{
					if(NPCInfo[i][npcFollow][0] != INVALID_PLAYER_ID)
					{
						player_GetPosition(NPCInfo[i][npcFollow][0]);
						if((NPCInfo[i][npcFollow][1] = npc_HaveFollowed(i,false)))
						{
							if(FCNPC_IsMoving(NPCInfo[i][npcPlayerID])) FCNPC_Stop(NPCInfo[i][npcPlayerID]);
							//NPCInfo[i][npcFollow][1] = 1;
						}
						else
						{
							if(NPCInfo[i][npcAttacking][1])
							{
								FCNPC_StopAttack(NPCInfo[i][npcPlayerID]);
								NPCInfo[i][npcAttacking][1] = 0;
							}
							if(!npc_IsInRange(i,NPCInfo[i][npcFollow][0]) && NPCInfo[i][npcFollow][0] != NPCInfo[i][npcPlayerID])
							{
								npc_Stop(i);
								npc_Command(i,NPCCMD_GROUPUP);
							}
							else npc_Move(i,MOVE_TYPE_RUN,PlayerInfo[NPCInfo[i][npcFollow][0]][pPosition][0],PlayerInfo[NPCInfo[i][npcFollow][0]][pPosition][1],PlayerInfo[NPCInfo[i][npcFollow][0]][pPosition][2]);
						}
					}
					if(NPCInfo[i][npcAttacking][0] != INVALID_PLAYER_ID && NPCInfo[i][npcCommand] == NPCCMD_ATTACK && NPCInfo[i][npcFollow][0] == NPCInfo[i][npcAttacking][0] && NPCInfo[i][npcFollow][1])
					{
						if(NPCInfo[i][npcProCommand] == e_NPCProCommand:npcprocmd_offensive) npc_HandleAttack(i,e_PowerUses:puOffensive);
						else if(NPCInfo[i][npcProCommand] == e_NPCProCommand:npcprocmd_defensive)
						{
							if(NPCInfo[i][npcHealth] < floatdiv(NPCInfo[i][npcStats][0],4.0)) npc_Command(i,NPCCMD_RETREAT,1);
							else npc_HandleAttack(i,e_PowerUses:puDefensive);
						}
						else npc_HandleAttack(i,e_PowerUses:puNoUse);
					}
				}
				if(secondFlag)
				{
					if(NPCInfo[i][npcCooldown] > 0) NPCInfo[i][npcCooldown]--;
					if(NPCInfo[i][npcDuration] > 0)
					{
						NPCInfo[i][npcDuration]--;
						if(!NPCInfo[i][npcDuration]) npc_Command(i,NPCCMD_CANCEL);
					}
					if(!NPCInfo[i][npcUnderAttack] && NPCInfo[i][npcHealth] < NPCInfo[i][npcStats][0]) health_Add(i,math_percent(1,NPCInfo[i][npcStats][0],100.0));
					if(NPCInfo[i][npcUnderAttack] > 0) NPCInfo[i][npcUnderAttack]--;
				}
			}
		}
	}
	return 1;
}
#undef function
// NPC
@f(_,npc.GetIndexByPlayer(playerid))
{
	if(player_IsNPC(playerid))
	{
		if(PlayerInfo[playerid][pNPCIndex] != INVALID_PLAYER_ID) return PlayerInfo[playerid][pNPCIndex];
		new n[MAX_PLAYER_NAME];
		GetPlayerName(playerid,n,sizeof(n));
		for(new i = 0; i < MAX_NPCS && PlayerInfo[playerid][pNPCIndex] == INVALID_PLAYER_ID; i++) if(equal(n,NPCInfo[i][npcCodeName])) PlayerInfo[playerid][pNPCIndex] = i;
		return PlayerInfo[playerid][pNPCIndex];
	}
	return INVALID_PLAYER_ID;
}
@f(_,npc.Reset(npcid))
{
	NPCInfo[npcid][npcConnected] = false;
	NPCInfo[npcid][npcUsage] = e_NPCUsage:npcusage_none;
	NPCInfo[npcid][npcCodeName][0] = EOS;
	NPCInfo[npcid][npcName][0] = EOS;
	NPCInfo[npcid][npcArrayPos] = INVALID_PLAYER_ID;
	NPCInfo[npcid][npcTag] = (Text3D:(INVALID_3DTEXT_ID));
	NPCInfo[npcid][npcTagDetails] = {0,0,0};
	NPCInfo[npcid][npcTagAdditional][0] = EOS;
	NPCInfo[npcid][npcPlayerID] = INVALID_PLAYER_ID;
	for(new i = 0; i < 4; i++) NPCInfo[npcid][npcStats][i] = 0.0;
	NPCInfo[npcid][npcHealth] = 0.0;
	NPCInfo[npcid][npcBehaviour] = e_NPCBehaviour:npcbehaviour_none;
	NPCInfo[npcid][npcProCommand] = e_NPCProCommand:npcprocmd_none;
	NPCInfo[npcid][npcCommand] = NPCCMD_NONE;
	NPCInfo[npcid][npcLeader] = INVALID_PLAYER_ID;
	NPCInfo[npcid][npcFocus] = INVALID_PLAYER_ID;
	NPCInfo[npcid][npcFollow] = {INVALID_PLAYER_ID,0};
	NPCInfo[npcid][npcOnMove] = false;
	NPCInfo[npcid][npcAttacking] = {INVALID_PLAYER_ID,0};
	for(new i = 0; i < MAX_POWER_CATEGORIES; i++) NPCInfo[npcid][npcAbility][i] = -1;
	NPCInfo[npcid][npcCooldown] = 0;
	NPCInfo[npcid][npcPlayerIndex] = -1;
	NPCInfo[npcid][npcDuration] = 0;
	NPCInfo[npcid][npcUsageID] = -1;
	NPCInfo[npcid][npcArea] = INVALID_AREA;
}
@f(_,npc.Spawn(e_NPCUsage:usage,Float:x,Float:y,Float:z,creator = INVALID_PLAYER_ID,vworld = VW_WORLD))
{
	new npcid = INVALID_PLAYER_ID;
	LoopEx(npc,i,<npcid == INVALID_PLAYER_ID>) if(NPCInfo[i][npcConnected] && NPCInfo[i][npcUsage] == e_NPCUsage:npcusage_none) npcid = i;
	if(npcid != INVALID_PLAYER_ID && player_IsNPC(NPCInfo[npcid][npcPlayerID]))
	{
		NPCInfo[npcid][npcUsage] = usage;
		NPCInfo[npcid][npcLeader] = NPCInfo[npcid][npcFollow][0] = (creator != INVALID_PLAYER_ID ? creator : NPCInfo[npcid][npcPlayerID]);
		if(!player_IsNPC(NPCInfo[npcid][npcLeader])) PlayerInfo[NPCInfo[npcid][npcLeader]][pNPC][PlayerInfo[NPCInfo[npcid][npcLeader]][pNPCs]] = npcid, NPCInfo[npcid][npcPlayerIndex] = PlayerInfo[NPCInfo[npcid][npcLeader]][pNPCs]++;
		NPCInfo[npcid][npcFollow][1] = 0;
		vworld_Set(NPCInfo[npcid][npcPlayerID],vworld);
		FCNPC_SetPosition(NPCInfo[npcid][npcPlayerID],x,y,z);
		FCNPC_SetHealth(NPCInfo[npcid][npcPlayerID],10000.0);
		//FCNPC_SetArmour(NPCInfo[npcid][npcPlayerID],0.0);
		npc_SetStats(npcid,.maxhealth = 10.0);
		if(npc_NeedsTag(npcid) && !NPCInfo[npcid][npcTagDetails][0]) npctag_Create(npcid);
		if(usage == e_NPCUsage:npcusage_test) // Basic test NPC health, skin, stats...
		{
			npc_SetStats(npcid,100.0,5.0,NPC_DEFAULT_VISION,2.0);
			npc_SetSkin(npcid,0);
		}
	}
	return npcid;
}
@f(_,npc.Destroy(npcid,bool:firsttime=false))
{
	new Float:p[3];
	FCNPC_GetPosition(NPCInfo[npcid][npcPlayerID],p[0],p[1],p[2]);
	if(NPCInfo[npcid][npcUsage] == e_NPCUsage:npcusage_clone) sound_PlayEffect3D(p[0],p[1],p[2],e_SoundEffects:snd_cloneout);
	if(!player_IsNPC(NPCInfo[npcid][npcLeader]) && NPCInfo[npcid][npcPlayerIndex] != -1)
	{
		for(new i = NPCInfo[npcid][npcPlayerIndex]; i < PlayerInfo[NPCInfo[npcid][npcLeader]][pNPCs] && i < (MAX_NPCS-1); i++) PlayerInfo[NPCInfo[npcid][npcLeader]][pNPC][i] = PlayerInfo[NPCInfo[npcid][npcLeader]][pNPC][i+1];
		PlayerInfo[NPCInfo[npcid][npcLeader]][pNPC][PlayerInfo[NPCInfo[npcid][npcLeader]][pNPCs]] = INVALID_PLAYER_ID, PlayerInfo[NPCInfo[npcid][npcLeader]][pNPCs]--;
	}
	NPCInfo[npcid][npcUsage] = e_NPCUsage:npcusage_none;
	NPCInfo[npcid][npcLeader] = NPCInfo[npcid][npcFollow][0] = INVALID_PLAYER_ID;
	NPCInfo[npcid][npcFollow][1] = 0;
	vworld_Set(NPCInfo[npcid][npcPlayerID],VW_NPCS);
	FCNPC_SetSkin(NPCInfo[npcid][npcPlayerID],0);
	FCNPC_SetInterior(NPCInfo[npcid][npcPlayerID],0);
	FCNPC_SetPosition(NPCInfo[npcid][npcPlayerID],0.0,0.0,0.0);
	if(!firsttime)
	{
		if(NPCInfo[npcid][npcArea] != INVALID_AREA) area_Destroy(NPCInfo[npcid][npcArea]);
		if(NPCInfo[npcid][npcTagDetails][0]) npctag_Destroy(npcid);
	}
}
@f(_,npc.SetVWorld(npcid,vworldid)) vworld_Set(NPCInfo[npcid][npcPlayerID],vworldid);
@f(_,npc.GetPlayerCount(playerid)) return PlayerInfo[playerid][pNPCs];
@f(_,npc.GetPlayerIndex(playerid,index)) return PlayerInfo[playerid][pNPC][index];
@f(_,npc.IsAlive(npcid)) return npcid >= 0 && npcid < MAX_NPCS && NPCInfo[npcid][npcConnected] && NPCInfo[npcid][npcUsage] != e_NPCUsage:npcusage_none;
@f(_,npc.SetStats(npcid,Float:maxhealth=0.0,Float:dmg=0.0,Float:vision=0.0,Float:as=0.0))
{
	if(maxhealth > 0.0) NPCInfo[npcid][npcHealth] = NPCInfo[npcid][npcStats][0] > NPCInfo[npcid][npcHealth] ? math_min(NPCInfo[npcid][npcHealth],NPCInfo[npcid][npcStats][0] = maxhealth) : (NPCInfo[npcid][npcStats][0] = maxhealth);
	if(dmg > 0.0) NPCInfo[npcid][npcStats][1] = dmg;
	if(vision > 0.0) NPCInfo[npcid][npcStats][2] = vision;
	if(as > 0.0) NPCInfo[npcid][npcStats][3] = as;
}
@f(_,npc.SetSkin(npcid,skinid)) SetPlayerSkin(NPCInfo[npcid][npcPlayerID],skinid);
@f(_,npc.SetDuration(npcid,duration)) NPCInfo[npcid][npcDuration] = duration;
@f(_,npc.SetPosition(npcid,Float:x,Float:y,Float:z)) FCNPC_SetPosition(NPCInfo[npcid][npcPlayerID],x,y,z);
@f(_,npc.GetPosition(npcid,&Float:x,&Float:y,&Float:z)) FCNPC_GetPosition(NPCInfo[npcid][npcPlayerID],x,y,z);
@f(_,npc.SetAngle(npcid,Float:a)) FCNPC_SetAngle(NPCInfo[npcid][npcPlayerID],a);
@f(_,npc.GetAngle(npcid,&Float:a)) FCNPC_GetAngle(NPCInfo[npcid][npcPlayerID],a);
@f(_,npc.SetSpecialAction(npcid,actionid)) FCNPC_SetSpecialAction(NPCInfo[npcid][npcPlayerID],actionid);
@f(_,npc.SetAnimation(npcid,e_Animation:animation,Float:fDelta=4.1,loop=0,lockx=1,locky=1,freeze=0,time=1))
{
	new animlib[32], animname[32];
	animlib = anim_GetNames(animation,true);
	animname = anim_GetNames(animation,false);
	FCNPC_SetAnimationByName(NPCInfo[npcid][npcPlayerID],f("%s:%s",animlib,animname),fDelta,loop,lockx,locky,freeze,time);
}
@f(_,npc.ClearAnimation(npcid)) FCNPC_ClearAnimations(NPCInfo[npcid][npcPlayerID]);
@f(bool,npc.ChanceToAbility(npcid,e_PowerUses:use))
{
	new bool:casted = false;
	if(!NPCInfo[npcid][npcCooldown] && use != e_PowerUses:puNoUse)
	{
		new power[MAX_POWER_CATEGORIES] = {-1,...}, powers = 0, pidx = -1;
		for(new i = 0; i < MAX_POWER_CATEGORIES; i++) if((pidx = NPCInfo[npcid][npcAbility][i]) != -1) if(PowerInfo[pidx][pwValid] && PowerInfo[pidx][pwUse] == use) power[powers++] = pidx;
		if(powers > 0)
		{
			pidx = random(powers);
			if(NPCInfo[npcid][npcAttacking][0] != INVALID_PLAYER_ID)
			{
				player_GetPosition(NPCInfo[npcid][npcAttacking][0]);
				for(new i = 0; i < 3; i++) PlayerInfo[NPCInfo[npcid][npcPlayerID]][pTargetPosition][i] = PlayerInfo[NPCInfo[npcid][npcAttacking][0]][pPosition][i];
			}
			power_Cast(NPCInfo[npcid][npcPlayerID],PowerInfo[pidx][pwCode]);
			npc_RandCooldown(npcid,2);
			casted = true;
		}
	}
	return casted;
}
@f(_,npc.RandCooldown(npcid,level)) NPCInfo[npcid][npcCooldown] = math_random(1 * level,6 * level);
@f(_,npc.FindEnemy(npcid))
{
	new d = floatround(NPCInfo[npcid][npcStats][2]), d3 = d, d2 = -1, e = INVALID_PLAYER_ID;
	Loop(player,i) if(!npc_IsAlly(npcid,i) && npc_IsInRange(npcid,i) && (d2 = player_GetDistance(i,NPCInfo[npcid][npcPlayerID])) < d)
	{
		if(NPCInfo[npcid][npcFocus] == i) return i;
		if(d2 < d3) d3 = d2, e = i;
	}
	return e;
}
@f(bool,npc.IsInRange(npcid,target))
{
	player_GetPosition(NPCInfo[npcid][npcLeader]);
	new bool:ret = IsPlayerInRangeOfPoint(target,NPCInfo[npcid][npcStats][2],PlayerInfo[NPCInfo[npcid][npcLeader]][pPosition][0],PlayerInfo[NPCInfo[npcid][npcLeader]][pPosition][1],PlayerInfo[NPCInfo[npcid][npcLeader]][pPosition][2]) == 1;
	return ret;
}
@f(bool,npc.IsAlly(npcid,playerid))
{
	new bool:ret = NPCInfo[npcid][npcLeader] == playerid;
	ret = teams_IsAlly(NPCInfo[npcid][npcLeader],playerid);
	return ret;
}
@f(_,npc.SetFightingStyle(npcid,style))
{
	if(!style)
	{
		new fStyles[] = {FIGHT_STYLE_NORMAL,FIGHT_STYLE_BOXING,FIGHT_STYLE_KUNGFU,FIGHT_STYLE_KNEEHEAD,FIGHT_STYLE_GRABKICK,FIGHT_STYLE_ELBOW};
		style = fStyles[random(sizeof(fStyles))];
	}
	FCNPC_SetFightingStyle(NPCInfo[npcid][npcPlayerID],style);
}
@f(_,npc.HandleAttack(npcid,e_PowerUses:use))
{
	new id = NPCInfo[npcid][npcAttacking][0];
	if(player_IsConnected(id) && npc_IsInRange(npcid,id) && !PlayerInfo[id][pDied])
	{
		new bool:used = npc_ChanceToAbility(npcid,use);
		if(!used && !NPCInfo[npcid][npcAttacking][1])
		{
			FCNPC_MeleeAttack(NPCInfo[npcid][npcPlayerID],npc_CalculateAttackSpeed(NPCInfo[npcid][npcStats][3]),true);
			NPCInfo[npcid][npcAttacking][1] = 1;
		}
	}
	else
	{
		npc_Stop(npcid);
		npc_Command(npcid,NPCCMD_GROUPUP);
	}
}
@f(_,npc.Stop(npcid))
{
	FCNPC_Stop(NPCInfo[npcid][npcPlayerID]);
	FCNPC_StopAim(NPCInfo[npcid][npcPlayerID]);
	FCNPC_StopAttack(NPCInfo[npcid][npcPlayerID]);
	NPCInfo[npcid][npcProCommand] = e_NPCProCommand:npcprocmd_none;
	NPCInfo[npcid][npcFocus] = INVALID_PLAYER_ID;
	NPCInfo[npcid][npcFollow][0] = NPCInfo[npcid][npcLeader];
	NPCInfo[npcid][npcFollow][1] = 0;
	NPCInfo[npcid][npcOnMove] = false;
	NPCInfo[npcid][npcAttacking] = {INVALID_PLAYER_ID,0};
	npc_RandCooldown(npcid,1);
}
@f(_,npc.SimpleStop(npcid)) FCNPC_Stop(NPCInfo[npcid][npcPlayerID]);
@f(_,npc.CalculateAttackSpeed(Float:as)) return max(200,NPC_MIN_ATTACKSPEED - (floatround(floatdiv(as,0.2))*100));
@f(_,npc.HaveFollowed(npcid,bool = true,playerid = INVALID_PLAYER_ID))
{
	if(NPCInfo[npcid][npcFollow][0] == INVALID_PLAYER_ID) return 0;
	if(bool) player_GetPosition(NPCInfo[npcid][npcFollow][0]);
	new Float:dis = NPC_MIN_DISTANCE;
	if(playerid != INVALID_PLAYER_ID && NPCInfo[npcid][npcCommand] == NPCCMD_FOLLOW) dis = PlayerInfo[playerid][pNPCFollowCD] > 0.0 ? PlayerInfo[playerid][pNPCFollowCD] : NPC_MIN_DISTANCE;
	return IsPlayerInRangeOfPoint(NPCInfo[npcid][npcPlayerID],dis,PlayerInfo[NPCInfo[npcid][npcFollow][0]][pPosition][0],PlayerInfo[NPCInfo[npcid][npcFollow][0]][pPosition][1],PlayerInfo[NPCInfo[npcid][npcFollow][0]][pPosition][2]);
}
@f(_,npc.Move(npcid,movetype,Float:x,Float:y,Float:z,Float:rad = 0.0))
{
	FCNPC_GoTo(NPCInfo[npcid][npcPlayerID],x,y,z,movetype,.radius = rad);
	return 1;
}
@f(_,npc.AssignArea(npcid,Float:distance = 0.0))
{
	new Float:coords[6] = {0.0,0.0,0.0,0.0,0.0,0.0};
	NPCInfo[npcid][npcArea] = area_Create(e_AreaType:areatype_sphere,e_AreaUse:areause_npc,npcid,coords,distance == 0.0 ? NPCInfo[npcid][npcStats][2] : distance);
	area_AttachToNPC(NPCInfo[npcid][npcArea],npcid);
}
@f(_,npc.Command(npcid,cmd=NPCCMD_NONE,param=0))
{
	new leader = NPCInfo[npcid][npcLeader], bool:isNewStatus = false;
	npc_Stop(npcid);
	switch(cmd)
	{
		case NPCCMD_NONE: // Stay idle
		{
			// Stay still at current position, cancel all commands (procmd / focus / follow / etc...)
			isNewStatus = true;
		}
		case NPCCMD_ATTACK: // Attack
		{
			// if offensive, all out & use abilities, if defensive run away at low hp
			// if focus X, attack only X
			// if defend X and defensive, stop attacking and defend X
			isNewStatus = true;
			NPCInfo[npcid][npcAttacking][0] = npc_FindEnemy(npcid);
			if(NPCInfo[npcid][npcAttacking][0] == INVALID_PLAYER_ID) npc_Command(npcid,NPCCMD_NONE);
			else
			{
				NPCInfo[npcid][npcOnMove] = true, NPCInfo[npcid][npcFollow][0] = NPCInfo[npcid][npcAttacking][0], NPCInfo[npcid][npcFollow][1] = npc_HaveFollowed(npcid);
				npc_SetFightingStyle(npcid,0); // random
			}
		}
		case NPCCMD_DEFEND: // Defend
		{
			// if offensive, attack enemy if found, if defensive attack only if teammate is being targeted / attacked
			// if focus X, attack only X when attacking
		}
		case NPCCMD_MOVE: // Move
		{
			// Types of moving:
			// 1 - Walk directly
			// 2 - Run directly
			// 3 - Sprint directly
			if(!player_IsConnected(leader) || leader == NPCInfo[npcid][npcPlayerID] || player_IsNPC(leader)) return 1;
			isNewStatus = true;
			NPCInfo[npcid][npcFollow][0] = INVALID_PLAYER_ID;
			new type = 0;
			switch(param)
			{
				case 1: type = MOVE_TYPE_WALK;
				case 2: type = MOVE_TYPE_RUN;
				case 3: type = MOVE_TYPE_SPRINT;
			}
			npc_Move(npcid,type,PlayerInfo[leader][pTargetPosition][0],PlayerInfo[leader][pTargetPosition][1],PlayerInfo[leader][pTargetPosition][2]);
		}
		case NPCCMD_FOLLOW: // Follow
		{
			// Target someone as followed
			if((player_IsConnected(param) && npc_IsInRange(npcid,param)) || param == INVALID_PLAYER_ID) NPCInfo[npcid][npcFollow][0] = param, NPCInfo[npcid][npcOnMove] = true, isNewStatus = true;
		}
		case NPCCMD_FOCUS: // Focus
		{
			// Target someone as focused
			if((player_IsConnected(param) && npc_IsInRange(npcid,param)) || param == INVALID_PLAYER_ID) NPCInfo[npcid][npcFocus] = param;
		}
		case NPCCMD_SCAN: // Scan
		{
			// Move towards point to move in circles in area until finding someone. if no one found, come back
			// if someone is found, if offensive attack, if defensive cancel itselfs
			// if has sensory skills, use it at the middle of the area
		}
		case NPCCMD_SPREAD: // Spread out
		{
			// Spread out until some maximum radius
			// if offensive, attack anyone found, if defensive ignore everything
		}
		case NPCCMD_WATCH: // Watch over
		{
			// Stay still and watch over teammates / followed ones
			// if has sensory skills, use them once a time
			// if focused on one, follow his actions and report
			// if offensive attack when being targeted, if defensive keep watching and ignore everything
		}
		case NPCCMD_RETREAT: // Retreat
		{
			// Types of retreating:
			// 1 - Retreat running to leader
			// 2 - Retreat running to base`
		}
		case NPCCMD_CHASE: // Chase
		{
			// Chase enemy until being told to stop
			// if offensive, chase until dead
		}
		case NPCCMD_PUSH: // Push up
		{
			// Split push
			// if offensive, attack anyone who gets in the way
			// if defensive, fall back if being attacked / at low hp
		}
		case NPCCMD_GROUPUP: // Group up
		{
			// Group up near the leader
			if(!player_IsConnected(leader) || leader == NPCInfo[npcid][npcPlayerID] || player_IsNPC(leader)) return 1;
			player_GetPosition(leader);
			npc_Move(npcid,MOVE_TYPE_SPRINT,PlayerInfo[leader][pPosition][0]+(random(2) ? math_frandom(2.0,5.0) : math_frandom(-5.0,-2.0)),PlayerInfo[leader][pPosition][1]+(random(2) ? math_frandom(2.0,5.0) : math_frandom(-5.0,-2.0)),PlayerInfo[leader][pPosition][2]);
			//npc_Move(npcid,MOVE_TYPE_SPRINT,PlayerInfo[leader][pPosition][0],PlayerInfo[leader][pPosition][1],PlayerInfo[leader][pPosition][2],5.0);
		}
		case NPCCMD_FORMATION: // Formation
		{
			// Stand up with formation (when moving / following save formation):
			// 1 - Arrow formation
			// 2 - Front & back line formation
		}
		case NPCCMD_CAPTURE: // Capture
		{
			// Catch up to a focused specific enemy, then surround him
		}
		case NPCCMD_ABILITY:
		{
			// Use specified ability
		}
		case NPCCMD_PROCMD:
		{
			// Activate Pro Command
			NPCInfo[npcid][npcProCommand] = e_NPCProCommand:param;
		}
		case NPCCMD_CANCEL:
		{
			// Go away / die
			npc_Destroy(npcid);
			if(!npc_GetPlayerCount(leader) && sidemenu_GetCurrentType(leader) == e_SideMenu:sidemenu_npccontrol) sidemenu_Close(leader,true);
		}
	}
	if(isNewStatus) NPCInfo[npcid][npcCommand] = cmd;
	return 1;
}
@f(_,npc.GetControlled(playerid,npcArray[MAX_NPCS]))
{
	new c = 0;
	if(PlayerInfo[playerid][pNPCCommand][0] == -1) for(new i = 0; i < PlayerInfo[playerid][pNPCs]; i++) npcArray[c++] = PlayerInfo[playerid][pNPC][i];
	else npcArray[c++] = PlayerInfo[playerid][pNPC][PlayerInfo[playerid][pNPCCommand][0]];
	return c;
}
@f(_,npc.GetHeader(npcid))
{
	new typ[64];
	switch(NPCInfo[npcid][npcUsage])
	{
		case npcusage_clone: typ = ""; // You won't know if it's a clone!
		case npcusage_pet: format(typ,sizeof(typ),"%s's summoning",player_GetName(NPCInfo[npcid][npcLeader]));
		case npcusage_villager: if(NPCInfo[npcid][npcUsageID] != -1) format(typ,sizeof(typ),"%s villager",TeamInfo[VillagerInfo[NPCInfo[npcid][npcUsageID]][vgrTeam]][tSName]);
		default: typ = "?";
	}
	return typ;
}
@f(_,npc.SetUsageID(npcid,usageid))
{
	NPCInfo[npcid][npcUsageID] = usageid;
	if(NPCInfo[npcid][npcTagDetails][0]) npctag_Update(npcid);
}
@f(_,npc.Chat(npcid,Float:distance,text[]))
{
	new Float:p[3], typ[MAX_CHAT_LENGTH];
	format(typ,sizeof(typ),npc_GetHeader(npcid));
	npc_GetPosition(npcid,p[0],p[1],p[2]);
	if(strlen(typ) > 0) format(typ,sizeof(typ),"[%s] %s: " @c(CHAT_TEXT) "%s",typ,NPCInfo[npcid][npcName],text);
	else format(typ,sizeof(typ),"%s: " @c(CHAT_TEXT) "%s",NPCInfo[npcid][npcName],text);
	chat_Message(p[0],p[1],p[2],distance,typ,0xffffffff,true);
	return 1;
}
@f(_,npc.SetName(npcid,name[]))
{
	format(NPCInfo[npcid][npcName],MAX_NAME_LENGTH,name);
	if(NPCInfo[npcid][npcTagDetails][0]) npctag_Update(npcid);
	return 1;
}
@f(bool,npc.NeedsTag(npcid))
{
	switch(NPCInfo[npcid][npcUsage])
	{
		case npcusage_clone, npcusage_pet, npcusage_villager: return true;
	}
	return false; // npcusage_none, npcusage_test, npcusage_intro
}
// Commands
cmd.npcadd(playerid,params[])
{
	#pragma unused params
	player_GetPosition(playerid);
	new id = npc_Spawn(e_NPCUsage:npcusage_test,PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2]);
	chat_Send(playerid,CC_CHAT_NEW,f("Created NPC " @c(CHAT_NEW_VALUE) "#%d" @c(CHAT_NEW) " (" @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) ") / Player ID " @c(CHAT_NEW_VALUE) "%03d",id,NPCInfo[id][npcCodeName],NPCInfo[id][npcPlayerID]));
	return 1;
}
cmd.mynpcadd(playerid,params[])
{
	#pragma unused params
	player_GetPosition(playerid);
	new id = npc_Spawn(e_NPCUsage:npcusage_test,PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],playerid);
	chat_Send(playerid,CC_CHAT_NEW,f("Created NPC " @c(CHAT_NEW_VALUE) "#%d" @c(CHAT_NEW) " (" @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) ") / Player ID " @c(CHAT_NEW_VALUE) "%03d" @c(CHAT_NEW) " - leaded by you",id,NPCInfo[id][npcCodeName],NPCInfo[id][npcPlayerID]));
	return 1;
}
cmd.myclone(playerid,params[])
{
	#pragma unused params
	player_GetPosition(playerid);
	new id = npc_Spawn(e_NPCUsage:npcusage_clone,PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],playerid);
	npc_SetSkin(id,skin_Get(playerid));
	npc_SetStats(id,.maxhealth = 1.0);
	chat_Send(playerid,CC_CHAT_NEW,f("Created clone NPC " @c(CHAT_NEW_VALUE) "#%d" @c(CHAT_NEW) " (" @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) ") / Player ID " @c(CHAT_NEW_VALUE) "%03d" @c(CHAT_NEW) " - leaded by you",id,NPCInfo[id][npcCodeName],NPCInfo[id][npcPlayerID]));
	return 1;
}
cmd.npcdel(playerid,params[])
{
	if(!strlen(params)) return chat_Usage(playerid,"/npcdel","npc id");
	new npcid = strval(params);
	if(!npc_IsAlive(npcid)) return chat_Error(playerid,"Invalid NPC ID.");
	npc_Destroy(npcid);
	chat_Send(playerid,CC_CHAT_NEW,f("Destroyed NPC " @c(CHAT_NEW_VALUE) "#%d" @c(CHAT_NEW) " (" @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) ")",npcid,NPCInfo[npcid][npcName]));
	return 1;
}
cmd.npccmd(playerid,params[])
{
	idx = 0, cmdt = str_tok(params,idx);
	if(!strlen(cmdt)) return chat_Usage(playerid,"/npccmd","*npc id","cmd id");
	new npcid = strval(cmdt);
	if(!npc_IsAlive(npcid)) return chat_Error(playerid,"Invalid NPC ID.");
	cmdt = str_tok(params,idx);
	if(!strlen(cmdt)) return chat_Usage(playerid,"/npccmd","npc id","*cmd id");
	new c = strval(cmdt);
	npc_Command(npcid,c);
	chat_Send(playerid,CC_CHAT_NEW,f("Command " @c(CHAT_NEW_VALUE) "%d" @c(CHAT_NEW) " set on NPC " @c(CHAT_NEW_VALUE) "#%d" @c(CHAT_NEW) " (" @c(CHAT_NEW_VALUE) "%s" @c(CHAT_NEW) ")",c,npcid,NPCInfo[npcid][npcName]));
	return 1;
}
cmd.npcpid(playerid,params[])
{
	if(!strlen(params)) return chat_Usage(playerid,"/npcpid","npc id");
	new npcid = strval(params);
	if(!npc_IsAlive(npcid)) return chat_Error(playerid,"Invalid NPC ID.");
	chat_Send(playerid,CC_CHAT_INFO,f("NPC #%d - %s (PID %03d) ",npcid,NPCInfo[npcid][npcName],NPCInfo[npcid][npcPlayerID]));
	return 1;
}
