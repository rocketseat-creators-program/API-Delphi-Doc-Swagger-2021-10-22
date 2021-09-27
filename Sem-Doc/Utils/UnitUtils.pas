unit UnitUtils;

interface
uses SysUtils;

function CreateGuuid: string;

implementation

function CreateGuuid: string;
var Guuid: TGUID;
begin
  CreateGUID(Guuid);
  Result := GUIDToString(Guuid).Replace('{', '').Replace('}', '').ToLower;
end;

end.
