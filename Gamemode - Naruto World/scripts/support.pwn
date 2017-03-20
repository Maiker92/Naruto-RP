// Anime Fantasy: Naruto World #17 script: support
#define function<%1> forward support_%1; public support_%1
#define MAX_HF_LINES 20
static helpFile[MAX_HELP_FILES][MAX_NAME_LENGTH], helpFiles = 0;
function<OnGameModeInit()>
{
	dialog_Create(d_Help,DIALOG_STYLE_LIST,@c(DIALOG_DHEADER) "Help Center","Close","",d_Null);
	dialog_AddLine(@c(DIALOG_TEXT) "{1}");
	dialog_Create(d_HelpSub,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Help","OK","",d_Help);
	dialog_AddLine(@c(DIALOG_TEXT) "{1}");
	new filename[64];
	idx = 0;
	while(ffind(DIR_HELP "/*.txt",filename,sizeof(filename),idx) && helpFiles < MAX_HELP_FILES)
	{
		format(filename,sizeof(filename),DIR_HELP "/%s",filename);
		strdel(filename,strfind(filename,"."),strlen(filename));
		str_set(helpFile[helpFiles++],filename,MAX_NAME_LENGTH);
		helpfile_Update(filename);
	}
	return 1;
}
function<OnGameModeExit()>
{
	return 1;
}
function<OnPlayerCommandText(playerid,cmdtext[])>
{
 	command(help,cmdtext);
	return 0;
}
function<OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])>
{
	if(dialogid == _:d_Help || dialogid == _:d_HelpSub)
	{
		new bool:go = false;
		if(response)
		{
			switch(helpfile_GetIntInfo(PlayerInfo[playerid][pHelpFile],"type"))
			{
				case DIALOG_STYLE_MSGBOX: go = true;
				case DIALOG_STYLE_LIST:
				{
					new goTo[MAX_NAME_LENGTH];
					format(goTo,sizeof(goTo),helpfile_GetStrInfo(PlayerInfo[playerid][pHelpFile],f("line%d",listitem)));
					strdel(goTo,0,strfind(goTo,"-")+1);
					helpfile_Show(playerid,goTo);
				}
			}
		}
		else
		{
			if(dialogid == _:d_Help) PlayerInfo[playerid][pHelpFile][0] = EOS;
			else go = true;
		}
		if(go) helpfile_Show(playerid,helpfile_GetStrInfo(PlayerInfo[playerid][pHelpFile],"click"));
	}
	return 1;
}
#undef function
// Help Files
@f(_,helpfile.Update(hfname[]=""))
{
	new filename[64], File:fh, line[M_S], lines = 0, key[64], val[64];
	format(filename,sizeof(filename),DIR_HELP "/%s.txt",!strlen(hfname) ? ("Help") : (hfname));
	fh = fopen(filename,io_read);
	if(fh) while(fread(fh,line) && lines < MAX_HF_LINES)
	{
		if(line[0] == ';' || strlen(line) <= 1) continue;
		if(strfind(line,"=") != -1)
		{
			strmid(key,line,0,strfind(line,"="));
			strmid(val,line,strfind(line,"=")+1,strlen(line));
			if(equal(key,"header")) property_StrSet(f("helpfile_%s_header",hfname),val);
			else if(equal(key,"type")) property_IntSet(f("helpfile_%s_type",hfname),strval(val));
			else if(equal(key,"click")) property_StrSet(f("helpfile_%s_click",hfname),val);
		}
		else property_StrSet(f("helpfile_%s_line%d",hfname,lines++),line);
	}
	property_IntSet(f("helpfile_%s_lines",hfname),lines);
	fclose(fh);
}
@f(_,helpfile.GetStrInfo(hfname[]="",info[])) return format(fstring,sizeof(fstring),property_StrGet(f("helpfile_%s_%s",hfname,info))), fstring;
@f(_,helpfile.GetIntInfo(hfname[]="",info[])) return property_IntGet(f("helpfile_%s_%s",hfname,info));
@f(_,helpfile.Show(playerid,hfname[]=""))
{
	new dialogFullText[M_D_L], type = helpfile_GetIntInfo(hfname,"type"), lines = helpfile_GetIntInfo(hfname,"lines");
	dialog_SetHeader(d_HelpSub,f(@c(DIALOG_DHEADER) "Help: %s",str_upper(hfname)));
	dialog_SetType(d_HelpSub,type);
	switch(type)
	{
		case DIALOG_STYLE_MSGBOX: for(new i = 0; i < lines; i++) str_add(dialogFullText,property_StrGet(f("helpfile_%s_line%d",hfname)),"\n");
		case DIALOG_STYLE_LIST:
		{
			new key[MAX_NAME_LENGTH];
			format(key,sizeof(key),property_StrGet(f("helpfile_%s_line%d",hfname)));
			strdel(key,strfind(key,"-"),strlen(key));
			for(new i = 0; i < lines; i++) str_add(dialogFullText,key,"\n");
		}
	}
	dialog_Show(playerid,!strlen(hfname) ? d_Help : d_HelpSub,"s",dialogFullText);
	str_set(PlayerInfo[playerid][pHelpFile],!strlen(hfname) ? ("Help") : (hfname),MAX_NAME_LENGTH);
}
@f(_,helpfile.IsExist(hfname[]=""))
{
	new filename[64];
	format(filename,sizeof(filename),DIR_HELP "/%s.txt",!strlen(hfname) ? ("Help") : (hfname));
	return fexist(filename);
}
// Description
@f(bool,description.IsValidCategory(cat[]))
{
	new descCats[][MAX_NAME_LENGTH] = {"Characters","OwnCharacters","Summonings","Teams","Powers","Places","Items","NPCs","Missions","Events","Jinchuurikies","Factions","Auras"};
	for(new i = 0; i < sizeof(descCats); i++) if(!strcmp(cat,descCats[i])) return true;
	return false;
}
@f(_,description.Check(cat[],code[]))
{
	assert description_IsValidCategory(cat);
	new dir[64];
	format(dir,sizeof(dir),DIR_DESC "/%s",cat);
	if(!fexist(dir)) dcreate(dir);
	format(dir,sizeof(dir),DIR_DESC "/%s/%s.txt",cat,code);
	if(!fexist(dir)) file_WriteAllText(dir,f("NO DESCRIPTION (%s/%s)",cat,code));
}
@f(_,description.Get(cat[],code[]))
{
	assert description_IsValidCategory(cat);
	new dir[64], fullDescription[M_D_L];
	format(dir,sizeof(dir),DIR_DESC "/%s/%s.txt",cat,code);
	if(fexist(dir))
	{
		new File:fh = fopen(dir,io_read);
		while(fread(fh,fstring)) str_add(fullDescription,fstring,"");
	}
	else format(fullDescription,sizeof(fullDescription),"UNDEFINED DESCRIPTION (%s/%s)",cat,code);
	return fullDescription;
}
// Commands
cmd.help(playerid,params[])
{
	#pragma unused params
	if(!helpfile_IsExist()) return chat_Error(playerid,"No help files. Please try again later.");
	helpfile_Show(playerid);
	return 1;
}
