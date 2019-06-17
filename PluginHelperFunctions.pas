(*
** This file is equivalent of IRPluginHelperFunctions.cpp in the plugin SDK

** Translated to delphi/pascal by:  Serkan Onat
** Copy Right : Reteset Software https://wwww.reteset.net
*)


unit PluginHelperFunctions;

interface

 uses
  SysUtils,
  Windows,
  Lua,
  Lauxlib;

  const
       IR_SDK_VERSION = 2;
       MAX_FORMATTED_ERROR = 1024;

       function GetTextFromResourceFile( ResID:PChar; ResType:PChar):PChar;
       function FormatSyntaxError(L: Plua_State; szErrorMsg:PChar):PChar;
       function CheckString (L: Plua_State; nArg:Integer):PChar;
       function CheckNumber (L: Plua_State; nArg:Integer):Double;
       function CheckBoolean (L: Plua_State; nArg:Integer):Boolean;
       procedure CheckTable (L: Plua_State; nArg:Integer);
       procedure SetGlobalErrorMessage(L: Plua_State; nCode:Integer; szMessage:PChar);
       procedure DoAutoTab(L: Plua_State; bNextTab:LongBool);
       procedure CheckNumArgs(L: Plua_State; nNumArgsRequired:Integer);
       procedure ResetLastError(L: Plua_State);



implementation



function GetTextFromResourceFile( ResID:PChar; ResType:PChar):PChar;
 var
   hFind, hRes: THandle;
   StrSRC: PChar;
 begin
  StrSRC := '';
  hFind := FindResource(HInstance, ResID, ResType);
  if hFind <> 0 then begin
    hRes:=LoadResource(HInstance, hFind);
    if hRes <> 0 then begin
      StrSRC := LockResource(hRes);
      UnlockResource(hRes);
    end;
    FreeResource(hFind);
  end;
  Result := StrSRC;
end;


procedure SetGlobalErrorMessage(L: Plua_State; nCode:Integer; szMessage:PChar);
begin
	lua_getglobal(L,'_tblErrorMessages');
	lua_pushnumber(L,nCode);
	lua_pushstring(L,szMessage);
	lua_settable(L,-3);
	lua_pop(L,1);
end;

procedure DoAutoTab(L: Plua_State; bNextTab:LongBool);
begin

	lua_getglobal(L,'Page');
	lua_pushstring(L,'DoAutoTab');
	lua_gettable(L,-2);
	lua_remove(L,-2);
	if(lua_isfunction(L,-1)) then

		lua_pushboolean(L,bNextTab);
		if not (lua_pcall(L,1,0,0) = 0) then
    lua_remove(L,-1)
    else
    lua_remove(L,-1);

end;


function FormatSyntaxError(L: Plua_State; szErrorMsg:PChar):PChar;
 var szFullMessage:PChar;
begin

  szFullMessage := szErrorMsg;
  
	lua_getglobal(L,'Debug');
	lua_pushstring(L,'GetSyntaxErrorString');
	lua_gettable(L,-2);
	lua_remove(L,-2);

if(lua_isfunction(L,-1))  then
   begin

     lua_pushstring(L,szErrorMsg);

        if not(lua_pcall(L,1,1,0) = 0) then
           begin

			     lua_remove(L,-1);
           end
        else
           begin

			       if(LStrLen(lua_tostring(L,-1)) < MAX_FORMATTED_ERROR)  then
                begin
                  szFullMessage := lua_tostring(L,-1);
                end
			       else
                begin
                  szFullMessage := 'Formatted error string is too long for buffer.';
                end;
			       lua_remove(L,-1);
		        end;
         end
	 else
	    begin
		    lua_remove(L,-1);
      end;
      Result :=  szFullMessage;
end;

procedure CheckNumArgs(L: Plua_State; nNumArgsRequired:Integer);
 var  szBuffer:PChar; szFinalError:PChar;
begin

	if(lua_gettop(L) < nNumArgsRequired) then
	  begin
    szBuffer := PChar(Format('%d arguments required.',[nNumArgsRequired]));
		szFinalError := FormatSyntaxError(L,szBuffer);
		lua_pushstring(L,szFinalError);
		lua_error(L);
	end;
end;

procedure ResetLastError(L: Plua_State);
begin

	lua_getglobal(L,'Application');
	lua_pushstring(L,'ResetLastError');
	lua_gettable(L,-2);
	lua_remove(L,-2);

	if(lua_isfunction(L,-1)) then
	begin
		 if not (lua_pcall(L,0,0,0) = 0) then
	    	begin
			   lua_remove(L,-1);
        end
  else
 	   begin
		    lua_remove(L,-1);
	   end;
  end;
end;

function CheckString (L: Plua_State; nArg:Integer):PChar;
 var strResult:PChar; szBuffer:PChar; szFinalError:PChar;
begin

  strResult := nil;

	if not ( lua_isstring(L,nArg) ) then
	   begin
       szBuffer := PChar(Format('Argument %d must be a string.',[nArg]));
		   szFinalError := FormatSyntaxError(L,szBuffer);
		   lua_pushstring(L,szFinalError);
		   lua_error(L);
	   end
  else
     begin
        strResult := lua_tostring(L, nArg);
     end;
	Result := strResult;
end;

function CheckNumber (L: Plua_State; nArg:Integer):Double;
 var nResult:Double; szBuffer:PChar; szFinalError:PChar;
begin

	nResult := lua_tonumber(L, nArg);
	if not ( lua_isnumber(L,nArg) ) then
	begin
    szBuffer := PChar(Format('Argument %d must be a number.',[nArg]));
		szFinalError := FormatSyntaxError(L,szBuffer);
		lua_pushstring(L,szFinalError);
		lua_error(L);
	end;
	Result := nResult;
end;

function CheckBoolean (L: Plua_State; nArg:Integer):Boolean;
 var bResult:Boolean; szBuffer:PChar; szFinalError:PChar;
begin

   bResult:= False;

	if not ( lua_isboolean(L,nArg) ) then
	   begin
      szBuffer := PChar(Format('Argument %d must be a boolean.',[nArg]));
		  szFinalError := FormatSyntaxError(L,szBuffer);
		  lua_pushstring(L,szFinalError);
		  lua_error(L);
	   end
  else
     begin
        bResult := lua_toboolean(L, nArg);
     end;

	Result := bResult;
end;

procedure CheckTable (L: Plua_State; nArg:Integer);
 var szBuffer:PChar; szFinalError:PChar;
begin
	if not ( lua_istable(L,nArg) ) then
	begin
    szBuffer := PChar(Format('Argument %d must be a table.',[nArg]));
		szFinalError := FormatSyntaxError(L,szBuffer);
		lua_pushstring(L,szFinalError);
		lua_error(L);
	end;
end;

end.
