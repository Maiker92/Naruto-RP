#tryinclude "string.inc"
@f(_,str.replace(findwhat[],replacewith[],const source[],bool=false))
{
	new findwhatLen = strlen(findwhat), replacewithLen = strlen(replacewith), sourceLen = strlen(source), difference = (sourceLen - findwhatLen) + 1, tmp[256], ret[M_D_L];
	strcat(ret,source);
	for(new i = 0; i < difference; i++)
	{
		strmid(tmp,ret,i,(i + findwhatLen),(findwhatLen + 1));
		if(!strcmp(tmp,findwhat,bool:bool))
		{
			strdel(ret,i,i + findwhatLen);
			strins(ret,replacewith,i,replacewithLen);
			i += findwhatLen;
		}
	}
	return ret;
}
@f(_,str.repeat(const source[], count))
{
	new sourceLen = strlen(source), mul = (sourceLen * count), i = 0, ret[M_S*2];
	while(i < mul)
	{
		strins(ret,source,i);
		i += sourceLen;
	}
	return ret;
}
@f(_,str.trim(const source[]))
{
	new begin, end, sourceLen = strlen(source), ret[M_S*2];
	strcat(ret,source);
	for(begin = 0; begin < sourceLen; begin++) switch(ret[begin])
	{
		case ' ', '\t', '\r', '\n': continue;
		default: break;
	}
	for(end = (sourceLen - 1); end > begin; end--) switch(ret[end])
	{
		case ' ', '\t', '\r', '\n': continue;
		default: break;
	}
	strdel(ret,(end + 1),sourceLen);
	strdel(ret,0,begin);
	return ret;
}
@f(_,str.split(const strsrc[],strdest[][],delimiter,strdestsize = sizeof strdest))
{
	str_reset2d(strdest,strdestsize);
	new i, li, aNum, len, len2 = strlen(strsrc);
	while(i <= len2)
	{
		if(strsrc[i] == delimiter || i == len2)
		{
			len = strmid(strdest[aNum],strsrc,li,i,128);
			strdest[aNum][len] = 0;
			li = i + 1;
			aNum++;
		}
		i++;
	}
}
@f(_,str.add(src[],const newline[],const seperator[],maxlen = sizeof src))
{
	if(strlen(src) > 0) strcat(src,seperator,maxlen);
	strcat(src,newline,maxlen);
}
@f(_,str.reset(src[])) return src[0] = '\0', 1;
@f(_,str.reset2d(src[][],size = sizeof src)) for(new i = 0; i < size; i++) src[i][0] = '\0';
@f(_,str.findin2d(find[],src[][],size = sizeof src))
{
	for(new i = 0; i < size; i++) if(equal(src[i],find)) return i;
	return -1;
}
@f(_,str.repchar(src[],ch,rep)) for(new i = 0, m = strlen(src); i < m; i++) if(src[i] == ch) src[i] = rep;
@f(bool,str.isnum(const string_[]))
{
	for(new i = string_[0] == '-' ? 1 : 0, j = strlen(string_); i < j; i++) if(string_[i] < '0' || string_[i] > '9') return false;
	return true;
}
@f(bool,str.isfloat(const string_[]))
{
	new dots = 0;
	for(new i = string_[0] == '-' ? 1 : 0, j = strlen(string_); i < j; i++)
	{
		if(string_[i] < '0' || string_[i] > '9') return false;
		if(string_[i] == '.') if(++dots > 1) return false;
	}
	return true;
}
@f(_,str.tok(const string_[], &index, somechar = ' '))
{   // by CompuPhase, improved by me
	new length = strlen(string_), result[M_S];
	while((index < length) && (string_[index] <= somechar)) index++;
	new offset = index;
	while((index < length) && (string_[index] > somechar) && ((index - offset) < (sizeof(result) - 1))) result[index - offset] = string_[index], index++;
	result[index - offset] = EOS;
	return result;
}
@f(_,str.rest(const string_[], index, somechar = ' '))
{   // by CompuPhase, improved by me
	new length = strlen(string_), offset = index, result[M_S];
	while((index < length) && ((index - offset) < (sizeof(result) - 1)) && (string_[index] > '\r')) result[index - offset] = string_[index], index++;
	result[index - offset] = EOS;
	if(result[0] == somechar && string_[0] != somechar) strdel(result,0,1);
	return result;
}
@f(_,str.set(dest[],source[],maxlength))
{
	new count = strlen(source);
	for(new i = 0; i < count && i < maxlength; i++) dest[i] = source[i];
	dest[count] = 0;
	return 1;
}
@f(_,str.generate(length,bool:nums=false,bool:abc=false,bool:ABC=false,bool:symbols=false))
{
	new ret[M_S], allowedChars[128];
	if(nums) allowedChars = "0123456789";
	if(abc) format(allowedChars,sizeof(allowedChars),"%sabcdefghijklmnopqrstuvwxyz",allowedChars);
	if(ABC) format(allowedChars,sizeof(allowedChars),"%sABCDEFGHIJKLMNOPQRSTUVWXYZ",allowedChars);
	if(symbols) format(allowedChars,sizeof(allowedChars),"%s!@#$^&*(){}[]-=+<>:,",allowedChars);
	for(new i = 0, m = strlen(allowedChars); i < length; i++) format(ret,sizeof(ret),"%s%c",ret,allowedChars[random(m)]);
	return ret;
}
@f(_,str.firstchars(const source[],len=1))
{
	strmid(fstring,source,0,len);
	return fstring;
}
@f(_,str.lastchars(source[],len))
{
	new srclen = strlen(source);
	strmid(fstring,source,srclen-len,srclen,sizeof(fstring));
	return fstring;
}
@f(_,str.startswith(src[],str[])) return equal(str_firstchars(src,strlen(str)),str);
@f(_,str.endswith(src[],str[])) return equal(str_lastchars(src,strlen(str)),str);
@f(_,str.loadxyz(str[],Float:var[3]))
{
	new j = 0;
	for(new i = 0; i < sizeof(var); i++) var[i] = floatstr(str_tok(str,j,','));
}
@f(_,str.loadxyza(str[],Float:var[4]))
{
	new j = 0;
	for(new i = 0; i < sizeof(var); i++) var[i] = floatstr(str_tok(str,j,','));
}
@f(_,str.remchar(src[],ch)) for(new i = 0, j = strlen(src); i < j; i++) if(src[i] == ch) strdel(src,i,1);
@f(_,str.countchar(src[],ch))
{
	new c = 0;
	for(new i = 0, j = strlen(src); i < j; i++) if(src[i] == ch) c++;
	return c;
}
@f(_,str.upper(src[]))
{
	new ret[M_S];
	for(new i = 0, len = strlen(src); i < len; i++) ret[i] = toupper(src[i]);
	return ret;
}
@f(_,str.lower(src[]))
{
	new ret[M_S];
	for(new i = 0, len = strlen(src); i < len; i++) ret[i] = tolower(src[i]);
	return ret;
}
@f(_,str.mul(src[],times))
{
	new ret[M_S];
	for(new i = 0; i < times; i++) strcat(ret,src);
	return ret;
}
@f(_,str.join(arr[],len,sep[]))
{
	new ret[M_S];
	for(new i = 0; i < len; i++)
	{
		format(ret,sizeof(ret),"%s%d",ret,arr[i]);
		if(i < len-1) strcat(ret,sep);
	}
	return ret;
}
@f(_,str.joinf(Float:arr[],len,sep[]))
{
	new ret[M_S];
	for(new i = 0; i < len; i++)
	{
		format(ret,sizeof(ret),"%s%.4f",ret,arr[i]);
		if(i < len-1) strcat(ret,sep);
	}
	return ret;
}
