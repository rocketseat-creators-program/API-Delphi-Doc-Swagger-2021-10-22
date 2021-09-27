unit UnitTodo.Model;

interface
uses
  System.Json;

type
  TTodo = class
  private
    Fid: string;
    Fdeadline: TDateTime;
    Fdone: boolean;
    Ftitle: string;
    Fcreated_at: TDateTime;
  published
    property id: string read Fid write Fid;
    property deadline: TDateTime read Fdeadline write Fdeadline;
    property done: boolean read Fdone write Fdone;
    property title: string read Ftitle write Ftitle;
    property created_at: TDateTime read Fcreated_at write Fcreated_at;
    function toJson: TJsonObject;
    class function FromJsonObject(Value: TJSONObject): TTodo;
  end;

implementation
uses
  Rest.Json;

{ TTodo }

class function TTodo.FromJsonObject(Value: TJSONObject): TTodo;
begin
  Result := TJson.JsonToObject<TTodo>(Value);
end;

function TTodo.toJson: TJsonObject;
begin
  Result := TJson.ObjectToJsonObject(Self);
end;

end.
