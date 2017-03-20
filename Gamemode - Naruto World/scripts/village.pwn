// Anime Fantasy: Naruto World #30 script: village
#define function<%1> forward village_%1; public village_%1
static villagers = 0, villagerSkin[MAX_SKINS] = {-1,...}, villagerSkins = 0;
function<OnGameModeInit()>
{
	// Reset villagers info
	for(new i = 0; i < MAX_VILLAGERS; i++) VillagerInfo[i][vgrValid] = false, VillagerInfo[i][vgrAArrayPos] = INVALID_VILLAGER_ID, VillagerInfo[i][vgrDArrayPos] = INVALID_VILLAGER_ID;
	// Find villager skins
	for(new i = 0; i < sizeof(SkinList); i++) if(strfind(SkinList[i][skName],"Villager",true) != -1) villagerSkin[villagerSkins++] = SkinList[i][skID];
	// Create NPCs based on population
	for(new i = 0, c = 0; i < MAX_TEAMS; i++) if(TeamInfo[i][tValid] && TeamInfo[i][tPopulation] > 0)
	{
		c = 0;
		while(c < VILLAGERS_PER_POPULATION_POINT*TeamInfo[i][tPopulation])
		{
			villager_Spawn(i);
			c++;
		}
		if(c > 0) printf("Spawned villagers for %s: %d",TeamInfo[i][tName],c);
	}
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPathRouteCompleted(pathid,routeid,pos)>
{
	if(route_GetOwnerType(routeid) == e_RouteOwnerType:routeowner_npc)
	{
		new roid = route_GetOwnerID(routeid);
		if(NPCInfo[roid][npcUsage] == e_NPCUsage:npcusage_villager)
		{
			new vid = NPCInfo[roid][npcUsageID];
			villager_Debug(vid,f("Finished part of a path route (path %d, pos %d, route %d)",pathid,pos,routeid));
			VillagerInfo[vid][vgrPos] = pos;
			if(route_IsFinishPoint(routeid))
			{
				if(route_IsEndPoint(routeid))
				{
					villager_Dismiss(vid,5 * math_random(3,9),.endroute = false);
					villager_Debug(vid,"Dismissed");
				}
				else
				{
					// walk backward
					// return 0;
				}
			}
		}
	}
	return 1;
}
function<GlobalScriptTimer(interval)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_second))
	{
		Loop(dvillager,i) if(VillagerInfo[i][vgrRespawnTime] > 0)
		{
			VillagerInfo[i][vgrRespawnTime]--;
			if(!VillagerInfo[i][vgrRespawnTime])
			{
				villager_Respawn(i);
				villager_Debug(i,"Respawned");
				break;
			}
		}
		Loop(avillager,i) if(!VillagerInfo[i][vgrRespawnTime])
		{
			if(VillagerInfo[i][vgrAction] == e_VillagerAction:villageract_walk && !random(10)) villager_RandomAction(i);
			else
			{
				if(VillagerInfo[i][vgrActionInfo][0] > 0)
				{
					VillagerInfo[i][vgrActionInfo][0]--;
					if(!VillagerInfo[i][vgrActionInfo][0]) VillagerInfo[i][vgrActionInfo][1] = -2;
				}
				if(VillagerInfo[i][vgrActionInfo][1] != 0)
				{
					if(VillagerInfo[i][vgrActionInfo][1] < 0) // stop stages
					{
						switch(VillagerInfo[i][vgrActionInfo][1])
						{
							case -2: villager_EndAction(i);
							case -1: villager_ReturnToPath(i);
						}
						VillagerInfo[i][vgrActionInfo][1]++;
					}
					else // start stages
					{
						VillagerInfo[i][vgrActionInfo][1]--;
					}
				}
			}
		}
	}
	return 1;
}
function<OnPlayerEnterArea(playerid,areaid)>
{
	if(AreaInfo[areaid][arValid] && AreaInfo[areaid][arUse] == e_AreaUse:areause_npc && NPCInfo[AreaInfo[areaid][arParam]][npcUsageID] != -1 && PlayerInfo[playerid][pStatus] == e_PlayerStatus:player_status_playing)
	{
		if(villager_RespectChance(respect_Get(playerid)))
		{
			new vid = NPCInfo[AreaInfo[areaid][arParam]][npcUsageID];
			if(VillagerInfo[vid][vgrTeam] == PlayerInfo[playerid][pTeam] && VillagerInfo[vid][vgrAction] == e_VillagerAction:villageract_walk) villager_Talk(vid,e_VillagerMessage:vilmsg_hello,playerid);
		}
	}
	return 1;
}
function<OnNPCDeath(npcid,killerid)>
{
	if(NPCInfo[npcid][npcUsage] == e_NPCUsage:npcusage_villager)
	{
		new vid = NPCInfo[npcid][npcUsageID];
		if(vid != -1)
		{
			new Float:p[3];
			npc_GetPosition(VillagerInfo[vid][vgrNPC],p[0],p[1],p[2]);
			sound_PlayEffect3D(p[0],p[1],p[2],e_SoundEffects:snd_villager_death);
			f(" * Villager " @c(CHAT_NOTICE_BOLD) "%s" @c(CHAT_NOTICE) " has been killed by " @c(CHAT_NOTICE_BOLD) "%s" @c(CHAT_NOTICE) "!",VillagerInfo[vid][vgrName],player_GetName(killerid));
			Loop(player,i) if(PlayerInfo[i][pTeam] == VillagerInfo[vid][vgrTeam] && perm_IsGranted(i,"villager_deaths_notice")) chat_Send(i,CC_CHAT_NOTICE,fstring);
			villager_Dismiss(vid,300);
		}
	}
	return 1;
}
function<OnNPCTakeDamage(npcid,damagerid,weaponid,bodypart,Float:health_loss)>
{
	if(NPCInfo[npcid][npcUsage] == e_NPCUsage:npcusage_villager)
	{
		new vid = NPCInfo[npcid][npcUsageID];
		if(vid != -1)
		{
			new Float:p[3];
			npc_GetPosition(VillagerInfo[vid][vgrNPC],p[0],p[1],p[2]);
			sound_PlayEffect3D(p[0],p[1],p[2],e_SoundEffects:snd_villager_hit);
		}
	}
	return 1;
}
#undef function
// Villager
@f(_,villager.Spawn(teamid))
{
	VillagerInfo[villagers][vgrGender] = 1 + random(2);
	format(VillagerInfo[villagers][vgrName],MAX_NAME_LENGTH,"%s %s",misc_GenerateRandomName(VillagerInfo[villagers][vgrGender]),misc_GenerateRandomName(3));
	VillagerInfo[villagers][vgrTeam] = teamid;
	VillagerInfo[villagers][vgrRoute] = -1;
	VillagerInfo[villagers][vgrPath] = teams_GetRandomPath(teamid);
	VillagerInfo[villagers][vgrPos] = 0;//random(path_GetCount(VillagerInfo[villagers][vgrPath]));
	VillagerInfo[villagers][vgrAction] = e_VillagerAction:villageract_walk;
	VillagerInfo[villagers][vgrActionInfo] = {0,0};
	VillagerInfo[villagers][vgrRespawnTime] = 0;
	VillagerInfo[villagers][vgrBeingDebugged] = false;
	VillagerInfo[villagers][vgrAArrayPos] = INVALID_VILLAGER_ID;
	villager_Respawn(villagers);
	VillagerInfo[villagers][vgrValid] = true;
	villagers++;
	return villagers-1;
}
@f(_,villager.Respawn(villagerid))
{
	new Float:p[5];
	path_GetPosition(VillagerInfo[villagerid][vgrPath],VillagerInfo[villagerid][vgrPos],p[0],p[1],p[2],p[3],p[4]);
	VillagerInfo[villagerid][vgrNPC] = npc_Spawn(e_NPCUsage:npcusage_villager,p[0],p[1],p[2]);
	npc_SetUsageID(VillagerInfo[villagerid][vgrNPC],villagerid);
	npc_SetSkin(VillagerInfo[villagerid][vgrNPC],0);//villagerSkin[random(villagerSkins)]);
	npc_SetStats(VillagerInfo[villagerid][vgrNPC],.maxhealth = 350.0,.vision = NPC_DEFAULT_VISION);
	npc_SetName(VillagerInfo[villagerid][vgrNPC],VillagerInfo[villagerid][vgrName]);
	npc_AssignArea(VillagerInfo[villagerid][vgrNPC],17.5);
	villager_GoPath(villagerid);
	if(VillagerInfo[villagerid][vgrDArrayPos] != INVALID_VILLAGER_ID)
	{
		ElementArrayDel(dvillager,VillagerInfo[villagerid][vgrDArrayPos],INVALID_VILLAGER_ID);
	}
	if(VillagerInfo[villagerid][vgrAArrayPos] == INVALID_VILLAGER_ID)
	{
		ElementArrayAdd(avillager,VillagerInfo[villagerid][vgrAArrayPos],villagerid);
	}
}
@f(_,villager.ReturnToPath(villagerid))
{
	if(VillagerInfo[villagerid][vgrRoute] != -1)
	{
		/*new p = RouteInfo[VillagerInfo[villagerid][vgrRoute]][rtPositionParam] == 0 ? (VillagerInfo[villagerid][vgrPos]-1) : (VillagerInfo[villagerid][vgrPos]+1);
		if(p < 0) p = 0;
		if(p >= PathInfo[VillagerInfo[villagerid][vgrPath]][pathCount]) p = PathInfo[VillagerInfo[villagerid][vgrPath]][pathCount]-1;
		route_Go(VillagerInfo[villagerid][vgrRoute],p);*/
		route_Go(VillagerInfo[villagerid][vgrRoute]);
		VillagerInfo[villagerid][vgrAction] = e_VillagerAction:villageract_walk;
		villager_Debug(villagerid,f("Returned to path %d, pos %d, route %d",VillagerInfo[villagerid][vgrPath],VillagerInfo[villagerid][vgrPos],VillagerInfo[villagerid][vgrRoute]));
	}
}
@f(_,villager.ContinuePath(villagerid))
{
	if(VillagerInfo[villagerid][vgrRoute] != -1)
	{
		route_Continue(VillagerInfo[villagerid][vgrRoute]);
		VillagerInfo[villagerid][vgrAction] = e_VillagerAction:villageract_walk;
		villager_Debug(villagerid,f("Continue path %d, pos %d, route %d",VillagerInfo[villagerid][vgrPath],VillagerInfo[villagerid][vgrPos],VillagerInfo[villagerid][vgrRoute]));
	}
}
@f(_,villager.GoPath(villagerid))
{
	if(VillagerInfo[villagerid][vgrValid] && VillagerInfo[villagerid][vgrRoute] != -1) route_End(VillagerInfo[villagerid][vgrRoute]);
	VillagerInfo[villagerid][vgrRoute] = path_Go(VillagerInfo[villagerid][vgrPath],VillagerInfo[villagerid][vgrNPC],e_RouteOwnerType:routeowner_npc,!random(2) ? (e_RouteMoveType:routemove_path) : (e_RouteMoveType:routemove_pathb),false,MOVE_TYPE_WALK);
}
@f(_,villager.GoNextPath(villagerid,previouspath,bool:prevbackward))
{
	if(VillagerInfo[villagerid][vgrValid] && VillagerInfo[villagerid][vgrRoute] != -1) route_End(VillagerInfo[villagerid][vgrRoute]);
	new bool:findOtherRandom = false;
	if(!prevbackward)
	{
		if(PathInfo[previouspath][pathConnections] > 0)
		{
			// Found a path connection(s), lets go with it
			new go = PathInfo[previouspath][pathConnection][random(PathInfo[previouspath][pathConnections])];
			VillagerInfo[villagerid][vgrPath] = go;
			VillagerInfo[villagerid][vgrPos] = -1;
			villager_GoPath(villagerid);
			villager_Debug(villagerid,f("Going to next path %d, at start pos, route %d",VillagerInfo[villagerid][vgrPath],VillagerInfo[villagerid][vgrRoute]));
		}
		else
		{
			if(!random(2))
			{
				// Go backward on current path
				VillagerInfo[villagerid][vgrRoute] = path_Go(VillagerInfo[villagerid][vgrPath],VillagerInfo[villagerid][vgrNPC],e_RouteOwnerType:routeowner_npc,e_RouteMoveType:routemove_pathb,false,MOVE_TYPE_WALK);
				villager_Debug(villagerid,f("Going backward on current path %d, pos %d, route %d",VillagerInfo[villagerid][vgrPath],VillagerInfo[villagerid][vgrPos],VillagerInfo[villagerid][vgrRoute]));
			}
			else findOtherRandom = true;
		}
	}
	else
	{
		if(PathInfo[previouspath][pathConnectedTo] > 0)
		{
			// Go to the previous path
			new go = PathInfo[previouspath][pathConnectedTo];
			VillagerInfo[villagerid][vgrPath] = go;
			VillagerInfo[villagerid][vgrPos] = -1;
			villager_GoPath(villagerid);
			villager_Debug(villagerid,f("Going to previous path %d, at start pos, route %d",VillagerInfo[villagerid][vgrPath],VillagerInfo[villagerid][vgrRoute]));
		}
		else findOtherRandom = true;
	}
	if(findOtherRandom)
	{
		villager_Debug(villagerid,"Searching for another random path");
	}
}
@f(_,villager.RandomAction(villager))
{
	villager_Debug(villager,"Villager takes random action");
	//new e_VillagerAction:acts[] = {villageract_sit,villageract_rest,villageract_read,villageract_eat,villageract_drink};
	//villager_TakeAction(villager,acts[random(sizeof(acts))],math_random(10,31));
}
@f(_,villager.TakeAction(villager,e_VillagerAction:action,duration))
{
	new param = villager_FindActionParam(villager,action);
	villager_Debug(villager,f("Villager takes action %d, duration %d, param found %d",_:action,duration,param));
	if(param == -1) return;
	switch(action)
	{
		case villageract_sit:
		{
		}
		case villageract_rest:
		{
		}
		case villageract_read:
		{
		}
		case villageract_eat:
		{
		}
		case villageract_drink:
		{
		}
	}
	VillagerInfo[villager][vgrAction] = action;
	VillagerInfo[villager][vgrActionInfo][0] = duration;
	VillagerInfo[villager][vgrActionInfo][1] = 0;
}
@f(_,villager.FindActionParam(villager,e_VillagerAction:action))
{
	new model[25] = {INVALID_STREAMED_OBJECT,...}, models = 0, Float:p[3];
	switch(action)
	{
		case villageract_sit: model[models++] = 1256;
		case villageract_rest: for(new i = 0; i < sizeof(SpecialObjects); i++) if(SpecialObjects[i][soType] == e_SpecialObjectType:sotype_tree) model[models++] = SpecialObjects[i][soModelID];
	}
	npc_GetPosition(VillagerInfo[villager][vgrNPC],p[0],p[1],p[2]);
	for(new i = 0; i < models; i++) LoopAr(mobject,model[i],j) if(math_distance_3d(ObjectInfo[j][oPos][0],ObjectInfo[j][oPos][1],ObjectInfo[j][oPos][2],p[0],p[1],p[2]) <= NPCInfo[VillagerInfo[villager][vgrNPC]][npcStats][2]) return j;
	return -1;
}
@f(_,villager.EndAction(villager,bool:setvar = true))
{
	villager_Debug(villager,f("Action %d finished",_:VillagerInfo[villager][vgrAction]));
	npc_ClearAnimation(VillagerInfo[villager][vgrNPC]);
	if(setvar) VillagerInfo[villager][vgrAction] = e_VillagerAction:villageract_walk;
	VillagerInfo[villager][vgrActionInfo][0] = 0;
}
@f(_,villager.Talk(villager,e_VillagerMessage:msgtype,talkto = INVALID_PLAYER_ID))
{
	VillagerInfo[villager][vgrAction] = e_VillagerAction:villageract_speak;
	VillagerInfo[villager][vgrActionInfo][1] = 0;
	switch(msgtype)
	{
		case vilmsg_hello:
		{
			if(talkto != INVALID_PLAYER_ID)
			{
				VillagerInfo[villager][vgrActionInfo][0] = 4;
				new Float:p[3];
				npc_GetPosition(VillagerInfo[villager][vgrNPC],p[0],p[1],p[2]);
				player_GetPosition(talkto);
				npc_SimpleStop(VillagerInfo[villager][vgrNPC]);
				npc_SetAngle(VillagerInfo[villager][vgrNPC],math_facepoint(p[0],p[1],PlayerInfo[talkto][pPosition][0],PlayerInfo[talkto][pPosition][1]));
				npc_SetAnimation(VillagerInfo[villager][vgrNPC],e_Animation:anim_wave,.time = 2500);
				new message[MAX_CHAT_LENGTH];
				format(message,sizeof(message),textline_GetRandomLine("villager_hello"));
				if(strfind(message,"{name}",true) != -1) format(message,sizeof(message),str_replace("{name}",respect_RespectfulName(talkto,INVALID_CHARACTER,true),message));
				npc_Chat(VillagerInfo[villager][vgrNPC],CHAT_DISTANCE_SAY,message);
				sound_PlayEffect3D(p[0],p[1],p[2],e_SoundEffects:snd_villager_talk);
			}
		}
		case vilmsg_sign:
		{
			// Villagers will ask for a signature of the player, that'd be awesome!
		}
	}
}
@f(bool,villager.RespectChance(respectlevel))
{
	new r = random(MAX_RESPECT);
	return r <= respectlevel;
}
@f(_,villager.Dismiss(villagerid,respawntime,bool:destroytoo = true,bool:endroute = true))
{
	if(!VillagerInfo[villagerid][vgrValid]) return;
	if(destroytoo) npc_Destroy(VillagerInfo[villagerid][vgrNPC]);
	VillagerInfo[villagerid][vgrRespawnTime] = respawntime;
	if(VillagerInfo[villagerid][vgrAArrayPos] != INVALID_VILLAGER_ID) ElementArrayDel(avillager,VillagerInfo[villagerid][vgrAArrayPos],INVALID_VILLAGER_ID);
	ElementArrayAdd(dvillager,VillagerInfo[villagerid][vgrDArrayPos],villagerid);
	if(VillagerInfo[villagerid][vgrRoute] != -1 && endroute)
	{
		route_End(VillagerInfo[villagerid][vgrRoute],true);
		VillagerInfo[villagerid][vgrRoute] = -1;
	}
}
@f(_,villager.Debug(villagerid,text[])) if(VillagerInfo[villagerid][vgrBeingDebugged]) Loop(player,i) if(PlayerInfo[i][pFocusDebugVillager] == villagerid) chat_System(i,CC_SYSTEM_VILLDBG,text);
@f(_,villager.PlayerDebug(playerid,villagerid,bool:enable))
{
	VillagerInfo[villagerid][vgrBeingDebugged] = enable;
	if(!enable) Loop(player,i) if(PlayerInfo[i][pFocusDebugVillager] == villagerid && i != playerid) VillagerInfo[villagerid][vgrBeingDebugged] = true;
}
