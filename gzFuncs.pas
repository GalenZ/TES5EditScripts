{
  gzFuncs.pas  GalenZ's TES5EDIT Script Functions
  current version: 2015-05-04
  
  A set of useful functions for use in TES5Edit scripts.
  
  This modules relies on functions in mteFunctions.pas, written by matortheeternal,
  available at https://github.com/matortheeternal/TES5EditScripts/blob/master/trunk/Edit%20Scripts/mteFunctions.pas
  but more normally includes as a component of his Merge Plugins script,
  available at http://www.nexusmods.com/skyrim/mods/37981/?
  
  List of functions:
  ------------------
  AddTracksFromMUSCRecordToList( muscRecord: IInterface; toList: TStringList; allowDuplicates: boolean): integer;
  GetMOActiveModNames( moPath: string) : TStringList;
  GetMOActiveProfileName( moPath: string) : string;
  GetMOFirstActiveFolderContainingSpecifiedFile( moBasePath: string; activeModNames: TStringList; filename: string) : string;
  GetMOProfileIniData( moPath, profileName: string) : TStringList;
  GetMOProfileActiveModNames( moPath, profileName: string) : TStringList; 
  StrEndsWith( s1, suffix: string) : boolean;
  StrStartsWith( s1, prefix: string): boolean;
  
  Change Log
  ----------
  2015-05-04 - Initial version.
}
  

unit gzFunctions;

uses mteFunctions;

const
  MOIniFileName = 'ModOrganizer.ini';
  MOProfileModlistFileName = 'modlist.txt';
  
  = 'Skyrim.esm'#13'Update.esm'#13'Dawnguard.esm'#13'HearthFires.esm'#13
  'Dragonborn.esm'#13'Fallout3.esm'#13'FalloutNV.esm'#13'Oblivion.esm'#13
  'Skyrim.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat'#13
  'Fallout3.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat'#13
  'Oblivion.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat'#13
  'FalloutNV.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat';
  GamePath = DataPath + '..\';
{ ----------------------------------------------------------------------
  Get the list of Mod Organizer's currently active mods, i.e. all active mods in the currently active profile.
  Parameters:
    moPath:  the pathname of the Mod Organizer folder, with a trailing '/'. e.g, 'c:/Mod Organizer/'
  Returns:
    A newly created list of all active mod names (folders) in the current active profile.
    This list may be empty, but will never be null.
    This list must be disposed of by the caller.
}

function GetMOActiveModNames( moPath: string) : string;
begin
  return GetMOProfileActiveModNames( moPath, GetMOActiveProfileName( moPath));  
end;

{ ----------------------------------------------------------------------
  Get the name of Mod Organizer's currently active profile.
  This can be found in the file <moPath>/ModOrgainzer.ini, under the entry 'active_profile=<xxx>'.
}

function GetMOActiveProfileName( moPath: string) : string;
begin
end;

{ ----------------------------------------------------------------------
  Get the name of the first active mod folder containing the specified file.
  This is typically used to find the folder containing a specified .esp file, so that assets may be copied from that folder.
  Parameters:
    moPath:  the pathname of the Mod Organizer folder, with a trailing '/'. e.g, 'c:/Mod Organizer/'
    modList:  a list of all active mods (folders) to search through.  Typically obtained from GetMOActiveModNames( moPath)
    filename: the name of the file to look for, relative to a mod folder, e.g. 'foo.esp' or 'meshes/foo.nif'
  Returns:
    the name of the first mod in modList such that FileExists( moPath + 'mods/' + <modName> '/' + filename)
    or '' if the file cannot be found.
}

