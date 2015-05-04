{
  This script will add a prefix and/or suffix to the Name field of every selected record.
  Will only add suffix/prefix if name does not already have the given suffix/prefix.
  
  2015-03-31 GalenZ V1.0
}
unit UserScript;

var
  DoPrepend: boolean;
  prefix: string;
  suffix: string;
  
function Initialize: integer;
var
  i: integer;
begin
  Result := 0;
  // ask for prefix or suffix mode
  //i := MessageDlg('Add Prefix [YES] or Suffix [NO] to Name?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
  //if i = mrYes then DoPrepend := true else
  //  if i = mrNo then DoPrepend := false else begin
  //    Result := 1;
  //    Exit;
  //  end;
  // ask for prefix string
  if not InputQuery('Enter', 'Prefix', prefix) then begin
    Result := 1;
    Exit;
  end;
  // ask for suffix string
  if not InputQuery('Enter', 'Suffix', suffix) then begin
    Result := 2;
    Exit;
  end;
  // empty strings - do nothing
  if (suffix = '') and (prefix = '') then
    Result := 3;
    Exit;
end;

{
  StrEndsWith:
  Checks to see if a string ends with an entered substring.
  
  Example usage:
  s := 'This is a sample string.';
  if StrEndsWith(s, 'string.') then
    AddMessage('It works!');
}
function StrEndsWith(s1, s2: string): boolean;
var
  i, n1, n2: integer;
begin
  Result := false;
  
  n1 := Length(s1);
  n2 := Length(s2);
  if n1 < n2 then exit;
  
  Result := (Copy(s1, n1 - n2 + 1, n2) = s2);
end;

{
  StrStartsWith:
  Checks to see if a string starts with an entered substring.
  
  Example usage:
  s := 'This is a sample string.';
  if StrStartsWith(s, 'This is') then
    AddMessage('It works!');
}
function StrStartsWith(s1, s2: string): boolean;
var
  i, n1, n2: integer;
begin
  Result := false;
  
  n1 := Length(s1);
  n2 := Length(s2);
  if n1 < n2 then exit;
  
  Result := (Copy(s1, 1, n2) = s2);
end;

function Process(e: IInterface): integer;
var
  elNameID: IInterface;
  newname: string;
begin
  Result := 0;
  elNameID := ElementByName(e, 'FULL - Name');
  if Assigned(elNameID) then begin
    newname := GetEditValue(elNameID);
    if not StrStartsWith( newname, prefix) then newname := prefix + newname;
    if not StrEndsWith( newname, suffix) then newname := newname + suffix;
    //if DoPrepend then
    //  newname := s + GetEditValue(elNameID);
    //else
    //  newname := GetEditValue(elNameID) + s;
    AddMessage('Processing: ' + Name(e) + ' -> ' + newname);
    SetEditValue(elNameID, newname);
  end;
end;

end.
