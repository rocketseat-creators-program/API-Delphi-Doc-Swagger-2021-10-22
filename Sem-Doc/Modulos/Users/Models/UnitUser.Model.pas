unit UnitUser.Model;

interface
uses
  UnitTodo.Model,
  REST.Json.Types,
  System.Generics.Collections,
  System.Json;

type
  TUserResquest = class
  private
    Fname: string;
    Fusername: string;
  published
    property name: string read Fname write Fname;
    property username: string read Fusername write Fusername;
  end;

  TUser = class
  private
    Fid: string;
    Fname: string;
    Fusername: string;
    Ftodos: TArray<TTodo>;
  published
    property id: string read Fid write Fid;
    property name: string read Fname write Fname;
    property username: string read Fusername write Fusername;
    property todos: TArray<TTodo> read Ftodos write Ftodos;
    function toJson: TJSONObject;
    class function fromJson(Value: TJSONObject): TUser;
  end;

implementation

uses Rest.Json;


{ TUsers }

class function TUser.fromJson(Value: TJSONObject): TUser;
begin
  Result := TJson.JsonToObject<TUser>(Value);
end;

function TUser.toJson: TJSONObject;
begin
  Result := TJson.ObjectToJsonObject(Self);
end;

end.
