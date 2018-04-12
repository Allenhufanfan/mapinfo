unit uPublicFunc;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  ExcelXP, OleServer, ComObj, ShellAPI;

procedure ToExcel(FListView: TListView; sFiledname: string);

procedure ToTxt(FListView: TListView; sFiledname: string);

implementation

procedure ToExcel(FListView: TListView; sFiledname: string);
var
  ExcelApp: Variant;
  i, j: integer;
  saveDlg: TSaveDialog;
  modelfile: string;
begin
  modelfile := ExtractFilePath(Paramstr(0)) + 'template.xls';
  if not FileExists(modelfile) then
  begin
    Application.MessageBox('ϵͳ��֧�ָñ�����', '��ʾ', MB_OK + MB_ICONINFORMATION);
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
        Application.MessageBox('�޷���Xls�ļ�����ȷ���Ѿ���װEXCEL.', '����', MB_OK + mb_IconStop);
        exit;
      end;

      if FileExists(saveDlg.FileName) then
      begin
        if application.messagebox('���ļ��Ѿ����ڣ�Ҫ������', 'ѯ��', mb_yesno + mb_iconquestion) = idyes then
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
      if Application.MessageBox('�����ļ��ɹ�!, �Ƿ���Ҫ���ڲ鿴? ', '��ʾ', MB_YESNO + MB_ICONINFORMATION + MB_DEFBUTTON2) = ID_YES then
        ShellExecute(Application.Handle, 'Open', Pchar(saveDlg.FileName), nil, nil, SW_SHOWNORMAL);
    except
      on E: Exception do
        MessageBox(Application.Handle, PChar(E.Message), 'ϵͳ��ʾ', MB_ICONINFORMATION or MB_OK);
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
    SaveDialog.FileName := sFiledname;
    if SaveDialog.Execute then
    begin
      StrList.SaveToFile(SaveDialog.FileName + '.txt'); //����stringlist��װ���ļ����ӿ�
      Application.MessageBox('�����ļ��ɹ���', '��ʾ', MB_ICONINFORMATION);
    end;
  finally
    StrList.Free;
  end;
end;

end.

