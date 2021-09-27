unit UnitTodos.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  System.Generics.Collections,
  SysUtils,
  System.Json,
  UnitTodo.Model,
  Horse.GBSwagger;

type
  TTodoController = class
    class procedure Registrar;
    class procedure GetAllTodos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure CreateTodo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure UpdateTodo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure DoneTodo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure DeleteTodo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TTodoController }

uses
  UnitUsers.Repository,
  UnitUser.Model, UnitCheckExistsUserAccount, UnitUtils;

class procedure TTodoController.CreateTodo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  UsersRepository: TUsersRepository;
  user: TUser;
  id: string;
  indice: Integer;
  todos: TArray<TTodo>;
  todo: TTodo;
begin
  id := Req.Headers['id'];
  oJson := Req.Body<TJSONObject>;
  if not Assigned(oJson) then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'Todo not found')).Status(THTTPStatus.BadRequest);
    Exit;
  end;
  UsersRepository := TUsersRepository.New;
  for user in UsersRepository.Users do
  begin
    if user.id = id then
    begin
      todos := user.todos;
      indice := Length(todos);
      SetLength(todos, indice+1);
      todo := TTodo.FromJsonObject(oJson);
      todo.id := CreateGuuid;
      todo.created_at := Date;      
      todos[indice] := todo;      
      user.todos := todos;
    end;
  end;
  Res.Send<TJSONObject>(todo.toJson).Status(THTTPStatus.Created);
end;

class procedure TTodoController.DeleteTodo(Req: THorseRequest;  Res: THorseResponse; Next: TProc);
var
  UsersRepository: TUsersRepository;
  user: TUser;
  id: string;
  IdUser: string;
  TodoExists: Boolean;
  i: Integer;
  Indice: Integer;
  Todos: TArray<TTodo>;
  IndexUser: Integer;  
begin
  IdUser := Req.Headers['id'];
  if not Req.Params.ContainsKey('id') then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'Id not informed')).Status(THTTPStatus.BadRequest);
    Exit;
  end;
  Id := Req.Params['id'];              
  UsersRepository := TUsersRepository.New;
  TodoExists := False;
  for user in UsersRepository.Users do
  begin
    if user.id = IdUser then
    begin
      for i := Low(user.todos) to High(user.todos) do
      begin
        if user.todos[i].id = Id then
        begin        
           TodoExists := True;
           Indice := i;
           Break;
        end;
      end;
    end;
  end;
  if not TodoExists then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'Todo not exists!')).Status(THTTPStatus.NotFound);
    Exit;
  end;
  if Assigned(user) then
  begin    
    Todos := user.todos;
    Delete(Todos, Indice, 1);
    IndexUser := UsersRepository.Users.IndexOf(user);
    user.todos := Todos;
    UsersRepository.Users[IndexUser] := user;
  end;
  Res.Send('').Status(THTTPStatus.NoContent);
end;

class procedure TTodoController.DoneTodo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  UsersRepository: TUsersRepository;
  user: TUser;
  id: string;
  IdUser: string;
  TodoExists: Boolean;
  i: Integer;
  Indice: Integer;
  IndexUser: Integer;
  jsonTodo: TJSONObject;
  Todo: TTodo;
begin
  IdUser := Req.Headers['id'];
  if not Req.Params.ContainsKey('id') then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'Id not informed')).Status(THTTPStatus.BadRequest);
    Exit;
  end;
  Id := Req.Params['id'];
  UsersRepository := TUsersRepository.New;
  TodoExists := False;
  for user in UsersRepository.Users do
  begin
    if user.id = IdUser then
    begin
      for i := Low(user.todos) to High(user.todos) do
      begin
        if user.todos[i].id = Id then
        begin
           TodoExists := True;
           Indice := i;
           Break;
        end;
      end;
    end;
  end;
  if not TodoExists then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'Todo not exists!')).Status(THTTPStatus.NotFound);
    Exit;
  end;
  IndexUser := UsersRepository.Users.IndexOf(user);
  UsersRepository.Users[IndexUser].todos[Indice].done := True;
  Res.Send<TJSONObject>(UsersRepository.Users[IndexUser].todos[Indice].toJson).Status(THTTPStatus.OK);
end;

class procedure TTodoController.GetAllTodos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var aJson: TJSONArray;
  i: integer;
  UsersRepository: TUsersRepository;
  user: TUser;
  IdUser: string;
  todo: TTodo;
begin
  IdUser := Req.Headers['id'];
  aJson := TJSONArray.Create;
  UsersRepository := TUsersRepository.New;
  for user in UsersRepository.Users do
  begin
    if user.id = IdUser then
    begin
      for todo in user.todos do
      begin
        aJson.AddElement(todo.toJson);
      end;
    end;
  end;
  Res.Send<TJSONArray>(aJson);
end;

