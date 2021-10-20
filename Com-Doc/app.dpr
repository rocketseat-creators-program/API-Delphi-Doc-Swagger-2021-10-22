program app;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  Horse.HandleException,
  Horse.GBSwagger,
  System.SysUtils,
  UnitTodo.Model in 'Modulos\Todos\Models\UnitTodo.Model.pas',
  UnitTodos.Controller in 'Modulos\Todos\Controllers\UnitTodos.Controller.pas',
  UnitUser.Model in 'Modulos\Users\Models\UnitUser.Model.pas',
  UnitUsers.Controller in 'Modulos\Users\Controllers\UnitUsers.Controller.pas',
  UnitCheckExistsUserAccount in 'Middlewares\UnitCheckExistsUserAccount.pas',
  UnitUsers.Repository in 'Modulos\Users\Repositories\UnitUsers.Repository.pas',
  UnitUtils in 'Utils\UnitUtils.pas';

var User: TUser;

begin
  THorse.Use(Jhonson)
        .Use(HandleException)
        .Use(HorseSwagger);

  TUsersController.Registrar;
  TTodoController.Registrar;

  Swagger
    .Info
      .Title('API para controle de Tarefas')
      .Contact
        .Name('Alessandro Dutra')
        .Email('cachopaweb@gmail.com')
        .URL('https://meusite.com.br')
      .&End
    .&End;

  THorse.Listen(9000,
  procedure(App: THorse)
  begin
    Writeln('Server is running on Port '+App.Port.ToString);
  end);
end.
