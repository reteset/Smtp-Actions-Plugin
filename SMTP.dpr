
(*
** Implementation unit of the main plugin dll /module

** Author:  Serkan Onat
** Copy Right : Reteset Software https://wwww.reteset.net
*)

library SMTP;


uses
  SysUtils,
  Windows,
  ShellApi,
  Lua,
  Lauxlib,
  PluginHelperFunctions,
  SmtpFunctions in 'SmtpFunctions.pas';


// #############################################################################

  const
       TPluginName = 'SMTP';
       TPluginVersion = '1.4.0.0';
       TAuthInformation = 'SMTP Action Plugin For AutoPlay Media Studio' +
       #13#10+'Created by www.amsplugins.com'+#13#10+'Copyright © 2008 - 2010 www.amsplugins.com';

// #############################################################################

function irPlg_GetPluginName(szBuffer:PChar; pnBufferSize:PInteger):Integer; export; cdecl;

 var nLength:Integer;

begin

	nLength := StrLen(TPluginName);

	if(pnBufferSize^ < nLength)  then
	  begin
		pnBufferSize^ := nLength;
		Result := -1;
	  end
  else
  	begin
      StrLCopy(szBuffer,TPluginName,nLength+1);
		  Result := nLength;
  	end;
end;

// #############################################################################

function irPlg_GetPluginVersion(szBuffer:PChar; pnBufferSize:PInteger):Integer; export; cdecl;

 var nLength:Integer;

begin

	nLength := StrLen(TPluginVersion);

	if(pnBufferSize^ < nLength)  then
	  begin
		pnBufferSize^ := nLength;
		Result := -1;
	  end
  else
  	begin
      StrLCopy(szBuffer,TPluginVersion,nLength+1);
		  Result := nLength;
  	end;
end;

// #############################################################################

function irPlg_GetAuthorInfo(szBuffer:PChar; pnBufferSize:PInteger):Integer; export; cdecl;

 var nLength:Integer;

begin

	nLength := StrLen(TAuthInformation);

	if(pnBufferSize^ < nLength)  then
	  begin
		pnBufferSize^ := nLength;
		Result := -1;
	  end
  else
  	begin
      StrLCopy(szBuffer,TAuthInformation,nLength+1);
		  Result := nLength;
  	end;
end;

// #############################################################################

function irPlg_GetLuaVersion(szBuffer:PChar; pnBufferSize:PInteger):Integer; export; cdecl;

 var nLength:Integer;

begin

	nLength := StrLen(LUA_VERSION_);

	if(pnBufferSize^ < nLength)  then
	  begin
		pnBufferSize^ := nLength;
		Result := -1;
	  end
  else
  	begin
      StrLCopy(szBuffer,LUA_VERSION_,nLength+1);
		  Result := nLength;
  	end;
end;

// #############################################################################

function irPlg_GetSDKVersion():Integer; export; cdecl;

begin

		  Result := IR_SDK_VERSION;

end;

// #############################################################################

function irPlg_ValidateLicense(LicenseInfo:PChar):Integer; export; cdecl;

begin

		  Result := 1;

end;

// #############################################################################

function irPlg_GetPluginActionXML(szBuffer:PChar; pnBufferSize:PInteger):Integer; export; cdecl;

 var nLength:Integer; strXML:PChar;

begin

  strXML := GetTextFromResourceFile( 'IDR_ACTIONSXML' , 'TEXTFILE');
	nLength := StrLen(strXML);

	if(pnBufferSize^ < nLength)  then
	  begin
		pnBufferSize^ := nLength;
		Result := -1;
	  end
  else
  	begin
      StrLCopy(szBuffer,strXML,nLength+1);
		  Result := nLength;
  	end;
end;

// #############################################################################

function irPlg_ShowHelpForAction(ActionName:PChar; PluginPath:PChar; ParentWnd:HWND):Boolean; export; cdecl;

 var strChmFile:String;  strTopicPath:String;
 var  WinPath: array[0..MAX_PATH + 1] of Char;
begin

  GetWindowsDirectory(WinPath,MAX_PATH);
  strChmFile := Format('%s\\Help.chm',[PluginPath]);
  strTopicPath := Format('%s\\Help.chm::/%s.html',[PluginPath,ActionName]);

	if (FileExists(strChmFile))  then
	   begin
      ShellExecute(ParentWnd, 'open', PChar(WinPath+'\hh.exe') , PChar(strTopicPath), nil, SW_SHOWNORMAL) ;
      Result := True;
	   end
  else
	   begin
       Result := False;
     end;
end;

// #############################################################################

function irPlg_ShowHelpForPlugin(PluginPath:PChar; ParentWnd:HWND):Boolean; export; cdecl;

 var strChmFile:String;

begin

  strChmFile := Format('%s\\Help.chm',[PluginPath]);

	if (FileExists(strChmFile))  then
	   begin
      ShellExecute(ParentWnd, 'open', PChar(strChmFile), nil, nil, SW_SHOWNORMAL) ;
      Result := True;
	   end
  else
	   begin
       Result := False;
     end;
end;

// #############################################################################

function irPlg_Action_RegisterActions(L: Plua_State):Integer; export; cdecl;
 
begin

    RegisterPluginActions(L);
    Result := 0;

end;

// #############################################################################

{$E lmd}

{$R SMTP.res}

// #############################################################################

exports

irPlg_GetPluginName ,
irPlg_GetPluginVersion ,
irPlg_GetAuthorInfo ,
irPlg_GetLuaVersion ,
irPlg_GetSDKVersion ,
irPlg_ValidateLicense ,
irPlg_GetPluginActionXML ,
irPlg_ShowHelpForAction ,
irPlg_ShowHelpForPlugin ,
irPlg_Action_RegisterActions;

// #############################################################################

begin
end.
 