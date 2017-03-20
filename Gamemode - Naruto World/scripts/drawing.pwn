// Anime Fantasy: Naruto World #09 script: drawing
#define function<%1> forward drawing_%1; public drawing_%1
static e_PlayerTD:initptds[] = {ptd_stats,ptd_powers,ptd_items,ptd_loading,ptd_notifications,ptd_buffs,ptd_soundtrack,ptd_movie},
	e_GlobalTD:initgtds[] = {gtd_character,gtd_map,gtd_menu,gtd_startup};
function<OnGameModeInit()>
{
	// Fade Text
	fadeText = TextDrawCreate(320.0,0.0,"_");
	TextDrawUseBox(fadeText,1);
	TextDrawBoxColor(fadeText,0);
	TextDrawLetterSize(fadeText,1.0,50.0);
	TextDrawTextSize(fadeText,1.0,640.0);
	TextDrawAlignment(fadeText,2);
	// Progress Bars
	progressbar_Initialize(e_ProgressBar:pb_health,0,562.0,17.0,74.0,0.6,-1778384746,-939523896);
	progressbar_Initialize(e_ProgressBar:pb_chakra,2,562.0,32.0,74.0,0.6,1664150,38600);
	progressbar_Initialize(e_ProgressBar:pb_xp,9,133.0,421.0,360.0,0.5,-926365596,1263225655);
	progressbar_Initialize(e_ProgressBar:pb_loading,88,220.0,300.0,210.0,1.6,-926365571,1263225725);
	// Global Text Draws
	for(new i = 0; i < sizeof(initgtds); i++) gtd_Create(initgtds[i]);
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerConnect(playerid)>
{
	for(new i = 0; i < sizeof(initptds); i++) ptd_Create(playerid,initptds[i]);
	return 1;
}
function<OnPlayerDisconnect(playerid,reason)>
{
	for(new i = 0; i < sizeof(initptds); i++) ptd_Destroy(playerid,initptds[i]);
	return 1;
}
function<LocalScriptTimer(interval,playerid)>
{
	if(timer_MeetsTimeUnit(interval,timeunit_tenth))
	{
		if(PlayerInfo[playerid][pScreenFade] != e_ScreenFade:screenfade_none)
		{
			PlayerInfo[playerid][pScreenFadeInfo][2] += PlayerInfo[playerid][pScreenFadeInfo][4];
			if(PlayerInfo[playerid][pScreenFadeInfo][2] <= 0 || PlayerInfo[playerid][pScreenFadeInfo][2] >= 255)
			{
				new bool:flag[2] = {false,false}, rtype = 0;
				if(PlayerInfo[playerid][pScreenFadeInfo][0] > 0)
				{
					rtype = PlayerInfo[playerid][pScreenFadeInfo][0];
					PlayerInfo[playerid][pScreenFadeInfo][0] = 0;
					switch(rtype)
					{
						case 1: PlayerInfo[playerid][pScreenFadeInfo][4] *= -1; // Now turn back!
						case 2: PlayerInfo[playerid][pScreenFadeInfo][4] *= -1, flag[0] = true; // Turn back & call function
					}
				}
				else flag[0] = true, flag[1] = true;
				if(flag[0]) OnPlayerEndScreenFade(playerid,PlayerInfo[playerid][pScreenFade],rtype,PlayerInfo[playerid][pScreenFadeInfo][1]);
				if(flag[1]) screenfade_Stop(playerid);
			}
			else
			{
				TextDrawBoxColor(fadeText,color_SetAlpha(PlayerInfo[playerid][pScreenFadeInfo][3],PlayerInfo[playerid][pScreenFadeInfo][2]));
				TextDrawShowForPlayer(playerid,fadeText);
			}
		}
		if(PlayerInfo[playerid][pPTDNeedAlpha])
		{
			new mn = 0, mx = 0, col = 0, bool:flag = false;
			for(new i = 0; i < MAX_PTD_ALPHA; i++) if(PlayerInfo[playerid][pPTDAlpha][i] > 0)
			{
				flag = false;
				PlayerInfo[playerid][pPTDAlpha][i] -= 5;
				if(PlayerInfo[playerid][pPTDAlpha][i] < 0) PlayerInfo[playerid][pPTDAlpha][i] = 0;
				ptd_GetMinMax(PlayerInfo[playerid][pPTDAlphaID][i],mn,mx);
				col = color_SetAlpha(PlayerInfo[playerid][pPTDAlphaColor][i],min(PlayerInfo[playerid][pPTDAlpha][i],255));
				for(new j = mn; j <= mx; j++)
				{
					PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][j],col);
					PlayerTextDrawShow(playerid,PlayerInfo[playerid][pPTD][j]);
				}
				if(!PlayerInfo[playerid][pPTDAlpha][i])
				{
					ptd_Hide(playerid,PlayerInfo[playerid][pPTDAlphaID][i]);
					flag = true;
				}
			}
			if(flag)
			{
				flag = false;
				for(new i = 0; i < MAX_PTD_ALPHA; i++) if(PlayerInfo[playerid][pPTDAlpha][i] > 0) flag = true;
				if(!flag) PlayerInfo[playerid][pPTDNeedAlpha] = false;
			}
		}
	}
	return 1;
}
function<OnPlayerClickTD(playerid,Text:clickedid)>
{
	new m = sidemenu_GetCurrent(playerid);
	if(m != -1) // Selecting menu option
	{
		if(clickedid == SideMenuInfo[m][smMenuTD][1]) sidemenu_Close(playerid);
		for(new i = 0; i < SideMenuInfo[m][smButtons]; i++) if(clickedid == SideMenuButtonInfo[SideMenuInfo[m][smButton][i]][smbButtonTD]) OnSideMenuClick(playerid,SideMenuInfo[m][smID],SideMenuInfo[m][smSubID],SideMenuButtonInfo[SideMenuInfo[m][smButton][i]][smbCode]);
	}
	return 0;
}
#undef function
// Private
static stock TDShow(playerid,Text:t)
{
	TextDrawShowForPlayer(playerid,t);
	SetPVarInt(playerid,f("%s_%d","tdshown",_:t),1);
}
static stock TDHide(playerid,Text:t)
{
	TextDrawHideForPlayer(playerid,t);
	SetPVarInt(playerid,f("%s_%d","tdshown",_:t),0);
}
static stock bool:TDIsVisible(playerid,Text:t) return GetPVarInt(playerid,f("%s_%d","tdshown",_:t)) == 1;
static stock PTDShow(playerid,PlayerText:t)
{
	PlayerTextDrawShow(playerid,t);
	SetPVarInt(playerid,f("%s_%d","ptdshown",_:t),1);
}
static stock PTDHide(playerid,PlayerText:t)
{
	PlayerTextDrawHide(playerid,t);
	SetPVarInt(playerid,f("%s_%d","ptdshown",_:t),0);
}
static stock bool:PTDIsVisible(playerid,PlayerText:t) return GetPVarInt(playerid,f("%s_%d","ptdshown",_:t)) == 1;
static stock TXDName(txdname[])
{
	new ret[MAX_NAME_LENGTH];
	format(ret,sizeof(ret),txdname);
	if(strlen(ret) < 2) format(ret,sizeof(ret),NULL_TXD);
	return ret;
}
// Global Text Draw
@f(_,gtd.Create(e_GlobalTD:gtdid))
{
	switch(gtdid)
	{
		case gtd_character: for(new i = 0; i < MAX_CHARACTERS; i++)
		{
			CharacterInfo[i][cText][0] = TextDrawCreate(179.0,140.0,".");
			TextDrawBackgroundColor(CharacterInfo[i][cText][0],0);
			TextDrawFont(CharacterInfo[i][cText][0],1);
			TextDrawLetterSize(CharacterInfo[i][cText][0],0.500000,25.0);
			TextDrawColor(CharacterInfo[i][cText][0],0);
			TextDrawSetOutline(CharacterInfo[i][cText][0],0);
			TextDrawSetProportional(CharacterInfo[i][cText][0],1);
			TextDrawSetShadow(CharacterInfo[i][cText][0],0);
			TextDrawUseBox(CharacterInfo[i][cText][0],1);
			TextDrawBoxColor(CharacterInfo[i][cText][0],1677721700);
			TextDrawTextSize(CharacterInfo[i][cText][0],476.0,11.0);
			TextDrawSetSelectable(CharacterInfo[i][cText][0],0);
			CharacterInfo[i][cText][1] = TextDrawCreate(181.0,146.0,TXDName(CharacterInfo[i][cAvatar]));
			TextDrawBackgroundColor(CharacterInfo[i][cText][1],0);
			TextDrawFont(CharacterInfo[i][cText][1],4);
			TextDrawLetterSize(CharacterInfo[i][cText][1],0.500000,1.0);
			TextDrawColor(CharacterInfo[i][cText][1],-1);
			TextDrawSetOutline(CharacterInfo[i][cText][1],0);
			TextDrawSetProportional(CharacterInfo[i][cText][1],1);
			TextDrawSetShadow(CharacterInfo[i][cText][1],1);
			TextDrawUseBox(CharacterInfo[i][cText][1],1);
			TextDrawBoxColor(CharacterInfo[i][cText][1],255);
			TextDrawTextSize(CharacterInfo[i][cText][1],64.0,64.0);
			TextDrawSetSelectable(CharacterInfo[i][cText][1],0);
			CharacterInfo[i][cText][2] = TextDrawCreate(399.0,245.0,".");
			TextDrawBackgroundColor(CharacterInfo[i][cText][2],0);
			TextDrawFont(CharacterInfo[i][cText][2],5);
			TextDrawLetterSize(CharacterInfo[i][cText][2],0.519999,1.200000);
			TextDrawColor(CharacterInfo[i][cText][2],-1);
			TextDrawSetOutline(CharacterInfo[i][cText][2],0);
			TextDrawSetProportional(CharacterInfo[i][cText][2],1);
			TextDrawSetShadow(CharacterInfo[i][cText][2],0);
			TextDrawUseBox(CharacterInfo[i][cText][2],1);
			TextDrawBoxColor(CharacterInfo[i][cText][2],0);
			TextDrawTextSize(CharacterInfo[i][cText][2],108.0,116.0);
			TextDrawSetPreviewModel(CharacterInfo[i][cText][2],CharacterInfo[i][cSkin]);
			TextDrawSetPreviewRot(CharacterInfo[i][cText][2],0.0,0.0,0.0,1.0);
			TextDrawSetSelectable(CharacterInfo[i][cText][2],0);
			CharacterInfo[i][cText][3] = TextDrawCreate(182.0,128.0,chars_GetName(i));
			TextDrawBackgroundColor(CharacterInfo[i][cText][3],0);
			TextDrawFont(CharacterInfo[i][cText][3],2);
			TextDrawLetterSize(CharacterInfo[i][cText][3],0.500000,1.700000);
			TextDrawColor(CharacterInfo[i][cText][3],-1);
			TextDrawSetOutline(CharacterInfo[i][cText][3],0);
			TextDrawSetProportional(CharacterInfo[i][cText][3],1);
			TextDrawSetShadow(CharacterInfo[i][cText][3],2);
			TextDrawSetSelectable(CharacterInfo[i][cText][3],0);
			CharacterInfo[i][cText][4] = TextDrawCreate(249.0,146.0,"Health: 100%~n~Chakra: 100%~n~~r~STR: ~w~000~n~~y~AGI: ~w~000~n~~b~INT: ~w~000~n~Player: ?");
			TextDrawBackgroundColor(CharacterInfo[i][cText][4],0);
			TextDrawFont(CharacterInfo[i][cText][4],1);
			TextDrawLetterSize(CharacterInfo[i][cText][4],0.310000,1.400000);
			TextDrawColor(CharacterInfo[i][cText][4],-1);
			TextDrawSetOutline(CharacterInfo[i][cText][4],0);
			TextDrawSetProportional(CharacterInfo[i][cText][4],1);
			TextDrawSetShadow(CharacterInfo[i][cText][4],0);
			TextDrawSetSelectable(CharacterInfo[i][cText][4],0);
			CharacterInfo[i][cText][5] = TextDrawCreate(182.0,250.0,"Team: %s~n~Rank: %s~n~Damage: %.1f~n~Max. Health: %.1f~n~Heal Rate: %.1f~n~Armour: %.1f~n~Jump Height: %.1f~n~Max. Chakra: %.1f~n~Chakra Reg.: %.1f");
			TextDrawBackgroundColor(CharacterInfo[i][cText][5],0);
			TextDrawFont(CharacterInfo[i][cText][5],1);
			TextDrawLetterSize(CharacterInfo[i][cText][5],0.330000,1.400000);
			TextDrawColor(CharacterInfo[i][cText][5],-1);
			TextDrawSetOutline(CharacterInfo[i][cText][5],0);
			TextDrawSetProportional(CharacterInfo[i][cText][5],1);
			TextDrawSetShadow(CharacterInfo[i][cText][5],0);
			TextDrawSetSelectable(CharacterInfo[i][cText][5],0);
			CharacterInfo[i][cText][6] = TextDrawCreate(383.0,146.0,"~b~Powers [000]~n~~n~~w~Power #1~n~Power #2~n~Power #3~n~Power #4~n~Power #5~n~Power #6~n~Power #7~n~Power #8~n~Power #9");
			TextDrawAlignment(CharacterInfo[i][cText][6],2);
			TextDrawBackgroundColor(CharacterInfo[i][cText][6],0);
			TextDrawFont(CharacterInfo[i][cText][6],1);
			TextDrawLetterSize(CharacterInfo[i][cText][6],0.330000,1.400000);
			TextDrawColor(CharacterInfo[i][cText][6],-1);
			TextDrawSetOutline(CharacterInfo[i][cText][6],0);
			TextDrawSetProportional(CharacterInfo[i][cText][6],1);
			TextDrawSetShadow(CharacterInfo[i][cText][6],0);
			TextDrawSetSelectable(CharacterInfo[i][cText][6],0);
		}
		case gtd_map:
		{
			map = TextDrawCreate(200.0,100.0,NULL_TXD);
			TextDrawBackgroundColor(map,255);
			TextDrawFont(map,4);
			TextDrawLetterSize(map,0.0,-2.0);
			TextDrawColor(map,-1);
			TextDrawSetOutline(map,0);
			TextDrawSetProportional(map,1);
			TextDrawSetShadow(map,1);
			TextDrawUseBox(map,1);
			TextDrawBoxColor(map,255);
			TextDrawTextSize(map,256.0,256.0);
			TextDrawSetSelectable(map,1);
		}
		case gtd_menu:
		{
			new s = sizeof(MenuOptions), Float:dis = 0.0, Float:start = 0.0;
			for(new i = 0; i < s; i++)
			{
				menuButtons[i] = TextDrawCreate(start = (587.0 - dis),427.0,MenuOptions[i]);
				if(i < s - 1) dis += floatadd(floatmul(12.0,float(strlen(MenuOptions[i+1]))),15.0);
				TextDrawBackgroundColor(menuButtons[i],255);
				TextDrawFont(menuButtons[i],1);
				TextDrawLetterSize(menuButtons[i],0.519999,2.0);
				TextDrawColor(menuButtons[i],-1);
				TextDrawSetOutline(menuButtons[i],0);
				TextDrawSetProportional(menuButtons[i],1);
				TextDrawSetShadow(menuButtons[i],1);
				TextDrawTextSize(menuButtons[i],start + floatmul(12.0,float(strlen(MenuOptions[i]))),20.0);
				TextDrawSetSelectable(menuButtons[i],1);
			}
			menuButtons[s] = TextDrawCreate(6.0,427.0,"LOGOUT/QUIT");
			TextDrawBackgroundColor(menuButtons[s],255);
			TextDrawFont(menuButtons[s],1);
			TextDrawLetterSize(menuButtons[s],0.519999,2.0);
			TextDrawColor(menuButtons[s],-939511041);
			TextDrawSetOutline(menuButtons[s],0);
			TextDrawSetProportional(menuButtons[s],1);
			TextDrawSetShadow(menuButtons[s],1);
			TextDrawTextSize(menuButtons[s],120.0,20.0);
			TextDrawSetSelectable(menuButtons[s],1);
		}
		case gtd_startup:
		{
			for(new i = 0; i < MAX_STARTUP_BUTTONS; i++)
			{
				StartOptions[i][stbTD] = TextDrawCreate(127.000000,100.000000+floatmul(25.0,float(i)),StartOptions[i][stbName]);
				TextDrawAlignment(StartOptions[i][stbTD],2);
				TextDrawBackgroundColor(StartOptions[i][stbTD],255);
				TextDrawFont(StartOptions[i][stbTD],3);
				TextDrawLetterSize(StartOptions[i][stbTD],0.660000,2.000000);
				TextDrawColor(StartOptions[i][stbTD],-1);
				TextDrawSetOutline(StartOptions[i][stbTD],1);
				TextDrawSetProportional(StartOptions[i][stbTD],1);
				TextDrawUseBox(StartOptions[i][stbTD],1);
				TextDrawBoxColor(StartOptions[i][stbTD],StartOptions[i][stbColor]);
				TextDrawTextSize(StartOptions[i][stbTD],24.000000,204.000000);
				TextDrawSetSelectable(StartOptions[i][stbTD],1);
			}
		}
	}
}
@f(_,gtd.Update(e_GlobalTD:gtdid,param,param2))
{
	switch(gtdid)
	{
		case gtd_character:
		{
			// tba: status (dead?), player name fix, longer box
			TextDrawSetString(CharacterInfo[param][cText][1],TXDName(CharacterInfo[param][cAvatar]));
			TextDrawSetPreviewModel(CharacterInfo[param][cText][2],CharacterInfo[param][cSkin]);
			TextDrawSetString(CharacterInfo[param][cText][3],f("(%d) %s",param,chars_GetName(param)));
			format(fstring,sizeof(fstring),"~r~STR: ~w~%d~n~~y~AGI: ~w~%d~n~~b~INT: ~w~%d~n~Player: %s",
				CharacterInfo[param][cStr],
				CharacterInfo[param][cAgi],
				CharacterInfo[param][cInt],
				user_GetKey(chars_GetUser(param),"name"));
			if(param2 == INVALID_PLAYER_ID)
				format(fstring,sizeof(fstring),"Health: %.0f%c~n~Chakra: %.0f%c~n~%s",
					PlayerInfo[param2][pHealth],'%',
					PlayerInfo[param2][pChakra],'%',
					fstring);
			else format(fstring,sizeof(fstring),"~n~~n~%s",fstring);
			TextDrawSetString(CharacterInfo[param][cText][4],fstring);
			format(fstring,sizeof(fstring),"Team: %s~n~Rank: %s~n~Damage: %.1f~n~Max. Health: %.1f~n~Heal Rate: %.1f~n~Armour: %.1f~n~Jump Height: %.1f~n~Max. Chakra: %.1f~n~Chakra Reg.: %.1f",
				TeamInfo[chars_GetTeam(param)][tName],
				rank_Name(rank_Get(param)),
				stats_GetDamage(param,damage_taijutsu),
				stats_GetStats(param,stats_health),
				stats_GetStats(param,stats_healthreg),
				stats_GetProtection(param,damage_taijutsu),
				stats_GetStats(param,stats_jump),
				stats_GetStats(param,stats_chakra),
				stats_GetStats(param,stats_chakrareg));
			TextDrawSetString(CharacterInfo[param][cText][5],fstring);
			TextDrawSetString(CharacterInfo[param][cText][6],"~b~Powers [000]");
		}
	}
}
@f(_,gtd.Show(playerid,e_GlobalTD:gtdid,param=0,param2=0))
{
	#pragma unused param2
	switch(gtdid)
	{
		case gtd_character: for(new i = 0; i <= 6; i++) TDShow(playerid,Text:CharacterInfo[param][cText][i]);
		case gtd_map: TDShow(playerid,map);
		case gtd_menu: for(new i = param + _:(param2); i < (!param ? 1 : sizeof(menuButtons)); i++) TDShow(playerid,menuButtons[i]);
		case gtd_startup: for(new i = 0; i < MAX_STARTUP_BUTTONS; i++) TDShow(playerid,StartOptions[i][stbTD]);
	}
	SetPVarInt(playerid,f("gtd%d",_:gtdid),1);
	SetPVarInt(playerid,f("gtd%dparam1",_:gtdid),param);
	SetPVarInt(playerid,f("gtd%dparam2",_:gtdid),param2);
}
@f(_,gtd.Hide(playerid,e_GlobalTD:gtdid,param=0,param2=0))
{
	#pragma unused param2
	switch(gtdid)
	{
		case gtd_character: for(new i = 0; i <= 6; i++) TDHide(playerid,Text:CharacterInfo[param][cText][i]);
		case gtd_map: TDHide(playerid,map);
		case gtd_menu: for(new i = param + _:(param2); i < (!param ? 1 : sizeof(menuButtons)); i++) TDHide(playerid,menuButtons[i]);
		case gtd_startup: for(new i = 0; i < MAX_STARTUP_BUTTONS; i++) TDHide(playerid,StartOptions[i][stbTD]);
	}
	SetPVarInt(playerid,f("gtd%d",_:gtdid),0);
	SetPVarInt(playerid,f("gtd%dparam1",_:gtdid),param);
	SetPVarInt(playerid,f("gtd%dparam2",_:gtdid),param2);
}
@f(bool,gtd.IsVisible(playerid,e_GlobalTD:gtdid,param=0,param2=0))
{
	#pragma unused param2
	switch(gtdid)
	{
		case gtd_character: for(new i = 0; i <= 6; i++) if(!TDIsVisible(playerid,CharacterInfo[param][cText][i])) return false;
		case gtd_map: if(!TDIsVisible(playerid,map)) return false;
		case gtd_menu: for(new i = param + _:(param2); i < (!param ? 1 : sizeof(menuButtons)); i++) if(!TDIsVisible(playerid,menuButtons[i])) return false;
		case gtd_startup: for(new i = 0; i < MAX_STARTUP_BUTTONS; i++) if(!TDIsVisible(playerid,StartOptions[i][stbTD])) return false;
	}
	return true;
}
@f(bool,gtd.IsShown(playerid,e_GlobalTD:gtdid)) return GetPVarInt(playerid,f("gtd%d",_:gtdid)) == 1;
@f(_,gtd.GetInfo(playerid,e_GlobalTD:gtdid,paramid = 1)) return GetPVarInt(playerid,f("gtd%dparam%d",_:gtdid,paramid));
// Player Text Draw
@f(_,ptd.Create(playerid,e_PlayerTD:ptdid))
{
	new p = 0;
	switch(ptdid)
	{
		case ptd_stats:
		{
			// Health + Chakra (0-5)
			progressbar_Create(playerid,e_ProgressBar:pb_health); // ptdid: 0+1
			progressbar_Create(playerid,e_ProgressBar:pb_chakra); // ptdid: 2+3
			p = 4;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,595.0,14.0,"0/0");
			PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.219999,1.100000);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
			p = 5;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,595.0,29.0,"0/0");
			PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.219999,1.100000);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
			// Ryu (6)
			p = 6;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,569.0,42.0,"$0");
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],3);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.449998,1.899999);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],6553800);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			// Avatar (7)
			p = 7;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,481.0,6.0,NULL_TXD);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],4);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.0,-2.0);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawUseBox(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p],64.0,64.0);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],1);
			// Level + XP (8-11)
			p = 8;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,514.0,62.0,"lvl 0");
			PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.329999,1.299999);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],0);
			progressbar_Create(playerid,e_ProgressBar:pb_xp); // ptdid: 9+10
			p = 11;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,307.0,417.0,"0 / 0");
			PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.329997,1.299998);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],0);
		}
		case ptd_powers:
		{
			// Categories (12-20), CD text (21-29), Category Names (30-38), Powers (39-83)
			for(new i = 0; i < MAX_POWER_CATEGORIES; i++)
			{
				p = 12+i;
				PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,130.0 + floatmul(40.0,float(i)),364.0,NULL_TXD);
				PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
				PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],4);
				PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.0,-2.0);
				PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
				PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
				PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
				PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],1);
				PlayerTextDrawUseBox(playerid,PlayerInfo[playerid][pPTD][p],1);
				PlayerTextDrawBoxColor(playerid,PlayerInfo[playerid][pPTD][p],255);
				PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p],32.0,32.0);
				PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],1);
				p = 12+i+MAX_POWER_CATEGORIES;
				PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,146.0 + floatmul(40.0,float(i)),375.0,"999");
				PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
				PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
				PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],2);
				PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.329997,1.299998);
				PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
				PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
				PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
				PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
				PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],0);
				p = 12+i+(MAX_POWER_CATEGORIES*2);
				PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,147.0 + floatmul(40.0,float(i)),395.0,"-");
				PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
				PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
				PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],2);
				PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.180000, 0.899999);
				PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
				PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
				PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
				PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
				PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p],16.0,40.0);
				PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],1);
				for(new j = 0; j < MAX_POWERS_PER_CATEGORY; j++)
				{
					p = 12+(MAX_POWER_CATEGORIES*3)+j+(MAX_POWERS_PER_CATEGORY*i);
					PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,147.0 + floatmul(40.0,float(i)),350.0-floatmul(12.0,float(j)),"-");
					PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
					PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
					PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],2);
					PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.329997,1.299998);
					PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
					PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
					PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
					PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
					PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p],12.0,150.0);
					PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],1);
				}
			}
		}
		case ptd_items:
		{
			// Item Selection (84-87)
			p = 84;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,550.0,354.0,NULL_TXD);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],4);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.0,-2.0);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawUseBox(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawBoxColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p],40.0,40.0);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],1);
			p = 85;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,499.0,371.0,NULL_TXD);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],4);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.0,-2.0);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawUseBox(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawBoxColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p],32.0,32.0);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],1);
			p = 86;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,601.0,371.0,NULL_TXD);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],4);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.0,-2.0);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawUseBox(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawBoxColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p],32.0,32.0);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],1);
			p = 87;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,569.0,347.0,"ITEM NAME~n~~n~~n~~n~0");
			PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.210000,1.100000);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],0);
		}
		case ptd_loading:
		{
			// Loading Bar (88-90)
			progressbar_Create(playerid,e_ProgressBar:pb_loading); // ptdid: 88+89
			p = 90;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,250.0,300.0,"loading: 000%");
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.500000,1.700000);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],-1);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
		}
		case ptd_notifications:
		{
			// Notification Text (91)
			p = 91;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,319.000000,336.000000,"Notification Text");
			PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.300000,1.100000);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p],630.000000,630.000000);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],0);
		}
		case ptd_buffs:
		{
			// Buffs / Debuffs (92-101)
			p = 92;
			for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++)
			{
				PlayerInfo[playerid][pPTD][p+i] = CreatePlayerTextDraw(playerid,610.0,320.0 + (13.0*i),i < 5 ? ("ld_beat:triang") : ("ld_beat:circle"));
				PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p+i],255);
				PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p+i],4);
				PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p+i],0.000000,-3.000000);
				PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p+i],-1);
				PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p+i],0);
				PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p+i],1);
				PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p+i],1);
				PlayerTextDrawUseBox(playerid,PlayerInfo[playerid][pPTD][p+i],1);
				PlayerTextDrawBoxColor(playerid,PlayerInfo[playerid][pPTD][p+i],255);
				PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][p+i],20.000000,16.000000);
				PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p+i],1);
			}
		}
		case ptd_soundtrack:
		{
			// Soundtrack (102)
			p = 102;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,560.000000,74.000000,"Soundtrack:~n~");
			PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.300000,1.100000);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],0x3B7A57FF);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],0);
		}
		case ptd_movie:
		{
			// Movie (103)
			p = 103;
			PlayerInfo[playerid][pPTD][p] = CreatePlayerTextDraw(playerid,560.000000,124.000000,"Movie:~n~");
			PlayerTextDrawAlignment(playerid,PlayerInfo[playerid][pPTD][p],2);
			PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][p],255);
			PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][p],0.300000,1.100000);
			PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][p],0x007FFFFF);
			PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][p],1);
			PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][p],0);
			PlayerTextDrawSetSelectable(playerid,PlayerInfo[playerid][pPTD][p],0);
		}
	}
}
@f(_,ptd.Update(playerid,e_PlayerTD:ptdid,upd[]=""))
{
	new bool:all = !strlen(upd);
	switch(ptdid)
	{
		case ptd_stats:
		{
			if(all || equal(upd,"health"))
			{
				progressbar_SetValue(playerid,e_ProgressBar:pb_health,math_percent(PlayerInfo[playerid][pHealth],stats_GetStats(playerid,stats_health))); // health bar
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][4],f("%.0f/%.0f",PlayerInfo[playerid][pHealth],stats_GetStats(playerid,stats_health))); // health text
				PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][4],PlayerInfo[playerid][pUnderAttack] ? -939511041 : -1);
			}
			if(all || equal(upd,"chakra"))
			{
				progressbar_SetValue(playerid,e_ProgressBar:pb_chakra,math_percent(PlayerInfo[playerid][pChakra],stats_GetStats(playerid,stats_chakra))); // chakra bar
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][5],f("%.0f/%.0f",PlayerInfo[playerid][pChakra],stats_GetStats(playerid,stats_chakra))); // chakra text
			}
			if(all || equal(upd,"money")) PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][6],f("$%06d",money_Get(playerid))); // ryo
			if(all || equal(upd,"avatar")) PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][7],TXDName(stats_GetAvatar(playerid))); // avatar
			if(all || equal(upd,"lvl"))
			{
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][8],f("lvl %d",level_Get(playerid))); // lvl
				progressbar_SetValue(playerid,e_ProgressBar:pb_xp,math_percent(xp_Get(playerid),xp_GetNextLevel(playerid))); // xp bar
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][11],f("%d / %d",xp_Get(playerid),xp_GetNextLevel(playerid))); // xp text
			}
		}
		case ptd_powers:
		{
			new tmp[MAX_NAME_LENGTH];
			for(new i = 1; i <= MAX_POWER_CATEGORIES; i++)
			{
				if(!power_HaveCategory(playerid,i)) continue;
				if(all || equal(upd,"create"))
				{
					GetPVarString(playerid,power_Var(i,0,"image"),tmp,sizeof(tmp));
					PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][11+i],TXDName(tmp)); // category image
					GetPVarString(playerid,power_Var(i,0,"name"),tmp,sizeof(tmp));
					PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][11+i+(MAX_POWER_CATEGORIES*2)],tmp); // category name
					for(new j = 1, dx = 0, pidx = -1; j <= MAX_POWERS_PER_CATEGORY; j++) if(power_HavePower(playerid,i,j))
					{
						dx = 11+(MAX_POWER_CATEGORIES*3)+j+(MAX_POWERS_PER_CATEGORY*(i-1)), pidx = power_IndexAtPos(playerid,i,j);
						if(pidx != -1) PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][dx],PowerInfo[pidx][pwName]); // power name
					}
				}
				if(all || equal(upd,"cd"))
				{
					valstr(tmp,cooldown_TimeLeft(playerid,i));
					PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][11+i+MAX_POWER_CATEGORIES],tmp); // cooldown text
				}
			}
		}
		case ptd_items:
		{
			if(all || equal(upd,"switch"))
			{
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][84],NULL_TXD); // current
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][85],NULL_TXD); // previous
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][86],NULL_TXD); // next
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][87],"ITEM NAME~n~~n~~n~~n~0"); // current item info
			}
			if(all || equal(upd,"ammo")) PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][87],"ITEM NAME~n~~n~~n~~n~0"); // current item info
		}
		case ptd_loading:
		{
			new Float:perc = math_percent(PlayerInfo[playerid][pLoading][0],LOADING_END);
			progressbar_SetValue(playerid,e_ProgressBar:pb_loading,perc);
			PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][90],f("loading: %03d%c",floatround(perc),'%'));
		}
		case ptd_notifications: PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][91],upd);
		case ptd_buffs:
		{
			new buffs = 0, debuffs = 0;
			for(new i = 0; i < MAX_BUFFS_PER_PLAYER; i++)
			{
				PlayerTextDrawHide(playerid,PlayerInfo[playerid][pPTD][92+i]);
				if(PlayerInfo[playerid][pBuff][i] > 0) PlayerTextDrawShow(playerid,PlayerInfo[playerid][pPTD][92 + (PlayerInfo[playerid][pBuffType] ? (buffs++) : (debuffs++))]);
			}
		}
		case ptd_soundtrack:
		{
			new i = audio_Index(upd);
			if(i != -1)
			{
				PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][102],f("Soundtrack:~n~%s",SoundInfo[i][sndName]));
				ptd_SetAlpha(playerid,0,ptdid,0x3B7A57FF,550);
			}
		}
		case ptd_movie:
		{
			PlayerTextDrawSetString(playerid,PlayerInfo[playerid][pPTD][103],f("Movie:~n~%s",upd));
			ptd_SetAlpha(playerid,1,ptdid,0x007FFFFF,550);
		}
	}
}
@f(_,ptd.Destroy(playerid,e_PlayerTD:ptdid))
{
	new st = 0, ed = 0;
	ptd_GetMinMax(ptdid,st,ed);
	for(new i = st; i <= ed; i++) PlayerTextDrawDestroy(playerid,PlayerInfo[playerid][pPTD][i]);
}
@f(bool,ptd.Action(playerid,e_PlayerTD:ptdid,act,param=0,param2=0))
{
	new st = 0, ed = 0, cat = -1, pow = -1, bool:vis = true;
	ptd_GetMinMax(ptdid,st,ed);
	for(new i = st; i <= ed && ((act == 3 && vis) || act != 3); i++)
	{
		if(ptdid == ptd_powers)
		{
			if(param == 2) i = st = ed = (20 + param2);
			switch(i)
			{
				case 12..38:
				{
					if(param == 1) continue;
					if(param == 2 && i < 21 && i > 29) continue;
					cat = i-11;
					while(cat > MAX_POWER_CATEGORIES) cat -= MAX_POWER_CATEGORIES;
					if(GetPVarType(playerid,power_Var(cat,0,"name")) == PLAYER_VARTYPE_NONE) continue;
					if(i >= 21 && i <= 29 && !cooldown_TimeLeft(playerid,cat) && param != 2) continue;
				}
				case 39..83:
				{
					if(param == 2) continue;
					cat = ((i-39)/MAX_POWERS_PER_CATEGORY+1), pow = ((i-39+MAX_POWERS_PER_CATEGORY)%MAX_POWERS_PER_CATEGORY)+1;
					if(GetPVarType(playerid,power_Var(cat,pow,"puid")) == PLAYER_VARTYPE_NONE) continue;
					if(param != 1 || (param == 1 && cat != param2)) continue;
				}
			}
		}
		switch(act)
		{
			case 1: PTDShow(playerid,PlayerInfo[playerid][pPTD][i]);
			case 2: PTDHide(playerid,PlayerInfo[playerid][pPTD][i]);
			case 3: if(!PTDIsVisible(playerid,PlayerInfo[playerid][pPTD][i])) vis = false;
		}
	}
	return vis;
}
@f(_,ptd.Show(playerid,e_PlayerTD:ptdid,param=0,param2=0)) return ptd_Action(playerid,ptdid,1,param,param2);
@f(_,ptd.Hide(playerid,e_PlayerTD:ptdid,param=0,param2=0)) return ptd_Action(playerid,ptdid,2,param,param2);
@f(bool,ptd.IsVisible(playerid,e_PlayerTD:ptdid,param=0,param2=0)) return ptd_Action(playerid,ptdid,3,param,param2);
@f(_,ptd.HideAll(playerid)) for(new i = 0; i < sizeof(initptds); i++) ptd_Hide(playerid,initptds[i]);
@f(_,ptd.GetMinMax(e_PlayerTD:ptdid,&st,&ed))
{
	switch(ptdid)
	{
		case ptd_stats: st = 0, ed = 11;
		case ptd_powers: st = 12, ed = 83;
		case ptd_items: st = 84, ed = 87;
		case ptd_loading: st = 88, ed = 90;
		case ptd_notifications: st = 91, ed = 91;
		case ptd_buffs: st = 92, ed = 101;
		case ptd_soundtrack: st = 102, ed = 102;
		case ptd_movie: st = 103, ed = 103;
	}
}
@f(_,ptd.SetAlpha(playerid,alphaid,e_PlayerTD:ptdid,color,amount))
{
	PlayerInfo[playerid][pPTDAlpha][alphaid] = amount;
	PlayerInfo[playerid][pPTDAlphaID][alphaid] = ptdid;
	PlayerInfo[playerid][pPTDAlphaColor][alphaid] = color;
	PlayerInfo[playerid][pPTDNeedAlpha] = true;
}
// Progress Bars
@f(_,progressbar.Initialize(e_ProgressBar:pb,ptdid,Float:x,Float:y,Float:width,Float:height,bgcolor,vlcolor))
{
	new pbid = _:pb;
	ProgressBar[pbid][pbValid] = true;
	ProgressBar[pbid][pbPTDID] = ptdid;
	ProgressBar[pbid][pbCoords][0] = x, ProgressBar[pbid][pbCoords][1] = y, ProgressBar[pbid][pbCoords][2] = width, ProgressBar[pbid][pbCoords][3] = height;
	ProgressBar[pbid][pbColors][0] = bgcolor, ProgressBar[pbid][pbColors][1] = vlcolor;
}
@f(_,progressbar.Create(playerid,e_ProgressBar:pb))
{
	new pbid = _:pb;
	PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]] = CreatePlayerTextDraw(playerid,ProgressBar[pbid][pbCoords][0],ProgressBar[pbid][pbCoords][1],".");
	PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],255);
	PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],1);
	PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],0.500000,ProgressBar[pbid][pbCoords][3]);
	PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],0);
	PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],0);
	PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],1);
	PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],0);
	PlayerTextDrawUseBox(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],1);
	PlayerTextDrawBoxColor(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],ProgressBar[pbid][pbColors][0]);
	PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]],ProgressBar[pbid][pbCoords][0]-5.0+ProgressBar[pbid][pbCoords][2],ProgressBar[pbid][pbCoords][3]);
	PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1] = CreatePlayerTextDraw(playerid,ProgressBar[pbid][pbCoords][0],ProgressBar[pbid][pbCoords][1],".");
	PlayerTextDrawBackgroundColor(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],255);
	PlayerTextDrawFont(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],1);
	PlayerTextDrawLetterSize(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],0.500000,ProgressBar[pbid][pbCoords][3]);
	PlayerTextDrawColor(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],0);
	PlayerTextDrawSetOutline(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],0);
	PlayerTextDrawSetProportional(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],1);
	PlayerTextDrawSetShadow(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],0);
	PlayerTextDrawUseBox(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],1);
	PlayerTextDrawBoxColor(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],ProgressBar[pbid][pbColors][1]);
	PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],ProgressBar[pbid][pbCoords][0]-5.0,ProgressBar[pbid][pbCoords][3]);
}
@f(_,progressbar.SetValue(playerid,e_ProgressBar:pb,Float:percent))
{
	new pbid = _:pb;
	PlayerTextDrawTextSize(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1],ProgressBar[pbid][pbCoords][0]-5.0+floatmul(floatdiv(ProgressBar[pbid][pbCoords][2],100.0),percent),ProgressBar[pbid][pbCoords][3]);
	if(PTDIsVisible(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1])) PlayerTextDrawShow(playerid,PlayerInfo[playerid][pPTD][ProgressBar[pbid][pbPTDID]+1]);
}
// Screen Fade
@f(_,screenfade.Start(playerid,e_ScreenFade:type,color,tick = 1,fadetype = 0,param = 0))
{
	PlayerInfo[playerid][pScreenFade] = type;
	PlayerInfo[playerid][pScreenFadeInfo][0] = fadetype;
	PlayerInfo[playerid][pScreenFadeInfo][1] = param;
	PlayerInfo[playerid][pScreenFadeInfo][2] = tick > 0 ? 0 : 255;
	PlayerInfo[playerid][pScreenFadeInfo][3] = color;
	PlayerInfo[playerid][pScreenFadeInfo][4] = tick;
	TextDrawBoxColor(fadeText,0);
	TextDrawShowForPlayer(playerid,fadeText);
}
@f(_,screenfade.Stop(playerid))
{
	PlayerInfo[playerid][pScreenFade] = e_ScreenFade:screenfade_none, PlayerInfo[playerid][pScreenFadeInfo] = {0,0,0,0,0};
	TextDrawHideForPlayer(playerid,fadeText);
}
// Side Menus
@f(_,sidemenu.Create(e_SideMenu:id,header[]))
{
	new smidx = -1;
	const MENU_LENGTH = 14;
	for(new i = 0; i < MAX_SIDE_MENUS && smidx == -1; i++) if(!SideMenuInfo[i][smValid]) smidx = i;
	if(smidx != -1)
	{
		SideMenuInfo[smidx][smValid] = true;
		SideMenuInfo[smidx][smID] = id;
		str_set(SideMenuInfo[smidx][smHeader],header,32);
		SideMenuInfo[smidx][smParent] = -1;
		SideMenuInfo[smidx][smSubID] = 0;
		SideMenuInfo[smidx][smMenuTD][0] = TextDrawCreate(7.000000,268.000000,f("%s~n~%s",header,str_mul("~n~",MENU_LENGTH)));
		TextDrawBackgroundColor(SideMenuInfo[smidx][smMenuTD][0],255);
		TextDrawFont(SideMenuInfo[smidx][smMenuTD][0],2);
		TextDrawLetterSize(SideMenuInfo[smidx][smMenuTD][0],0.250000,1.000000);
		TextDrawColor(SideMenuInfo[smidx][smMenuTD][0],173079190);
		TextDrawSetOutline(SideMenuInfo[smidx][smMenuTD][0],0);
		TextDrawSetProportional(SideMenuInfo[smidx][smMenuTD][0],1);
		TextDrawSetShadow(SideMenuInfo[smidx][smMenuTD][0],0);
		TextDrawUseBox(SideMenuInfo[smidx][smMenuTD][0],1);
		TextDrawBoxColor(SideMenuInfo[smidx][smMenuTD][0],150);
		TextDrawTextSize(SideMenuInfo[smidx][smMenuTD][0],125.0,0.0);
		TextDrawSetSelectable(SideMenuInfo[smidx][smMenuTD][0],1);
		SideMenuInfo[smidx][smMenuTD][1] = TextDrawCreate(77.000000,268.000000 + floatmul(9.0,float(MENU_LENGTH)),"(X) Close");
		TextDrawBackgroundColor(SideMenuInfo[smidx][smMenuTD][1],255);
		TextDrawFont(SideMenuInfo[smidx][smMenuTD][1],2);
		TextDrawLetterSize(SideMenuInfo[smidx][smMenuTD][1],0.250000,1.000000);
		TextDrawColor(SideMenuInfo[smidx][smMenuTD][1],-16119146);
		TextDrawSetOutline(SideMenuInfo[smidx][smMenuTD][1],0);
		TextDrawSetProportional(SideMenuInfo[smidx][smMenuTD][1],1);
		TextDrawSetShadow(SideMenuInfo[smidx][smMenuTD][1],0);
		TextDrawTextSize(SideMenuInfo[smidx][smMenuTD][1],130.0,10.0);
		TextDrawSetSelectable(SideMenuInfo[smidx][smMenuTD][1],1);
	}
	return smidx;
}
@f(_,sidemenu.CreateSub(parent,e_SideMenu:id,subid,header[]))
{
	new smidx = sidemenu_Create(id,header);
	if(smidx != -1)
	{
		SideMenuInfo[smidx][smSubID] = subid, SideMenuInfo[smidx][smParent] = parent;
		TextDrawSetString(SideMenuInfo[smidx][smMenuTD][1],"(X) Back");
	}
	return smidx;
}
@f(_,sidemenu.AddButton(smidx,code[],key[],button[]))
{
	new bsmidx = -1;
	for(new i = 0, m = MAX_SIDE_MENUS * MAX_SIDE_BUTTONS; i < m && bsmidx == -1; i++) if(!SideMenuButtonInfo[i][smbValid]) bsmidx = i;
	if(bsmidx != -1)
	{
		SideMenuButtonInfo[bsmidx][smbValid] = true;
		str_set(SideMenuButtonInfo[bsmidx][smbKey],key,4);
		SideMenuButtonInfo[bsmidx][smbKeyID] = key_FindID(key);
		str_set(SideMenuButtonInfo[bsmidx][smbCode],code,8);
		str_set(SideMenuButtonInfo[bsmidx][smbText],button,32);
		SideMenuButtonInfo[bsmidx][smbMenu] = smidx;
		SideMenuButtonInfo[bsmidx][smbButtonTD] = TextDrawCreate(7.0,286.0 + floatmul(9.0,float(SideMenuInfo[smidx][smButtons])),f("%s\t\t%s",key,button));
		TextDrawBackgroundColor(SideMenuButtonInfo[bsmidx][smbButtonTD],255);
		TextDrawFont(SideMenuButtonInfo[bsmidx][smbButtonTD],2);
		TextDrawLetterSize(SideMenuButtonInfo[bsmidx][smbButtonTD],0.250000,1.000000);
		TextDrawColor(SideMenuButtonInfo[bsmidx][smbButtonTD],-1);
		TextDrawSetOutline(SideMenuButtonInfo[bsmidx][smbButtonTD],0);
		TextDrawSetProportional(SideMenuButtonInfo[bsmidx][smbButtonTD],1);
		TextDrawSetShadow(SideMenuButtonInfo[bsmidx][smbButtonTD],0);
		TextDrawTextSize(SideMenuButtonInfo[bsmidx][smbButtonTD],150.0,10.0);
		TextDrawSetSelectable(SideMenuButtonInfo[bsmidx][smbButtonTD],1);
		SideMenuInfo[smidx][smButton][SideMenuInfo[smidx][smButtons]++] = bsmidx;
		//TextDrawSetString(SideMenuInfo[smidx][smMenuTD][0],f("%s~n~%s",SideMenuInfo[smidx][smHeader],str_mul("~n~",SideMenuInfo[smidx][smButtons])));
	}
}
/*@f(_,sidemenu.FormatButton(id,subid,code[],const types[]="",{Float,_}:...)) damn this world! I can't do such thing because the text draws are global ><
{
	new smidx = sidemenu_GetIndex(id,subid);
	if(smidx != -1)
	{
		new bsmidx = -1;
		for(new i = 0; i < SideMenuInfo[smidx][smButtons] && bsmidx == -1; i++) if(equal(SideMenuButtonInfo[SideMenuInfo[smidx][smButton][i]][smbCode],code)) bsmidx = i;
		if(bsmidx != -1)
		{
			new newText[32];
			format(newText,sizeof(newText),SideMenuButtonInfo[SideMenuInfo[smidx][smButton][bsmidx]][smbText]);
			const prefix = 4;
			if(numargs() > prefix)
			{
				new c = numargs() - prefix, cur = 1, num[16], strArg[32];
				while(cur <= c)
				{
					format(num,sizeof(num),"{%d}",cur);
					switch(types[cur-1])
					{
						case 's': { GetStringArg(prefix+cur-1,strArg); }
						case 'i', 'd': valstr(strArg,getarg(prefix+cur-1));
						case 'f': format(strArg,sizeof(strArg),"%.4f",getarg(prefix+cur-1));
					}
					format(newText,32,str_replace(num,strArg,newText));
					format(strArg,sizeof(strArg),"");
					cur++;
				}
			}
			TextDrawSetString(SideMenuButtonInfo[SideMenuInfo[smidx][smButton][bsmidx]][smbButtonTD],newText);
		}
	}
}*/
@f(_,sidemenu.Open(playerid,e_SideMenu:id,subid))
{
	new smidx = sidemenu_GetIndex(id,subid);
	if(PlayerInfo[playerid][pSideMenu] == smidx) return;
	if(PlayerInfo[playerid][pSideMenu] == -1) for(new i = MIN_KEY_ID; i < MAX_KEY_ID; i++) PlayerInfo[playerid][pBindedKeys][i-MIN_KEY_ID] = key_IsBinded(playerid,i);
	else sidemenu_Close(playerid,true);
	PlayerInfo[playerid][pSideMenu] = smidx;
	if(PlayerInfo[playerid][pSideMenu] != -1) for(new i = 0, m = max(2,SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smButtons]); i < m; i++)
	{
		if(i < 2) TDShow(playerid,SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smMenuTD][i]);
		if(i < SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smButtons])
		{
			TDShow(playerid,SideMenuButtonInfo[SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smButton][i]][smbButtonTD]);
			key_Bind(playerid,SideMenuButtonInfo[SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smButton][i]][smbKeyID]);
		}
	}
	key_Bind(playerid,KEYID_X);
	cursor_Show(playerid);
}
@f(_,sidemenu.Close(playerid,bool:all = false))
{
	if(PlayerInfo[playerid][pSideMenu] != -1)
	{
		for(new i = 0, m = max(2,SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smButtons]); i < m; i++)
		{
			if(i < 2) TDHide(playerid,SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smMenuTD][i]);
			if(i < SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smButtons])
			{
				TDHide(playerid,SideMenuButtonInfo[SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smButton][i]][smbButtonTD]);
				key_Unbind(playerid,SideMenuButtonInfo[SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smButton][i]][smbKeyID]);
			}
		}
		if(all) PlayerInfo[playerid][pSideMenu] = -1;
		else
		{
			new smidx = PlayerInfo[playerid][pSideMenu];
			PlayerInfo[playerid][pSideMenu] = -1;
			if(SideMenuInfo[smidx][smParent] != -1) sidemenu_Open(playerid,SideMenuInfo[smidx][smID],SideMenuInfo[smidx][smParent]);
		}
	}
	if(PlayerInfo[playerid][pSideMenu] == -1)
	{
		cursor_Hide(playerid);
		key_Unbind(playerid,KEYID_X);
		for(new i = MIN_KEY_ID; i < MAX_KEY_ID; i++)
		{
			if(PlayerInfo[playerid][pBindedKeys][i-MIN_KEY_ID]) key_Bind(playerid,i);
			PlayerInfo[playerid][pBindedKeys][i-MIN_KEY_ID] = false;
		}
	}
}
@f(_,sidemenu.GetCurrent(playerid)) return PlayerInfo[playerid][pSideMenu];
@f(e_SideMenu,sidemenu.GetCurrentType(playerid)) return PlayerInfo[playerid][pSideMenu] > -1 ? SideMenuInfo[PlayerInfo[playerid][pSideMenu]][smID] : e_SideMenu:sidemenu_none;
@f(_,sidemenu.GetIndex(e_SideMenu:id,subid = 0))
{
	for(new i = 0; i < MAX_SIDE_MENUS; i++) if(SideMenuInfo[i][smValid] && SideMenuInfo[i][smID] == id && SideMenuInfo[i][smSubID] == subid) return i;
	return -1;
}
