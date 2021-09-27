unit UnitCheckExistsUserAccount;

interface

uses
  Horse,
  System.Json,
  System.SysUtils,
  Horse.Commons;

procedure checksExistsUserAccount(Req: THorseRequest; Res: THorseResponse; Next: TProc);


implementation

uses
  UnitUsers.Repository,
  UnitUser.Model;

procedure checksExistsUserAccount(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  id: string;
  userExists: boolean;
  UserRepository: TUsersRepository;
  user: TUser;
begin
  id := Req.Headers['id'];
  //verifica e existencia do usuario
  UserRepository := TUsersRepository.New;
  userExists := False;
  for user in UserRepository.Users do
  begin
   if user.id = id then
   begin
     userExists := True;
     Break;
   end;
  end;
  //caso não exista retorna erro e status 400 = bad request
  if (not userExists) then
  begin
    raise Exception.Create('User not Exists!');
  end;

  Next();
end;

end.
