#tryinclude "file.inc"
@f(_,file.ReadAllText(filename[],const exception[] = ""))
{
	new File:fh, line[M_S], read[M_D_L], len = strlen(exception);
	if(!fexist(filename)) return read;
	fh = fopen(filename,io_read);
	while(fread(fh,line))
	{
		if(len > 0) if(strfind(line,exception,true) != -1) continue;
		str_add(read,str_trim(line),"\n");
	}
	fclose(fh);
	return read;
}
@f(_,file.WriteAllText(filename[],text[]))
{
	new File:fh = fopen(filename,io_write);
	fwrite(fh,text);
	fclose(fh);
}
@f(_,file.Create(filename[])) fclose(fopen(filename,io_write));
@f(bool,file.IsValidName(filename[]))
{
	for(new i = 0, m = strlen(filename); i < m; i++)
	{
		if((filename[i] >= 'a' && filename[i] <= 'z') ||
		(filename[i] >= 'A' && filename[i] <= 'Z') ||
		(filename[i] >= '0' && filename[i] <= '9')) continue;
		return false;
	}
	return true;
}
