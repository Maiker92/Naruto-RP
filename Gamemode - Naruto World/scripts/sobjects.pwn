// Anime Fantasy: Naruto World #31 script: sobjects
#define function<%1> forward sobjects_%1; public sobjects_%1
function<OnGameModeInit()>
{
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_halfsec) && PlayerInfo[playerid][pSObject][0] != INVALID_STREAMED_OBJECT && PlayerInfo[playerid][pSObject][1] < 1)
	{
		switch(PlayerInfo[playerid][pSObject][1])
		{
			case 0:
			{
				new e_Animation:anim = anim_none;
				switch(SpecialObjects[ObjectInfo[PlayerInfo[playerid][pSObject][0]][oSID]][soModelID])
				{
					case 1256: /* Bench */ anim = e_Animation:anim_sit;
				}
				if(anim != e_Animation:anim_none) anim_Apply(playerid,anim);
			}
		}
		PlayerInfo[playerid][pSObject][1]++;
	}
	return 1;
}
#undef function
// Special Object
@f(bool,sobject.PlayerSeat(playerid,objectid,bool:toggle))
{
	if(ObjectInfo[objectid][oSID] == -1) return;
	new Float:p[4];
	if(toggle)
	{
		new seat = sobject_GetEmptySeat(objectid);
		if(seat != -1)
		{
			sobject_GetSeatPos(objectid,seat,p[0],p[1],p[2],p[3]);
			sobject_AssignSeat(objectid,seat,playerid,true);
			player_SetPosition(playerid,p[0],p[1],p[2]);
			player_SetAngle(playerid,p[3]);
		}
	}
	else
	{
		sobject_GetSeatPos(objectid,PlayerInfo[playerid][pSObject][1],p[0],p[1],p[2],p[3]);
		math_xyinfront(p[0],p[1],p[3],floatmul(SpecialObject[ObjectInfo[objectid][oSID]][soRadius],0.66));
		sobject_AssignSeat(objectid,seat,playerid,true);
		if(PlayerInfo[playerid][pNPCIndex] == INVALID_PLAYER_ID)
		{
			anim_Clear(playerid);
			player_SetPosition(playerid,p[0],p[1],p[2]);
			player_SetAngle(playerid,p[3]);
		}
		else
		{
			npc_SetPosition(PlayerInfo[playerid][pNPCIndex],p[0],p[1],p[2]);
			npc_SetAngle(PlayerInfo[playerid][pNPCIndex],p[3]);
		}
	}
}
@f(_,sobject.GetSeatPos(objectid,seat,&Float:x,&Float:y,&Float:z,&Float:a))
{
	if(ObjectInfo[objectid][oSID] == -1) return;
	new Float:p[3], Float:r[3];
	object_GetPos(objectid,p[0],p[1],p[2]);
	object_GetRot(objectid,r[0],r[1],r[2]);
	switch(SpecialObjects[ObjectInfo[PlayerInfo[playerid][pSObject][0]][oSID]][soModelID])
	{
		case 1256: /* Bench */
		{
			switch(seat)
			{
				case 0:
				{
				}
				case 1:
				{
				}
				case 2:
				{
				}
			}
			a = r[5], z = p[2]; // angle & height will be the same as the bench
		}
	}
}
@f(_,sobject.GetEmptySeat(objectid))
{
	if(ObjectInfo[objectid][oSID] == -1) return -1;
	for(new i = 0; i < MAX_SOBJECT_SEATS && i < SpecialObjects[ObjectInfo[objectid][oSID]][soMaxSeats] && seat == -1; i++) if(ObjectInfo[objectid][oSPlayer][i] == INVALID_PLAYER_ID) return i;
	return -1;
}
@f(_,sobject.AssingSeat(objectid,seat,playerid,bool:assign))
{
	if(assign)
	{
		ObjectInfo[objectid][oSPlayer][seat] = playerid;
		PlayerInfo[playerid][pSObject][0] = objectid;
		PlayerInfo[playerid][pSObject][1] = seat;
		PlayerInfo[playerid][pSObject][2] = 0;
		ObjectInfo[objectid][oSPlayers]++;
	}
	else
	{
		ObjectInfo[objectid][oSPlayer][seat] = INVALID_PLAYER_ID;
		PlayerInfo[playerid][pSObject][0] = INVALID_STREAMED_OBJECT;
		PlayerInfo[playerid][pSObject][1] = 0;
		PlayerInfo[playerid][pSObject][2] = 0;
		ObjectInfo[objectid][oSPlayers]--;
	}
}
@f(bool,sobject.IsSpecial(objectid))
{
	if(ObjectInfo[objectid][oSID] == -1) for(new i = 0; i < sizeof(SpecialObjects) && ObjectInfo[objectid][oSID] == -1; i++) if(SpecialObjects[i][soModelID] == (ObjectInfo[objectid][oModel]+OBJECT_MODEL_ID_OFFSET)) ObjectInfo[objectid][oSID] = i;
	return ObjectInfo[objectid][oSID] != -1;
}
@f(_,sobject.ApplySpeciality(objectid))
{
	new i = ObjectInfo[objectid][oSID];
	if(i != -1)
	{
		if(SpecialObjects[i][soRadius] > 0.0)
		{
			new e_AreaType:type = e_AreaType:areatype_none, Float:coords[6], mx = 0;
			if(SpecialObjects[i][soHeight] > 0.0) type = e_AreaType:areatype_sphere, mx = 3;
			else type = e_AreaType:areatype_circle, mx = 2;
			for(new j = 0; j < mx; j++) coords[j] = ObjectInfo[objectid][oPos][j];
			ObjectInfo[objectid][oSArea] = area_Create(type,e_AreaUse:areause_sobject,objectid,coords,SpecialObjects[i][soRadius]);
			area_AttachToObject(ObjectInfo[objectid][oSArea],objectid);
		}
	}
}
