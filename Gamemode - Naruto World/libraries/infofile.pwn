@f(_,infofile.Initialize())
{
	dialog_Create(d_InfoFile,DIALOG_STYLE_MSGBOX,@c(DIALOG_DHEADER) "Info File","OK","",d_Null);
	dialog_AddLine(@c(DIALOG_HEADER) "(!) READING INFO FILE: {1}" @c(DIALOG_TEXT) "\n\n{2}");
}
@f(bool,infofile.Check(name[]))
{
	f(DIR_INFOFILES "/%s.txt",name);
	if(fexist(fstring)) return true;
	else file_Create(fstring);
	return false;
}
@f(_,infofile.Show(playerid,name[]))
{
	f(DIR_INFOFILES "/%s.txt",name);
	if(fexist(fstring))
	{
		new fulltext[M_D_L], line[256], File:fh = fopen(fstring,io_read);
		if(fh)
		{
			while(fread(fh,line)) if(line[0] != '#') format(fulltext,sizeof(fulltext),"%s%s",fulltext,line);
			strdel(name,strlen(name)-4,strlen(name));
			dialog_SetHeader(d_InfoFile,name);
			dialog_Show(playerid,d_InfoFile,"ss",str_upper(name),fulltext);
		}
	}
}
@f(_,infofile.Format(categ[],file[]))
{
	new str[64];
	format(str,sizeof(str),"%s-%s.txt",categ,file);
	return str;
}
