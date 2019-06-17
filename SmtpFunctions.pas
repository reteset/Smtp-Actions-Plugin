(*
** Implementation unit of the plugin which is used to send emails

** Author:  Serkan Onat
** Copy Right : Reteset Software https://wwww.reteset.net
*)


unit SmtpFunctions;

interface
  uses
  SysUtils,
  Windows,
  ComObj,
  PluginHelperFunctions,
  Lua,
  Lauxlib;

   function   SendMail(L: Plua_State): Integer; cdecl;
   function   RegisterPluginActions(L: Plua_State): Integer;

implementation

function SendMail(L: Plua_State): Integer; cdecl;
  var
  p:PChar;

  SmtpObject:OleVariant;
  SmtpConfig:OleVariant;
  szReturnVal:PChar;
  szXmailer:PChar;
  bHtmlBody:Boolean;
  bTextBody:Boolean;
  bCreateMHTMLBody:Boolean;

	szFromName:PChar;
	szFromEmail:PChar;
  szTo:PChar;
	szTextBody:PChar;
	szSubject:PChar;
  szImportance:PChar;
  szReplyTo:PChar;
	szCC:PChar;
  szBCC:PChar;
	szServer:PChar;
	nServerPort:Double;
  szUserName:PChar;
	szPassWord:PChar;
	Authenticated:Boolean;
	UseSSL:Boolean;
  const SchemaUrl:PChar = 'http://schemas.microsoft.com/cdo/configuration/';
  begin

  szReturnVal := 'OK';
  bHtmlBody := False;
  bTextBody := False;
	szFromName := '';
	szFromEmail := '';
  szTo := '';
	szTextBody := '';
	szSubject := '';
  szImportance := 'normal';
	szCC := '';
  szBCC := '';
  szReplyTo := '';
	szServer := '';
	nServerPort := 20;
  szUserName := '';
	szPassWord := '';
  bCreateMHTMLBody := False;
	Authenticated := False;
	UseSSL := True;
  szXmailer := '';

  PluginHelperFunctions.CheckNumArgs(L,2);

  //--------------Mail Properties ------------------
  if (lua_type (L, 1) = LUA_TTABLE) then
		begin
	     lua_pushnil (L);
	      while not(lua_next (L, 1) = 0) do
			   begin
	          p := lua_tostring (L, -2);

			      if ( p = 'FromName' ) then szFromName := lua_tostring (L, -1);
            if ( p = 'FromEmail' ) then szFromEmail := lua_tostring (L, -1);
            if ( p = 'To' ) then szTo := lua_tostring (L, -1);
			      if ( p = 'TextBody' ) then begin bCreateMHTMLBody := False; bTextBody := True; bHtmlBody := False; szTextBody := lua_tostring (L, -1); end;
			      if ( p = 'HtmlBody' ) then begin bCreateMHTMLBody := False; bHtmlBody := True; bTextBody := False; szTextBody := lua_tostring (L, -1); end;
            if ( p = 'CreateMHTMLBody' ) then begin bCreateMHTMLBody := True; bHtmlBody := False; bTextBody := False; szTextBody := lua_tostring (L, -1); end;
			      if ( p = 'Subject' ) then szSubject := lua_tostring (L, -1);
			      if ( p = 'Importance' ) then szImportance := lua_tostring (L, -1);
		    	  if ( p = 'CC' ) then szCC := lua_tostring (L, -1);
		    	  if ( p = 'BCC' ) then szBCC := lua_tostring (L, -1);
            if ( p = 'Xmailer' ) then szXmailer := lua_tostring (L, -1);
            if ( p = 'ReplyTo' ) then szReplyTo := lua_tostring (L, -1);

            lua_pop (L, 1);
         end;
     end;
   //--------------Mail Properties ------------------

   //--------------Server Properties ------------------
   if (lua_type (L, 2) = LUA_TTABLE) then
		 begin
	      lua_pushnil (L);
	       while not(lua_next (L, 2) = 0) do
			    begin
	           p := lua_tostring (L, -2);
			       if ( p = 'Server' ) then szServer := lua_tostring (L, -1);
			       if ( p = 'ServerPort' ) then nServerPort := lua_tonumber (L, -1);
			       if ( p = 'UseSSL' ) then UseSSL := lua_toboolean (L, -1);
			       if ( p = 'Authenticated' ) then Authenticated := lua_toboolean (L, -1);
             if ( p = 'UserName' ) then szUserName := lua_tostring (L, -1);
			       if ( p = 'PassWord' ) then szPassWord := lua_tostring (L, -1);
			       lua_pop (L, 1);
	         end;
     end;
   //--------------Server Properties ------------------


   SmtpObject := CreateOleObject('CDO.Message');
   SmtpConfig := CreateOleObject('CDO.Configuration');

   SmtpObject.From:= '"'+String(szFromName)+'" < '+String(szFromEmail)+' >';
   SmtpObject.To:= String(szTo);
   SmtpObject.Subject:= String(szSubject);
   SmtpObject.CC:= String(szCC);
   SmtpObject.BCC:= String(szBCC);
   SmtpObject.Fields.Update;

