@f(_,dialog.Create(e_Dialog:id,style,header[],button1[],button2[],e_Dialog:parent))
{
	lastDialog = id;
    DialogInfo[_:id][dType] = style;
    DialogInfo[_:id][dTempType] = -1;
    format(DialogInfo[_:id][dHeader],64,header);
    format(DialogInfo[_:id][dButton1],32,button1);
    format(DialogInfo[_:id][dButton2],32,button2);
    DialogInfo[_:id][dParent] = parent;
    DialogInfo[_:id][dText][0] = EOS;
    return 1;
}
@f(_,dialog.AddLine(text[])) return format(DialogInfo[_:lastDialog][dText],M_D_L,DialogInfo[_:lastDialog][dText][0] == EOS ? ("%s%s") : ("%s\n%s"),DialogInfo[_:lastDialog][dText],text);
@f(_,dialog.SetHeader(e_Dialog:id,header[])) return format(DialogInfo[_:id][dHeader],64,header);
@f(_,dialog.SetType(e_Dialog:id,type)) return DialogInfo[_:id][dType] = type;
@f(_,dialog.SetTemporaryType(e_Dialog:id,type)) return DialogInfo[_:id][dTempType] = DialogInfo[_:id][dType], DialogInfo[_:id][dType] = type;
@f(_,dialog.SetParam(playerid,param[])) format(PlayerInfo[playerid][pDialogParam],32,param);
@f(_,dialog.GetParam(playerid)) return PlayerInfo[playerid][pDialogParam];
@f(_,dialog.SetButtons(e_Dialog:id,button1[],button2[]))
{
    format(DialogInfo[_:id][dButton1],32,button1);
    format(DialogInfo[_:id][dButton2],32,button2);
}
@f(_,dialog.Show(playerid,e_Dialog:id,const types[]="",{Float,_}:...))
{
	PlayerInfo[playerid][pDialogParam][0] = EOS;
	new sentText[M_D_L];
	format(sentText,M_D_L,DialogInfo[_:id][dText]);
	const prefix = 3;
	if(numargs() > prefix)
	{
		new c = numargs() - prefix, cur = 1, num[16], strArg[M_D_L];
		while(cur <= c)
		{
			format(num,sizeof(num),"{%d}",cur);
			switch(types[cur-1])
			{
				case 's': { GetStringArg(prefix+cur-1,strArg); }
				case 'i', 'd': valstr(strArg,getarg(prefix+cur-1));
				case 'f': format(strArg,M_S,"%.4f",getarg(prefix+cur-1));
			}
			if(types[cur-1] == 's' && !strlen(strArg)) strdel(sentText,strfind(sentText,num),strfind(sentText,num)+3);
			else format(sentText,M_D_L,str_replace(num,strArg,sentText));
			format(strArg,sizeof(strArg),"");
			cur++;
		}
	}
	ShowPlayerDialog(playerid,_:id,DialogInfo[_:id][dType],DialogInfo[_:id][dHeader],sentText,DialogInfo[_:id][dButton1],DialogInfo[_:id][dButton2]);
	if(DialogInfo[_:id][dTempType] != -1) DialogInfo[_:id][dType] = DialogInfo[_:id][dTempType], DialogInfo[_:id][dTempType] = -1;
	PlayerInfo[playerid][pDialog] = id;
	PlayerInfo[playerid][pDialogOneButton] = !strlen(DialogInfo[_:id][dButton2]);
	return 1;
}
@f(_,dialog.Hide(playerid))
{
	ShowPlayerDialog(playerid,-1,0,"","","","");
	PlayerInfo[playerid][pDialog] = d_Null;
}
@f(_,dialog.IsVisible(playerid,e_Dialog:id)) return PlayerInfo[playerid][pDialog] == id;
@f(_,dialog.IsAnyVisible(playerid)) return PlayerInfo[playerid][pDialog] != d_Null;
@f(_,dialog.GoBack(playerid))
{
	new e_Dialog:parent = PlayerInfo[playerid][pDialog] != d_Null ? DialogInfo[(_:(PlayerInfo[playerid][pDialog]))][dParent] : d_Null;
	if(parent != d_Null) dialog_Show(playerid,parent);
}
