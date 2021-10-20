unit UnitUsers.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Generics.Collections,
  System.Json,
  UnitUser.Model,
  Horse.GBSwagger;


type
  TUsersController = class
    class procedure Registrar;
    class procedure GetAllUsers(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure CreateUser(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TUsersController }

uses UnitUsers.Repository, UnitUtils, UnitTodo.Model;

class procedure TUsersController.CreateUser(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  user: TUser;
  usuarioAlreadyExists: Boolean;
  UserRepository: TUsersRepository;
begin
  oJson := Req.Body<TJSONObject>;
  if not Assigned(oJson) then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'user not found')).Status(THTTPStatus.NotFound);
    Exit;
  end;
  usuarioAlreadyExists := False;
  UserRepository := TUsersRepository.New;
  for user in UserRepository.Users do
  begin
    usuarioAlreadyExists := oJson.GetValue<string>('username') = user.username;
    if usuarioAlreadyExists then
      Break;
  end;
  if usuarioAlreadyExists then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'user already exists!')).Status(THTTPStatus.BadRequest);
    Exit;
  end;
  user := TUser.fromJson(oJson);
  user.id := CreateGuuid;
  UserRepository.Users.Add(user);
  Res.Send<TJSONObject>(user.toJson).Status(THTTPStatus.Created);
end;

class procedure TUsersController.GetAllUsers(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  aJson: TJSONArray;
  user: TUser;
  UserRepository: TUsersRepository;
begin
  aJson := TJSONArray.Create;
  UserRepository := TUsersRepository.New;
  for user in UserRepository.Users do
  begin
    aJson.AddElement(user.toJson);
  end;
  Res.Send<TJSONArray>(aJson);
end;

class procedure TUsersController.Registrar;
begin
  THorse.Get('/users', GetAllUsers)
        .Post('/users', CreateUser);
end;

initialization
  Swagger
    .Path('/users')
      .Tag('Users')
        .GET('List all', 'List all Users')
          .AddResponse(200, 'Ok')
            .Schema(TUserResponse)
            .IsArray(True)
          .&End
          .AddResponse(500, 'Internal server error').&End
        .&End
        .POST('Create user', 'Create new user')
          .AddParamBody('New User', 'New User')
            .Schema(TUserResquest)
          .&End
          .AddResponse(201, 'Created')
            .Schema(TUserResponse)
          .&End
          .AddResponse(404, 'User not found').&End
          .AddResponse(400, 'Users already exists').&End
          .AddResponse(500, 'Internal server error').&End
        .&End
      .&End

end.
