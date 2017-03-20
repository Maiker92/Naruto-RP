// Anime Fantasy: Naruto World #27 script: anim
#define function<%1> forward anim_%1; public anim_%1
//#define DEBUG_ANIM // Used to print player animations on chat
function<OnGameModeInit()>
{
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerUpdate(playerid)>
{
	new i = GetPlayerAnimationIndex(playerid);
	if(i != PlayerInfo[playerid][pAnimation])
	{
		OnAnimationChanged(playerid,PlayerInfo[playerid][pAnimation],i);
		PlayerInfo[playerid][pAnimation] = i;
	}
	return 1;
}
forward OnAnimationChanged(playerid,oldanim,newanim);
public OnAnimationChanged(playerid,oldanim,newanim)
{
	if(PlayerInfo[playerid][pDebugAnimations])
	{
		new animlib[32], animname[32];
		GetAnimationName(newanim,animlib,sizeof(animlib),animname,sizeof(animname));
		chat_Send(playerid,CC_CHAT_INFO,f("[Animation Changed] %d, %s, %s",newanim,animlib,animname));
	}
	for(new i = 0; i < sizeof(PlayerActions); i++) if(newanim == PlayerActions[i][0]) OnPlayerAction(playerid,PlayerActions[i][1]);
	return 1;
}
#undef function
// Animation
@f(_,anim.Load(playerid,animlib[])) return ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
@f(_,anim.Apply(playerid,e_Animation:animation,bool:loop=false,bool:lockx=false,bool:locky=false,bool:freeze=false,time=0))
{
	new r = 0;
	if(anim_CanUse(playerid))
	{
		new animlib[32], animname[32];
		animlib = anim_GetNames(animation,true);
		animname = anim_GetNames(animation,false);
		r = ApplyAnimation(playerid,animlib,animname,4.1,_:loop,_:(!lockx),_:(!locky),_:freeze,time);
	}
	return r;
}
@f(bool,anim.CanUse(playerid)) return player_GetPositionStatus(playerid) == PS_GROUND && !PlayerInfo[playerid][pFrozen];
@f(_,anim.Clear(playerid)) return ClearAnimations(playerid);
@f(_,anim.GetNames(e_Animation:animation,bool:whichone))
{
	new animlib[32], animname[32];
	switch(animation)
	{
		case anim_death: animlib = "PED", animname = "KO_shot_front";
		case anim_chat: animlib = "PED", animname = "IDLE_CHAT";
		case anim_shout:
		{
			switch(random(3))
			{
				case 0: animlib = "ON_LOOKERS", animname = "Pointup_shout";
				case 1: animlib = "ON_LOOKERS", animname = "shout_in";
				case 2: animlib = "RIOT", animname = "RIOT_shout";
			}
		}
		case anim_dance:
		{
			animlib = "DANCING";
			switch(random(6))
			{
				case 0: animname = "DAN_LOOP_A";
				case 1: animname = "DNCE_M_A";
				case 2: animname = "DNCE_M_B";
				case 3: animname = "DNCE_M_C";
				case 4: animname = "DNCE_M_D";
				case 5: animname = "DNCE_M_E";
			}
		}
		case anim_sit:
		{
			switch(random(3))
			{
				case 0: animlib = "BEACH", animname = "ParkSit_M_loop";
				case 1: animlib = "PED", animname = "SEAT_IDLE";
				case 2: animlib = "CARRY", animname = "crry_prtial";
			}
		}
		case anim_wave:
		{
			switch(random(3))
			{
				case 0: animlib = "ON_LOOKERS", animname = "wave_in";
				case 1: animlib = "ON_LOOKERS", animname = "wave_loop";
				case 2: animlib = "ON_LOOKERS", animname = "wave_out";
			}
		}
	}
	return whichone ? (animname) : (animlib);
}
