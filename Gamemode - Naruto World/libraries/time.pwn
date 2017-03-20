@f(_,time.GetTimeAsString(bool:withseconds = false,tav = ':'))
{
	new t[3], s[16];
	gettime(t[0],t[1],t[2]);
	format(s,sizeof(s),"%02d%c%02d",t[0],tav,t[1]);
	if(withseconds) format(s,sizeof(s),"%s%c%02d",s,tav,t[2]);
	return s;
}
@f(_,time.GetDateAsString(tav = '/'))
{
	new d[3], s[16];
	getdate(d[0],d[1],d[2]);
	format(s,sizeof(s),"%02d%c%02d%c%d",d[2],tav,d[1],tav,d[0]);
	return s;
}