if (szReplyTo <> '') then
   begin
   SmtpObject.ReplyTo := String(szReplyTo);
   end;

if (bHtmlBody = True) then
    begin
    SmtpObject.HTMLBody:= String(szTextBody);
    end
else if (bTextBody = True) then
    begin
    SmtpObject.Textbody:= String(szTextBody);
    end
else if (bCreateMHTMLBody = True) then
    begin
    SmtpObject.CreateMHTMLBody(String(szTextBody));
    end;

    //--------------Attachments ------------------
   if (lua_type (L, 3) = LUA_TTABLE) then
		 begin
	      lua_pushnil (L);
	       while not(lua_next (L, 3) = 0) do
			    begin
	           p := lua_tostring (L, -1);
			       if ( FileExists(p) ) then
             begin
                SmtpObject.AddAttachment(String(p));
             end;
			       lua_pop (L, 1);
	         end;
     end;
   //-------------- Attachments ------------------
     
   SmtpObject.Fields.Item ('urn:schemas:mailheader:Importance') := String(szImportance);
   SmtpObject.Fields.Update;

if(szXmailer <> '' ) then
   begin
   SmtpObject.Fields.Item ('urn:schemas:mailheader:x-mailer') := String(szXmailer);
   SmtpObject.Fields.Update;
   end;

    SmtpConfig.Fields.Item (SchemaUrl+'sendusing'):= 2;
    SmtpConfig.Fields.Item (SchemaUrl+'smtpserver'):= String(szServer);
    SmtpConfig.Fields.Item (SchemaUrl+'smtpserverport'):= nServerPort;
    SmtpConfig.Fields.Update;

if (UseSSL = True) then
    begin
    SmtpConfig.Fields.Item (SchemaUrl+'smtpusessl'):= Integer(1);
    SmtpConfig.Fields.Update;
    end;




 if (Authenticated = True) then
     begin
     SmtpConfig.Fields.Item (SchemaUrl+'smtpauthenticate'):= Integer(1);
     SmtpConfig.Fields.Item (SchemaUrl+'sendpassword'):= String(szPassword);
     SmtpConfig.Fields.Item (SchemaUrl+'sendusername'):= String(szUserName);
     end
      else
      begin
      SmtpConfig.Fields.Item (SchemaUrl+'smtpauthenticate'):= Integer(0);
     end;
   SmtpConfig.Fields.Update;
   SmtpObject.Configuration :=  SmtpConfig;

try
       SmtpObject.Send;

       except on E: Exception do
       szReturnVal:=PChar(E.Message);
    end;

  SmtpObject := VarNull;
  SmtpConfig := VarNull;
  lua_pushstring(L,szReturnVal);
  Result := 1;
end;



function  RegisterPluginActions(L: Plua_State): Integer;

     var lib_funcs: array [0..0] of luaL_reg;
     var I:Integer;
begin

    lib_funcs[0].name := 'SendMail';
    lib_funcs[0].func :=  SendMail;

    lua_newtable(L);
    for I := Low(lib_funcs) to High(lib_funcs) do
      begin
        lua_newtable(L);
        lua_pushstring(L, lib_funcs[I].name);
        lua_pushcfunction(L, lib_funcs[I].func);
        lua_settable(L,-3);
      end;
     lua_setglobal(L, 'SMTP');

    Result := 0;
end;

end.
