unit uSQLiteUtils;

interface

// 使用 UniDaC 组件

uses
  Classes, SysUtils, StrUtils, Forms, DB, LiteCallUni,
  DBAccess, Uni, MemDS, SQLiteUniProvider;

type
  TSQLSelectEvent = function: TUniQuery of object;

function CreateSQLite3DB(const DatabaseFile: String): TUniConnection;
function CreateSQLite3Query(Database: TUniConnection): TUniQuery;
function CreateSQLite3SQL(Database: TUniConnection): TUniSQL;

procedure ExecuteSQL(Query: TUniQuery; SQL: String; AutoTransaction: Boolean = True);
procedure ExecSelectSQL(Query: TUniQuery; const SQL: String);
procedure ExecQuery(Query: TUniQuery; const SQL: String; AutoTransaction: Boolean = True);

procedure CommitTrans(Database: TUniConnection; DoDisconnect: Boolean = False);
procedure StartTrans(Database: TUniConnection);

implementation

function CreateSQLite3DB(const DatabaseFile: String): TUniConnection;
begin
  Result := TUniConnection.Create(Application);  // 用 Nil 在办公时会退出异常
  Result.Database := DatabaseFile;
  Result.ProviderName := 'SQLite';
  Result.LoginPrompt := False;
  Result.Connected := True;
end;

function CreateSQLite3SQL(Database: TUniConnection): TUniSQL;
begin
  Result := TUniSQL.Create(Application);
  Result.Connection := Database;
end;

function CreateSQLite3Query(Database: TUniConnection): TUniQuery;
begin
  Result := TUniQuery.Create(Application);
  Result.Connection := Database;
end;

procedure ExecuteSQL(Query: TUniQuery; SQL: String; AutoTransaction: Boolean);
var
  AttachDB: Boolean;
  DatabasePath: String;
begin
  if UpperCase(SQL) = 'COMMIT' then
    Exit;
    
  // SQLite 数据库是写独占的
  // ATTACH/DETACH DATABASE 不能打开事务
  AttachDB := (Pos('ATTACH', SQL) in [1..3]);
  if AttachDB then             // 允许出现关键词 <DB_PATH>/<DATABASE_PATH>, 替换路径
  begin
    DatabasePath := ExtractFilePath(Query.Connection.Database);
    SQL := StringReplace(SQL, '<DB_PATH>', DatabasePath, [rfReplaceAll, rfIgnoreCase]);
    SQL := StringReplace(SQL, '<DATABASE_PATH>', DatabasePath, [rfReplaceAll, rfIgnoreCase]);
  end else
    AttachDB := (Pos('DETACH', SQL) in [1..3]);
    
  if AutoTransaction or AttachDB then
    CommitTrans(Query.Connection, AttachDB);

  try
    try
      if Query.Active then
        Query.Active := False;

      Query.SQL.Text := SQL;
//      Query.SQL.SaveToFile('exec.sql');      // 调试
      Query.Execute;

      if AutoTransaction or AttachDB then
        CommitTrans(Query.Connection);
    finally
      Query.SQL.Clear;
    end;
  except
    with Query.Connection do
      if InTransaction then
        Rollback;
    Raise;
  end;
end;

procedure ExecSelectSQL(Query: TUniQuery; const SQL: String);
begin
  if Query.Active then
    Query.Active := False;
  Query.SQL.Text := SQL;
  Query.Active := True;
end;

procedure ExecQuery(Query: TUniQuery; const SQL: String; AutoTransaction: Boolean);
var
  SQLHead: string;
begin
  SQLHead := Copy(SQL, 1, 10);
  if (Pos('SELECT', SQLHead) in [1..3]) or (Pos('WITH', SQLHead) in [1..3]) then     // RECURSIVE
    ExecSelectSQL(Query, SQL)
  else
    ExecuteSQL(Query, SQL, AutoTransaction);
end;

procedure CommitTrans(Database: TUniConnection; DoDisconnect: Boolean);
begin
  with Database do
  begin
    if InTransaction then
      Commit;
    if DoDisconnect then
      Connected := False
    else
    if not InTransaction then          // 不启动时非常慢
      StartTransaction;
  end;
end;

procedure StartTrans(Database: TUniConnection);
begin
  with Database do
  begin
    if not Connected then
      Connected := True;
    if not InTransaction then          // 不启动时非常慢
      StartTransaction;
  end;
end;

initialization

finalization

end.
