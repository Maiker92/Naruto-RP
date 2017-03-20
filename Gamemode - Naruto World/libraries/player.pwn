@f(_,player.ResetInfo(playerid))
{
	PlayerInfo[playerid][pName][0] = EOS;
	PlayerInfo[playerid][pDisplayName][0] = EOS;
	PlayerInfo[playerid][pIP][0] = EOS;
	PlayerInfo[playerid][pClass] = 0;
	PlayerInfo[playerid][pConnectionID] = INVALID_CONNECTION;
	PlayerInfo[playerid][pStatus] = e_PlayerStatus:player_status_none;
	PlayerInfo[playerid][pUserID] = 0;
	PlayerInfo[playerid][pLogged] = false;
	PlayerInfo[playerid][pFailedLogins] = 0;
	PlayerInfo[playerid][pInterpolate] = {0,0,0};
	PlayerInfo[playerid][pWatchingMovie] = {-1,0};
	PlayerInfo[playerid][pUnderAttack] = 0;
	PlayerInfo[playerid][pScreenFade] = e_ScreenFade:screenfade_none;
	PlayerInfo[playerid][pScreenFadeInfo] = {0,0,0,0,0};
	PlayerInfo[playerid][pAdmin] = 0;
	PlayerInfo[playerid][pSPID] = INVALID_SPICKUP;
	PlayerInfo[playerid][pLoadedAnimations] = false;
	PlayerInfo[playerid][pHelpFile][0] = EOS;
	PlayerInfo[playerid][pNameTag] = (Text3D:(INVALID_3DTEXT_ID));
	PlayerInfo[playerid][pNameTagDetails] = {0,0,0};
	PlayerInfo[playerid][pNameTagAdditional][0] = EOS;
	PlayerInfo[playerid][pCursorShow] = false;
	PlayerInfo[playerid][pTargetReason] = e_TargetReason:targetreason_none;
	PlayerInfo[playerid][pTargetType] = 0;
	PlayerInfo[playerid][pTargetObjects] = 0;
	PlayerInfo[playerid][pTargetIcon] = {0,0};
	PlayerInfo[playerid][pNotificationTime] = 0;
	PlayerInfo[playerid][pNPCIndex] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pSpawned] = false;
	PlayerInfo[playerid][pPowerPrepare] = {-1,0,0,0};
	PlayerInfo[playerid][pSideMenu] = -1;
	PlayerInfo[playerid][pConnected] = -1;
	PlayerInfo[playerid][pIsNPC] = -1;
	PlayerInfo[playerid][pKick] = 0;
	PlayerInfo[playerid][pLastChat][0] = EOS;
	PlayerInfo[playerid][pDialogParam][0] = EOS;
	PlayerInfo[playerid][SpawnAfterSpec] = false;
	PlayerInfo[playerid][pCameraUpdates] = 0;
	PlayerInfo[playerid][pIntro] = -1;
	PlayerInfo[playerid][pPTDNeedAlpha] = false;
	PlayerInfo[playerid][pSelectionID] = {-1,-1,-1};
	PlayerInfo[playerid][pSelectionSource] = e_SelectionSource:selsrc_none;
	PlayerInfo[playerid][pSelectionSourceID] = 0;
	PlayerInfo[playerid][pSelectionReason][0] = EOS;
	PlayerInfo[playerid][pDialog] = d_Null;
	PlayerInfo[playerid][pDialogOneButton] = false;
	PlayerInfo[playerid][pSuperJetpack] = false;
	PlayerInfo[playerid][pModifiedJump] = -999.0;
	PlayerInfo[playerid][pDialogSelect] = -1;
	PlayerInfo[playerid][pDebugAnimations] = false;
	PlayerInfo[playerid][pJumpGravityModify] = 0;
	PlayerInfo[playerid][pListSounds] = 0;
	PlayerInfo[playerid][pLastMusicPlayed] = 0;
	PlayerInfo[playerid][pFocusDebugVillager] = -1;
	PlayerInfo[playerid][pTargetPlayerID] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][pSavingPathCoords] = false;
	for(new i = 0; i < 100; i++)
	{
		if(i < MAX_PTD) PlayerInfo[playerid][pPTD][i] = INVALID_PLAYER_TEXT_DRAW;
		if(i < MAX_PTD_ALPHA) PlayerInfo[playerid][pPTDAlpha][i] = 0, PlayerInfo[playerid][pPTDAlphaID][i] = e_PlayerTD:ptd_none, PlayerInfo[playerid][pPTDAlphaColor][i] = 0;
		if(i < 9) PlayerInfo[playerid][pCamera][i] = 0.0;
		if(i < 3) PlayerInfo[playerid][pTargetPosition][i] = 0.0, PlayerInfo[playerid][pTargetFloats][i] = 0.0;
		if(i < 4) PlayerInfo[playerid][pSilence][i] = false;
		if(i < MAX_TARGET_OBJECTS) PlayerInfo[playerid][pTargetObject][i] = -1;
		if(i < MAX_SOUNDS) PlayerInfo[playerid][pPlayingSound][i] = 0, PlayerInfo[playerid][pSoundPosition][i] = 0, PlayerInfo[playerid][pSoundLength][i] = 0, PlayerInfo[playerid][pSoundLoop][i] = false, PlayerInfo[playerid][pListSound][i] = 0;
		if(i < 2) PlayerInfo[playerid][pSavingPathDistance][i] = 0.0;
	}
}
@f(_,player.ResetCharacterInfo(playerid))
{
	PlayerInfo[playerid][pLoading] = {LOADING_NONE,0};
	PlayerInfo[playerid][pPlayerID] = 0;
	PlayerInfo[playerid][pCharacter] = INVALID_CHARACTER;
	PlayerInfo[playerid][pHealth] = 0.0;
	PlayerInfo[playerid][pChakra] = 0.0;
	PlayerInfo[playerid][pDied] = false;
	PlayerInfo[playerid][pLevel] = 1;
	PlayerInfo[playerid][pTeam] = 0;
	PlayerInfo[playerid][pXP] = 0;
	PlayerInfo[playerid][pMoney] = 0;
	PlayerInfo[playerid][pCrowdControl] = {0,0};
	PlayerInfo[playerid][pPowerSelection] = {0,0};
	PlayerInfo[playerid][pFrozen] = false;
	PlayerInfo[playerid][pRoot] = false;
	PlayerInfo[playerid][pBasicAttack] = {0,0,0,0};
	PlayerInfo[playerid][pBasicAttackCode][0] = EOS;
	PlayerInfo[playerid][pNPCs] = 0;
	PlayerInfo[playerid][pNPCCommand] = {-1,NPCCMD_NONE,0};
	PlayerInfo[playerid][pNPCFollowCD] = 0.0;
	PlayerInfo[playerid][pAnimation] = 0;
	PlayerInfo[playerid][pSObject] = {INVALID_STREAMED_OBJECT,0,0};
	for(new i = 0; i < 100; i++)
	{
		if(i < MAX_EFFECTS_PER_TIME) PlayerInfo[playerid][pDOT][i] = 0, PlayerInfo[playerid][pHOT][i] = 0, PlayerInfo[playerid][pDPS][i] = 0;
		if(i < MAX_BUFFS_PER_PLAYER) PlayerInfo[playerid][pBuff][i] = 0, PlayerInfo[playerid][pBuffType][i] = false;
		if(i < 4) PlayerInfo[playerid][pPosition][i] = 0.0, PlayerInfo[playerid][pLastPos][i] = 0.0;
		if(i < MAX_POWER_CATEGORIES) PlayerInfo[playerid][pCooldown][i] = 0, PlayerInfo[playerid][pSavedCooldown][i] = 0;
		if(i < MAX_NPCS) PlayerInfo[playerid][pNPC][i] = INVALID_PLAYER_ID;
	}
}
@f(_,player.Close(playerid))
{
	if(PlayerInfo[playerid][pCursorShow]) CancelSelectTextDraw(playerid);
}
@f(_,player.GetNickname(playerid))
{
	new n[MAX_PLAYER_NAME];
	return format(n,sizeof(n),PlayerInfo[playerid][pName]), n;
}
@f(_,player.GetName(playerid))
{
	new ret[MAX_PLAYER_NAME];
	if(PlayerInfo[playerid][pCharacter] == INVALID_CHARACTER) format(ret,sizeof(ret),PlayerInfo[playerid][pName]);
	else
	{
		if(PlayerInfo[playerid][pDisplayName][0] == EOS) player_UpdateDisplayName(playerid);
		format(ret,sizeof(ret),PlayerInfo[playerid][pDisplayName]);
	}
	return ret;
}
@f(_,player.UpdateDisplayName(playerid))
{
	if(PlayerInfo[playerid][pCharacter] == INVALID_CHARACTER)
	{
		format(PlayerInfo[playerid][pDisplayName],MAX_PLAYER_NAME,player_GetNickname(playerid));
		format(PlayerInfo[playerid][pDisplayNickname],MAX_PLAYER_NAME,player_GetNickname(playerid));
	}
	else
	{
		format(PlayerInfo[playerid][pDisplayName],MAX_PLAYER_NAME,chars_GetDisplayName(PlayerInfo[playerid][pCharacter]));
		format(PlayerInfo[playerid][pDisplayNickname],MAX_PLAYER_NAME,chars_GetName(PlayerInfo[playerid][pCharacter]));
	}
}
@f(_,player.GetIP(playerid))
{
	new ret[16];
	return format(ret,sizeof(ret),PlayerInfo[playerid][pIP]), ret;
}
@f(_,player.GetDistance(playerid,playerid2))
{
	new Float:p[6];
	GetPlayerPos(playerid,p[0],p[1],p[2]);
	GetPlayerPos(playerid2,p[3],p[4],p[5]);
	return math_distance_3d(p[0],p[1],p[2],p[3],p[4],p[5]);
}
@f(bool,player.IsInRangeOfPlayer(playerid,playerid2,Float:range))
{
	new Float:p[3];
	GetPlayerPos(playerid2,p[0],p[1],p[2]);
	return IsPlayerInRangeOfPoint(playerid,range,p[0],p[1],p[2]) && vworld_Get(playerid) == vworld_Get(playerid2);
}
@f(_,player.GetPosition(playerid)) return PlayerInfo[playerid][pNPCIndex] == INVALID_PLAYER_ID ? GetPlayerPos(playerid,PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2]) : npc_GetPosition(PlayerInfo[playerid][pNPCIndex],PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2]);
@f(_,player.SetPosition(playerid,Float:x,Float:y,Float:z))
{
	if(PlayerInfo[playerid][pRoot]) PlayerInfo[playerid][pRootPoint][0] = x, PlayerInfo[playerid][pRootPoint][1] = y, PlayerInfo[playerid][pRootPoint][2] = z;
	return SetPlayerPos(playerid,x,y,z);
}
@f(_,player.GetAngle(playerid)) return GetPlayerFacingAngle(playerid,PlayerInfo[playerid][pPosition][3]);
@f(_,player.SetAngle(playerid,Float:a)) return SetPlayerFacingAngle(playerid,a);
@f(_,player.GetRandom())
{
	new r = INVALID_PLAYER_ID;
	do r = random(players);
	while !player_IsConnected(player[r]);
	return r;
}
@f(_,player.Freeze(playerid,bool:toggle = true)) return TogglePlayerControllable(playerid,!(PlayerInfo[playerid][pFrozen] = toggle));
@f(_,player.Stop(playerid,bool:sound = false))
{
	if(sound) PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	TogglePlayerControllable(playerid,1);
	return TogglePlayerControllable(playerid,!PlayerInfo[playerid][pFrozen]);
}
@f(_,player.GetPositionStatus(playerid))
{
	new c = GetPlayerControlState(playerid), j = GetPlayerJumpState(playerid);
	if(c == 3 || j == 32) return PS_GROUND;
	else if(c == 1 && j == 34) return PS_AIR;
	else if(c == 1 && j != 34) return PS_WATER;
	else return PS_NONE;
}
@f(bool,player.IsInCircle(playerid,Float:x,Float:y,Float:radius))
{
	new Float:p[3];
	GetPlayerPos(playerid,p[0],p[1],p[2]);
	return math_distance_2d(p[0],p[1],x,y) <= radius;
}
@f(bool,player.IsInSquare2D(playerid,Float:minx,Float:maxx,Float:miny,Float:maxy))
{
	new Float:p[3];
	GetPlayerPos(playerid,p[0],p[1],p[2]);
	return p[0] >= minx && p[0] <= maxx && p[1] >= miny && p[1] <= maxy;
}
@f(bool,player.IsInSquare3D(playerid,Float:minx,Float:maxx,Float:miny,Float:maxy,Float:minz,Float:maxz))
{
	new Float:p[3];
	GetPlayerPos(playerid,p[0],p[1],p[2]);
	return p[0] >= minx && p[0] <= maxx && p[1] >= miny && p[1] <= maxy && p[2] >= minz && p[2] <= maxz;
}
@f(bool,player.IsConnected(playerid)) return playerid >= 0 && playerid < MAX_PLAYERS ? (bool:(PlayerInfo[playerid][pConnected] == -1 ? (PlayerInfo[playerid][pConnected] = IsPlayerConnected(playerid)) : PlayerInfo[playerid][pConnected])) : false;
@f(bool,player.IsNPC(playerid)) return playerid >= 0 && playerid < MAX_PLAYERS ? (bool:(PlayerInfo[playerid][pIsNPC] == -1 ? (PlayerInfo[playerid][pIsNPC] = IsPlayerConnected(playerid) && IsPlayerNPC(playerid)) : PlayerInfo[playerid][pIsNPC])) : false;
@f(_,player.SetSpawnInfo(playerid,team,skin,Float:x,Float:y,Float:z,Float:rotation)) return SetSpawnInfo(playerid,team,skin,PlayerInfo[playerid][pSpawnPos][0] = x,PlayerInfo[playerid][pSpawnPos][1] = y,PlayerInfo[playerid][pSpawnPos][2] = z,PlayerInfo[playerid][pSpawnPos][3] = rotation,0,0,0,0,0,0);
@f(_,player.Spawn(playerid))
{
	SpawnPlayer(playerid);
	PlayerInfo[playerid][pSpawned] = true;
}
