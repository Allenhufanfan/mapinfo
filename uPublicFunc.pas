unit uPublicFunc;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  ExcelXP, OleServer, ComObj, ShellAPI;

procedure ToExcel(FListView: TListView; sFiledname: string);

procedure ToTxt(FListView: TListView; sFiledname: string);

procedure ToVCF(FListView: TListView; sFiledname: string);

implementation

procedure ToExcel(FListView: TListView; sFiledname: string);
var
  ExcelApp: Variant;
  i, j: integer;
  saveDlg: TSaveDialog;
  modelfile: string;
begin
  if FListView.Items.Count <= 0 then
    Exit;

  modelfile := ExtractFilePath(Paramstr(0)) + 'template.xls';
  if not FileExists(modelfile) then
  begin
    Application.MessageBox('系统不支持该报表导出', '提示', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  saveDlg := TSaveDialog.Create(nil);
  saveDlg.Filter := 'Excel files (*.xls)';
  saveDlg.DefaultExt := 'xls';
  saveDlg.FileName := sFiledname;
  if saveDlg.Execute then
  try
    try
      try
        ExcelApp := CreateOleObject('Excel.Application');
      except
        Application.MessageBox('无法打开Xls文件，请确认已经安装EXCEL.', '错误', MB_OK + mb_IconStop);
        exit;
      end;

      if FileExists(saveDlg.FileName) then
      begin
        if application.messagebox('该文件已经存在，要覆盖吗？', '询问', mb_yesno + mb_iconquestion) = idyes then
          DeleteFile(PChar(saveDlg.FileName))
        else
          exit;
      end;

      ExcelApp.Visible := False;
      ExcelApp.WorkBooks.Open(modelfile);
      ExcelApp.WorkSheets[1].Activate;
      ExcelApp.DisplayAlerts := False;

      try
        for i := 0 to FListView.Items.Count - 1 do
        begin
          for j := 1 to FListView.Columns.Count - 1 do
            ExcelApp.WorkSheets[1].Cells[2 + i, j] := FListView.Items[i].SubItems.Strings[j - 1];
        end;
      except

      end;

      ExcelApp.ActiveWorkBook.SaveAs(saveDlg.FileName);
      if Application.MessageBox('导出文件成功!, 是否需要现在查看? ', '提示', MB_YESNO + MB_ICONINFORMATION + MB_DEFBUTTON2) = ID_YES then
        ShellExecute(Application.Handle, 'Open', Pchar(saveDlg.FileName), nil, nil, SW_SHOWNORMAL);
    except
      on E: Exception do
        MessageBox(Application.Handle, PChar(E.Message), '系统提示', MB_ICONINFORMATION or MB_OK);
    end;
  finally
    ExcelApp.quit;
    saveDlg.Free;
  end;
end;

procedure ToTxt(FListView: TListView; sFiledname: string);
const
  FormatStr = '%:-20s|';
var
  StrList: TStringList;
  SaveDialog: TSaveDialog;
  i, j: Integer;
  Str: string;
  Line: string;
begin
  if FListView.Items.Count <= 0 then
    Exit;

  StrList := TStringList.Create;
  try
    Str := '';
    Line := '';
    for i := 1 to FListView.Columns.Count - 1 do
    begin
      Str := Str + Format(FormatStr, [FListView.Columns[i].Caption]);
      Line := Line + '--------------------+';
    end;
    StrList.Add(Str);
    Strlist.Add(Line);
    for j := 0 to FListView.Items.Count - 1 do
    begin
      Str := '';
      //Str := Format(FormatStr, [FListView.Items[j].Caption]);
      for i := 1 to FListView.Columns.Count - 1 do
        Str := Str + Format(FormatStr, [FListView.Items[j].SubItems[i - 1]]);
      StrList.Add(Str);
    end;

    SaveDialog := TSaveDialog.Create(nil);
    SaveDialog.Filter := '*.txt|*.txt';
    SaveDialog.DefaultExt := 'txt';
    SaveDialog.FileName := sFiledname;
    if SaveDialog.Execute then
    begin
      if FileExists(SaveDialog.FileName) then
      begin
        if application.messagebox('该文件已经存在，要覆盖吗？', '询问', mb_yesno + mb_iconquestion) = idyes then
          DeleteFile(PChar(SaveDialog.FileName))
        else
          exit;
      end;

      StrList.SaveToFile(SaveDialog.FileName); //采用stringlist封装的文件流接口
      Application.MessageBox('导出文件成功！', '提示', MB_ICONINFORMATION);
    end;
  finally
    StrList.Free;
  end;
end;

procedure ToVCF(FListView: TListView; sFiledname: string);
var
  StrList: TStringList;
  SaveDialog: TSaveDialog;
  i, j: Integer;
  orgname,phone,addr: string;
  Line: string;
begin
  if FListView.Items.Count <= 0 then
    Exit;

  StrList := TStringList.Create;
  try
    for i := 0 to FListView.Items.Count - 1 do
    begin
      StrList.Add('BEGIN:VCARD');
      StrList.Add('VERSION:2.1');

      orgname := FListView.Items[i].SubItems[1];
      phone := FListView.Items[i].SubItems[2];
      addr := FListView.Items[i].SubItems[4];
      StrList.Add('ORG;CHARSET=gb2312:' + orgname);
      StrList.Add('TEL;WORK;VOICE:' + phone);
      StrList.Add('ADR;WORK;CHARSET=gb2312:;;' + addr + ';;;');

      StrList.Add('END:VCARD');
    end;
    SaveDialog := TSaveDialog.Create(nil);
    SaveDialog.Filter := '*.vcf|*.vcf';
    SaveDialog.DefaultExt := 'vcf';
    SaveDialog.FileName := sFiledname;
    if SaveDialog.Execute then
    begin
      if FileExists(SaveDialog.FileName) then
      begin
        if application.messagebox('该文件已经存在，要覆盖吗？', '询问', mb_yesno + mb_iconquestion) = idyes then
          DeleteFile(PChar(SaveDialog.FileName))
        else
          exit;
      end;
      StrList.SaveToFile(SaveDialog.FileName); //采用stringlist封装的文件流接口
      Application.MessageBox('导出文件成功！', '提示', MB_ICONINFORMATION);
    end;

  finally
    StrList.Free;
  end;
end;

end.