class procedure TTodoController.UpdateTodo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  UsersRepository: TUsersRepository;
  user: TUser;
  id: string;
  IdUser: string;
  TodoExists: Boolean;
  i: Integer;
  Indice: Integer;
  IndexUser: Integer;
  jsonTodo: TJSONObject;
  Todo: TTodo;
begin
  IdUser := Req.Headers['id'];
  Id := Req.Params['id'];
  jsonTodo := Req.Body<TJSONObject>;//parse json object
  if not Assigned(jsonTodo) then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'Todo not found')).Status(THTTPStatus.NotFound);
    Exit;
  end;
  UsersRepository := TUsersRepository.New;
  TodoExists := False;
  for user in UsersRepository.Users do
  begin
    if user.id = IdUser then
    begin
      for i := Low(user.todos) to High(user.todos) do
      begin
        if user.todos[i].id = Id then
        begin
           TodoExists := True;
           Indice := i;
           Break;
        end;
      end;
    end;
  end;
  if not TodoExists then
  begin
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('message', 'Todo not exists!')).Status(THTTPStatus.BadRequest);
    Exit;
  end;
  if Assigned(user) then
  begin
    IndexUser := UsersRepository.Users.IndexOf(user);
    Todo := UsersRepository.Users[IndexUser].todos[Indice];
    Todo.title := jsonTodo.GetValue<string>('title');
    todo.deadline := jsonTodo.GetValue<TDateTime>('deadline');
    UsersRepository.Users[IndexUser].todos[Indice] := Todo;
  end;
  Res.Send<TJSONObject>(jsonTodo).Status(THTTPStatus.OK);
end;

class procedure TTodoController.Registrar;
begin
  THorse.Get('/todos', checksExistsUserAccount, GetAllTodos)
        .Post('/todos', checksExistsUserAccount, CreateTodo)
        .Put('/todos/:id', checksExistsUserAccount, UpdateTodo)
        .Patch('/todos/:id/done', checksExistsUserAccount, DoneTodo)
        .Delete('/todos/:id', checksExistsUserAccount, DeleteTodo)
end;

initialization
  Swagger
    .Info
      .Title('API para controle de todos')
      .Contact
        .Name('Alessandro Dutra')
        .Email('cachopaweb@gmail.com')
        .URL('https://meusite.com.br')
      .&End
    .&End
    .Path('todos')
      .Tag('Todos')
      .GET('List All', 'List All todos')
        .AddParamHeader('id', 'id user')
          .Required(True)
        .&End
        .AddResponse(400, 'User not Exists').&End
        .AddResponse(200, 'Ok')
          .Schema(TTodo)
          .IsArray(true)
        .&End
      .&End
      .POST('Create Todo', 'Create new Todo')
        .AddParamHeader('id', 'id user')
          .Required(True)
        .&End
        .AddParamBody('Todo data', 'Todo data')
          .Required(True)
          .Schema(TTodo)
        .&End
        .AddResponse(201, 'Created')
          .Schema(TTodo)
        .&End
        .AddResponse(400, 'User not Exists').&End
        .AddResponse(500, 'Internal server error').&End
      .&End
    .&End
    .Path('/todos/:id')
      .Tag('Todos')
      .PUT('Update Todo', 'Update specific todo')
          .AddParamHeader('id', 'user id')
            .Required(true)
            .Schema(SWAG_STRING)
          .&End
          .AddParamPath('id', 'id of todo')
            .Required(True)
            .Schema(SWAG_STRING)
          .&End
          .AddParamBody('Todo', 'Todo json object')
            .Schema(TTodo)
            .Required(true)
          .&End
          .AddResponse(400, 'User not exists').&End
          .AddResponse(404, 'Todo not found').&End
          .AddResponse(500, 'Internal server error').&End
        .&End
      .DELETE('Delete todo', 'Delete one todo')
        .AddParamHeader('id', 'user id')
           .Schema(SWAG_STRING)
           .Required(true)
        .&End
        .AddParamPath('id', 'id of todo')
           .Schema(SWAG_STRING)
           .Required(True)
        .&End
        .AddResponse(204, 'No Content').&End
        .AddResponse(400, 'User not exists').&End
        .AddResponse(404, 'Todo not found').&End
        .AddResponse(500, 'Internal server error').&End
      .&End
    .&End
    .Path('/todos/:id/done')
      .Tag('Todos')
      .PATCH('Set todo done', 'Update todo for done')
          .AddParamHeader('id', 'user id')
            .Schema(SWAG_STRING)
            .Required(true)
          .&End
          .AddParamPath('id', 'id of todo')
            .Schema(SWAG_STRING)
            .Required(true)
          .&End
          .AddResponse(204, 'No Content').&End
          .AddResponse(400, 'User not exists').&End
          .AddResponse(404, 'Todo not found').&End
          .AddResponse(500, 'Internal server error').&End
        .&End
      .&End
    .&End
end.
