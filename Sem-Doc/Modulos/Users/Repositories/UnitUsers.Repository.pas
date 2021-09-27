unit UnitUsers.Repository;

interface

uses
    System.Generics.Collections,
    UnitUser.Model,
    UnitTodo.Model;

type
  TUsersRepository = class
    private
      FUsers: TList<TUser>;
      class var instance: TUsersRepository;
    public
      constructor Create;
      destructor Destroy;override;
      class function New: TUsersRepository;
      function Users: TList<TUser>;
  end;

implementation

{ TUsersRepository }

constructor TUsersRepository.Create;
begin
  FUsers := TList<TUser>.Create;
end;

destructor TUsersRepository.Destroy;
begin
  FUsers.Free;
  inherited;
end;

class function TUsersRepository.New: TUsersRepository;
begin
  if not Assigned(instance) then
    instance := Self.Create;
  Result := instance;
end;

function TUsersRepository.Users: TList<TUser>;
begin
  Result := FUsers;
end;

end.
