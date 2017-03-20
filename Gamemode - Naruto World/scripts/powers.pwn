// Anime Fantasy: Naruto World #22 script: powers
#define function<%1> forward powers_%1; public powers_%1
#define castkeyword "cast"
static PowerEffectCodes[][data_PowerEffectData] =
{	// name:effect params:affect,duration
	{peDamage,"damage",3}, 			// amount,ispercent,dmgtype
	{peDPS,"dps",5},				// amount,ispercent,dmgtype,interval,times
	{peHeal,"heal",2},				// amount,ispercent
	{peSummon,"summon",2},			// id,summontype
	{peClone,"clone",4},			// id,amount,clonetype,param
	{peKnockback,"knockback",1},	// range
	{peCrowdControl,"cc",1},		// cctype
	{peTransform,"transform",1},	// id
	{peBuff,"buff",4},				// bufftype,typeparam,amount,multiple
	{peDebuff,"debuff",4},			// bufftype,typeparam,amount,multiple
	{peAura,"aura",2},				// auraid,radius
	{peSilence,"silence",1},		// silencetype
	{peBasicAttack,"basic",3},		// times,damage,dmgtype
	{peProjectile,"projectile",2},	// direction,powerid
	{peChakra,"chakra",2}			// amount,ispercent
};
function<OnGameModeInit()>
{
	// Loading Powers
	sqlite_Query(gameDatabase,f("SELECT * FROM `%s`",sqlite_TableName(e_SQLiteTable:st_Powers)));
	new m = sqlite_NumRows(), pid = 0, effString[64], splt[3][32], eid = -1;
	if(m >= 1 && m <= MAX_POWERS) for(new i = 0; i < m; i++)
	{
		pid = strval(sqlite_GetField("id"));
		PowerInfo[pid][pwValid] = true;
		format(PowerInfo[pid][pwName],MAX_NAME_LENGTH,sqlite_GetField("name"));
		format(PowerInfo[pid][pwCode],MAX_NAME_LENGTH,sqlite_GetField("codename"));
		format(PowerInfo[pid][pwAvatar],MAX_NAME_LENGTH,sqlite_GetField("avatar"));
		PowerInfo[pid][pwLevel] = strval(sqlite_GetField("level"));
		PowerInfo[pid][pwBuyable] = strval(sqlite_GetField("buyable"));
		PowerInfo[pid][pwType] = power_GetType(strval(sqlite_GetField("type")));
		PowerInfo[pid][pwTarget] = target_FromInt(strval(sqlite_GetField("target")));
		PowerInfo[pid][pwRange] = floatstr(sqlite_GetField("range"));
		PowerInfo[pid][pwRadius] = floatstr(sqlite_GetField("radius"));
		PowerInfo[pid][pwElement] = strval(sqlite_GetField("element"));
		PowerInfo[pid][pwUse] = power_GetUse(strval(sqlite_GetField("use")));
		for(new j = 1; j <= MAX_POWER_EFFECTS; j++)
		{
			format(effString,sizeof(effString),sqlite_GetField(f("effect%d",j)));
			str_remchar(effString,' ');
			if(strlen(effString) > 0)
			{
				PowerInfo[pid][pwEffect][j-1] = true;
				property_StrSet(effect_Var(pid,j,"full"),effString);
				str_split(effString,splt,':');
				property_StrSet(effect_Var(pid,j,"name"),splt[0]);
				if((eid = effect_Index(splt[0])) != -1)
				{
					property_IntSet(effect_Var(pid,j,"id"),eid);
					if(str_countchar(splt[1],',') == (PowerEffectCodes[eid][pfParams]-1))
					{
						str_split(splt[1],fsplitted,',');
						for(new pr = 0; pr < PowerEffectCodes[eid][pfParams] && pr < MAX_POWER_EFFECT_PARAMS; pr++) property_IntSet(effect_Var(pid,j,f("param%d",pr)),strval(fsplitted[pr]));
						str_split(splt[2],fsplitted,',');
						property_IntSet(effect_Var(pid,j,"affect"),strval(fsplitted[0]));
						property_IntSet(effect_Var(pid,j,"duration"),strval(fsplitted[1]));
					}
					else printf("Power #%d error: Invalid amount of parameters (%d instead of %d)",pid,str_countchar(splt[1],',')+1,PowerEffectCodes[eid][pfParams]);
				}
				else printf("Power #%d error: Effect name not found (%s)",pid,splt[0]);
			}
			else PowerInfo[pid][pwEffect][j-1] = false;
			eid = -1;
		}
		description_Check("Powers",PowerInfo[pid][pwCode]);
		printf("Loaded Power: %s",PowerInfo[pid][pwName]);
		sqlite_NextRow();
	}
	sqlite_FreeResults();
	// Power / Category Description Dialog
	dialog_Create(d_PowerDesc,DIALOG_STYLE_MSGBOX,"X","Use","Close",d_Null);
	dialog_AddLine("{1}");
	dialog_Create(d_PowerCategory,DIALOG_STYLE_MSGBOX,"X","Close","",d_Null);
	dialog_AddLine(@c(DIALOG_HEADER) "POWER CATEGORY OVERVIEW: {1}" @c(DIALOG_TEXT) "\n{2}");
	// Creating Cast Code List
	collections[LIST_CASTCODES] = list_Create();
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	buff_ResetAll(playerid);
	return 1;
}
function<OnPlayerUpdate(playerid)>
{
	if(PlayerInfo[playerid][pRoot]) if(!IsPlayerInRangeOfPoint(playerid,0.5,PlayerInfo[playerid][pRootPoint][0],PlayerInfo[playerid][pRootPoint][1],PlayerInfo[playerid][pRootPoint][2]))
	{
		player_SetPosition(playerid,PlayerInfo[playerid][pRootPoint][0],PlayerInfo[playerid][pRootPoint][1],PlayerInfo[playerid][pRootPoint][2]);
		player_Stop(playerid);
	}
	return 1;
}
function<OnPlayerTargetSelect(playerid,e_TargetReason:targetreason,targetid,Float:x,Float:y,Float:z)>
{
	if(targetreason == e_TargetReason:targetreason_power)
	{
		power_Cast(playerid,PowerInfo[PlayerInfo[playerid][pPowerPrepare][0]][pwCode],PlayerInfo[playerid][pPowerPrepare][1],PlayerInfo[playerid][pPowerPrepare][2]);
		player_Stop(playerid);
		PlayerInfo[playerid][pPowerPrepare][3] = 1;
		misc_Notification(playerid,NOTIFICATION_INFO,f("power used: %s",PowerInfo[PlayerInfo[playerid][pPowerPrepare][0]][pwName]));
		power_Cancel(playerid,PowerInfo[PlayerInfo[playerid][pPowerPrepare][0]][pwCode]);
	}
	return 1;
}
function<OnPlayerTargetCancel(playerid,e_TargetReason:targetreason)>
{
	if(targetreason == e_TargetReason:targetreason_power)
	{
		misc_Notification(playerid,NOTIFICATION_INFO,f("aborted used: %s",PowerInfo[PlayerInfo[playerid][pPowerPrepare][0]][pwName]));
		power_Cancel(playerid,PowerInfo[PlayerInfo[playerid][pPowerPrepare][0]][pwCode]);
	}
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_second))
	{
		// Handle powers that affected the player
		new tmp[64], tmp2 = 0, cc[16], m = list_Count(collections[LIST_CASTCODES]);
		if(m > 0) for(new c = 0; c < m; c++)
		{
			format(cc,sizeof(cc),#castkeyword "%06d",list_Get(collections[LIST_CASTCODES],c));
			for(new e = 1; e <= MAX_POWER_EFFECTS; e++)
			{
				format(tmp,sizeof(tmp),"effectduration-%d-%s",e,cc);
				if(GetPVarType(playerid,tmp) != PLAYER_VARTYPE_NONE)
				{
					tmp2 = GetPVarInt(playerid,tmp)-100;
					if(tmp2 < 1) effect_Deactivate(playerid,cc,e);
					else SetPVarInt(playerid,tmp,tmp2);
				}
			}
		}
		// Cooldown / buff ticks
		cooldown_Tick(playerid);
		buff_Tick(playerid);
	}
	if(timer_MeetsTimeUnit(interval,timeunit_tenth)) for(new i = 0, tmp = 0; i < MAX_EFFECTS_PER_TIME; i++)
	{
		// Damage over time
		if(PlayerInfo[playerid][pDOT][i] > 0)
		{
			PlayerInfo[playerid][pDOT][i]--;
			health_Damage(playerid,GetPVarFloat(playerid,f("dot%d-dmg",i)),stats_GetDamageType(GetPVarInt(playerid,f("dot%d-type",i))));
			if(!PlayerInfo[playerid][pDOT][i])
			{
				DeletePVar(playerid,f("dot%d-dmg",i));
				DeletePVar(playerid,f("dot%d-type",i));
				DeletePVar(playerid,f("dot%d-code",i));
				DeletePVar(playerid,f("dot%d-eff",i));
			}
		}
		// Heal over time
		if(PlayerInfo[playerid][pHOT][i] > 0)
		{
			PlayerInfo[playerid][pHOT][i]--;
			health_Add(playerid,GetPVarFloat(playerid,f("hot%d-heal",i)));
			if(!PlayerInfo[playerid][pHOT][i])
			{
				DeletePVar(playerid,f("hot%d-heal",i));
				DeletePVar(playerid,f("hot%d-code",i));
				DeletePVar(playerid,f("hot%d-eff",i));
			}
		}
		// Damage per second
		if(PlayerInfo[playerid][pDPS][i] > 0 && timer_MeetsTimeUnit(interval,PlayerInfo[playerid][pDPS][i]))
		{
			health_Damage(playerid,GetPVarFloat(playerid,f("dps%d-dmg",i)),stats_GetDamageType(GetPVarInt(playerid,f("dps%d-type",i))));
			tmp = GetPVarInt(playerid,f("dps%d-times",i))-1;
			if(!tmp)
			{
				PlayerInfo[playerid][pDPS][i] = 0;
				DeletePVar(playerid,f("dps%d-dmg",i));
				DeletePVar(playerid,f("dps%d-type",i));
				DeletePVar(playerid,f("dps%d-times",i));
				DeletePVar(playerid,f("dps%d-code",i));
				DeletePVar(playerid,f("dps%d-eff",i));
			}
			else SetPVarInt(playerid,f("dps%d-times",i),tmp);
		}
		// Crowd control
		if(PlayerInfo[playerid][pCrowdControl][1] > 0)
		{
			PlayerInfo[playerid][pCrowdControl][1]--;
			if(!PlayerInfo[playerid][pCrowdControl][1])
			{
				PlayerInfo[playerid][pCrowdControl][0] = 0;
				CancelCCEffect(playerid);
			}
		}
	}
	return 1;
}
#undef function
// Private
static stock CancelCCEffect(playerid)
{
	PlayerInfo[playerid][pCrowdControl][0] = 0, PlayerInfo[playerid][pRoot] = false;
	SetPlayerControl(playerid,false);
	SetPlayerDrunkLevel(playerid,0);
}
// Powers
@f(_,power.UpdatePowers(playerid,characterid))
{
	if(characterid != -1)
	{
		new powerString[M_S], i = 1, splt[MAX_POWERS_PER_CATEGORY+1][32];
		do
		{
			format(powerString,sizeof(powerString),sqlite_GetString(gameDatabase,e_SQLiteTable:st_Characters,characterid,f("power%d",i)));
			if(strlen(powerString) > 0)
			{
				str_remchar(powerString,' ');
				str_split(powerString,splt,':');
				str_split(splt[0],fsplitted,',');
				SetPVarString(playerid,power_Var(i,0,"name"),fsplitted[0]);
				SetPVarString(playerid,power_Var(i,0,"image"),fsplitted[1]);
				SetPVarInt(playerid,power_Var(i,0,"cd"),0);
				for(new j = 1; j <= MAX_POWERS_PER_CATEGORY; j++) if(strlen(splt[j]) > 0)
				{
					str_split(splt[j],fsplitted,',');
					SetPVarString(playerid,power_Var(i,j,"puid"),fsplitted[0]);
					SetPVarInt(playerid,power_Var(i,j,"level"),strval(fsplitted[1]));
					SetPVarFloat(playerid,power_Var(i,j,"chakra"),strval(fsplitted[2]));
					SetPVarInt(playerid,power_Var(i,j,"cd"),strval(fsplitted[3]));
				}
			}
			i++, powerString = "";
		}
		while i <= MAX_POWER_CATEGORIES;
	}
}
@f(_,power.ClearPowers(playerid))
{
	for(new i = 1; i <= MAX_POWER_CATEGORIES; i++)
	{
		if(GetPVarType(playerid,power_Var(i,0,"name")) != PLAYER_VARTYPE_NONE)
		{
			DeletePVar(playerid,power_Var(i,0,"name"));
			DeletePVar(playerid,power_Var(i,0,"image"));
			DeletePVar(playerid,power_Var(i,0,"cd"));
			for(new j = 1; j <= MAX_POWERS_PER_CATEGORY; j++) if(GetPVarType(playerid,power_Var(i,j,"puid")) != PLAYER_VARTYPE_NONE)
			{
				DeletePVar(playerid,power_Var(i,j,"puid"));
				DeletePVar(playerid,power_Var(i,j,"level"));
				DeletePVar(playerid,power_Var(i,j,"chakra"));
				DeletePVar(playerid,power_Var(i,j,"cd"));
			}
		}
		PlayerInfo[playerid][pCooldown][i-1] = 0;
	}
}
@f(_,power.Index(powercode[]))
{
	f("power_%s",powercode);
	new pidx = -1;
	if(!property_IntExist(fstring))
	{
		for(new i = 0; i < MAX_POWERS && pidx == -1; i++) if(PowerInfo[i][pwValid] && equal(PowerInfo[i][pwCode],powercode)) pidx = i;
		if(pidx != -1) property_IntSet(fstring,pidx);
		return pidx;
	}
	return property_IntGet(fstring);
}
@f(bool,power.HaveCategory(playerid,category)) return GetPVarType(playerid,power_Var(category,0,"name")) != PLAYER_VARTYPE_NONE;
@f(bool,power.HavePower(playerid,category,powerid=1)) return GetPVarType(playerid,power_Var(category,powerid,"puid")) != PLAYER_VARTYPE_NONE;
@f(bool,power.FindDetails(playerid,powerindex,&category,&powerid))
{
	for(new i = 1; i <= MAX_POWER_CATEGORIES; i++) if(power_HaveCategory(playerid,i)) for(new j = 1; j <= MAX_POWERS_PER_CATEGORY; j++) if(power_HavePower(playerid,i,j)) if(power_IndexAtPos(playerid,i,j) == powerindex) return category = i, powerid = j, true;
	return false;
}
@f(_,power.CanUse(playerid,cat,pid))
{
	new pidx = -1, puid[MAX_NAME_LENGTH];
	GetPVarString(playerid,power_Var(cat,pid,"puid"),puid,sizeof(puid));
	pidx = power_Index(puid);
	if(level_Get(playerid) < GetPVarInt(playerid,power_Var(cat,pid,"level"))) return -1;
	if(PlayerInfo[playerid][pChakra] < GetPVarFloat(playerid,power_Var(cat,pid,"chakra"))) return -2;
	if(cooldown_TimeLeft(playerid,cat) > 0) return -3;
	if(GAME_LEVEL < PowerInfo[pidx][pwLevel]) return -4;
	if(PowerInfo[pidx][pwType] != powertype_active) return -5;
	if(PlayerInfo[playerid][pSilence][_:PowerInfo[pidx][pwUse]]) return -6;
	return 1;
}
@f(_,power.Prepare(playerid,powercode[]))
{
	new pidx = power_Index(powercode);
	if(pidx != -1)
	{
		new col = CC_COLOR_WHITE;
		switch(PowerInfo[pidx][pwUse])
		{
			case puOffensive: col = CC_COLOR_RED;
			case puDefensive: col = CC_COLOR_BLUE;
			case puEscape: col = CC_COLOR_GREY;
			case puSensory, puSupport, puUtility: col = CC_COLOR_GREEN;
		}
		target_Start(playerid,e_TargetReason:targetreason_power,PowerInfo[pidx][pwTarget],col,PowerInfo[pidx][pwRange],PowerInfo[pidx][pwRadius]);
		power_Script(playerid,powercode,"prepare");
		// I ain't gonna define PlayerInfo[playerid][pPowerPrepare] as it's defined in control.pwn
	}
}
@f(_,power.Cancel(playerid,powercode[],bool:abs = false))
{
	target_Stop(playerid);
	PlayerInfo[playerid][pPowerPrepare] = {-1,0,0,0};
	if(abs) power_Script(playerid,powercode,"cancel");
}
@f(_,power.Cast(playerid,powercode[],cat=0,pid=0,Float:chakra=0.0))
{
	SendClientMessageToAll(-1,f("DEBUG - Starting %s",powercode));
	new pidx = power_Index(powercode);
	if(pidx != -1)
	{
		// Make sure it is an active power
		assert PowerInfo[pidx][pwType] == powertype_active;
		// Creating a new cast code
		new castcode[32], Float:p[4], castcondenumber = 0;
		do format(castcode,sizeof(castcode),#castkeyword "%06d",castcondenumber = random(1000000));
		while property_IntExist(f("%s-caster",castcode));
		list_Add(collections[LIST_CASTCODES],castcondenumber);
		property_IntSet(f("%s-caster",castcode),playerid);
		property_IntSet(f("%s-power",castcode),pidx);
		for(new i = 1, eid = -1; i <= MAX_POWER_EFFECTS; i++) if(PowerInfo[pidx][pwEffect][i-1])
		{
			eid = property_IntGet(effect_Var(pidx,i,"id"));
			property_IntSet(f("%s-e%d-id",castcode,i),eid);
			for(new pr = 0; pr < PowerEffectCodes[eid][pfParams] && pr < MAX_POWER_EFFECT_PARAMS; pr++) property_IntSet(f("%s-e%d-param%d",castcode,i,pr),property_IntGet(effect_Var(pidx,i,f("param%d",pr))));
			property_IntSet(f("%s-e%d-affect",castcode,i),property_IntGet(effect_Var(pidx,i,"affect")));
			property_IntSet(f("%s-e%d-duration",castcode,i),property_IntGet(effect_Var(pidx,i,"duration")));
		}
		// Find who needs to be affected by this power
		player_GetPosition(playerid);
		player_GetAngle(playerid);
		for(new i = 0; i < 3; i++) p[i] = PlayerInfo[playerid][pPosition][i];
		switch(PowerInfo[pidx][pwTarget])
		{
			case powertarget_self: effect_Add(playerid,castcode,playerid);
			case powertarget_single:
			{
				new target = target_GetTargetedPlayer(playerid);
				if(target != INVALID_PLAYER_ID) effect_Add(target,castcode,playerid);
			}
			case powertarget_radius: Loop(player,i) if(IsPlayerInRangeOfPoint(i,PowerInfo[pidx][pwRadius],p[0],p[1],p[2])) effect_Add(i,castcode,playerid);
			case powertarget_groundline:
			{
				new Float:line[3];
				for(new i = 0; i < PowerInfo[pidx][pwRange]; i++)
				{
					line[0] = (floatmul(i,PowerInfo[pidx][pwRadius]) * floatsin(-p[3],degrees)), line[1] = (floatmul(i,PowerInfo[pidx][pwRadius]) * floatcos(-p[3],degrees)), line[2] = p[2];
					Loop(player,j) if(IsPlayerInRangeOfPoint(j,PowerInfo[pidx][pwRange],p[0],p[1],p[2]) && IsPlayerInRangeOfPoint(j,PowerInfo[pidx][pwRadius],line[0],line[1],line[2])) effect_Add(i,castcode,playerid);
				}
			}
			case powertarget_line:
			{
				// VVGT
			}
			case powertarget_circle: Loop(player,i) if(IsPlayerInRangeOfPoint(i,PowerInfo[pidx][pwRadius],PlayerInfo[playerid][pTargetPosition][0],PlayerInfo[playerid][pTargetPosition][1],PlayerInfo[playerid][pTargetPosition][2])) effect_Add(i,castcode,playerid);
			case powertarget_square:
			{
				new Float:size = floatdiv(PowerInfo[pidx][pwRadius],2.0);
				Loop(player,i) if(player_IsInSquare3D(i,PlayerInfo[playerid][pTargetPosition][0]-size,PlayerInfo[playerid][pTargetPosition][0]+size,PlayerInfo[playerid][pTargetPosition][1]-size,PlayerInfo[playerid][pTargetPosition][1]+size,PlayerInfo[playerid][pTargetPosition][2]-size,PlayerInfo[playerid][pTargetPosition][2]+size)) effect_Add(i,castcode,playerid);
			}
			case powertarget_sphere:
			{
				// VVGT
			}
			case powertarget_point:
			{
				new ptarget = INVALID_PLAYER_ID, Float:rd = math_min(POINT_RADIUS,PowerInfo[pidx][pwRadius]);
				LoopEx(player,i,<ptarget == INVALID_PLAYER_ID>) if(IsPlayerStreamedIn(playerid,i) && IsPlayerInRangeOfPoint(i,rd,PlayerInfo[playerid][pTargetPosition][0],PlayerInfo[playerid][pTargetPosition][1],PlayerInfo[playerid][pTargetPosition][2])) ptarget = i;
				if(ptarget != INVALID_PLAYER_ID) effect_Add(ptarget,castcode,playerid);
			}
		}
		if(!player_IsNPC(playerid))
		{
			// Start cooldown for this power
			if(cat != 0 && pid != 0) cooldown_Start(playerid,cat,pid);
			// Take required chakra
			chakra_Use(playerid,cat != 0 && pid != 0 ? GetPVarFloat(playerid,power_Var(cat,pid,"chakra")) : chakra);
		}
		// Run the power effects
		effect_Apply(castcode);
		power_Script(playerid,powercode,"use");
		// Debug message
		chat_Message(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],CC_POWER_USAGE,f(" * %s used %s",player_GetName(playerid),PowerInfo[pidx][pwName]),GetPlayerColor(playerid),false);
		SendClientMessageToAll(-1,f("DEBUG - Castcode %s created for %s",castcode,PowerInfo[pidx][pwName]));
	}
}
@f(_,power.Script(playerid,powercode[],script[],param = 0))
{
	new pcid = 0;
	#pragma unused pcid, powercode, param
	if(equal(script,"prepare"))
	{
	}
	else if(equal(script,"cancel"))
	{
		anim_Clear(playerid);
	}
	else if(equal(script,"use"))
	{
	}
	else if(equal(script,"hit")) // param = hit id
	{
	}
	else if(equal(script,"end"))
	{
	}
}
@f(bool,power.HasPassive(playerid,powercode[]))
{
	new puid[32], dx = power_Index(powercode);
	if(dx == -1 || PowerInfo[dx][pwType] != e_PowerTypes:powertype_passive) return false;
	for(new i = 0; i < MAX_POWER_CATEGORIES; i++) for(new j = 1; j <= MAX_POWERS_PER_CATEGORY; j++) if(GetPVarType(playerid,power_Var(i,j,"puid")) != PLAYER_VARTYPE_NONE)
	{
		GetPVarString(playerid,power_Var(i,j,"puid"),puid,sizeof(puid));
		if(equal(puid,powercode)) return true;
	}
	return false;
}
@f(_,power.CheckPassive(playerid,powercode[]))
{
}
@f(_,power.IndexAtPos(playerid,cat,pid))
{
	new puid[32];
	if(GetPVarType(playerid,power_Var(cat,pid,"puid")) != PLAYER_VARTYPE_NONE) GetPVarString(playerid,power_Var(cat,pid,"puid"),puid,sizeof(puid));
	return strlen(puid) > 0 ? power_Index(puid) : -1;
}
@f(e_PowerTypes,power.GetType(num))
{
	switch(num)
	{
		case 1: return powertype_active;
		case 2: return powertype_passive;
	}
	return powertype_none;
}
@f(e_PowerUses,power.GetUse(num))
{
	switch(num)
	{
		case 1: return puOffensive;
		case 2: return puDefensive;
		case 3: return puEscape;
		case 4: return puSensory;
		case 5: return puSupport;
		case 6: return puUtility;
	}
	return puNoUse;
}
@f(_,power.TypeAsString(e_PowerTypes:type))
{
	new tmp[16];
	switch(type)
	{
		case powertype_active: tmp = "Active";
		case powertype_passive: tmp = "Passive";
	}
	return tmp;
}
@f(_,power.UseAsString(e_PowerUses:use))
{
	new tmp[16];
	switch(use)
	{
		case puOffensive: tmp = "Offensive";
		case puDefensive: tmp = "Defensive";
		case puEscape: tmp = "Escape";
		case puSensory: tmp = "Sensory";
		case puSupport: tmp = "Support";
		case puUtility: tmp = "Utility";
	}
	return tmp;
}
@f(_,power.GetDescription(playerid,cat,pid))
{
	new powerDescription[M_D_L], powercode[MAX_NAME_LENGTH], pidx = -1, tmp[64], tmp2[64], line[M_S], powerparams[MAX_POWER_EFFECT_PARAMS];
	GetPVarString(playerid,power_Var(cat,pid,"puid"),powercode,sizeof(powercode));
	pidx = power_Index(powercode);
	// Usage
	format(powerDescription,sizeof(powerDescription),@c(DIALOG_HEADER) "POWER OVERVIEW: %s",str_upper(PowerInfo[pidx][pwName]));
	str_add(powerDescription,f(@c(DIALOG_INFO) "[Game Level: " @c(DIALOG_INFO_VALUE) "%d" @c(DIALOG_INFO) " || Power ID: " @c(DIALOG_INFO_VALUE) "%03d" @c(DIALOG_INFO) "]" @c(DIALOG_TEXT),PowerInfo[pidx][pwLevel],PowerInfo[pidx][pwID]),"\n\n");
	str_add(powerDescription,"","\n");
	str_add(powerDescription,f("Type: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT) " (" @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT) ")",power_TypeAsString(PowerInfo[pidx][pwType]),power_UseAsString(PowerInfo[pidx][pwUse])),"\n");
	if(PowerInfo[pidx][pwType] == powertype_active)
	{
		str_add(powerDescription,f("Target: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),target_ToString(PowerInfo[pidx][pwTarget])),"\n");
		if(PowerInfo[pidx][pwRange] > 0.0) str_add(powerDescription,f("Max Range: " @c(DIALOG_VALUE) "%.0f" @c(DIALOG_TEXT),PowerInfo[pidx][pwRange]),"\n");
		if(PowerInfo[pidx][pwRadius] > 0.0) str_add(powerDescription,f("Radius: " @c(DIALOG_VALUE) "%.0f" @c(DIALOG_TEXT),PowerInfo[pidx][pwRadius]),"\n");
	}
	if(PowerInfo[pidx][pwElement] > 0) str_add(powerDescription,"Element: " @c(DIALOG_VALUE) "TBA" @c(DIALOG_TEXT),"\n");
	str_add(powerDescription,"","\n");
	// Desciption
	str_add(powerDescription,f("\n%s\n",description_Get("Powers",powercode)),"\n");
	str_add(powerDescription,"","\n");
	// Effects
	for(new i = 1, eid = -1, affect = 0, duration = 0; i <= MAX_POWER_EFFECTS; i++) if(PowerInfo[pidx][pwEffect][i-1])
	{
		eid = property_IntGet(effect_Var(pidx,i,"id"));
		for(new pr = 0; pr < PowerEffectCodes[eid][pfParams] && pr < MAX_POWER_EFFECT_PARAMS; pr++) powerparams[pr] = property_IntGet(effect_Var(pidx,i,f("param%d",pr)));
		affect = property_IntGet(effect_Var(pidx,i,"affect"));
		duration = property_IntGet(effect_Var(pidx,i,"duration"));
		switch(affect)
		{
			case 1: tmp2 = "Allies & Self";
			case 2: tmp2 = "Enemies";
			case 3: tmp2 = "Allies, Enemies & Self";
			case 4: tmp2 = "Allies";
			case 5: tmp2 = "Allies & Enemies";
		}
		switch(PowerEffectCodes[eid][pfType])
		{
			case peDamage: // Damage; amount,ispercent,dmgtype
			{
				tmp = stats_DamageTypeAsString(stats_GetDamageType(powerparams[2]));
				if(duration > 0)
				{
					str_add(powerDescription,f("%s damage over time: " @c(DIALOG_VALUE) "%d%c" @c(DIALOG_TEXT) " [%s]",tmp,powerparams[0],powerparams[1] ? '%' : ' ',tmp2),"\n");
					str_add(powerDescription,f("%s damage duration: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),tmp,convert_secondsformat(duration)),"\n");
				}
				else str_add(powerDescription,f("%s damage: " @c(DIALOG_VALUE) "%d%c" @c(DIALOG_TEXT) " [%s]",tmp,powerparams[0],powerparams[1] ? '%' : ' ',tmp2),"\n");
			}
			case peDPS: // Damage per second; amount,ispercent,dmgtype,interval,times
			{
				tmp = stats_DamageTypeAsString(stats_GetDamageType(powerparams[2]));
				str_add(powerDescription,f("%s damage per %s: " @c(DIALOG_VALUE) "%d%c" @c(DIALOG_TEXT) " [%s]",tmp,powerparams[3] == 100 ? ("second") : ("time"),powerparams[0],powerparams[1] ? '%' : ' ',tmp2),"\n");
				if(powerparams[3] == 100) str_add(powerDescription,f("%s damage times: " @c(DIALOG_VALUE) "%d" @c(DIALOG_TEXT),tmp,powerparams[4]),"\n");
				else str_add(powerDescription,f("%s damage times: " @c(DIALOG_VALUE) "%d" @c(DIALOG_TEXT) " each " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),tmp,powerparams[4],convert_secondsformat(powerparams[3])),"\n");
			}
			case peHeal: // Heal; amount,ispercent
			{
				if(duration > 0)
				{
					str_add(powerDescription,f("Heal over time: " @c(DIALOG_VALUE) "%d%c" @c(DIALOG_TEXT) " [%s]",powerparams[0],powerparams[1] ? '%' : ' ',tmp2),"\n");
					str_add(powerDescription,f("Heal duration: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),convert_secondsformat(duration)),"\n");
				}
				else str_add(powerDescription,f("Heal: " @c(DIALOG_VALUE) "%d%c" @c(DIALOG_TEXT) " [%s]",powerparams[0],powerparams[1] ? '%' : ' ',tmp2),"\n");
			}
			case peSummon:
			{
			}
			case peClone:
			{
				if(!powerparams[0]) tmp = "Self";
				else format(tmp,sizeof(tmp),chars_GetName(powerparams[0]));
				str_add(powerDescription,f("Clone: " @c(DIALOG_VALUE) "%d %s" @c(DIALOG_TEXT),powerparams[1],tmp),"\n");
				switch(powerparams[2])
				{
					case 1:
					{
						str_add(powerDescription,f("Clone type #%d: " @c(DIALOG_VALUE) "1-hit to kill" @c(DIALOG_TEXT),powerparams[2]),"\n");
						str_add(powerDescription,f("Clone health: " @c(DIALOG_VALUE) "0.1" @c(DIALOG_TEXT) " HP"),"\n");
						str_add(powerDescription,f("Clone basic damage: " @c(DIALOG_VALUE) "%d%c" @c(DIALOG_TEXT) " of creator",powerparams[3],'%'),"\n");
						str_add(powerDescription,f("Clone attack speed: " @c(DIALOG_VALUE) "100%c" @c(DIALOG_TEXT) " of creator",'%'),"\n");
						str_add(powerDescription,f("Clone vision: " @c(DIALOG_VALUE) "%d" @c(DIALOG_TEXT) " (basic clone vision)",NPC_DEFAULT_VISION),"\n");
					}
				}
			}
			case peKnockback:
			{
			}
			case peCrowdControl: // Crowd Control; cctype
			{
				switch(powerparams[0])
				{
					case 1: tmp = "Stun";
					case 2: tmp = "Mesmerize";
					case 3: tmp = "Drunk";
					case 4: tmp = "Root";
				}
				str_add(powerDescription,f("%s: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT) " [%s]",tmp,convert_secondsformat(duration),tmp2),"\n");
			}
			case peTransform: // Transform; id
			{
				str_add(powerDescription,f("Transformation character: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT) " [%s]",chars_GetName(powerparams[0]),tmp2),"\n");
				if(duration > 0) str_add(powerDescription,f("Transformation duration: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),convert_secondsformat(duration)),"\n");
			}
			case peBuff, peDebuff: // Buff; bufftype,typeparam,amount,multiple
			{
				new tmp3[32];
				switch(buff_GetTypeFromID(powerparams[0]))
				{
					case buff_stats: tmp = "Stats", tmp3 = stats_StatsTypeAsString(stats_GetStatsType(powerparams[1]));
					case buff_damage: tmp = "Damage", tmp3 = stats_DamageTypeAsString(stats_GetDamageType(powerparams[1]));
					case buff_protection: tmp = "Protection", tmp3 = stats_DamageTypeAsString(stats_GetDamageType(powerparams[1]));
					case buff_lowerstats:
					{
						tmp = "Stats";
						switch(powerparams[1])
						{
							case 1: tmp3 = "STR";
							case 2: tmp3 = "AGI";
							case 3: tmp3 = "INT";
						}
					}
				}
				str_add(powerDescription,f("%s (%s) %sbuff: " @c(DIALOG_VALUE) "%d" @c(DIALOG_TEXT) " [%s]",tmp,tmp3,PowerEffectCodes[eid][pfType] == peBuff ? ("") : ("de"),powerparams[2],tmp2),"\n");
				if(duration > 0) str_add(powerDescription,f("%s (%s) %sbuff duration: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),tmp,tmp3,PowerEffectCodes[eid][pfType] == peBuff ? ("") : ("de"),convert_secondsformat(duration)),"\n");
			}
			case peAura:
			{
			}
			case peSilence: // Silence; silencetype
			{
				str_add(powerDescription,f("Silence: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT) " [%s]",power_UseAsString(power_GetUse(powerparams[0])),tmp2),"\n");
				if(duration > 0) str_add(powerDescription,f("Silence duration: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),convert_secondsformat(duration)),"\n");
			}
			case peBasicAttack: // Basic Attack; times,damage,dmgtype
			{
				str_add(powerDescription,f("Basic attack damage (%s): " @c(DIALOG_VALUE) "%d" @c(DIALOG_TEXT) " [%s]",stats_DamageTypeAsString(stats_GetDamageType(powerparams[1])),powerparams[1],tmp2),"\n");
				str_add(powerDescription,f("Basic attack ammo: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),powerparams[0]),"\n");
				if(duration > 0) str_add(powerDescription,f("Basic attack duration: " @c(DIALOG_VALUE) "%s" @c(DIALOG_TEXT),convert_secondsformat(duration)),"\n");
			}
			case peProjectile:
			{
			}
			case peChakra: // amount,ispercent
			{
				str_add(powerDescription,f("%s chakra: " @c(DIALOG_VALUE) "%d%c" @c(DIALOG_TEXT) " [%s]",powerparams[0] > 0 ? ("Get") : ("Reduce"),powerparams[0],powerparams[1] ? '%' : ' ',tmp2),"\n");
			}
		}
	}
	str_add(powerDescription,line,"\n\n");
	// Requirements
	str_add(powerDescription,f("Required level: " @c(DIALOG_VALUE) "%d" @c(DIALOG_TEXT),GetPVarInt(playerid,power_Var(cat,pid,"level"))),"\n");
	str_add(powerDescription,f("Chakra cost: " @c(DIALOG_VALUE) "%.0f" @c(DIALOG_TEXT),GetPVarFloat(playerid,power_Var(cat,pid,"chakra"))),"\n");
	str_add(powerDescription,f("Cooldown: " @c(DIALOG_VALUE) "%d" @c(DIALOG_TEXT),GetPVarInt(playerid,power_Var(cat,pid,"cd"))),"\n");
	// EOS
	return powerDescription;
}
@f(_,power.Var(cat,pid,var[]))
{
	new v[32];
	format(v,sizeof(v),"power-%d-%d-%s",cat,pid,var);
	return v;
}
// Effects
@f(_,effect.Index(effectname[]))
{
	f("effect_%s",effectname);
	new eidx = -1;
	if(!property_IntExist(fstring))
	{
		for(new i = 0; i < sizeof(PowerEffectCodes) && eidx == -1; i++) if(equal(PowerEffectCodes[i][pfCode],effectname)) eidx = i;
		if(eidx != -1) property_IntSet(fstring,eidx);
		return eidx;
	}
	return property_IntGet(fstring);
}
@f(_,effect.Var(pidx,eidx,var[]))
{
	new v[32];
	format(v,sizeof(v),"effect-%d-%d-%s",pidx,eidx,var);
	return v;
}
@f(_,effect.Add(playerid,castcode[],caster))
{
	if(GetPVarType(playerid,f("affected-%s",castcode)) == PLAYER_VARTYPE_NONE)
	{
		SetPVarInt(playerid,f("affected-%s",castcode),1);
		power_Script(caster,PowerInfo[property_IntGet(f("%s-power",castcode))][pwCode],"hit",playerid);
		SendClientMessageToAll(-1,f("DEBUG - Castcode %s affected %s",castcode,player_GetName(playerid)));
	}
}
@f(_,effect.Apply(castcode[]))
{
	new powerparams[MAX_POWER_EFFECT_PARAMS], tmp = -1, playerid = property_IntGet(f("%s-caster",castcode)), pidx = property_IntGet(f("%s-power",castcode)), m = 0;
	for(new e = 1, eid = -1, duration = 0, affect = 0; e <= MAX_POWER_EFFECTS; e++) if(PowerInfo[pidx][pwEffect][e-1])
	{
		eid = property_IntGet(f("%s-e%d-id",castcode,e));
		duration = property_IntGet(f("%s-e%d-duration",castcode,e));
		affect = property_IntGet(f("%s-e%d-affect",castcode,e));
		for(new pr = 0; pr < PowerEffectCodes[eid][pfParams] && pr < MAX_POWER_EFFECT_PARAMS; pr++) powerparams[pr] = property_IntGet(f("%s-e%d-param%d",castcode,e,pr));
		f("affected-%s",castcode);
		Loop(player,i) if(GetPVarType(i,fstring) != PLAYER_VARTYPE_NONE)
		{
			SendClientMessageToAll(-1,f("DEBUG - Castcode %s, %s testing effect on %s",castcode,PowerEffectCodes[eid][pfCode],player_GetName(i)));
			if((affect == 1 && teams_IsAlly(playerid,i)) || (affect == 2 && !teams_IsAlly(playerid,i)) || affect == 3 || (affect == 4 && teams_IsAlly(playerid,i) && playerid != i) || (affect == 5 && playerid != i))
			{
				SendClientMessageToAll(-1,f("DEBUG - Castcode %s, %s effect applied on %s",castcode,PowerEffectCodes[eid][pfCode],player_GetName(i)));
				switch(PowerEffectCodes[eid][pfType])
				{
					case peDamage: // Damage; amount,ispercent,dmgtype
					{
						powerparams[1] = clamp(powerparams[1],0,1);
						if(powerparams[1]) powerparams[0] = floatround(math_percent(powerparams[0],stats_GetStats(i,stats_health)));
						if(duration > 0) // Damage over time
						{
							for(new d = 0; d < MAX_EFFECTS_PER_TIME && tmp == -1; d++) if(!PlayerInfo[i][pDOT][d]) tmp = i;
							if(tmp != -1)
							{
								PlayerInfo[i][pDOT][tmp] = duration / 10;
								SetPVarFloat(i,f("dot%d-dmg",tmp),floatdiv(float(powerparams[0]),float(PlayerInfo[i][pDOT][tmp])));
								SetPVarInt(i,f("dot%d-type",tmp),powerparams[2]);
								SetPVarString(i,f("dot%d-code",tmp),castcode);
								SetPVarInt(i,f("dot%d-eff",tmp),e);
							}
						}
						else // Instant Damage
							health_Damage(i,float(powerparams[0]),stats_GetDamageType(powerparams[2]));
					}
					case peDPS: // Damage per second; amount,ispercent,dmgtype,interval,times
					{
						powerparams[1] = clamp(powerparams[1],0,1);
						if(powerparams[1]) powerparams[0] = floatround(math_percent(powerparams[0],stats_GetStats(i,stats_health)));
						for(new d = 0; d < MAX_EFFECTS_PER_TIME && tmp == -1; d++) if(!PlayerInfo[i][pDPS][d]) tmp = i;
						if(tmp != -1)
						{
							PlayerInfo[i][pDPS][tmp] = powerparams[3];
							SetPVarFloat(i,f("dps%d-dmg",tmp),float(powerparams[0]));
							SetPVarInt(i,f("dps%d-type",tmp),powerparams[2]);
							SetPVarInt(i,f("dps%d-times",tmp),powerparams[4]);
							SetPVarString(i,f("dps%d-code",tmp),castcode);
							SetPVarInt(i,f("dps%d-eff",tmp),e);
						}
					}
					case peHeal: // Heal; amount,ispercent
					{
						powerparams[1] = clamp(powerparams[1],0,1);
						if(powerparams[1]) powerparams[0] = floatround(math_percent(powerparams[0],stats_GetStats(i,stats_health)));
						if(duration > 0) // Heal over time
						{
							for(new d = 0; d < MAX_EFFECTS_PER_TIME && tmp == -1; d++) if(!PlayerInfo[i][pHOT][d]) tmp = i;
							if(tmp != -1)
							{
								PlayerInfo[i][pHOT][tmp] = duration / 10;
								SetPVarFloat(i,f("hot%d-heal",tmp),floatdiv(float(powerparams[0]),float(PlayerInfo[i][pHOT][tmp])));
								SetPVarString(i,f("hot%d-code",tmp),castcode);
								SetPVarInt(i,f("hot%d-eff",tmp),e);
							}
						}
						else // Instant Heal
							health_Add(i,float(powerparams[0]));
					}
					case peSummon:
					{
						// duration > 0 ? (time to disappear) : (stay forever)
					}
					case peClone: // Clone; id,amount,clonetype,param
					{
						// duration > 0 ? (time to disappear) : (until died)
						if(!powerparams[0]) powerparams[0] = skin_Get(playerid);
						player_GetPosition(playerid);
						new npcid, skinid = skin_Get(playerid), Float:maxhp, Float:dmg, Float:vis, Float:as, created = 0;
						switch(powerparams[2])
						{
							case 1: // Regular clone, 1-shot to kill, damage based on % of creator
							{
								maxhp = 0.1;
								dmg = math_percent(_:powerparams[3],basicattack_GetDamage(playerid));
								vis = NPC_DEFAULT_VISION;
								as = stats_GetStats(playerid,stats_attackspeed);
								powerparams[3] = clamp(powerparams[3],1,MAX_NPCS);
							}
						}
						while(created < powerparams[1])
						{
							npcid = npc_Spawn(e_NPCUsage:npcusage_clone,PlayerInfo[playerid][pPosition][0] + math_frandom(float(0-powerparams[1]),powerparams[1]),PlayerInfo[playerid][pPosition][1] + math_frandom(float(0-powerparams[1]),powerparams[1]),PlayerInfo[playerid][pPosition][2],playerid);
							npc_SetSkin(npcid,skinid);
							npc_SetStats(npcid,maxhp,dmg,vis,as);
							if(duration > 0) npc_SetDuration(npcid,duration);
							created++;
						}
					}
					case peKnockback:
					{
						// duration > 0 ? (fall for time) : (knockback)
					}
					case peCrowdControl: // Crowd Control; cctype
					{
						// duration > 0 ? (cc time) : (until ticked);
						if(PlayerInfo[i][pCrowdControl][0] > 0)
						{
							m = list_Count(collections[LIST_CASTCODES]);
							if(m > 0) for(new c = 0, cc[32], bool:flag = false; c < m && !flag; c++)
							{
								format(cc,sizeof(cc),#castkeyword "%06d",list_Get(collections[LIST_CASTCODES],c));
								if(equal(cc,castcode)) continue;
								for(new e_ = 1, eid_ = -1; e_ <= MAX_POWER_EFFECTS && !flag; e_++) if(PowerInfo[pidx][pwEffect][e-1])
								{
									eid_ = property_IntGet(f("%s-e%d-id",cc,e_));
									if(PowerEffectCodes[eid_][pfType] == peCrowdControl && property_IntGet(f("%s-e%d-param0",cc,e_)) == powerparams[0])
									{
										flag = true;
										effect_Deactivate(i,cc,e_);
									}
								}
							}
						}
						switch(PlayerInfo[i][pCrowdControl][0] = powerparams[0])
						{
							case 1: // Stun
							{
								SetPlayerControl(i,true);
								if(duration > 0) nametag_SetAdditionalText(i,duration*10,@c(COLOR_WHITE) "Stunned");
							}
							case 2: // Mesmerize
							{
								SetPlayerControl(i,true);
								if(duration > 0) nametag_SetAdditionalText(i,duration*10,@c(COLOR_PURPLE) "Mesmerized");
							}
							case 3: // Drunk
							{
								SetPlayerDrunkLevel(i,2000+(duration > 0 ? (100 * duration) : 48000));
								if(duration > 0) nametag_SetAdditionalText(i,duration*10,@c(COLOR_PINK) "Drunk");
							}
							case 4: // Root
							{
								PlayerInfo[i][pRoot] = true;
								GetPlayerPos(i,PlayerInfo[i][pRootPoint][0],PlayerInfo[i][pRootPoint][1],PlayerInfo[i][pRootPoint][2]);
								if(duration > 0) nametag_SetAdditionalText(i,duration*10,@c(COLOR_GREEN) "Root");
							}
						}
						PlayerInfo[i][pCrowdControl][1] = duration;
						//duration = (duration / 100) + (_:(duration % 100 > 0));
					}
					case peTransform: // Transform; id
					{
						// duration > 0 ? (time to return) : (y);
						chars_Set(i,powerparams[0],.ingame = true);
					}
					case peBuff, peDebuff: // Buff; bufftype,typeparam,amount,multiple
					{
						if(duration > 0)
						{
							powerparams[3] = clamp(powerparams[1],0,1);
							buff_Set(i,powerparams[0],powerparams[1],PowerEffectCodes[eid][pfType] == peBuff ? powerparams[2] : (0-powerparams[2]),duration / 100,bool:powerparams[3],f("frompower-%d-e%d",property_IntGet(f("%s-power",castcode)),e),castcode,e);
						}
					}
					case peAura:
					{
						// duration > 0 ? (time to disappear) : (until died);
					}
					case peSilence: // Silence; silencetype
					{
						// duration > 0 ? (silence time) : (until died);
						if(PlayerInfo[i][pSilence][powerparams[0]])
						{
							m = list_Count(collections[LIST_CASTCODES]);
							if(m > 0) for(new c = 0, cc[32], bool:flag = false; c < m && !flag; c++)
							{
								format(cc,sizeof(cc),#castkeyword "%06d",list_Get(collections[LIST_CASTCODES],c));
								if(equal(cc,castcode)) continue;
								for(new e_ = 1, eid_ = -1; e_ <= MAX_POWER_EFFECTS && !flag; e_++) if(PowerInfo[pidx][pwEffect][e-1])
								{
									eid_ = property_IntGet(f("%s-e%d-id",cc,e_));
									if(PowerEffectCodes[eid_][pfType] == peSilence && property_IntGet(f("%s-e%d-param0",cc,e_)) == powerparams[0])
									{
										flag = true;
										effect_Deactivate(i,cc,e_);
									}
								}
							}
						}
						PlayerInfo[i][pSilence][powerparams[0]] = true;
					}
					case peBasicAttack: // Basic Attack; times,damage,dmgtype
					{
						// duration > 0 ? (time to reset) : (until died);
						if(PlayerInfo[i][pSilence][powerparams[0]])
						{
							m = list_Count(collections[LIST_CASTCODES]);
							if(m > 0) for(new c = 0, cc[32], bool:flag = false; c < m && !flag; c++) if(PowerInfo[pidx][pwEffect][e-1])
							{
								format(cc,sizeof(cc),#castkeyword "%06d",list_Get(collections[LIST_CASTCODES],c));
								if(equal(cc,castcode)) continue;
								for(new e_ = 1, eid_ = -1; e_ <= MAX_POWER_EFFECTS && !flag; e_++)
								{
									eid_ = property_IntGet(f("%s-e%d-id",cc,e_));
									if(PowerEffectCodes[eid_][pfType] == peBasicAttack)
									{
										flag = true;
										effect_Deactivate(i,cc,e_);
									}
								}
							}
						}
						for(new j = 0; j < 3; j++) PlayerInfo[i][pBasicAttack][j] = powerparams[i];
						PlayerInfo[i][pBasicAttack][3] = e;
						format(PlayerInfo[i][pBasicAttackCode],16,castcode);
					}
					case peProjectile:
					{
						// duration > 0 ? (time to disappear) : (continue);
					}
					case peChakra: // Chakra; amount,ispercent
					{
						// give/take chakra
						powerparams[1] = clamp(powerparams[1],0,1);
						if(powerparams[1]) powerparams[0] = floatround(math_percent(powerparams[0],stats_GetStats(i,stats_chakra)));
						if(powerparams[0] > 0) chakra_Add(playerid,powerparams[0]);
						else chakra_Use(playerid,powerparams[0]);
					}
				}
				if(duration > 0)
				{
					SetPVarInt(i,f("effectduration-%d-%s",e,castcode),duration);
					chat_Send(i,CC_CHAT_NOTICE,f("You've been affected by " @c(CHAT_NOTICE_BOLD) "%s" @c(CHAT_NOTICE) "'s " @c(CHAT_NOTICE_BOLD) "%s" @c(CHAT_NOTICE) " for " @c(CHAT_NOTICE_BOLD) "%s" @c(CHAT_NOTICE) ".",PlayerInfo[playerid][pDisplayName],PowerInfo[pidx][pwName],convert_secondsformat(duration)));
				}
				else chat_Send(i,CC_CHAT_NOTICE,f("You've been affected by " @c(CHAT_NOTICE_BOLD) "%s" @c(CHAT_NOTICE) "'s " @c(CHAT_NOTICE_BOLD) "%s" @c(CHAT_NOTICE) ".",PlayerInfo[playerid][pDisplayName],PowerInfo[pidx][pwName]));
			}
		}
	}
}
@f(bool,effect.IsDone(castcode[]))
{
	f("affected-%s",castcode);
	new c = 0;
	Loop(player,i) if(GetPVarType(i,fstring) != PLAYER_VARTYPE_NONE) c++;
	return !c;
}
@f(_,effect.Deactivate(playerid,castcode[],specificeffect = 0))
{
	new tmp[64], powerparams[MAX_POWER_EFFECT_PARAMS], pidx = property_IntGet(f("%s-power",castcode));
	for(new e = !specificeffect ? 1 : specificeffect, eid = -1; e <= (!specificeffect ? MAX_POWER_EFFECTS : specificeffect); e++) if(PowerInfo[pidx][pwEffect][e-1])
	{
		eid = property_IntGet(f("%s-e%d-id",castcode,e));
		for(new pr = 0; pr < PowerEffectCodes[eid][pfParams] && pr < MAX_POWER_EFFECT_PARAMS; pr++) powerparams[pr] = property_IntGet(f("%s-e%d-param%d",castcode,e,pr));
		switch(PowerEffectCodes[eid][pfType])
		{
			case peDamage:
			{
				new id = -1;
				for(new i = 0; i < MAX_EFFECTS_PER_TIME && id == -1; i++) if(PlayerInfo[playerid][pDOT][i] > 0)
				{
					GetPVarString(playerid,f("dot%d-code"),tmp,sizeof(tmp));
					if(!equal(tmp,castcode) || GetPVarInt(playerid,f("dot%d-eff")) != e) continue;
					id = i;
				}
				if(id != -1)
				{
					PlayerInfo[playerid][pDOT][id] = 0;
					DeletePVar(playerid,f("dot%d-dmg",id));
					DeletePVar(playerid,f("dot%d-type",id));
					DeletePVar(playerid,f("dot%d-code",id));
					DeletePVar(playerid,f("dot%d-eff",id));
				}
			}
			case peDPS:
			{
				new id = -1;
				for(new i = 0; i < MAX_EFFECTS_PER_TIME && id == -1; i++) if(PlayerInfo[playerid][pDPS][i] > 0)
				{
					GetPVarString(playerid,f("dps%d-code"),tmp,sizeof(tmp));
					if(!equal(tmp,castcode) || GetPVarInt(playerid,f("dps%d-eff")) != e) continue;
					id = i;
				}
				if(id != -1)
				{
					PlayerInfo[playerid][pDPS][id] = 0;
					DeletePVar(playerid,f("dps%d-dmg",id));
					DeletePVar(playerid,f("dps%d-type",id));
					DeletePVar(playerid,f("dps%d-times",id));
					DeletePVar(playerid,f("dps%d-code",id));
					DeletePVar(playerid,f("dps%d-eff",id));
				}
			}
			case peHeal:
			{
				new id = -1;
				for(new i = 0; i < MAX_EFFECTS_PER_TIME && id == -1; i++) if(PlayerInfo[playerid][pHOT][i] > 0)
				{
					GetPVarString(playerid,f("hot%d-code"),tmp,sizeof(tmp));
					if(!equal(tmp,castcode) || GetPVarInt(playerid,f("hot%d-eff")) != e) continue;
					id = i;
				}
				if(id != -1)
				{
					PlayerInfo[playerid][pHOT][id] = 0;
					DeletePVar(playerid,f("hot%d-heal",id));
					DeletePVar(playerid,f("hot%d-code",id));
					DeletePVar(playerid,f("hot%d-eff",id));
				}
			}
			case peSummon: break;
			case peClone: break; // handled in npcs.pwn
			case peKnockback: break;
			case peCrowdControl:
			{
				if(PlayerInfo[playerid][pCrowdControl][0] > 0 || PlayerInfo[playerid][pCrowdControl][1] > 0)
				{
					PlayerInfo[playerid][pCrowdControl] = {0,0};
					CancelCCEffect(playerid);
				}
			}
			case peTransform:
			{
				SendClientMessage(playerid,-1,"Untrans 1");
				chars_Set(playerid,PlayerInfo[playerid][pOriginalCharacter],.ingame = true);
				SendClientMessage(playerid,-1,"Untrans 2");
				new details[2];
				SendClientMessage(playerid,-1,"Untrans 3");
				power_FindDetails(playerid,pidx,details[0],details[1]);
				SendClientMessage(playerid,-1,"Untrans 4");
				cooldown_Start(playerid,details[0],details[1]);
				SendClientMessage(playerid,-1,"Untrans 5");
			}
			case peBuff, peDebuff:
			{
				new id = -1;
				for(new i = 0; i < MAX_BUFFS_PER_PLAYER && id == -1; i++) if(PlayerInfo[playerid][pBuff][i] > 0)
				{
					GetPVarString(playerid,f("buff%d-code"),tmp,sizeof(tmp));
					if(!equal(tmp,castcode) || GetPVarInt(playerid,f("buff%d-eff")) != e) continue;
					id = i;
				}
				if(id != -1)
				{
					PlayerInfo[playerid][pBuff][id] = 0, PlayerInfo[playerid][pBuffType][id] = false;
					DeletePVar(playerid,f("buff%d-type",id));
					DeletePVar(playerid,f("buff%d-param",id));
					DeletePVar(playerid,f("buff%d-amount",id));
					DeletePVar(playerid,f("buff%d-key",id));
					DeletePVar(playerid,f("buff%d-desc",id));
					DeletePVar(playerid,f("buff%d-code",id));
					DeletePVar(playerid,f("buff%d-eff",id));
				}
			}
			case peAura: break;
			case peSilence: PlayerInfo[playerid][pSilence][powerparams[0]] = false;
			case peBasicAttack:
			{
				for(new i = 0; i < 4; i++) PlayerInfo[playerid][pBasicAttack][i] = 0;
				PlayerInfo[playerid][pBasicAttackCode][0] = EOS;
			}
			case peProjectile: break;
		}
		if(GetPVarType(playerid,f("effectduration-%d-%s",e,castcode)) != PLAYER_VARTYPE_NONE) DeletePVar(playerid,fstring);
	}
	new c = 0;
	for(new e = 1; e <= MAX_POWER_EFFECTS; e++) if(GetPVarType(playerid,f("effectduration-%d-%s",e,castcode)) != PLAYER_VARTYPE_NONE) c++;
	if(!c && GetPVarType(playerid,f("affected-%s",castcode)) != PLAYER_VARTYPE_NONE) DeletePVar(playerid,fstring);
	if(effect_IsDone(castcode)) effect_End(castcode);
}
@f(_,effect.End(castcode[]))
{
	SendClientMessageToAll(-1,f("DEBUG - Castcode %s - END",castcode));
	f("affected-%s",castcode);
	Loop(player,i) if(GetPVarType(i,fstring) != PLAYER_VARTYPE_NONE) effect_Deactivate(i,castcode);
	power_Script(property_IntGet(f("%s-caster",castcode)),PowerInfo[property_IntGet(f("%s-[power",castcode))][pwCode],"end");
	property_IntRemove(f("%s-caster",castcode));
	property_IntRemove(f("%s-power",castcode));
	for(new i = 1, eid = -1; i <= MAX_POWER_EFFECTS; i++)
	{
		eid = property_IntGet(f("%s-e%d-id",castcode,i));
		property_IntRemove(f("%s-e%d-id",castcode,i));
		for(new pr = 0; pr < PowerEffectCodes[eid][pfParams] && pr < MAX_POWER_EFFECT_PARAMS; pr++) property_IntRemove(f("%s-e%d-param%d",castcode,i,pr));
		property_IntRemove(f("%s-e%d-affect",castcode,i));
		property_IntRemove(f("%s-e%d-duration",castcode,i));
	}
	list_RemoveValue(collections[LIST_CASTCODES],strval((strdel(castcode,0,strlen(castkeyword)), castcode)));
}
// Cooldown
@f(_,cooldown.Tick(playerid))
{
	new bool:cd = false;
	for(new i = 1; i <= MAX_POWER_CATEGORIES; i++) if(PlayerInfo[playerid][pCooldown][i-1] > 0)
	{
		PlayerInfo[playerid][pCooldown][i-1]--;
		if(!cd) cd = true;
		if(!PlayerInfo[playerid][pCooldown][i-1]) ptd_Hide(playerid,e_PlayerTD:ptd_powers,2,i);
	}
	if(cd) ptd_Update(playerid,e_PlayerTD:ptd_powers,"cd");
}
@f(_,cooldown.Reset(playerid,cat))
{
	PlayerInfo[playerid][pCooldown][cat-1] = 0;
	ptd_Update(playerid,e_PlayerTD:ptd_powers,"cd");
}
@f(_,cooldown.ResetAll(playerid))
{
	for(new i = 0; i < MAX_POWER_CATEGORIES; i++) PlayerInfo[playerid][pCooldown][i] = 0;
	ptd_Update(playerid,e_PlayerTD:ptd_powers,"cd");
}
@f(_,cooldown.TimeLeft(playerid,cat)) return PlayerInfo[playerid][pCooldown][cat-1];
@f(_,cooldown.Start(playerid,cat,pid))
{
	PlayerInfo[playerid][pCooldown][cat-1] = GetPVarInt(playerid,power_Var(cat,pid,"cd"));
	ptd_Update(playerid,e_PlayerTD:ptd_powers,"cd");
	ptd_Show(playerid,e_PlayerTD:ptd_powers,2,cat);
}
@f(_,cooldown.Reduce(playerid,cat,seconds))
{
	PlayerInfo[playerid][pCooldown][cat-1] = max(PlayerInfo[playerid][pCooldown][cat-1]-seconds,1);
	ptd_Update(playerid,e_PlayerTD:ptd_powers,"cd");
	ptd_Hide(playerid,e_PlayerTD:ptd_powers,2,cat);
}
@f(_,cooldown.Save(playerid)) for(new i = 0; i < MAX_POWER_CATEGORIES; i++) PlayerInfo[playerid][pSavedCooldown][i] = PlayerInfo[playerid][pCooldown][i];
@f(_,cooldown.Load(playerid)) for(new i = 0; i < MAX_POWER_CATEGORIES; i++) PlayerInfo[playerid][pCooldown][i] = PlayerInfo[playerid][pSavedCooldown][i], PlayerInfo[playerid][pSavedCooldown][i] = 0;
// Buffs
@f(_,buff.Set(playerid,type,param,amount,time,bool:multiple,key[],desc[],eff))
{
	new b = -1;
	if(!multiple) b = buff_Find(playerid,key);
	for(new i = 0; i < MAX_BUFFS_PER_PLAYER && b == -1; i++) if(!PlayerInfo[playerid][pBuff]) b = i;
	if(b != -1)
	{
		PlayerInfo[playerid][pBuff][b] = time, PlayerInfo[playerid][pBuffType][b] = amount > 0;
		SetPVarInt(playerid,f("buff%d-type",b),type);
		SetPVarInt(playerid,f("buff%d-param",b),param);
		SetPVarInt(playerid,f("buff%d-amount",b),amount);
		SetPVarString(playerid,f("buff%d-key",b),key);
		if(str_startswith(desc,#castkeyword))
		{
			new buffdesc[64];
			format(buffdesc,sizeof(buffdesc),"%s by %s",PowerInfo[property_IntGet(f("%s-power",desc))][pwName],player_GetName(property_IntGet(f("%s-caster",desc))));
			SetPVarString(playerid,f("buff%d-desc",b),buffdesc);
			SetPVarString(playerid,f("buff%d-code",b),desc);
			SetPVarInt(playerid,f("buff%d-eff",b),eff);
		}
		ptd_Update(playerid,e_PlayerTD:ptd_powers);
	}
}
@f(bool,buff.GetType(playerid,buffindex)) return PlayerInfo[playerid][pBuffType][buffindex];
@f(bool,buff.Remove(playerid,buffindex))
{
	PlayerInfo[playerid][pBuff][buffindex] = 0;
	PlayerInfo[playerid][pBuffType][buffindex] = false;
	DeletePVar(playerid,f("buff%d-type",buffindex));
	DeletePVar(playerid,f("buff%d-param",buffindex));
	DeletePVar(playerid,f("buff%d-amount",buffindex));
	DeletePVar(playerid,f("buff%d-key",buffindex));
	DeletePVar(playerid,f("buff%d-desc",buffindex));
	DeletePVar(playerid,f("buff%d-code",buffindex));
	DeletePVar(playerid,f("buff%d-eff",buffindex));
}
@f(_,buff.Find(playerid,key[]))
{
	for(new i = 0, key_[32]; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[playerid][pBuff] > 0)
	{
		GetPVarString(playerid,f("buff%d-key",i),key_,sizeof(key_));
		if(equal(key_,key)) return i;
	}
	return -1;
}
@f(_,buff.Tick(playerid))
{
	for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[playerid][pBuff][i] > 0)
	{
		PlayerInfo[playerid][pBuff][i]--;
		if(!PlayerInfo[playerid][pBuff][i]) buff_Remove(playerid,i);
	}
}
@f(_,buff.ResetAll(playerid)) for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[playerid][pBuff][i] > 0) buff_Remove(playerid,i);
@f(e_BuffType,buff.GetTypeFromID(id))
{
	new e_BuffType:ret = e_BuffType:buff_none;
	switch(id)
	{
		case 1: ret = e_BuffType:buff_stats;
		case 2: ret = e_BuffType:buff_damage;
		case 3: ret = e_BuffType:buff_protection;
		case 4: ret = e_BuffType:buff_lowerstats;
	}
	return ret;
}
