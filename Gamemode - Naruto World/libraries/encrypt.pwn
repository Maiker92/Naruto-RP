@f(_,encrypt.Password(password[]))
{
	new pass[64], length = strlen(password);
	for(new i = 0; i < length; i++) pass[i] = password[i];
	pass[length] = EOS;
	for(new i = 0; i < length; i++) if((pass[i] += (3 ^ i) * (i % 15)) > (0xff)) pass[i] -= 256;
	return pass;
}
@f(_,encrypt.Property(prop[]))
{
	new s[2] = {1,0};
	for(new i = 0, l = strlen(prop); i < l; i++) s[0] = (s[0] + prop[i]) % 65521, s[1] = (s[1] + s[0]) % 65521;
	return (s[1] << 16) + s[0];
}
