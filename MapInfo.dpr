program MapInfo;

uses
  Vcl.Forms,
  uMapInfo in 'uMapInfo.pas' {frmMapInfo},
  uSetCity in 'uSetCity.pas' {frmSetCity},
  uPublicFunc in 'uPublicFunc.pas',
  uRegister in 'uRegister.pas' {frmRegister},
  dmDBSQLite3 in 'dmDBSQLite3.pas' {dmSQLite3: TDataModule},
  uSQLiteUtils in 'uSQLiteUtils.pas',
  uRegCode in 'uRegCode.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMapInfo, frmMapInfo);
  Application.CreateForm(TfrmSetCity, frmSetCity);
  Application.CreateForm(TfrmRegister, frmRegister);
  //Application.CreateForm(TdmSQLite3, dmSQLite3);
  Application.Run;
end.
