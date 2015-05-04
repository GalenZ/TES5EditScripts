{
  Merge the selected MUSC MusicLists into the last-selected list
  
  2015-04-28 v1.0 Debugged and working
}
unit UserScript;
uses mteFunctions;

var
  mergedTracks: TStringList;
  lastMUSCRecord: IInterface;

function Initialize: integer;
begin
  mergedTracks := TStringList.Create;
  AddMessage('Merging track lists, please wait...');
end;

// Add tracks from the specified MUSC record to the specified string list,
// with or without allowing duplicates
// return the number of tracks added, or -1 if the src MUSC record is invalid
function AddTracksFromRecordToList( e: IInterface; toList: TStringList; allowDuplicates: boolean): integer;
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

// for each selected TNAM list, add all tracks in the list to the temporary list, without duplications
function Process(e: IInterface): integer;
var
  n: int;
begin
  n := AddTracksFromRecordToList( e, mergedTracks, (1 = 0));
  if( n < 0 ) then begin
    AddMessage( 'Non-MUSC record ' + Name(e) + ' in ' + GetFileName( GetFile(e)));
  end
  else begin
    lastMUSCRecord := e;
    AddMessage( 'Adding ' + IntToStr( n) + ' tracks from ' + Name(e) + ' in ' + GetFileName(GetFile(e)));
  end;
end;

// at end, we take the original contents of the final list as-is,
// and add other tracks without duplicating any existing tracks in that final list record
// thus, this script will ALWAYS add things to the existing final list,
// rather than overwriting it whole
function Finalize: integer;
var
  i: integer;
  finalList : TStringList;
  v : string;
  n : integer;
  
begin
  if mergedTracks.count = 0 then begin
    AddMessage('No music tracks to merge.');
    mergedTracks.Free;
    Exit;
  end;
  
  finalList := TStringList.create;
  // allow dups when adding tracks from final MUSC, as we want it intact
  n := AddTracksFromRecordToList( lastMUSCRecord, finalList, 1 = 1);
  // but don't allow dups when adding tracks from all previous MUSC lists
  for i := 0 to mergedTracks.Count - 1 do begin
    v := mergedTracks[i];
    if( finalList.indexOf( v) < 0 ) then
      finalList.Add(v);
  end;
  
  // print the final track list for debugging
  //AddMessage( 'Final Track List = ');
  for i := 0 to mergedTracks.Count - 1 do begin
     v := mergedTracks[i];
     // TODO - really need to add masters to file containing final record
     //AddMessage( 'Track #' + IntToStr(i) + ' = ' + v);
  end;
  AddMessage('');
  AddMessage( 'Assigning new tracks list to ' + Name(lastMUSCRecord) + ' in ' + GetFileName(GetFile(lastMUSCRecord)));
  
  // now actually set the value, dammit
  SetListEditValues( lastMUSCRecord, 'TNAM', finalList);
  
  mergedTracks.Free;
  finalList.Free;
  {
  // borrowed code as model - not part of actual code in any way
  // create a new patch file
  newfile := AddNewFile;
  if not Assigned(newfile) then begin
    AddMessage('Patch file creation canceled');
    Result := 1;
    Exit;
  end;
  for i := 0 to cells.Count - 1 do begin
    r := recs[i];
    // add current plugin as a master
    AddRequiredElementMasters(GetFile(r), newfile, False);
    // copy CELL record to patch, parameters: record, file, AsNew, DeepCopy
    wbCopyElementToFile(r, newfile, False, True);
  end;
  AddMessage(Format('Patch file created with %d cell records.', [cells.Count]));
  }
end;

end.