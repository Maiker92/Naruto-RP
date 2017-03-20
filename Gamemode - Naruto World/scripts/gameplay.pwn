// Anime Fantasy: Naruto World #07 script: gameplay
#define function<%1> forward gameplay_%1; public gameplay_%1
function<OnGameModeInit()>
{
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	SetPlayerHUD(playerid,false);
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	// Spawn Info
	player_SetPosition(playerid,PlayerInfo[playerid][pSpawnPos][0],PlayerInfo[playerid][pSpawnPos][1],PlayerInfo[playerid][pSpawnPos][2]);
	player_SetAngle(playerid,PlayerInfo[playerid][pSpawnPos][3]);
	vworld_Set(playerid,VW_WORLD);
 	SetPlayerInterior(playerid,0);
	skin_Set(playerid,CharacterInfo[PlayerInfo[playerid][pCharacter]][cSkin]);
	teams_ApplyFriendlyFire(playerid);
	// Health Setup
	SetPlayerHealth(playerid,100000.0);
	PlayerInfo[playerid][pDied] = false;
	health_Set(playerid,stats_GetStats(playerid,stats_health));
	// Loading
	if(PlayerInfo[playerid][pLoading][0] != LOADING_END2) gameplay_Load(playerid);
	// Camera Setup
	SetPlayerCameraDistance(playerid,DEFAULT_CAMERA_DISTANCE);
	camera_Reset(playerid);
	// Toggle Infinite Run
	SetPlayerInfiniteRun(playerid,1);
	// Toggle Super Jump (so player won't be 'hurt' when landing)
	SetPlayerSuperJump(playerid,1);
	return 1;
}
function<OnPlayerTakeDamage(playerid,issuerid,Float:amount,weaponid)>
{
	// Taijutsu (Basic Attack)
	if(!weaponid && issuerid != INVALID_PLAYER_ID) basicattack_Perform(issuerid,playerid);
	return 1;
}
function<OnPlayerAction(playerid,actionid)>
{
	player_GetPosition(playerid);
	switch(actionid)
	{
		case ACTION_JUMP:
		{
			// Ninja Jump
			if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && /*GetPlayerJumpState(playerid) == 32 && */PlayerInfo[playerid][pStatus] == e_PlayerStatus:player_status_playing)
			{
				new Float:height = (PlayerInfo[playerid][pModifiedJump] == -999.0 ? stats_GetStats(playerid,stats_jump) : PlayerInfo[playerid][pModifiedJump]);
				//new Float:v[3];
				//GetPlayerVelocity(playerid,v[0],v[1],v[2]);
				//SetPlayerVelocity(playerid,v[0],v[1],v[2] + height);
				player_GetPosition(playerid);
				sound_PlayEffect3D(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],e_SoundEffects:snd_jump,playerid);
				SetPlayerGravity(playerid,WORLD_GRAVITY - math_safefloatdiv(height,1000.0));
				PlayerInfo[playerid][pJumpGravityModify] = 20; // In case we have no report of any ACTION_LAND...
			}
		}
		case ACTION_LAND:
		{
			// Landing Sound
			SetPlayerGravity(playerid,WORLD_GRAVITY);
			PlayerInfo[playerid][pJumpGravityModify] = 0;
			player_GetPosition(playerid);
			sound_PlayEffect3D(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],e_SoundEffects:snd_land,playerid);
		}
		case ACTION_FALL:
		{
			// Falling from jump
			//SetPlayerGravity(playerid,WORLD_GRAVITY); modified with pJumpGravityModify
		}
	}
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_quarsec))
	{
		// Linux Spawn Shit
		if(!IsPlayerInRangeOfPoint(playerid,3.0,PlayerInfo[playerid][pSpawnPos][0],PlayerInfo[playerid][pSpawnPos][1],PlayerInfo[playerid][pSpawnPos][2]) && /*PlayerInfo[playerid][pSpawned] && */PlayerInfo[playerid][pLoading][0] != LOADING_NONE && PlayerInfo[playerid][pLoading][0] != LOADING_END2)
		{
			player_SetPosition(playerid,PlayerInfo[playerid][pSpawnPos][0],PlayerInfo[playerid][pSpawnPos][1],PlayerInfo[playerid][pSpawnPos][2]);
			player_SetAngle(playerid,PlayerInfo[playerid][pSpawnPos][3]);
			camera_Reset(playerid);
		}
		// Loading
		if(PlayerInfo[playerid][pCharacter] == INVALID_CHARACTER || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 1;
		if(PlayerInfo[playerid][pLoading][0] != LOADING_NONE && PlayerInfo[playerid][pLoading][0] != LOADING_END2)
		{
			new bool:cont = false;
			switch(PlayerInfo[playerid][pLoading][0])
			{
				case LOADING_START:
				{
					chat_Send(playerid,CC_CHAT_NOTICE,"Please wait while we're loading a few features for you.");
					ptd_Show(playerid,e_PlayerTD:ptd_loading);
					cont = true;
				}
				case LOADING_OBJECTS:
				{
					const time = 3;
					if(!PlayerInfo[playerid][pLoading][1])
					{
						PlayerInfo[playerid][pLoading][1] = time+1;
						chat_System(playerid,CC_SYSTEM_LOADING,"Loading objects. This gonna take a few seconds...");
					}
					else if(PlayerInfo[playerid][pLoading][1] == 1) cont = true, PlayerInfo[playerid][pLoading][1] = 0;
					else
					{
						PlayerInfo[playerid][pLoading][1]--;
						Streamer_Update(playerid);
					}
				}
				case LOADING_SECURITY:
				{
					chat_System(playerid,CC_SYSTEM_LOADING,"Checking some security issues.");
					cont = true;
				}
				case LOADING_POWERS:
				{
					chat_System(playerid,CC_SYSTEM_LOADING,"Loading player powers.");
					power_UpdatePowers(playerid,18); //PlayerInfo[playerid][pCharacter]);
					cont = true;
				}
				case LOADING_TEXTDRAWS:
				{
					new e_PlayerTD:ptds[] = {ptd_stats,ptd_powers,ptd_items}, e_GlobalTD:gtds[] = {gtd_menu};
					if(!PlayerInfo[playerid][pLoading][1])
					{
						PlayerInfo[playerid][pLoading][1] = 1;
						chat_System(playerid,CC_SYSTEM_LOADING,"Loading screen drawings.");
					}
					else if(PlayerInfo[playerid][pLoading][1] == sizeof(ptds)+sizeof(gtds)+1) cont = true, PlayerInfo[playerid][pLoading][1] = 0;
					else
					{
						if(PlayerInfo[playerid][pLoading][1] >= 1 && PlayerInfo[playerid][pLoading][1] <= sizeof(ptds))
						{
							ptd_Update(playerid,ptds[PlayerInfo[playerid][pLoading][1]-1]);
							ptd_Show(playerid,ptds[PlayerInfo[playerid][pLoading][1]-1]);
						}
						else if(PlayerInfo[playerid][pLoading][1] >= sizeof(ptds)+1 && PlayerInfo[playerid][pLoading][1] <= sizeof(ptds)+sizeof(gtds)) gtd_Show(playerid,gtds[PlayerInfo[playerid][pLoading][1]-sizeof(ptds)-1]);
						PlayerInfo[playerid][pLoading][1]++;
					}
				}
				case LOADING_ANIMATIONS:
				{
					if(!PlayerInfo[playerid][pLoadedAnimations])
					{
						new animlibs[][16] = {"BOMBER","RAPPING","SHOP","BEACH","SMOKING","FOOD","ON_LOOKERS","DEALER","CRACK","CARRY","COP_AMBIENT","PARK","INT_HOUSE","FOOD","PED","KISSING"};
						for(new i = 0; i < sizeof(animlibs); i++) anim_Load(playerid,animlibs[i]);
						PlayerInfo[playerid][pLoadedAnimations] = true;
					}
					chat_System(playerid,CC_SYSTEM_LOADING,"Loading player animations.");
					cont = true;
				}
				case LOADING_END:
				{
					chat_System(playerid,CC_SYSTEM_LOADING,"You've done loading. Have fun! :)");
					player_Freeze(playerid,false);
					PlayerInfo[playerid][pLoading] = {LOADING_END2,0};
					ptd_Hide(playerid,e_PlayerTD:ptd_loading);
					cont = false;
				}
			}
			if(cont)
			{
				PlayerInfo[playerid][pLoading][0]++;
				ptd_Update(playerid,e_PlayerTD:ptd_loading);
			}
		}
		else
		{
			if(timer_MeetsTimeUnit(interval,timeunit_second))
			{
				// Regenerating health & chakra
				if(PlayerInfo[playerid][pHealth] < stats_GetStats(playerid,stats_health) && !PlayerInfo[playerid][pUnderAttack]) health_Add(playerid,stats_GetStats(playerid,stats_healthreg));
				if(PlayerInfo[playerid][pChakra] < stats_GetStats(playerid,stats_chakra)) chakra_Add(playerid,stats_GetStats(playerid,stats_chakrareg));
				// Under attack check
				if(PlayerInfo[playerid][pUnderAttack] > 0) PlayerInfo[playerid][pUnderAttack]--;
				// Built-in health
				if(!PlayerInfo[playerid][pDied]) SetPlayerHealth(playerid,100000.0);
				// Scoreboard
				SetPlayerScore(playerid,level_Get(playerid));
				// Camera fix
				//if(GetPlayerCamera1Distance(playerid) != DEFAULT_CAMERA_DISTANCE) SetPlayerCameraDistance(playerid,DEFAULT_CAMERA_DISTANCE);
			}
		}
		// Jump Update
		if(PlayerInfo[playerid][pJumpGravityModify] > 0)
		{
			PlayerInfo[playerid][pJumpGravityModify]--;
			if(!PlayerInfo[playerid][pJumpGravityModify]) SetPlayerGravity(playerid,WORLD_GRAVITY);
		}
	}
	return 1;
}
#undef function
// Gameplay
@f(_,gameplay.Load(playerid))
{
	player_Freeze(playerid);
	PlayerInfo[playerid][pLoading] = {LOADING_START,0};
}
// Stats
@f(_,stats.GetSpeciality(id,bool = false,bool:amount = true))
{
	if(amount)
	{
		new n = 0;
		switch(CharacterInfo[!bool ? id : PlayerInfo[id][pCharacter]][cSpc])
		{
			case 1: n = CharacterInfo[!bool ? id : PlayerInfo[id][pCharacter]][cStr];
			case 2: n = CharacterInfo[!bool ? id : PlayerInfo[id][pCharacter]][cAgi];
			case 3: n = CharacterInfo[!bool ? id : PlayerInfo[id][pCharacter]][cInt];
		}
		return n;
	}
	else return CharacterInfo[!bool ? id : PlayerInfo[id][pCharacter]][cSpc];
}
@f(_,stats.GetStr(playerid))
{
	// Basic stats
	new n = CharacterInfo[PlayerInfo[playerid][pCharacter]][cStr];
	// Items
	n += 0;
	// Buffs
	for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[playerid][pBuff][i] > 0) if(buff_GetTypeFromID(GetPVarInt(playerid,f("buff%d-type",i))) == e_BuffType:buff_lowerstats && GetPVarInt(playerid,f("buff%d-param",i)) == 1) n += float(GetPVarInt(playerid,f("buff%d-amount",i)));
	// Auras
	n += 0;
	// Passive Powers
	n += 0;
	return n;
}
@f(_,stats.GetAgi(playerid))
{
	// Basic stats
	new n = CharacterInfo[PlayerInfo[playerid][pCharacter]][cAgi];
	// Items
	n += 0;
	// Buffs
	for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[playerid][pBuff][i] > 0) if(buff_GetTypeFromID(GetPVarInt(playerid,f("buff%d-type",i))) == e_BuffType:buff_lowerstats && GetPVarInt(playerid,f("buff%d-param",i)) == 2) n += float(GetPVarInt(playerid,f("buff%d-amount",i)));
	// Auras
	n += 0;
	// Passive Powers
	n += 0;
	return n;
}
@f(_,stats.GetInt(playerid))
{
	// Basic stats
	new n = CharacterInfo[PlayerInfo[playerid][pCharacter]][cInt];
	// Items
	n += 0;
	// Buffs
	for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[playerid][pBuff][i] > 0) if(buff_GetTypeFromID(GetPVarInt(playerid,f("buff%d-type",i))) == e_BuffType:buff_lowerstats && GetPVarInt(playerid,f("buff%d-param",i)) == 3) n += float(GetPVarInt(playerid,f("buff%d-amount",i)));
	// Auras
	n += 0;
	// Passive Powers
	n += 0;
	return n;
}
@f(Float,stats.GetStats(id,e_Stats:type,ret = 1,bool:isPlayer = true))
{
	// Basic stats
	new Float:base = stats_GetBase(type,stats_GetSpeciality(id,isPlayer,false)),
		Float:basic = stats_GetBasic(id,type,isPlayer) * stats_GetPoints(type),
		Float:lvl = isPlayer ? (min(0,level_Get(id)-1) * floatmul(stats_GetPoints(type),2.0)) : 0.0,
		Float:add = 0.0,
		Float:cap = stats_GetCap(type);
	// Additions
	if(isPlayer)
	{
		// Items
		add += 0.0;
		// Buffs
		for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[id][pBuff][i] > 0) if(buff_GetTypeFromID(GetPVarInt(id,f("buff%d-type",i))) == e_BuffType:buff_stats && stats_GetStatsType(GetPVarInt(id,f("buff%d-param",i))) == type) add += float(GetPVarInt(id,f("buff%d-amount",i)));
		// Aura
		add += 0.0;
		// Passive Powers
		add += 0.0;
	}
	// Result
	new Float:sum = (base + basic + lvl + add);
	switch(ret)
	{
		case 1: /* total */ return cap == 0.0 ? sum : math_min(sum,cap);
		case 2: /* basic */ return basic;
		case 3: /* addition */ return add;
		case 4: /* cap (max.) */ return cap;
		case 5: /* base */ return base;
		case 6: /* level */ return lvl;
	}
	return 0.0;
}
@f(Float,stats.GetCap(e_Stats:type))
{
	new Float:cap = 0.0;
	switch(type)
	{
	 	case stats_health: cap = 4000.0;
		case stats_healthreg: cap = 7.0;
		case stats_chakra: cap = 3000.0;
		case stats_chakrareg: cap = 12.0;
		case stats_movespeed: cap = 10.0;
		case stats_attackspeed: cap = 150.0;
		case stats_jump: cap = 20.0;
		case stats_evasion: cap = 20.0;
		case stats_critical: cap = 80.0;
		case stats_cooldown: cap = 25.0;
		case stats_lifesteal: cap = 50.0;
		case stats_vision: cap = PLAYER_DEFAULT_VISION;
		case stats_basicattack: cap = 0.0;
		case stats_hearing: cap = PLAYER_DEFAULT_HEARING;
		case stats_noise: cap = PLAYER_DEFAULT_NOISE;
	}
	return cap;
}
@f(Float,stats.GetBase(e_Stats:type,speciality))
{
	new Float:base = 0.0;
	switch(type)
	{
	 	case stats_health: switch(speciality)
	 	{
		 	case 1: base = 400.0;
		 	case 2: base = 350.0;
		 	case 3: base = 300.0;
	 	}
		case stats_healthreg: switch(speciality)
	 	{
		 	case 1: base = 2.00;
		 	case 2: base = 1.40;
		 	case 3: base = 1.45;
	 	}
		case stats_chakra: switch(speciality)
	 	{
		 	case 1: base = 200.0;
		 	case 2: base = 230.0;
		 	case 3: base = 300.0;
	 	}
		case stats_chakrareg: switch(speciality)
	 	{
		 	case 1: base = 1.00;
		 	case 2: base = 1.50;
		 	case 3: base = 1.80;
	 	}
		case stats_movespeed: switch(speciality)
	 	{
		 	case 1: base = 2.10;
		 	case 2: base = 2.00;
		 	case 3: base = 2.00;
	 	}
		case stats_attackspeed: switch(speciality)
	 	{
		 	case 1: base = 0.95;
		 	case 2: base = 1.00;
		 	case 3: base = 0.85;
	 	}
		case stats_jump: switch(speciality)
	 	{
		 	case 1: base = 1.80;
		 	case 2: base = 2.00;
		 	case 3: base = 1.80;
	 	}
		case stats_evasion: base = 0.0;
		case stats_critical: base = 0.0;
		case stats_cooldown: base = 0.0;
		case stats_lifesteal: base = 0.0;
		case stats_vision: base = PLAYER_DEFAULT_VISION;
		case stats_basicattack: switch(speciality)
		{
			case 1: base = 24.0;
			case 2: base = 27.00;
			case 3: base = 16.00;
		}
		case stats_hearing: base = PLAYER_DEFAULT_HEARING;
		case stats_noise: base = PLAYER_DEFAULT_NOISE;
	}
	return base;
}
@f(Float,stats.GetPoints(e_Stats:type))
{
	new Float:points = 0.0;
	switch(type)
	{
	 	case stats_health: points = 25.0;
		case stats_healthreg: points = 0.13;
		case stats_chakra: points = 18.0;
		case stats_chakrareg: points = 0.16;
		case stats_movespeed: points = 0.01;
		case stats_attackspeed: points = 0.009;
		case stats_jump: points = 0.05;
		case stats_evasion: points = 0.0;
		case stats_critical: points = 0.0;
		case stats_cooldown: points = 0.0;
		case stats_lifesteal: points = 0.0;
		case stats_vision: points = 0.0;
		case stats_basicattack: points = 1.04;
		case stats_hearing: points = 0.0;
		case stats_noise: points = 0.0;
	}
	return points;
}
@f(Float,stats.GetBasic(id,e_Stats:type,bool:isPlayer = true))
{
	new Float:basic = 0.0;
	switch(type)
	{
	 	case stats_health: basic = (isPlayer ? stats_GetStr(id) : CharacterInfo[id][cStr]);
		case stats_healthreg: basic = (isPlayer ? stats_GetStr(id) : CharacterInfo[id][cStr]);
		case stats_chakra: basic = (isPlayer ? stats_GetInt(id) : CharacterInfo[id][cInt]);
		case stats_chakrareg: basic = (isPlayer ? stats_GetInt(id) : CharacterInfo[id][cInt]);
		case stats_movespeed: basic = (isPlayer ? stats_GetAgi(id) : CharacterInfo[id][cAgi]);
		case stats_attackspeed: basic = (isPlayer ? stats_GetAgi(id) : CharacterInfo[id][cAgi]);
		case stats_jump: basic = (isPlayer ? stats_GetAgi(id) : CharacterInfo[id][cAgi]);
		case stats_evasion: basic = 0.0;
		case stats_critical: basic = 0.0;
		case stats_cooldown: basic = 0.0;
		case stats_lifesteal: basic = 0.0;
		case stats_vision: basic = 0.0;
		case stats_basicattack: basic = stats_GetSpeciality(id,isPlayer);
		case stats_hearing: basic = 0.0;
		case stats_noise: basic = 0.0;
	}
	return basic;
}
@f(Float,stats.GetDamage(playerid,e_Damage:type,ret = 1))
{
	// Basic stats
	new Float:basic = 0.0, Float:add = 0.0, Float:cap = stats_GetDamageCap(type,false);
	switch(type)
	{
	 	case damage_taijutsu: basic = 0.0;
		case damage_ninjutsu: basic = 0.0;
		case damage_genjutsu: basic = 0.0;
		case damage_true: basic = 0.0;
	}
	// Items
	add += 0.0;
	// Buffs
	for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[playerid][pBuff][i] > 0) if(buff_GetTypeFromID(GetPVarInt(playerid,f("buff%d-type",i))) == e_BuffType:buff_damage && stats_GetDamageType(GetPVarInt(playerid,f("buff%d-param",i))) == type) add += float(GetPVarInt(playerid,f("buff%d-amount",i)));
	// Aura
	add += 0.0;
	// Passive Powers
	add += 0.0;
	// Result
	switch(ret)
	{
		case 1: /* total */ return cap == 0.0 ? (basic + add) : math_min((basic + add),cap);
		case 2: /* basic */ return basic;
		case 3: /* addition */ return add;
		case 4: /* cap (max.) */ return cap;
	}
	return 0.0;
}
@f(Float,stats.GetProtection(playerid,e_Damage:type,ret = 1))
{
	// Basic stats
	new Float:basic = 0.0, Float:add = 0.0, Float:cap = stats_GetDamageCap(type,true);
	switch(type)
	{
	 	case damage_taijutsu: basic = floatmul(stats_GetAgi(playerid),0.33);
		case damage_ninjutsu: basic = 0.0;
		case damage_genjutsu: basic = 0.0;
		case damage_true: basic = 0.0;
	}
	// Items
	add += 0.0;
	// Buffs
	for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++) if(PlayerInfo[playerid][pBuff][i] > 0) if(buff_GetTypeFromID(GetPVarInt(playerid,f("buff%d-type",i))) == e_BuffType:buff_protection && stats_GetDamageType(GetPVarInt(playerid,f("buff%d-param",i))) == type) add += float(GetPVarInt(playerid,f("buff%d-amount",i)));
	// Aura
	add += 0.0;
	// Passive Powers
	add += 0.0;
	// Result
	switch(ret)
	{
		case 1: /* total */ return cap == 0.0 ? (basic + add) : math_min((basic + add),cap);
		case 2: /* basic */ return basic;
		case 3: /* addition */ return add;
		case 4: /* cap (max.) */ return cap;
	}
	return 0.0;
}
@f(Float,stats.GetDamageCap(e_Damage:type,bool:protection))
{
	new Float:cap = 0.0;
	if(!protection) switch(type)
	{
	 	case damage_taijutsu: cap = 200.0;
		case damage_ninjutsu: cap = 600.0;
		case damage_genjutsu: cap = 600.0;
		case damage_true: cap = 0.0;
	}
	else switch(type)
	{
	 	case damage_taijutsu: cap = 250.0;
		case damage_ninjutsu: cap = 250.0;
		case damage_genjutsu: cap = 250.0;
		case damage_true: cap = 0.0;
	}
	return cap;
}
@f(_,stats.GetAvatar(id,bool:isPlayer = true))
{
	new av[MAX_NAME_LENGTH];
	return format(av,sizeof(av),"avatar:%s",CharacterInfo[isPlayer ? PlayerInfo[id][pCharacter] : id][cAvatar]), av;
}
@f(e_Stats,stats.GetStatsType(num))
{
	switch(num)
	{
		case 1: return stats_health;
		case 2: return stats_healthreg;
		case 3: return stats_chakra;
		case 4: return stats_chakrareg;
		case 5: return stats_movespeed;
		case 6: return stats_attackspeed;
		case 7: return stats_jump;
		case 8: return stats_evasion;
		case 9: return stats_critical;
		case 10: return stats_cooldown;
		case 11: return stats_lifesteal;
		case 12: return stats_vision;
		case 13: return stats_basicattack;
		case 14: return stats_hearing;
		case 15: return stats_noise;
	}
	return stats_none;
}
@f(e_Damage,stats.GetDamageType(num))
{
	switch(num)
	{
		case 1: return damage_taijutsu;
		case 2: return damage_ninjutsu;
		case 3: return damage_genjutsu;
		case 4: return damage_true;
	}
	return damage_none;
}
@f(_,stats.GetCount(num))
{
	switch(num)
	{
		case 1: /* stats */ return 13;
		case 2: /* damage */ return 4;
		case 3: /* protection */ return 3;
	}
	return 0;
}
@f(_,stats.StatsTypeAsString(e_Stats:type))
{
	new tmp[32];
	switch(type)
	{
		case stats_health: tmp = "Max Health";
		case stats_healthreg: tmp = "Health Regeneration";
		case stats_chakra: tmp = "Max Chakra";
		case stats_chakrareg: tmp = "Chakra Regeneration";
		case stats_movespeed: tmp = "Movement Speed";
		case stats_attackspeed: tmp = "Attack Speed";
		case stats_jump: tmp = "Jump Height";
		case stats_evasion: tmp = "Evasion";
		case stats_critical: tmp = "Critical Hit Chance";
		case stats_cooldown: tmp = "Cooldown Reduction";
		case stats_lifesteal: tmp = "Lifesteal";
		case stats_vision: tmp = "Vision";
		case stats_basicattack: tmp = "Basic Attack";
		case stats_hearing: tmp = "Hearing";
		case stats_noise: tmp = "Noise";
	}
	return tmp;
}
@f(_,stats.DamageTypeAsString(e_Damage:type))
{
	new tmp[16];
	switch(type)
	{
		case damage_taijutsu: tmp = "Taijutsu";
		case damage_ninjutsu: tmp = "Ninjutsu";
		case damage_genjutsu: tmp = "Genjutsu";
		case damage_true: tmp = "True";
	}
	return tmp;
}
@f(_,stats.SpecialityIntAsString(type))
{
	new tmp[16];
	switch(type)
	{
		case 1: tmp = "STR";
		case 2: tmp = "AGI";
		case 3: tmp = "INT";
	}
	return tmp;
}
// Basic Attack
@f(Float,basicattack.GetDamage(playerid))
{
	printf("stats = %.2f",stats_GetStats(playerid,stats_basicattack));
	printf("taijutsu = %d",math_percent(20,stats_GetDamage(playerid,damage_taijutsu)));
	printf("true = %.2f",stats_GetDamage(playerid,damage_true));
	printf("%.2f",stats_GetStats(playerid,stats_basicattack) + math_percent(20.0,stats_GetDamage(playerid,damage_taijutsu)) + stats_GetDamage(playerid,damage_true));
	return stats_GetStats(playerid,stats_basicattack) + math_percent(20.0,stats_GetDamage(playerid,damage_taijutsu)) + stats_GetDamage(playerid,damage_true);
}
@f(_,basicattack.Perform(playerid,targetid))
{
	new Float:dmg, e_Damage:type;
	if(PlayerInfo[playerid][pBasicAttack][0] > 0)
	{
		// Special basic attack (granted by power)
		PlayerInfo[playerid][pBasicAttack][0]--;
		dmg = float(PlayerInfo[playerid][pBasicAttack][1]);
		type = stats_GetDamageType(PlayerInfo[playerid][pBasicAttack][2]);
		if(!PlayerInfo[playerid][pBasicAttack][0]) effect_Deactivate(playerid,PlayerInfo[playerid][pBasicAttackCode],PlayerInfo[playerid][pBasicAttack][3]);
	}
	else
	{
		// HP Regeneration Cancel
		PlayerInfo[playerid][pUnderAttack] = max(PlayerInfo[playerid][pUnderAttack]+1,3);
		// Basic Taijutsu Damage
		dmg = basicattack_GetDamage(playerid), type = e_Damage:damage_taijutsu;
		// Evasion
		if(stats_GetStats(playerid,stats_evasion) > 0 && math_random(0,floatround(stats_GetStats(playerid,stats_evasion,4))) <= floatround(stats_GetStats(playerid,stats_evasion)))
		{
			dmg = 0.0;
			nametag_SetAdditionalText(playerid,2,@c(FIGHTING_NOTES) "Miss!");
		}
		if(dmg > 0.0)
		{
			// Critical Hit
			if(stats_GetStats(playerid,stats_critical) > 0 && math_random(0,floatround(stats_GetStats(playerid,stats_critical,4))) <= floatround(stats_GetStats(playerid,stats_critical)))
			{
				dmg *= 2.0;
				nametag_SetAdditionalText(playerid,2,@c(FIGHTING_NOTES) "CRITICAL HIT");
			}
			// Lifesteal
			if(stats_GetStats(playerid,stats_lifesteal) > 0) health_Add(playerid,math_percent(stats_GetStats(playerid,stats_lifesteal),dmg));
		}
	}
	// Decrease victim health
	if(dmg > 0.0) health_Damage(targetid,dmg,type,playerid);
	// Play hit sound
	player_GetPosition(targetid);
	sound_PlayEffect3D(PlayerInfo[targetid][pPosition][0],PlayerInfo[targetid][pPosition][1],PlayerInfo[targetid][pPosition][2],e_SoundEffects:snd_hit,playerid);
}
// Health
@f(_,health.Damage(playerid,Float:dmg,e_Damage:type,issuerid = INVALID_PLAYER_ID))
{
	if(dmg <= 0.0) return;
	new Float:d = dmg;
	// Deal damage to NPCs
	if(player_IsNPC(playerid))
	{
		// NPC is being attacked
		NPCInfo[PlayerInfo[playerid][pNPCIndex]][npcUnderAttack] = 3;
		// Call the relevant event
		OnNPCTakeDamage(PlayerInfo[playerid][pNPCIndex],issuerid,0,0,dmg);
	}
	// Deal damage to players
	else
	{
		// Damage decrease based on protections
		d = health_DamageAfterMitigation(d,stats_GetProtection(playerid,type));
		new Float:mitigated = floatsub(dmg,d);
		#pragma unused mitigated
		// Decrease the health / considering death situation
		if(d > 0.0 && PlayerInfo[playerid][pHealth] > 0.0 && !PlayerInfo[playerid][pDied])
		{
			PlayerInfo[playerid][pHealth] -= d;
			if(PlayerInfo[playerid][pHealth] <= 0) health_Kill(playerid);
		}
		// Player is being attacked
		PlayerInfo[playerid][pUnderAttack] = min(PlayerInfo[playerid][pUnderAttack]+1,3);
		// Updating the health bar
		ptd_Update(playerid,e_PlayerTD:ptd_stats,"health");
		// Updating the player name tag
		if(PlayerInfo[playerid][pNameTagDetails][0]) nametag_Update(playerid);
	}
}
@f(_,health.Add(playerid,Float:hp))
{
	if(hp <= 0.0) return;
	// Heal NPCs
	if(player_IsNPC(playerid))
	{
		new npcid = PlayerInfo[playerid][pNPCIndex];
		// Increase the health
		if(NPCInfo[npcid][npcHealth] > 0.0 && NPCInfo[npcid][npcUsage] != e_NPCUsage:npcusage_none) NPCInfo[npcid][npcHealth] = math_min(NPCInfo[npcid][npcHealth] + hp,NPCInfo[npcid][npcStats][0]);
		// Updating the NPC name tag
		npctag_Update(npcid);
	}
	// Heal players
	{
		// Increase the health
		if(PlayerInfo[playerid][pHealth] > 0.0 && !PlayerInfo[playerid][pDied]) PlayerInfo[playerid][pHealth] = math_min(PlayerInfo[playerid][pHealth] + hp,stats_GetStats(playerid,stats_health));
		// Updating the health bar
		ptd_Update(playerid,e_PlayerTD:ptd_stats,"health");
		// Updating the player name tag
		if(PlayerInfo[playerid][pNameTagDetails][0]) nametag_Update(playerid);
	}
}
@f(_,health.Set(playerid,Float:hp))
{
	PlayerInfo[playerid][pHealth] = math_min(stats_GetStats(playerid,stats_health),hp);
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"health");
}
@f(_,health.Kill(playerid))
{
	if(PlayerInfo[playerid][pCharacter] != INVALID_CHARACTER)
	{
		new Float:p[4];
		teams_GetRandomSpawnPoint(chars_GetTeam(PlayerInfo[playerid][pCharacter]),p[0],p[1],p[2],p[3]);
		player_SetSpawnInfo(playerid,NO_TEAM,CharacterInfo[PlayerInfo[playerid][pCharacter]][cSkin],p[0],p[1]+WORLD_Y_OFFSET,p[2]+SPAWN_Z_OFFSET,p[3]);
	}
	PlayerInfo[playerid][pHealth] = 0.0, PlayerInfo[playerid][pDied] = true, PlayerInfo[playerid][pSpawned] = true;
	SetPlayerHealth(playerid,0.0);
	//anim_Apply(playerid,anim_death,.freeze=true,.time=1000);
	//OnPlayerDeath(playerid,issuerid,-1);
}
@f(Float,health.DamageAfterMitigation(Float:damage,Float:protection,Float:base = PROTECTION_BASE)) return math_safefloatdiv(floatmul(base,damage),floatadd(protection,base));
// Chakra
@f(_,chakra.Use(playerid,Float:chakra))
{
	// Increase the chakra
	assert chakra > 0.0;
	PlayerInfo[playerid][pChakra] = math_max(0.0,PlayerInfo[playerid][pChakra]-chakra);
	// Update the chakra bar
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"chakra");
}
@f(_,chakra.Add(playerid,Float:chakra))
{
	// Increase the chakra
	if(chakra > 0.0 && PlayerInfo[playerid][pChakra] > 0.0 && !PlayerInfo[playerid][pDied]) PlayerInfo[playerid][pChakra] = math_min(PlayerInfo[playerid][pChakra] + chakra,stats_GetStats(playerid,stats_chakra));
	// Updating the chakra bar
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"chakra");
}
@f(_,chakra.Set(playerid,Float:chakra))
{
	PlayerInfo[playerid][pChakra] = math_min(stats_GetStats(playerid,stats_chakra),chakra);
	ptd_Update(playerid,e_PlayerTD:ptd_stats,"chakra");
}
// Respect
@f(_,respect.Get(playerid))
{
	new res = 0;
	// Character base respect
	if(PlayerInfo[playerid][pCharacter] != INVALID_CHARACTER)
	{
		// Rank-based respect
		res += floatround(floatpower(2.0,rank_GetPlayerRank(playerid)));
	}
	// (Formula) Goodwill? etc...
	return min(MAX_RESPECT,res);
}
@f(_,respect.RespectfulName(playerid,from_character=INVALID_CHARACTER,bool:randomize=false))
{
	new n[64], type = 0, r;
	if(PlayerInfo[playerid][pCharacter] == INVALID_CHARACTER) return n;
	// Basic information
	format(n,sizeof(n),chars_GetFirstName(PlayerInfo[playerid][pCharacter]));
	r = rank_GetPlayerRank(playerid);
	// Rank-based title
	if(randomize && !random(2))
	{
		switch(r)
		{
			case 6:
			{
				switch(random(2))
				{
					case 0: n = "Mister";
					case 1: n = "Master";
				}
			}
			case 7: format(n,sizeof(n),TeamInfo[PlayerInfo[playerid][pTeam]][tLeader]);
			//default: format(n,sizeof(n),chars_GetFirstName(PlayerInfo[playerid][pCharacter]));
		}
	}
	switch(from_character == INVALID_CHARACTER ? 2 : CharacterInfo[from_character][cRespect])
	{
		case 1: type = r > rank_Get(from_character) ? 3 : (r < rank_Get(from_character) ? 1 : 2);
		case 2: type = r >= 6 ? 3 : 2;
	}
	if(type > 0) format(n,sizeof(n),respect_JapaneseHonorifics(n,type,CharacterInfo[PlayerInfo[playerid][pCharacter]][cGender]));
	return n;
}
@f(_,respect.JapaneseHonorifics(title[],type,gender))
{
	new n[64];
	switch(type)
	{
		case 1:
		{
			switch(random(2))
			{
				case 0: format(n,sizeof(n),"%s-kun",title);
				case 1: format(n,sizeof(n),"%s-chan",title);
			}
		}
		case 2:
		{
			switch(random(3))
			{
				case 0: format(n,sizeof(n),"%s-san",title);
				case 1: format(n,sizeof(n),"%s-senpai",title);
				case 2: format(n,sizeof(n),"Senpai");
			}
		}
		case 3:
		{
			new r = random(equal(title,"Lord") ? 3 : 4);
			switch(r)
			{
				case 0: format(n,sizeof(n),"%s-sama",title);
				case 1: format(n,sizeof(n),"%s-dono",title);
				case 2: format(n,sizeof(n),title); // do nothing! ("Hokage")
				case 3:
				{
					switch(gender)
					{
						case 1:
						{
							switch(random(2))
							{
								case 0: format(n,sizeof(n),"Lord %s",title);
								case 1: format(n,sizeof(n),"King %s",title);
							}
						}
						case 2:
						{
							switch(random(2))
							{
								case 0: format(n,sizeof(n),"Princess %s",title);
								case 1: format(n,sizeof(n),"Lady %s",title);
							}
						}
					}
				}
			}
		}
	}
	return n;
}
