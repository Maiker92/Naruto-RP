// Anime Fantasy: Naruto World #04 script: chat
#define function<%1> forward chat_%1; public chat_%1
function<OnGameModeInit()>
{
	// Load text lines (not that this is relevant to the rest of this script code, but I have no other place to put that)
	textline_LoadAll();
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerText(playerid,text[])>
{
	format(PlayerInfo[playerid][pLastChat],MAX_CHAT_LENGTH,text);
	if(str_endswith(PlayerInfo[playerid][pLastChat],"!!!"))
	{
		strdel(PlayerInfo[playerid][pLastChat],strlen(PlayerInfo[playerid][pLastChat])-2,strlen(PlayerInfo[playerid][pLastChat]));
		chat_Shout(playerid,PlayerInfo[playerid][pLastChat]);
	}
	else if(str_startswith(PlayerInfo[playerid][pLastChat],".."))
	{
		strdel(PlayerInfo[playerid][pLastChat],0,2);
		chat_Whisper(playerid,PlayerInfo[playerid][pLastChat]);
	}
	else chat_Say(playerid,PlayerInfo[playerid][pLastChat]);
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
 	command(pm,cmdtext);
 	command(me,cmdtext);
 	command(whisper,cmdtext);
 	shortcut(w,cmdtext,whisper);
 	command(shout,cmdtext);
 	shortcut(s,cmdtext,shout);
	return 0;
}
#undef function
// Chat
@f(_,chat.Say(playerid,text[]))
{
	player_GetPosition(playerid);
	new Float:distance = floatmul(CHAT_DISTANCE_SAY,floatdiv(stats_GetStats(playerid,stats_noise),100.0));
	chat_Message(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],distance,f("%s: " @c(CHAT_TEXT) "%s",player_GetName(playerid),text),0xffffffff,true);
	new wordsCount = str_countchar(text,' ') + 1;
	anim_Apply(playerid,e_Animation:anim_chat,.time = max(wordsCount,3) * 500);
	return 1;
}
@f(_,chat.Shout(playerid,text[]))
{
	player_GetPosition(playerid);
	new Float:distance = floatmul(CHAT_DISTANCE_SHOUT,floatdiv(stats_GetStats(playerid,stats_noise),100.0));
	chat_Message(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],distance,f("%s shouts: " @c(CHAT_TEXT) "%s",player_GetName(playerid),text),0xffffffff,true);
	new wordsCount = str_countchar(text,' ') + 1;
	anim_Apply(playerid,e_Animation:anim_shout,.time = max(wordsCount,3) * 500);
	return 1;
}
@f(_,chat.Whisper(playerid,text[]))
{
	player_GetPosition(playerid);
	new Float:distance = floatmul(CHAT_DISTANCE_WHISPER,floatdiv(stats_GetStats(playerid,stats_noise),100.0));
	chat_Message(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],distance,f("%s whispers: " @c(CHAT_TEXT) "%s",player_GetName(playerid),text),0xffffffff,true);
	return 1;
}
@f(_,chat.Me(playerid,text[]))
{
	player_GetPosition(playerid);
	chat_Message(PlayerInfo[playerid][pPosition][0],PlayerInfo[playerid][pPosition][1],PlayerInfo[playerid][pPosition][2],CHAT_DISTANCE_ME,f(" * %s %s",player_GetName(playerid),text),0xffffffff,true);
	return 1;
}
@f(_,chat.Send(playerid,color,const message[]))
{
	if(PlayerInfo[playerid][pKick]) return 1;
	return SendClientMessage(playerid,color,message);
}
@f(_,chat.SendAll(color,const message[]))
{
	Loop(player,i) chat_Send(i,color,message);
	return 1;
}
@f(_,chat.Clear(playerid,bool = false)) for(new i = 0; i < 20 + (bool ? 100 : 0); i++) chat_Send(playerid,-1," ");
@f(_,chat.Message(Float:x,Float:y,Float:z,Float:distance=10.0,text[],color=0,bool:changedcolor=false))
{
	const half = MAX_CHAT_LENGTH / 2;
	new bool:findflag = false, findpos = strfind(text,"{"), len = strlen(text);
	if(findpos != -1) if(len > findpos+7) if(text[findpos+7] == '}') findflag = true;
	if(len > half && !findflag) // Until i'll find a way to ignore color embedding along the string, i'll be using this dirty trick
	{
		new text1[M_S], text2[M_S];
		strmid(text1,text,0,half);
		strmid(text2,text,half,len);
		if(!changedcolor)
		{
			Loop(player,i) if(IsPlayerInRangeOfPoint(i,floatmul(distance,floatdiv(stats_GetStats(i,stats_hearing),100.0)),x,y,z))
			{
				chat_Send(i,color,f("%s ..",text1));
				chat_Send(i,color,f(".. %s",text2));
			}
		}
		else
		{
			new tmp = -1;
			Loop(player,i) if(IsPlayerInRangeOfPoint(i,floatmul(distance,floatdiv(stats_GetStats(i,stats_hearing),100.0)),x,y,z))
			{
				player_GetPosition(i);
				chat_Send(i,tmp = color_SetShade(color,0-min(floatround(floatmul(floatdiv(255.0,distance),float(math_distance_3d(x,y,z,PlayerInfo[i][pPosition][0],PlayerInfo[i][pPosition][1],PlayerInfo[i][pPosition][2])))),200)),f("%s ..",text1));
				chat_Send(i,tmp,f(".. %s",text2));
			}
		}
	}
	else
	{
	    if(!changedcolor)
		{
			Loop(player,i) if(IsPlayerInRangeOfPoint(i,distance,x,y,z)) chat_Send(i,color,text);
  		}
	    else
		{
			Loop(player,i) if(IsPlayerInRangeOfPoint(i,distance,x,y,z))
			{
				player_GetPosition(i);
				chat_Send(i,color_SetShade(color,(0-min(floatround(floatmul(floatdiv(255.0,distance),float(math_distance_3d(x,y,z,PlayerInfo[i][pPosition][0],PlayerInfo[i][pPosition][1],PlayerInfo[i][pPosition][2])))),200))),text);
			}
		}
	}
	return 1;
}
@f(_,chat.System(playerid,systemcolor,text[]))
{
	new sysname[32];
	switch(systemcolor)
	{
		case CC_SYSTEM_NPCS: sysname = "NPC Control";
		case CC_SYSTEM_LOADING: format(sysname,sizeof(sysname),"Loading Step %d/%d",PlayerInfo[playerid][pLoading][0],LOADING_END);
		case CC_SYSTEM_PERMS: sysname = "Permissions";
		case CC_SYSTEM_VILLDBG: sysname = "Villager Debug";
	}
	return chat_Send(playerid,systemcolor,f("[%s]: " @c(CHAT_TEXT) "%s",sysname,text)), 1;
}
@f(_,chat.Error(playerid,text[])) return chat_Send(playerid,CC_CHAT_ERROR,f("[ERROR]: %s",text)), 1;
@f(_,chat.Usage(playerid,cmd[],...))
{
	new str[M_S*2], na = numargs(), c[64];
	format(str,sizeof(str),"[USAGE]: %s",cmd);
	if(na > 2)
	{
		if(na == 3)
		{
			GetStringArg(2,c);
			format(str,sizeof(str),"%s (" @c(CHAT_BOLD) "%s" @c(CHAT_USAGE) ")",str,c);
		}
		else for(new i = 2; i < na; i++)
		{
			GetStringArg(i,c);
			if(c[0] == '*')
			{
				strdel(c,0,1);
				strins(c,@c(CHAT_BOLD),0);
				strins(c,@c(CHAT_USAGE),strlen(c));
			}
			format(str,sizeof(str),"%s (%s)",str,c);
		}
	}
	return chat_Send(playerid,CC_CHAT_USAGE,str), 1;
}
@f(_,chat.Group(sender,e_Chats:chat,message[]))
{
	new chatName[16], chatColor = CC_COLOR_WHITE, reciever[MAX_PLAYERS] = {INVALID_PLAYER_ID,...}, recievers = 0, j = 0;
	switch(chat)
	{
		case chat_admins:
		{
			chatName = "Admins", chatColor = CC_COLOR_ORANGE;
			Loop(player,i) if(admin_IsAdmin(i) && i != sender) reciever[recievers++] = i;
		}
	}
	reciever[recievers++] = sender;
	f("<Chat: %s> %s (%s, %03d): %s",chatName,player_GetNickname(sender),player_GetName(sender),sender,message);
	while(j < recievers) chat_Send(reciever[j++],chatColor,fstring);
	return 1;
}
// Commands
cmd.pm(playerid,params[])
{
	new pl[64], text[MAX_CHAT_LENGTH];
	idx = 0;
	str_set(pl,str_tok(params,idx),64);
	text = str_rest(params,idx);
	if(!strlen(pl)) return chat_Usage(playerid,"/pm","*player","text");
	if(!strlen(text)) return chat_Usage(playerid,"/pm","player","*text");
	new id = convert_playerid(pl,playerid);
	if(!player_IsConnected(id)) return chat_Error(playerid,"Invalid player.");
	if(id == playerid) return chat_Error(playerid,"Why would you want to PM yourself?");
	chat_Send(id,CC_PM_IN,f("<< PM from %s (%s, %03d): %s",player_GetNickname(playerid),player_GetName(playerid),playerid,text));
	chat_Send(playerid,CC_PM_OUT,f(">> PM sent to %s (%s, %03d): %s",player_GetNickname(playerid),player_GetName(playerid),playerid,text));
    return 1;
}
cmd.me(playerid,params[])
{
	if(!strlen(params)) return chat_Usage(playerid,"/me","text");
	return chat_Me(playerid,params), 1;
}
cmd.whisper(playerid,params[])
{
	if(!strlen(params)) return chat_Usage(playerid,"/whisper","text to whisper");
	return chat_Whisper(playerid,params), 1;
}
cmd.shout(playerid,params[])
{
	if(!strlen(params)) return chat_Usage(playerid,"/shout","text to shout");
	return chat_Shout(playerid,params), 1;
}
