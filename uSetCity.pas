unit uSetCity;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxCustomData, cxStyles, cxTL,
  cxTextEdit, cxTLdxBarBuiltInMenu, Vcl.StdCtrls, cxInplaceContainer,
  uni;

type
  TfrmSetCity = class(TForm)
    TreeList_city: TcxTreeList;
    cxTreeList1Column1: TcxTreeListColumn;
    btn_Sure: TButton;
    btn_Close: TButton;
    procedure btn_SureClick(Sender: TObject);
    procedure btn_CloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GetCitys(Query: TUniQuery);
    procedure AddTreelist(sAarea_name, sSub_area_name: string);
    function GetSelectedCity: TStrings;
    procedure SetSelectedCity(strCitys: Tstrings);
    { Public declarations }
  end;

var
  frmSetCity: TfrmSetCity;

implementation

{$R *.dfm}

procedure TfrmSetCity.AddTreelist(sAarea_name, sSub_area_name: string);
var
  i: Integer;
  vNode: TcxTreeListNode;
begin
  TreeList_city.Root.CheckGroupType := ncgCheckGroup;
  TreeList_city.OptionsView.CheckGroups := True;
  TreeList_city.BeginUpdate;
  try
    for i := 0 to TreeList_city.Root.Count - 1 do
    begin
      if (TreeList_city.Root.Items[i].Texts[0] = sAarea_name) then
      begin
        //有主节点，则直接增加子节点
        vNode := TreeList_city.Root.Items[i];
        with vNode.AddChild do
        begin
          CheckGroupType := ncgCheckGroup;
          Values[0] := sSub_area_name;
        end;
        exit;
      end;
    end;
    //没有找到主节点，直接增加主节点和子节点
    vNode := TreeList_city.Add;
    vNode.CheckGroupType := ncgCheckGroup;
    vNode.Values[0] := sAarea_name;
    with vNode.AddChild do
    begin
      CheckGroupType := ncgCheckGroup;
      Values[0] := sSub_area_name;
    end;
  finally
    TreeList_city.EndUpdate;
  end;
end;

procedure TfrmSetCity.btn_SureClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TfrmSetCity.btn_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSetCity.GetCitys(Query: TUniQuery);
var
  sArea_type, sArea_code, sAarea_name, sSub_area_type, sSub_area_code, sSub_area_name: string;
begin
  if Query.RecordCount < 0 then
    Exit;
  with Query do
  begin
    First;
    while not Eof do
    begin
      sArea_type := FieldByName('area_type').AsString;
      sArea_code := FieldByName('area_code').AsString;
      sAarea_name := FieldByName('area_name').AsString;
      sSub_area_type := FieldByName('sub_area_type').AsString;
      sSub_area_code := FieldByName('sub_area_code').AsString;
      sSub_area_name := FieldByName('sub_area_name').AsString;
      AddTreelist(sAarea_name, sSub_area_name);
      Next;
    end;
  end;
end;

function TfrmSetCity.GetSelectedCity: TStrings;
var
  i: Integer;
  MyStringList: TStringList;
begin
  MyStringlist := TStringList.Create;
  //遍历所有节点，获取选择的城市
  for i := 0 to TreeList_city.AbsoluteCount - 1 do
  begin
    if TreeList_city.AbsoluteItems[i].Checked then
    begin
      if not (TreeList_city.AbsoluteItems[i].HasChildren) then
        MyStringList.Add(TreeList_city.AbsoluteItems[i].Texts[0]);
    end;
  end;
  Result := MyStringList;
  //MyStringList.Free;
end;

procedure TfrmSetCity.SetSelectedCity(strCitys: Tstrings);
var
  i, j: Integer;
begin
  for i := 0 to strCitys.Count - 1 do
  begin
    for j := 0 to TreeList_city.AbsoluteCount - 1 do
    begin
      if strCitys.Strings[i] = TreeList_city.AbsoluteItems[j].Texts[0] then
        TreeList_city.AbsoluteItems[j].Checked := True;
    end;
  end;
end;

end.

