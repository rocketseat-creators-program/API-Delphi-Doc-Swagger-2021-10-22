unit UnitTodos.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  System.Generics.Collections,
  SysUtils,
  System.Json,
  UnitTodo.Model;

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
  IdUser: string;
  indice: Integer;
  todos: TArray<TTodo>;
  todo: TTodo;
begin
  IdUser := Req.Headers['id'];
  oJson := Req.Body<TJSONObject>;
  UsersRepository := TUsersRepository.New;
  for user in UsersRepository.Users do
  begin
    if user.id = IdUser then
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
  idTodo: string;
  IdUser: string;
  TodoExists: Boolean;
  i: Integer;
  Indice: Integer;
  Todos: TArray<TTodo>;
  IndexUser: Integer;  
begin
  IdUser := Req.Headers['id'];
  idTodo := Req.Params['id'];
  UsersRepository := TUsersRepository.New;
  TodoExists := False;
  for user in UsersRepository.Users do
  begin
    if user.id = IdUser then
    begin
      for i := Low(user.todos) to High(user.todos) do
      begin
        if user.todos[i].id = idTodo then
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
  idTodo: string;
  IdUser: string;
  TodoExists: Boolean;
  i: Integer;
  Indice: Integer;
  IndexUser: Integer;
  jsonTodo: TJSONObject;
  Todo: TTodo;
begin
  IdUser := Req.Headers['id'];
  idTodo := Req.Params['id'];
  UsersRepository := TUsersRepository.New;
  TodoExists := False;
  for user in UsersRepository.Users do
  begin
    if user.id = IdUser then
    begin
      for i := Low(user.todos) to High(user.todos) do
      begin
        if user.todos[i].id = idTodo then
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
  idTodo: string;
  IdUser: string;
  TodoExists: Boolean;
  i: Integer;
  Indice: Integer;
  IndexUser: Integer;
  jsonTodo: TJSONObject;
  Todo: TTodo;
begin
  IdUser := Req.Headers['id'];
  idTodo := Req.Params['id'];
  jsonTodo := Req.Body<TJSONObject>;//parse json object
  UsersRepository := TUsersRepository.New;
  TodoExists := False;
  for user in UsersRepository.Users do
  begin
    if user.id = IdUser then
    begin
      for i := Low(user.todos) to High(user.todos) do
      begin
        if user.todos[i].id = idTodo then
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
  Res.Send<TJSONObject>(Todo.toJson).Status(THTTPStatus.OK);
end;

class procedure TTodoController.Registrar;
begin
  THorse.Get('/todos', checksExistsUserAccount, GetAllTodos)
        .Post('/todos', checksExistsUserAccount, CreateTodo)
        .Put('/todos/:id', checksExistsUserAccount, UpdateTodo)
        .Delete('/todos/:id', checksExistsUserAccount, DeleteTodo)
        .Patch('/todos/:id/done', checksExistsUserAccount, DoneTodo);
end;

end.
