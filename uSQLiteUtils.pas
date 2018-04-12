unit uSQLiteUtils;

interface

// ʹ�� UniDaC ���

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
  Result := TUniConnection.Create(Application);  // �� Nil �ڰ칫ʱ���˳��쳣
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
    
  // SQLite ���ݿ���д��ռ��
  // ATTACH/DETACH DATABASE ���ܴ�����
  AttachDB := (Pos('ATTACH', SQL) in [1..3]);
  if AttachDB then             // ������ֹؼ��� <DB_PATH>/<DATABASE_PATH>, �滻·��
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
//      Query.SQL.SaveToFile('exec.sql');      // ����
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
    if not InTransaction then          // ������ʱ�ǳ���
      StartTransaction;
  end;
end;

procedure StartTrans(Database: TUniConnection);
begin
  with Database do
  begin
    if not Connected then
      Connected := True;
    if not InTransaction then          // ������ʱ�ǳ���
      StartTransaction;
  end;
end;

initialization

finalization

end.
