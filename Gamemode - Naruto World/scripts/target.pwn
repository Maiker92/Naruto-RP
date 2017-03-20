// Anime Fantasy: Naruto World #25 script: target
#define function<%1> forward target_%1; public target_%1
static targeting[MAX_PLAYERS] = {INVALID_PLAYER_ID,...}, bool:cursorEnabled[MAX_PLAYERS] = {false,...};
new stock const
	Float:TARGET_HEAD = 2.0,		// Height above player head to show an arrow (for self / single target)
	Float:ROTATION_SPEED = 3.0,		// Speed of arrow rotation
	Float:UNDERGROUND_Z = -1000.0,	// Underground height where the object shouldn't be visible
	Float:POINT_RADIUS = 2.2;		// Target point radius, used to find players being targeted
function<OnGameModeInit()>
{
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	if(target_IsTargeting(playerid)) target_Stop(playerid);
	for(new i = 0; i < MAX_TARGET_OBJECTS; i++) if(object_IsValid(PlayerInfo[playerid][pTargetObject][i])) object_Destroy(PlayerInfo[playerid][pTargetObject][i]);
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	//for(new i = 0; i < MAX_TARGET_OBJECTS; i++) if(PlayerInfo[playerid][pTargetObject][i] == -1) PlayerInfo[playerid][pTargetObject][i] = object_Create(19133,0.0,0.0,-999.0,0.0,0.0,0.0,0,VW_WORLD,playerid);
	for(new i = 0; i < MAX_TARGET_OBJECTS; i++) if(PlayerInfo[playerid][pTargetObject][i] == -1) PlayerInfo[playerid][pTargetObject][i] = object_Create(19133,0.0,0.0,0.0,0.0,0.0,0.0,0,VW_OBJECTS,playerid);
	return 1;
}
function<OnPlayerDeath(playerid,killerid,reason)>
{
	if(target_IsTargeting(playerid)) target_Stop(playerid);
	return 1;
}
function<OnPlayerKeyStateChange(playerid,newkeys,oldkeys)>
{
	if(target_IsTargeting(playerid))
	{
		new e_TargetReason:tR = PlayerInfo[playerid][pTargetReason];
		if(tR != e_TargetReason:targetreason_none)
		{
			if(newkeys & KEY_FIRE)
			{
				OnPlayerTargetSelect(playerid,tR,targeting[playerid],PlayerInfo[playerid][pTargetPosition][0],PlayerInfo[playerid][pTargetPosition][1],PlayerInfo[playerid][pTargetPosition][2]);
				target_Stop(playerid);
				player_Stop(playerid);
			}
			else if(newkeys & KEY_SPRINT)
			{
				OnPlayerTargetCancel(playerid,tR);
				target_Stop(playerid);
			}
		}
	}
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(target_IsTargeting(playerid))
	{
		new e_PowerTargets:type = target_FromInt(PlayerInfo[playerid][pTargetType]);
		if(timer_MeetsTimeUnit(interval,timeunit_jiffy))
		{
			new Float:c[3], ot = PlayerInfo[playerid][pTargetObject][0], Float:spd = 0.0, Float:p[3];
			GetPlayerCameraFrontVector(playerid,c[0],c[1],c[2]);
			player_GetPosition(playerid);
			new Float:distance = floatmul(1.0 + (c[2] < 0.0 ? c[2] : 0.0),PlayerInfo[playerid][pTargetFloats][1]);
			PlayerInfo[playerid][pTargetPosition][0] = PlayerInfo[playerid][pPosition][0] + floatmul(c[0],distance),
			PlayerInfo[playerid][pTargetPosition][1] = PlayerInfo[playerid][pPosition][1] + floatmul(c[1],distance),
			PlayerInfo[playerid][pTargetPosition][2] = PlayerInfo[playerid][pPosition][2];
			spd = GetPlayerDistanceFromPoint(playerid,ObjectInfo[ot][oPos][0],ObjectInfo[ot][oPos][1],ObjectInfo[ot][oPos][2]) > PlayerInfo[playerid][pTargetFloats][1] ? 99999.0 : 75.0;
			PlayerInfo[playerid][pTargetIcon][0] += PlayerInfo[playerid][pTargetIcon][1] ? (0-5) : 5;
			if((!PlayerInfo[playerid][pTargetIcon][0] && PlayerInfo[playerid][pTargetIcon][1]) || (PlayerInfo[playerid][pTargetIcon][0] == 255 && !PlayerInfo[playerid][pTargetIcon][1])) PlayerInfo[playerid][pTargetIcon][1] = !PlayerInfo[playerid][pTargetIcon][1];
			SetPlayerMapIcon(playerid,ICON_TARGET,PlayerInfo[playerid][pTargetPosition][0],PlayerInfo[playerid][pTargetPosition][1],PlayerInfo[playerid][pTargetPosition][2],0,(PlayerInfo[playerid][pTargetIcon][0] * 16777216) + 255);
			switch(type)
			{
				case powertarget_self, powertarget_single, powertarget_point:
				{
					PlayerInfo[playerid][pTargetFloats][0] = ((PlayerInfo[playerid][pTargetFloats][0] += ROTATION_SPEED) > 360.0 ? (PlayerInfo[playerid][pTargetFloats][0] = 0.0) : PlayerInfo[playerid][pTargetFloats][0]);
					new Float:additionZ = 0.0;
					if(type == e_PowerTargets:powertarget_self)
					{
						for(new i = 0; i < 3; i++) p[i] = PlayerInfo[playerid][pPosition][i];
						additionZ = TARGET_HEAD;
					}
					else if(type == e_PowerTargets:powertarget_single)
					{
						if(timer_MeetsTimeUnit(interval,timeunit_halfsec))
						{
							new Float:closepos = POINT_RADIUS, closeplayer = INVALID_PLAYER_ID, Float:tmpdis = 0.0;
							Loop(player,i) if(playerid == i || IsPlayerStreamedIn(i,playerid))
							{
								player_GetPosition(i);
								tmpdis = math_distance_3d(PlayerInfo[playerid][pTargetPosition][0],PlayerInfo[playerid][pTargetPosition][1],PlayerInfo[playerid][pTargetPosition][2],PlayerInfo[i][pPosition][0],PlayerInfo[i][pPosition][1],PlayerInfo[i][pPosition][2]);
								if(tmpdis < closepos || (closepos == POINT_RADIUS && tmpdis <= closepos)) closepos = tmpdis, closeplayer = i;
							}
							targeting[playerid] = closeplayer; // or INVALID_PLAYER_ID? who knows!
						}
						for(new i = 0; i < 3; i++) p[i] = targeting[playerid] == INVALID_PLAYER_ID ? PlayerInfo[playerid][pTargetPosition][i] : PlayerInfo[targeting[playerid]][pPosition][i];
						if(targeting[playerid] != INVALID_PLAYER_ID) additionZ = TARGET_HEAD;
					}
					else if(type == e_PowerTargets:powertarget_point) for(new i = 0; i < 3; i++) p[i] = PlayerInfo[playerid][pTargetPosition][i];
					object_Move(ot,p[0],p[1],p[2]+additionZ,spd,0.0,0.0,PlayerInfo[playerid][pTargetFloats][0]);
				}
				case powertarget_radius, powertarget_circle:
				{
					new Float:x, Float:y, Float:angle = 360/PlayerInfo[playerid][pTargetObjects], Float:a = 0.0, Float:pitch = 0.0, Float:yaw = 0.0, Float:addition = floatdiv(angle,100.0), Float:o[3];
					PlayerInfo[playerid][pTargetFloats][0] = ((PlayerInfo[playerid][pTargetFloats][0] += addition) >= 360.0 ? (PlayerInfo[playerid][pTargetFloats][0] = 0.0) : PlayerInfo[playerid][pTargetFloats][0]);
					if(type == e_PowerTargets:powertarget_radius) for(new i = 0; i < 3; i++) p[i] = PlayerInfo[playerid][pPosition][i];
					else if(type == e_PowerTargets:powertarget_circle) for(new i = 0; i < 3; i++) p[i] = PlayerInfo[playerid][pTargetPosition][i];
					for(new i = 0; i < PlayerInfo[playerid][pTargetObjects]; i++)
					{
						x = p[0] + floatcos(a - PlayerInfo[playerid][pTargetFloats][0],degrees) * PlayerInfo[playerid][pTargetFloats][2];
						y = p[1] + floatsin(a - PlayerInfo[playerid][pTargetFloats][0],degrees) * PlayerInfo[playerid][pTargetFloats][2];
						a += angle;
						object_GetPos(PlayerInfo[playerid][pTargetObject][i],o[0],o[1],o[2]);
						pitch = floatabs(atan2(floatsqroot(floatpower(p[0] - o[0],2.0) + floatpower(p[1] - o[1],2.0)),p[2] - o[2]));
						yaw = atan2(p[1] - o[1],p[0] - o[0]) - 90.0;
						object_Move(PlayerInfo[playerid][pTargetObject][i],x,y,p[2] - 0.5,spd,0.0,pitch,yaw);
					}
				}
				case powertarget_groundline, powertarget_line:
				{
					new Float:x, Float:y, Float:z, Float:offset = floatdiv(PlayerInfo[playerid][pTargetFloats][1],PlayerInfo[playerid][pTargetObjects]), Float:of, Float:o[3];
					player_GetAngle(playerid);
					PlayerInfo[playerid][pTargetFloats][0] = PlayerInfo[playerid][pTargetFloats][0] >= offset ? 0.0 : (PlayerInfo[playerid][pTargetFloats][0] + floatdiv(offset,100.0));
					for(new i = 0; i < PlayerInfo[playerid][pTargetObjects]; i++)
					{
						object_GetPos(PlayerInfo[playerid][pTargetObject][i],o[0],o[1],o[2]);
						if(type == e_PowerTargets:powertarget_groundline)
						{
							of = ((offset * i) + floatdiv(offset,3) + PlayerInfo[playerid][pTargetFloats][0]);
							x = (of * floatsin(-PlayerInfo[playerid][pPosition][3],degrees)), y = (of * floatcos(-PlayerInfo[playerid][pPosition][3],degrees));
							object_Move(PlayerInfo[playerid][pTargetObject][i],PlayerInfo[playerid][pPosition][0] + x,PlayerInfo[playerid][pPosition][1] + y,PlayerInfo[playerid][pPosition][2] - 0.5,spd,0.0,90.0,PlayerInfo[playerid][pPosition][3] + 270.0);
						}
						else if(type == e_PowerTargets:powertarget_line)
						{
							of = (offset * i) + floatdiv(offset,3);
							x = PlayerInfo[playerid][pPosition][0] + floatmul(c[0],of), y = PlayerInfo[playerid][pPosition][1] + floatmul(c[1],of), z = PlayerInfo[playerid][pPosition][2] + floatmul(c[2],of);
							object_Move(PlayerInfo[playerid][pTargetObject][i],x,y,z < (p[2]-0.5) ? (p[2]-0.5) : z,spd,0.0,90.0,atan2(c[1],c[0]) + 180.0);
						}
					}
				}
			}
		}
	}
	return 1;
}
#undef function
// Target
@f(_,target.GetTargetedPlayer(playerid)) return targeting[playerid];
@f(_,target.Start(playerid,e_TargetReason:targetreason,e_PowerTargets:type,color,Float:range,Float:radius))
{
	if(target_IsTargeting(playerid)) target_Stop(playerid);
	new amount = 0;
	switch(type)
	{
		case powertarget_self, powertarget_single, powertarget_point: amount = 1;
		case powertarget_radius: amount = math_bonds(floatround(floatdiv(radius,1.1)),3,MAX_TARGET_OBJECTS);
		case powertarget_groundline: amount = math_bonds(floatround(floatdiv(floatdiv(range + radius,2.0),1.1)),2,MAX_TARGET_OBJECTS);
		case powertarget_line: amount = math_bonds(floatround(floatdiv(floatdiv(range + radius,2.0),1.1)),2,MAX_TARGET_OBJECTS);
		case powertarget_circle: amount = math_bonds(floatround(floatdiv(radius,1.1)),3,MAX_TARGET_OBJECTS);
		case powertarget_square: amount = 1;
		case powertarget_sphere: amount = 1;
	}
	player_GetPosition(playerid);
	PlayerInfo[playerid][pTargetReason] = targetreason, PlayerInfo[playerid][pTargetType] = target_ToInt(type), PlayerInfo[playerid][pTargetObjects] = amount;
	PlayerInfo[playerid][pTargetFloats][0] = 0.0, PlayerInfo[playerid][pTargetFloats][1] = range, PlayerInfo[playerid][pTargetFloats][2] = radius;
	for(new i = 0; i < amount; i++) if(object_IsValid(PlayerInfo[playerid][pTargetObject][i]))
	{
		Streamer_SetIntData(STREAMER_TYPE_OBJECT,PlayerInfo[playerid][pTargetObject][i],E_STREAMER_WORLD_ID,VW_WORLD);
		object_Colorize(PlayerInfo[playerid][pTargetObject][i],color);
		object_SetPos(PlayerInfo[playerid][pTargetObject][i],PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],-200.0);
	}
	if((cursorEnabled[playerid] = cursor_IsVisible(playerid))) cursor_Hide(playerid);
	Streamer_Update(playerid);
}
@f(_,target.Stop(playerid))
{
	if(target_IsTargeting(playerid))
	{
		RemovePlayerMapIcon(playerid,ICON_TARGET);
		if(cursorEnabled[playerid]) cursor_Show(playerid);
		for(new i = 0; i < PlayerInfo[playerid][pTargetObjects]; i++) if(object_IsValid(PlayerInfo[playerid][pTargetObject][i]))
		{
			Streamer_SetIntData(STREAMER_TYPE_OBJECT,PlayerInfo[playerid][pTargetObject][i],E_STREAMER_WORLD_ID,VW_OBJECTS);
			//object_SetPos(PlayerInfo[playerid][pTargetObject][i],0.0,0.0,-999.0);
		}
		PlayerInfo[playerid][pTargetReason] = e_TargetReason:targetreason_none, PlayerInfo[playerid][pTargetType] = 0, PlayerInfo[playerid][pTargetObjects] = 0;
		for(new i = 0; i < 3; i++) PlayerInfo[playerid][pTargetFloats][i] = 0.0;
		Streamer_Update(playerid);
	}
}
@f(bool,target.IsTargeting(playerid)) return PlayerInfo[playerid][pTargetType] > 0;
@f(e_PowerTargets,target.FromInt(num))
{
	switch(num)
	{
		case 1: return powertarget_self;
		case 2: return powertarget_single;
		case 3: return powertarget_radius;
		case 4: return powertarget_groundline;
		case 5: return powertarget_line;
		case 6: return powertarget_circle;
		case 7: return powertarget_square;
		case 8: return powertarget_sphere;
		case 9: return powertarget_point;
	}
	return powertarget_none;
}
@f(_,target.ToInt(e_PowerTargets:type))
{
	switch(type)
	{
		case powertarget_self: return 1;
		case powertarget_single: return 2;
		case powertarget_radius: return 3;
		case powertarget_groundline: return 4;
		case powertarget_line: return 5;
		case powertarget_circle: return 6;
		case powertarget_square: return 7;
		case powertarget_sphere: return 8;
		case powertarget_point: return 9;
	}
	return 0;
}
@f(_,target.ToString(e_PowerTargets:target))
{
	new tmp[16];
	switch(target)
	{
		case powertarget_self: tmp = "Self";
		case powertarget_single: tmp = "Single Target";
		case powertarget_radius: tmp = "Radius";
		case powertarget_groundline: tmp = "Line";
		case powertarget_line: tmp = "Line";
		case powertarget_circle: tmp = "Circle Area";
		case powertarget_square: tmp = "Square Area";
		case powertarget_sphere: tmp = "Sphere Area";
		case powertarget_point: tmp = "Point";
	}
	return tmp;
}
