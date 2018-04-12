unit uSetMapInfoSql;

interface

uses
  System.SysUtils, SQLiteTable3;


//�ٶȵ�ͼͨ����������ȡ��Ӧ�ĳ��д���
function GetCitycode_Baidu(sCityName: string): string;
//�ߵµ�ͼͨ����������ȡ��Ӧ�ĳ��д���
function GetCitycode_Gaode(sCityName: string): string;

//function GetRegisterInfo(): Boolean;

var
  SqlDb: TSQLiteDatabase;

implementation

function GetCitycode_Baidu(sCityName: string): string;
var
  SqlTb: TSQLiteTable;
begin
  SqlDb := TSQLiteDatabase.Create('mapinfo.db');
  if SqlDb.TableExists('baidu_citycode') then
  begin
    SqlTb := SqlDb.GetTable('select * from baidu_citycode');
    while not SqlTb.EOF do
    begin
      if (sCityName = Trim(SqlTb.FieldAsString(SqlTb.FieldIndex['sub_area_name']))) then
      begin
        Result := SqlTb.FieldAsString(SqlTb.FieldIndex['sub_area_code']);
        Break;
      end;
      SqlTb.Next;
    end;
    SqlTb.Free;
  end;
  SqlDb.Free;
end;

function GetCitycode_Gaode(sCityName: string): string;
var
  SqlTb: TSQLiteTable;
begin
  SqlDb := TSQLiteDatabase.Create('mapinfo.db');
  if SqlDb.TableExists('gaode_citycode') then
  begin
    SqlTb := SqlDb.GetTable('select * from gaode_citycode');
    while not SqlTb.EOF do
    begin
      if (sCityName = Trim(SqlTb.FieldAsString(SqlTb.FieldIndex['sub_area_name']))) then
      begin
        Result := SqlTb.FieldAsString(SqlTb.FieldIndex['sub_area_code']);
        Break;
      end;
      SqlTb.Next;
    end;
    SqlTb.Free;
  end;
  SqlDb.Free;
end;


end.

