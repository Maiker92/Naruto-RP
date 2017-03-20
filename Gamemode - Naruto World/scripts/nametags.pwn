// Anime Fantasy: Naruto World #19 script: nametags
#define function<%1> forward nametags_%1; public nametags_%1
function<OnGameModeInit()>
{
	// Disable SA-MP name tags
	ShowNameTags(0);
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerSpawn(playerid)>
{
	if(!PlayerInfo[playerid][pNameTagDetails][0]) nametag_Create(playerid);
	else nametag_Update(playerid);
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	if(PlayerInfo[playerid][pNameTagDetails][0]) nametag_Destroy(playerid);
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_second)) if(PlayerInfo[playerid][pNameTagDetails][2] > 0)
	{
		PlayerInfo[playerid][pNameTagDetails][2]--;
		if(!PlayerInfo[playerid][pNameTagDetails][2])
		{
			str_reset(PlayerInfo[playerid][pNameTagAdditional]);
			nametag_Update(playerid);
		}
	}
	return 1;
}
function<GlobalScriptTimer(interval)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_halfsec)) Loop(npc,npcid) if(NPCInfo[npcid][npcTagDetails][0]) if(NPCInfo[npcid][npcTagDetails][2] > 0)
	{
		NPCInfo[npcid][npcTagDetails][2]--;
		if(!NPCInfo[npcid][npcTagDetails][2])
		{
			str_reset(NPCInfo[npcid][npcTagAdditional]);
			npctag_Update(npcid);
		}
	}
	return 1;
}
#undef function
// Name Tag
@f(_,nametag.Create(playerid))
{
	if(!PlayerInfo[playerid][pNameTagDetails][0])
	{
		PlayerInfo[playerid][pNameTag] = Create3DTextLabel(nametag_GetText(playerid),color_SetAlpha(CC_NAME_TAG,NAMETAG_DRAW_ALPHA),0.0,0.0,-500.0,NAMETAG_DRAW_DISTANCE,VW_WORLD,1);
		PlayerInfo[playerid][pNameTagDetails] = {1,1,0};
		Attach3DTextLabelToPlayer(PlayerInfo[playerid][pNameTag],playerid,0.0,0.0,0.3);
	}
}
@f(_,nametag.Destroy(playerid))
{
	if(PlayerInfo[playerid][pNameTagDetails][0])
	{
		Delete3DTextLabel(PlayerInfo[playerid][pNameTag]);
		PlayerInfo[playerid][pNameTag] = (Text3D:(INVALID_3DTEXT_ID));
		PlayerInfo[playerid][pNameTagDetails] = {0,0,0};
	}
}
@f(_,nametag.GetText(playerid))
{
	new nametagtext[M_S], perc = floatround(math_percent(PlayerInfo[playerid][pHealth],stats_GetStats(playerid,stats_health,true),100.0)), perccol[10];
	perccol = nametag_HPColorString(perc);
	format(nametagtext,sizeof(nametagtext),"(%s)\n%s\nHP: %s%d%c",player_GetNickname(playerid),player_GetName(playerid),perccol,perc,'%');
	if(PlayerInfo[playerid][pNameTagDetails][2] > 0) format(nametagtext,sizeof(nametagtext),"%s\n%s",nametagtext,PlayerInfo[playerid][pNameTagAdditional]);
	return nametagtext;
}
@f(_,nametag.Update(playerid)) if(PlayerInfo[playerid][pNameTagDetails][0]) Update3DTextLabelText(PlayerInfo[playerid][pNameTag],color_SetAlpha(CC_NAME_TAG,NAMETAG_DRAW_ALPHA),nametag_GetText(playerid));
@f(_,nametag.SetAdditionalText(playerid,seconds,text[]))
{
	PlayerInfo[playerid][pNameTagDetails][2] = seconds;
	str_set(PlayerInfo[playerid][pNameTagAdditional],text,strlen(text));
	nametag_Update(playerid);
}
@f(_,nametag.HPColorString(percent))
{
	new perccol[10];
	switch(percent)
	{
		case 75..100: perccol = @c(COLOR_GREEN);
		case 41..74: perccol = @c(COLOR_YELLOW);
		case 11..40: perccol = @c(COLOR_RED);
		case 1..9: perccol = @c(COLOR_DARKRED);
		case 0: perccol = @c(COLOR_GREY);
	}
	return perccol;
}
// NPC Tag
@f(_,npctag.Create(npcid))
{
	if(!NPCInfo[npcid][npcTagDetails][0])
	{
		NPCInfo[npcid][npcTag] = Create3DTextLabel(npctag_GetText(npcid),color_SetAlpha(CC_NAME_TAG,NAMETAG_DRAW_ALPHA),0.0,0.0,-500.0,NAMETAG_DRAW_DISTANCE_NPC,VW_WORLD,1);
		NPCInfo[npcid][npcTagDetails] = {1,1,0};
		Attach3DTextLabelToPlayer(NPCInfo[npcid][npcTag],NPCInfo[npcid][npcPlayerID],0.0,0.0,0.3);
	}
}
@f(_,npctag.Destroy(npcid))
{
	if(NPCInfo[npcid][npcTagDetails][0])
	{
		Delete3DTextLabel(NPCInfo[npcid][npcTag]);
		NPCInfo[npcid][npcTag] = (Text3D:(INVALID_3DTEXT_ID));
		NPCInfo[npcid][npcTagDetails] = {0,0,0};
	}
}
@f(_,npctag.GetText(npcid))
{
	new nametagtext[M_S], perc = floatround(math_percent(NPCInfo[npcid][npcHealth],NPCInfo[npcid][npcStats][0],100.0)), perccol[10];
	perccol = nametag_HPColorString(perc);
	format(nametagtext,sizeof(nametagtext),npc_GetHeader(npcid));
	if(strlen(nametagtext) > 1) format(nametagtext,sizeof(nametagtext),"(%s)\n",nametagtext);
	format(nametagtext,sizeof(nametagtext),"%s%s\nHP: %s%d%c",nametagtext,NPCInfo[npcid][npcName],perccol,perc,'%');
	//if(NPCInfo[npcid][npcLeader] != NPCInfo[npcid][npcPlayerID] && player_IsConnected(NPCInfo[npcid][npcLeader])) format(nametagtext,sizeof(nametagtext),"(%s)\n%s",player_GetName(NPCInfo[npcid][npcLeader]),nametagtext); No need since I have GetHeader
	if(NPCInfo[npcid][npcTagDetails][2] > 0) format(nametagtext,sizeof(nametagtext),"%s\n%s",nametagtext,NPCInfo[npcid][npcTagAdditional]);
	return nametagtext;
}
@f(_,npctag.Update(npcid)) if(NPCInfo[npcid][npcTagDetails][0]) Update3DTextLabelText(NPCInfo[npcid][npcTag],color_SetAlpha(CC_NAME_TAG,NAMETAG_DRAW_ALPHA),npctag_GetText(npcid));
@f(_,npctag.SetAdditionalText(npcid,seconds,text[]))
{
	NPCInfo[npcid][npcTagDetails][2] = seconds;
	str_set(NPCInfo[npcid][npcTagAdditional],text,strlen(text));
	npctag_Update(npcid);
}
