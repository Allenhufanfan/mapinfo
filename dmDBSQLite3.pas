unit dmDBSQLite3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, Provider, uni, UniProvider, SQLiteUniProvider, DBAccess;

type
  TdmSQLite3 = class(TDataModule)
    SQLiteUniProvider: TSQLiteUniProvider;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    FConnection: TUniConnection;
    FCon_lic: TUniConnection;   //��ȡ���ע�������ļ� lic.db  ����
    FQuery: TUniQuery;
    FExecSQL: TUniSQL;
  public
    //���д���ʼ��Ϣ
    procedure InsetInitinfo(sReg_code: string; sActi_code: string);
    //�ٶȵ�ͼͨ����������ȡ��Ӧ�ĳ��д���
    function GetCitycode_Baidu(sCityName: string): string;
    //�ߵµ�ͼͨ����������ȡ��Ӧ�ĳ��д���
    function GetCitycode_Gaode(sCityName: string): string;
    //��ȡ������Ϣ
    function GetCityTree: TUniQuery;
    //��ȡע����Ϣ
    function GetSqlReginfo(var sReg_code: string; var sActi_code: string): Boolean;
    //����ע����Ϣ
    function SetSqlReginfo(sReg_code: string; sActi_code: string): Boolean;
    //����ע����Ϣ
    function RevertSqlReginfo(sReg_code: string; sActi_code: string): Boolean;
  end;

var
  dmSQLite3: TdmSQLite3;

implementation

uses
  uSQLiteUtils;     //UniDAC��Sqlite����

{$R *.dfm}

procedure TdmSQLite3.DataModuleCreate(Sender: TObject);
var
  sLibary: string;
  sLic_Database: string;
begin
  inherited;
  sLibary := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
  //ע����Ϣ�ļ�
  sLic_Database := ExtractFilePath(ParamStr(0)) + 'lic.db';

  // ���ݿ�
  FConnection := CreateSQLite3DB('mapinfo.db');
  FQuery := CreateSQLite3Query(FConnection);
  FExecSQL := CreateSQLite3SQL(FConnection);
  FConnection.Connected := True;

  FCon_lic := TUniConnection.Create(Application);
  FCon_lic.ConnectString := 'Provider Name=SQLite;Database=' + sLic_Database + ';Client Library=' + sLibary + ';Encryption Key=kingdom;Login Prompt=False';
  FCon_lic.Connected := True;
end;

procedure TdmSQLite3.DataModuleDestroy(Sender: TObject);
begin
  inherited;
  FQuery.Free;
  FExecSQL.Free;
  try
    FConnection.Free;  // UniDAC ���� SQLite ������ʾ�쳣
    FCon_lic.Free;
  except
  end;
end;

function TdmSQLite3.GetCitycode_Baidu(sCityName: string): string;
var
  sqlstr: string;
begin
  sqlstr := 'select sub_area_code from baidu_citycode where sub_area_name =' + QuotedStr(sCityName);
  FQuery.Connection := FConnection;
  ExecSelectSQL(FQuery, sqlstr);
  if FQuery.RecordCount = 1 then
    Result := FQuery.FieldByName('sub_area_code').AsString;
end;

function TdmSQLite3.GetCitycode_Gaode(sCityName: string): string;
var
  sqlstr: string;
begin
  sqlstr := 'select sub_area_code from gaode_citycode where sub_area_name =' + QuotedStr(sCityName);
  FQuery.Connection := FConnection;
  ExecSelectSQL(FQuery, sqlstr);
  if FQuery.RecordCount = 1 then
    Result := FQuery.FieldByName('sub_area_code').AsString;
end;

function TdmSQLite3.GetCityTree: TUniQuery;
var
  sqlstr: string;
begin
  sqlstr := 'select * from baidu_citycode';
  FQuery.Connection := FConnection;
  ExecSelectSQL(FQuery, sqlstr);
  Result := FQuery;
end;

function TdmSQLite3.GetSqlReginfo(var sReg_code: string; var sActi_code: string): Boolean;
var
  sqlstr: string;
begin
  sqlstr := 'select * from reginfo';
  FQuery.Connection := FCon_lic;
  ExecSelectSQL(FQuery, sqlstr);
  if FQuery.RecordCount = 1 then
  begin
    with FQuery do
    begin
      sReg_code := FieldByName('reg_code').AsString;
      sActi_code := FieldByName('acti_code').AsString;
    end;
  end;
end;

procedure TdmSQLite3.InsetInitinfo(sReg_code, sActi_code: string);
var
  sInsertsql,sQrysql :string;
  nCnt : Integer;
begin
  //��ѯ
  sQrysql := 'select * from reginfo';
  sInsertsql := 'insert into reginfo values(' + QuotedStr(sReg_code) + ',' + QuotedStr(sActi_code) + ')';
  try
    FQuery.Connection := FCon_lic;
    ExecSelectSQL(FQuery, sQrysql);
    nCnt := FQuery.RecordCount;
    if nCnt = 0 then
      ExecuteSQL(FQuery, sInsertsql);
  except

  end;
end;

function TdmSQLite3.RevertSqlReginfo(sReg_code, sActi_code: string): Boolean;
var
  sInsertsql, sDelsql, sQrysql: string;
  nCnt : Integer;
begin
  Result := False;
  //��ѯ
  sQrysql := 'select * from reginfo';
  //ɾ��
  sDelsql := 'delete from reginfo;';
  //����
  sInsertsql := 'insert into reginfo values(' + QuotedStr(sReg_code) + ',' + QuotedStr(sActi_code) + ')';

  try
    FQuery.Connection := FCon_lic;
    ExecSelectSQL(FQuery, sQrysql);
    nCnt := FQuery.RecordCount;
    if nCnt = 1 then
    begin
      ExecuteSQL(FQuery, sDelsql);
      ExecuteSQL(FQuery, sInsertsql);
    end;
    Result := True;
  except
    Result := False;
  end;
end;


function TdmSQLite3.SetSqlReginfo(sReg_code: string; sActi_code: string): Boolean;
var
  sInsertsql, sUpdsql, sQrysql: string;
  nCnt : Integer;
begin
  Result := False;
  //��ѯ
  sQrysql := 'select * from reginfo';
  //����
  sUpdsql := 'update reginfo set acti_code =' + QuotedStr(sActi_code) + ' where reg_code =' + QuotedStr(sReg_code);
  //����
  sInsertsql := 'insert into reginfo values(' + QuotedStr(sReg_code) + ',' + QuotedStr(sActi_code) + ')';
  try
    FQuery.Connection := FCon_lic;
    ExecSelectSQL(FQuery, sQrysql);
    nCnt := FQuery.RecordCount;
    if nCnt = 1 then
    begin
      ExecuteSQL(FQuery, sUpdsql);
    end
    else if nCnt = 0 then
      ExecuteSQL(FQuery, sInsertsql);

    Result := True;
  except
    Result := False;
  end;
end;

end.