GetMOFirstActiveFolderContainingSpecifiedFile( moPath: string; modList: TStringList; filename: string) : string;
begin
  i, n: int;
  modName: string;
  n := modList.count;
  for( i := 0 to n-1 ) do begin
    modName := modList[i];
    if( FileExists( moPath + 'mods/' + modName + '/' + filename) then return modName;
  end;
  return '';
end;

{ ----------------------------------------------------------------------
  Get the list of Mod Organizer's currently active mods, i.e. all active mods in the currently active profile.
  Parameters:
    moPath:  the pathname of the Mod Organizer folder, with a trailing '/'. e.g, 'c:/Mod Organizer/'
    profileName:  the name of the profile to look in, such that moPath + 'profiles/' + profileName exists.
  Returns:
    A newly created list of all active mod names (folders) in the specified profile.
    This list may be empty (i.e. if the moPath is bad, or the specified profile does not exist.
    This list must be disposed of by the caller.
}

function GetMOProfileActiveModNames( moPath, profileName: string) : TStringList; 
begin
  modList: TStringList;
  modlistFilePath: string;
  modList := TStringList.Create;
  modListFilePath := moPath + 'profiles/' + profileName + '/' + MoProfileModlistFileName;
  repeat begin
    
  return GetMOProfileActiveModNames( moPath, GetMOActiveProfileName( moPath));  
end;

{ ----------------------------------------------------------------------
  Add tracks from the specified MUSC record to the specified string list, with or without allowing duplicates
  Return the number of tracks added, or -1 if the src MUSC record is invalid
}

function AddTracksFromMUSCRecordToList( e: IInterface; toList: TStringList; allowDuplicates: boolean): integer;
var
  Sig: string;
  track : IInterface;
  trackID : string;
  i: int;
  tc: int;
  tracks : IInterface;
  v : string;
  action : string;
  count : int;
  
begin
  count := 0;
  Result := -1;
  if not (IsEditable(e)) then begin
    Result := -1;
    Exit;
  end;
  
  Sig := Signature(e);
  
  if (Sig <> 'MUSC') then begin
    //AddMessage( 'Non-MUSC record ' + Name(e) + ' is type ' + Sig);
    Result := -1;
    Exit;
  end;
  
  if( not ElementExists( e, 'TNAM' )) then begin
    //AddMessage( 'MUSC record ' + Name(e) + ' does not have TNAM element');
    Result := -1;
    Exit;
  end;
 
  tracks := ElementBySignature( lastMUSCRecord, 'TNAM');  // TNAM is list of tracks in MUSC record
  tc := ElementCount(tracks);
  //AddMessage( 'Processing ' + IntToStr( tc) + ' tracks from ' + Name(e) + ' in ' + GetFileName(GetFile(e)));
  
  // process all tracks in the current MUSC list, add new tracks to list
  for i := 0 to tc - 1 do begin
    action := '';
    track := ElementByIndex(tracks, i);
    trackID := IntToHex(FormID(track), 8);
    v := GetEditValue(track);
    // add new track to output list if this is first list processed (to keep vanilla track duplicates)
    // or if track is not already in list
    if( (allowDuplicates) or (toList.indexOf(v) < 0) ) then begin
      // newTracks[ toList.count] := track;
      toList.Add( v);
      count := count + 1;
      action := ' : added';
      //AddMessage( 'Track #' + IntToStr(i) + ' = ' + v + action);
    end;
    //AddMessage( 'Track #' + IntToStr(i) + ' = ' + v + action);
  end;
  Result := count;
end;


{ ----------------------------------------------------------------------
  StrEndsWith:
  Checks to see if a string ends with an entered substring.
  
  Example usage:
  s := 'This is a sample string.';
  if StrEndsWith(s, 'string.') then
    AddMessage('It works!');
}
function StrEndsWith(s1, suffix: string): boolean;
var
  i, n1, n2: integer;
begin
  Result := false;
  
  n1 := Length(s1);
  n2 := Length(suffix);
  if n1 < n2 then exit;
  
  Result := (Copy(s1, n1 - n2 + 1, n2) = suffix);
end;

{ ------------------------------------------------------------------------
  StrStartsWith:
  Checks to see if a string starts with an entered substring.
  
  Example usage:
  s := 'This is a sample string.';
  if StrStartsWith(s, 'This is') then
    AddMessage('It works!');
}

function StrStartsWith(s1, prefix: string): boolean;
var
  i, n1, n2: integer;
begin
  Result := false;
  
  n1 := Length(s1);
  n2 := Length(prefix);
  if n1 < n2 then exit;
  
  Result := (Copy(s1, 1, n2) = prefix);
end;