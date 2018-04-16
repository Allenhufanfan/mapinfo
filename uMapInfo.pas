unit uMapInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.DateUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.ExtCtrls, dxBar, cxClasses, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, qjson, Web.HTTPApp,
  Vcl.ActnList, IdAntiFreezeBase, Vcl.IdAntiFreeze, uPublicFunc, cxLabel,
  dxBarExtItems, cxBarEditItem, dxColorEdit, cxGroupBox, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, dmDBSQLite3,
  uRegCode, IdHashMessageDigest, IdGlobal;

type
  //建立一个获取数据的线程
  TRevThread = class(TThread)
  private
    FCityCode: string;  //当前城市代码
    FCityName: string;  //当前城市名称
    FWd: string;        //当前关键字查询 url编码
    FKeyWord: string;   //当前关键字查询
  protected
    procedure Execute; override;
  public
    constructor Create;
    //获取JSON串
    function GetHTML(Url: string): string;
    //Unicode转中文编码
    function UnicodeToChinese(inputstr: string): string;
    procedure UpdateListView_Baidu;
    procedure UpdateListView_GaoDe;
    procedure UpdateListView_360;
    procedure UpdateListView_Tencent;
    //获取百度地图查询信息总条数
    function GetBaiduMapInfoCnt(sCityCode, sWd: string): Integer;
    //获取高德地图查询信息总条数
    function GetGaodeMapInfoCnt(sCityCode, sWd: string): Integer;
    //获取360地图查询信息总条数
    function Get360MapInfoCnt(sCityCode, sWd: string): Integer;
    //获取腾讯地图查询信息总条数
    function GetTencentMapInfoCnt(sCityCode, sWd: string): Integer;
    function GetHTTPS(Url: string): string;
    function GetUnixTime: string;
    function GetPhoneNum(sPhone: string): string;
    function SplitString(Source, Deli: string): string;
    function SetPhoneNum(sPhone: string): string;
  end;

type
  TfrmMapInfo = class(TForm)
    lvMapInfo: TListView;
    Panel2: TPanel;
    IdHTTP1: TIdHTTP;
    Panel3: TPanel;
    Panel4: TPanel;
    GroupBox1: TGroupBox;
    mmCity: TMemo;
    GroupBox2: TGroupBox;
    mmKeywd: TMemo;
    Panel5: TPanel;
    GroupBox3: TGroupBox;
    btn_Start: TButton;
    btn_Stop: TButton;
    btn_Clear: TButton;
    btn_ExportXls: TButton;
    btn_txt: TButton;
    ChkPhone: TCheckBox;
    btn_Addcity: TButton;
    Button8: TButton;
    Label1: TLabel;
    edt_Cnt: TcxTextEdit;
    edt_Cityname: TcxTextEdit;
    Label2: TLabel;
    edt_Status: TcxTextEdit;
    Label3: TLabel;
    edt_KeyWord: TcxTextEdit;
    Label4: TLabel;
    ActionList: TActionList;
    Act_Addcity: TAction;
    Act_AddKeyWord: TAction;
    IdAntiFreeze1: TIdAntiFreeze;
    group_Map: TcxGroupBox;
    Act_BarClick: TAction;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    ChkTelphone: TCheckBox;
    dxBarManager: TdxBarManager;
    dxBarManager1Bar1: TdxBar;
    dxBarBtn_Baidu: TdxBarLargeButton;
    dxBarBtn_tencent: TdxBarLargeButton;
    dxBarBtn_Gaode: TdxBarLargeButton;
    dxBarBtn_360: TdxBarLargeButton;
    dxBarLargeButton2: TdxBarLargeButton;
    dxBarSubItem1: TdxBarSubItem;
    dxBarSubItem2: TdxBarSubItem;
    Act_Register: TAction;
    procedure Act_AddcityExecute(Sender: TObject);
    procedure Act_BarClickExecute(Sender: TObject);
    procedure Act_RegisterExecute(Sender: TObject);
    procedure btn_ExportXlsClick(Sender: TObject);
    procedure btn_StartClick(Sender: TObject);
    procedure btn_StopClick(Sender: TObject);
    procedure btn_ClearClick(Sender: TObject);
    procedure btn_txtClick(Sender: TObject);
    procedure dxBarBtn_360Click(Sender: TObject);
    procedure dxBarBtn_BaiduClick(Sender: TObject);
    procedure dxBarBtn_GaodeClick(Sender: TObject);
    procedure dxBarBtn_tencentClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure lvMapInfoClick(Sender: TObject);
  private
    { Private declarations }
    FHttpFlag: Boolean; // 查询标志，点击查询时，置为true，停止查询置为false；
    FReg_code: string;  //机器码
    FActi_code: string; //激活码
  public
    { Public declarations }
    FSqliteDataModule: TdmSQLite3;
    FBaiduMap_thread: TRevThread;
    FMapFlag: Integer; //0：百度地图  1：腾讯地图  2：高德地图  3：360地图
    //设置主界面状态
    procedure Update_lbl();
    //获取软件是否激活
    function IsActivation: Boolean;
    //打开软件初始化激活信息
    procedure InitRegInfo;
    procedure ShowQrymsg();
    procedure ShowActimsg();
    procedure setQryFlag();
    function strTOMD5(S: string): string;
  end;

var
  frmMapInfo: TfrmMapInfo;

implementation

{$R *.dfm}
uses
  uSetCity, uRegister;

const
  sBaiduMapAppid = 'IWRYE8nGCyLWl9RmGXSEnYE4Qes1HX2x'; //百度地图秘钥
  sGaodeMapAppid = 'fd6d774a75d0e52bf9696fb9d079445e'; //高德地图秘钥
  //fd6d774a75d0e52bf9696fb9d079445e
  //f6d2e2a4644fa7d750d7e0bfbe14d23
  sTencentMapAppid = '6PJBZ-CQXKD-WK54A-HGDWF-FSIJH-I5FWI'; //腾讯地图秘钥

procedure TfrmMapInfo.Act_AddcityExecute(Sender: TObject);
begin
  frmSetCity := TfrmSetCity.Create(self);
  with frmSetCity do
  begin
    try
      GetCitys(Self.FSqliteDataModule.GetCityTree);
      SetSelectedCity(Self.mmCity.Lines);
      if ShowModal = mrOk then
      begin
        Self.mmCity.Lines.Clear;
        Self.mmCity.Lines.AddStrings(GetSelectedCity);
      end;
    finally
      frmSetCity.Free;
    end;
  end;
end;

procedure TfrmMapInfo.Act_BarClickExecute(Sender: TObject);
begin
  group_Map.Caption := '当前地图：百度地图综合搜索';
end;

procedure TfrmMapInfo.Act_RegisterExecute(Sender: TObject);
begin
  if not FHttpFlag then
  begin
   //注册窗口
    frmRegister := TfrmRegister.Create(self);
    with frmRegister do
    begin
      try
        SetUI(FReg_code, FActi_code);
        if ShowModal = mrOk then
        begin

        end;
      finally
        frmRegister.Free;
      end;
    end;
    //获取是否激活信息
    FSqliteDataModule.GetSqlReginfo(FReg_code, FActi_code);
  end
  else
    ShowQrymsg;
end;

procedure TfrmMapInfo.btn_ExportXlsClick(Sender: TObject);
begin
  if not IsActivation then
  begin
    ShowActimsg;
    Exit;
  end;

  if not FHttpFlag then
    ToExcel(lvMapInfo, Self.Caption)
  else
    ShowQrymsg;
end;

procedure TfrmMapInfo.btn_StartClick(Sender: TObject);
begin
  if (mmCity.Lines.Text = '') or (Trim(mmKeywd.Lines.Text) = '') then
  begin
    Application.MessageBox('请选择【城市】以及【行业关键字】查询！', '错误', MB_OK + MB_ICONWARNING);
    Exit;
  end;
  lvMapInfo.Items.Clear;
  //创建地图数据解析线程
  FHttpFlag := True;
  setQryFlag;
  FBaiduMap_thread := TRevThread.Create();
  FBaiduMap_thread.FreeOnTerminate := True;
  FBaiduMap_thread.Resume;
end;

procedure TfrmMapInfo.btn_StopClick(Sender: TObject);
begin
  FHttpFlag := False;
  setQryFlag;
  if (FBaiduMap_thread <> nil) then
  begin
    if FBaiduMap_thread.Suspended then
      FBaiduMap_thread.Resume;
    FBaiduMap_thread.Terminate;
    FBaiduMap_thread := nil;
   // FreeAndNil(FBaiduMap_thread);
  end;
end;

procedure TfrmMapInfo.btn_ClearClick(Sender: TObject);
begin
  if not FHttpFlag then
    lvMapInfo.Items.Clear
  else
    ShowQrymsg;
end;

procedure TfrmMapInfo.btn_txtClick(Sender: TObject);
begin
  if not IsActivation then
  begin
    ShowActimsg;
    Exit;
  end;

  if not FHttpFlag then
    ToTxt(lvMapInfo, Self.Caption)
  else
    ShowQrymsg;
end;

procedure TfrmMapInfo.dxBarBtn_360Click(Sender: TObject);
begin
  if not FHttpFlag then
  begin
    FMapFlag := 3;
    group_Map.Caption := '当前地图：360地图综合搜索';
  end
  else
    ShowQrymsg;
end;

procedure TfrmMapInfo.dxBarBtn_BaiduClick(Sender: TObject);
begin
  if not FHttpFlag then
  begin
    FMapFlag := 0;
    group_Map.Caption := '当前地图：百度地图综合搜索';
  end
  else
    ShowQrymsg;
end;

procedure TfrmMapInfo.dxBarBtn_GaodeClick(Sender: TObject);
begin
  if not FHttpFlag then
  begin
    FMapFlag := 2;
    group_Map.Caption := '当前地图：高德地图综合搜索';
  end
  else
    ShowQrymsg;
end;

procedure TfrmMapInfo.dxBarBtn_tencentClick(Sender: TObject);
begin
  if not FHttpFlag then
  begin
    FMapFlag := 1;
    group_Map.Caption := '当前地图：腾讯地图综合搜索';
  end
  else
    ShowQrymsg;
end;

procedure TfrmMapInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FSqliteDataModule) then
    FSqliteDataModule.Free;

  if (FBaiduMap_thread <> nil) then
  begin
    if FBaiduMap_thread.Suspended then
      FBaiduMap_thread.Resume;
    FBaiduMap_thread.Terminate;
    FBaiduMap_thread := nil;
   // FreeAndNil(FBaiduMap_thread);
  end;
end;

procedure TfrmMapInfo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FHttpFlag then
  begin
    ShowQrymsg;
    CanClose := False; //保持程序的执行
    Exit;
  end;

  if Application.MessageBox(PChar('确定要退出吗?'), '提示', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON1	) = IDYES then
  begin
    application.Terminate; //关闭程序
  end
  else
    CanClose := False; //保持程序的执行
end;

procedure TfrmMapInfo.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  group_Map.Caption := '当前地图：百度地图综合搜索';
  lvMapInfo.Clear;

  lvMapInfo.Columns.Clear;
  for i := 0 to 8 do
  begin
    lvMapInfo.Columns.Add;
    lvMapInfo.Columns.Items[i].Width := 100;
    lvMapInfo.Columns.Items[i].Alignment := taCenter;
  end;
  lvMapInfo.Columns.Items[1].Caption := '编号';
  lvMapInfo.Columns.Items[2].Caption := '店铺名 ';
  lvMapInfo.Columns.Items[3].Caption := '联系电话';
  lvMapInfo.Columns.Items[4].Caption := '地图坐标';
  lvMapInfo.Columns.Items[5].Caption := '地址';
  lvMapInfo.Columns.Items[6].Caption := '区域 ';
  lvMapInfo.Columns.Items[7].Caption := '行业';
  lvMapInfo.Columns.Items[8].Caption := '关键字';
  lvMapInfo.Columns.Items[1].Width := 50;
  lvMapInfo.Columns.Items[2].Width := 150;
  lvMapInfo.Columns.Items[3].Width := 130;
  lvMapInfo.Columns.Items[5].Width := 200;
  lvMapInfo.Columns.Items[0].Width := 0;
  lvMapInfo.Columns.Items[8].Width := 0;

  lvMapInfo.ViewStyle := vsreport;
  lvMapInfo.GridLines := False;

  //创建连接sqlite的datamodule
  FSqliteDataModule := TdmSQLite3.Create(self);
  InitRegInfo;
end;

function TfrmMapInfo.IsActivation: Boolean;
begin
  //获取注册信息
  FSqliteDataModule.GetSqlReginfo(FReg_code, FActi_code);
  if strToMD5(FReg_code) <> FActi_code then
    Result := False
  else
    Result := True;
end;

procedure TfrmMapInfo.InitRegInfo;
var
  sGUID: string;
begin
  //获取注册信息
  FSqliteDataModule.GetSqlReginfo(FReg_code, FActi_code);

  sGUID := GetRegCode;

  //没有注册信息，则调用生成机器码
  if FReg_code = '' then
  begin
    FSqliteDataModule.InsetInitinfo(sGUID, '');
  end
  else
  begin
    if FReg_code <> sGUID then
    begin
      FSqliteDataModule.RevertSqlReginfo(sGUID, '');
      FActi_code := '';
    end;
  end;
  FSqliteDataModule.GetSqlReginfo(FReg_code, FActi_code);
end;

procedure TfrmMapInfo.lvMapInfoClick(Sender: TObject);
begin
  Update_lbl;
end;

procedure TfrmMapInfo.setQryFlag;
begin
  if FHttpFlag then
  begin
    btn_Start.Enabled := False;
    btn_Stop.Enabled := True;
  end
  else
  begin
    btn_Start.Enabled := True;
    btn_Stop.Enabled := False;
  end;
end;

procedure TfrmMapInfo.ShowActimsg;
begin
  MessageBox(Handle, '未激活版本！', '错误', MB_OK + MB_ICONWARNING);
end;

procedure TfrmMapInfo.ShowQrymsg;
begin
  MessageBox(Handle, '查询中，请稍后或者停止查询！', '提示', MB_OK + MB_ICONWARNING);
end;

function TfrmMapInfo.strTOMD5(S: string): string;
var
  Md5Encode: TIdHashMessageDigest5;
begin
  Md5Encode := TIdHashMessageDigest5.Create;
  result := Md5Encode.HashStringAsHex(S);
  Md5Encode.Free;
end;

procedure TfrmMapInfo.Update_lbl;
begin
  if lvMapInfo.ItemIndex > 0 then
  begin
    with lvMapInfo do
    begin
      edt_Cnt.Text := IntToStr(Items.Count);
      edt_Status.Text := Selected.SubItems.Strings[1];
      edt_Cityname.Text := Selected.SubItems.Strings[5];
      edt_KeyWord.Text := Selected.SubItems.Strings[7];
    end;
  end;

end;

constructor TRevThread.Create;
begin
  inherited Create(True);
  //FidHttp_MapInfo := TIdHTTP.Create(nil);
  //FidHttp_MapInfo.ReadTimeout := 3000;
  //FidHttp_MapInfo.ConnectTimeout := 3000;
end;

procedure TRevThread.Execute;
var
  i, j, k: Integer;
  sUrl_MapInfo, s: string;
  nWdCnt: Integer;   //关键字行数
  sWd: string;       //关键字转化成Url编码
  nCityCnt: Integer; //城市行数
begin
  inherited;
  try
    if not Terminated then
    begin
      nWdCnt := frmMapInfo.mmKeywd.Lines.Count;
      nCityCnt := frmMapInfo.mmCity.Lines.Count;
      for i := 0 to nCityCnt - 1 do   //按关键字行数 * 城市行数，来取得要查询的次数
      begin
        FCityName := frmMapInfo.mmCity.Lines[i];
        for j := 0 to nWdCnt - 1 do
        begin
          FKeyWord := frmMapInfo.mmKeywd.Lines[j];
          if Trim(FKeyWord) = '' then
            Continue;

          FWd := HTTPEncode(UTF8Encode(FKeyWord));
          if frmMapInfo.FMapFlag = 0 then        //百度
          begin
            FCityCode := frmMapInfo.FSqliteDataModule.GetCitycode_Baidu(FCityName);
            Synchronize(UpdateListView_Baidu);
          end
          else if frmMapInfo.FMapFlag = 1 then    //腾讯
          begin
            FCityCode := FCityName;
            Synchronize(UpdateListView_Tencent);
          end
          else if frmMapInfo.FMapFlag = 2 then    //高德
          begin
            FCityCode := frmMapInfo.FSqliteDataModule.GetCitycode_Gaode(FCityName);
            Synchronize(UpdateListView_GaoDe);
          end
          else if frmMapInfo.FMapFlag = 3 then     //360
          begin
            FCityCode := FCityName;
            Synchronize(UpdateListView_360);
          end;
        end;
      end;
    end;
  finally
    //查询完毕，重置查询状态
    frmMapInfo.FHttpFlag := False;
    frmMapInfo.setQryFlag;
    FreeOnTerminate := True;
    Application.MessageBox('查询完成！', '提示', MB_OK + MB_ICONINFORMATION);
  end;
end;

function TRevThread.Get360MapInfoCnt(sCityCode, sWd: string): Integer;
var
  //解析json
  AJson, AJson_Result: TQJson;
  sHTML: string;
  i: Integer;
  sUrl_MapInfo, sUnixTime: string;
begin
  Result := 0;
  sUnixTime := GetUnixTime;
  sUrl_MapInfo := 'https://restapi.map.so.com/newapi?jsoncallback=jQuery18309076796343886822_' + sUnixTime + '&keyword=' + FWd + '&cityname=' + FCityCode + '&batch=0&number=10&scheme=https&regionType=rectangle&sid=1000&region=&_=' + sUnixTime;
  sHTML := GetHTTPS(sUrl_MapInfo);
  if sHTML = '' then
    Exit;
  AJson := TQJson.Create;
  try
    AJson.Parse(sHTML);
    if AJson.AsString = '' then
      Exit;

    Result := AJson.ItemByName('pagesize').AsInteger;  // 总的页面数
  finally
    AJson.Free;
  end;
end;

function TRevThread.GetBaiduMapInfoCnt(sCityCode, sWd: string): Integer;
var
  //解析json
  AJson, AJson_Result: TQJson;
  sHTML: string;
  i: Integer;
  sUrl_MapInfo: string;
  FidHttp_MapInfo: TIdHTTP;
begin
  Result := 0;
  sUrl_MapInfo := 'http://api.map.baidu.com/?qt=s&c=' + sCityCode + '&wd=' + sWd + '&rn=10&ie=utf-8&oue=1&fromproduct=jsapi&res=api&callback=BMap._rd._cbk74658&' + 'ak=' + sBaiduMapAppid;
  sHTML := GetHTML(sUrl_MapInfo);
  if sHTML = '' then
    Exit;
  AJson := TQJson.Create;
  try
    AJson.Parse(sHTML);
    if AJson.AsString = '' then
      Exit;

    Result := AJson.ItemByName('result').ItemByName('aladdin_res_num').AsInteger;
  finally
    AJson.Free;
  end;
end;

function TRevThread.GetTencentMapInfoCnt(sCityCode, sWd: string): Integer;
var
  //解析json
  AJson, AJson_Result: TQJson;
  sHTML: string;
  i: Integer;
  sUrl_MapInfo: string;
  FidHttp_MapInfo: TIdHTTP;
begin
  Result := 0;
  sUrl_MapInfo := 'http://apis.map.qq.com/ws/place/v1/search?boundary=region(' + sCityCode + ',0)&page_size=20&page_index=1&keyword=' + FWd + '&orderby=_distance&key=' + sTencentMapAppid;

  sHTML := GetHTML(sUrl_MapInfo);
  if sHTML = '' then
    Exit;
  AJson := TQJson.Create;
  try
    AJson.Parse(sHTML);
    if AJson.AsString = '' then
      Exit;

    Result := AJson.ItemByName('count').AsInteger;
  finally
    AJson.Free;
  end;
end;

function TRevThread.GetGaodeMapInfoCnt(sCityCode, sWd: string): Integer;
var
  //解析json
  AJson, AJson_Result: TQJson;
  sHTML: string;
  i: Integer;
  sUrl_MapInfo: string;
begin
  Result := 0;
  sUrl_MapInfo := 'http://restapi.amap.com/v3/place/text?s=rsv3&children=&key=' + sGaodeMapAppid + '&offset=10&page=1&city=' + FCityCode + '&extensions=all&language=zh_cn&callback=jsonp_925081_&keywords=' + FWd;
  sHTML := GetHTML(sUrl_MapInfo);
  if sHTML = '' then
    Exit;
  AJson := TQJson.Create;
  try
    AJson.Parse(sHTML);
    if AJson.AsString = '' then
      Exit;

    Result := AJson.ItemByName('count').AsInteger;  // 总数
  finally
    AJson.Free;
  end;
end;

function TRevThread.GetHTTPS(Url: string): string;
var
  s_HTML: string;
  i: Integer;
  FidHttp_MapInfo: TIdHTTP;
  FidSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := '';
  try
    //https获取初始化
    FidHttp_MapInfo := TIdHTTP.Create(nil);
    FidSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    FidSSLIOHandlerSocketOpenSSL.SSLOptions.Method := sslvSSLv23;
    FidHttp_MapInfo.IOHandler := FidSSLIOHandlerSocketOpenSSL;

    s_HTML := FidHttp_MapInfo.Get(Url);
    s_HTML := UnicodeToChinese(s_HTML);
    i := Pos('(', s_HTML);
    s_HTML := Copy(s_HTML, i + 1, Length(s_HTML) - i - 1);
    Result := s_HTML;
  finally
    FidHttp_MapInfo.Free;
    FidSSLIOHandlerSocketOpenSSL.Free;
  end;
end;

function TRevThread.GetHTML(Url: string): string;
var
  s_HTML: string;
  i: Integer;
  FidHttp_MapInfo: TIdHTTP;
begin
  Result := '';
  try
    FidHttp_MapInfo := TIdHTTP.Create(nil);
    s_HTML := FidHttp_MapInfo.Get(Url);
    s_HTML := UnicodeToChinese(s_HTML);
    i := Pos('(', s_HTML);
    if frmMapInfo.FMapFlag <> 1 then
      s_HTML := Copy(s_HTML, i + 1, Length(s_HTML) - i - 1);
    Result := s_HTML;
  finally
    FidHttp_MapInfo.Free;
  end;
end;

function TRevThread.GetPhoneNum(sPhone: string): string;
var
  sStr: string;
begin
  //20180413,修复手机号码重复bug
  Result := '';
  if frmMapInfo.ChkPhone.Checked then
  begin
    Result := sPhone;
    Exit;
  end;
  if Length(sPhone) = 11 then
  begin
    Result := sPhone;
    Exit;
  end
  else if Length(sPhone) < 11 then
  begin
    Result := '';
    Exit;
  end
  else if Length(sPhone) > 11 then
  begin
    sStr := SplitString(sPhone, ';');
    if Length(sStr) = 11 then
    begin
      Result := sStr;
      Exit;
    end;

    sStr := SplitString(sPhone, ',');
    if Length(sStr) = 11 then
    begin
      Result := sStr;
      Exit;
    end;

    sStr := SplitString(sPhone, ' ');
    if Length(sStr) = 11 then
    begin
      Result := sStr;
      Exit;
    end;

  end;
end;

function TRevThread.GetUnixTime: string;
begin
  Result := IntToStr((DateTimeToUnix(Now) - 8 * 60 * 60) * 1000);
end;

function TRevThread.SetPhoneNum(sPhone: string): string;
begin
  if Trim(sPhone) = '' then
  begin
    Result := sPhone;
    Exit;
  end;
  if not (frmMapInfo.IsActivation) then
  begin
    //if frmMapInfo.ChkPhone.Checked then
    //  Result := copy(sPhone, 0, 7)
    //else
      Result := copy(sPhone, 0, 7) + '****';
  end
  else
    Result := sPhone;
end;

function TRevThread.SplitString(Source, Deli: string): string;
var
  EndOfCurrentString: byte;
  sSpiltestr: string;
begin
  Result := '';
  while Pos(Deli, Source) > 0 do
  begin
    EndOfCurrentString := Pos(Deli, Source);
    sSpiltestr := (Copy(Source, 1, EndOfCurrentString - 1));
    if Length(Trim(sSpiltestr)) = 11 then
    begin
      Result := sSpiltestr;
      Exit;
    end;
    Source := Copy(Source, EndOfCurrentString + length(Deli), length(Source) - EndOfCurrentString);
  end;
  if Length(Trim(Source)) = 11 then
  begin
    Result := Source;
  end;
end;

function TRevThread.UnicodeToChinese(inputstr: string): string;
var
  index: Integer;
  temp, top, last: string;
begin
  index := 1;
  while index >= 0 do
  begin
    index := Pos('\u', inputstr) - 1;
    if index < 0 then
    begin
      last := inputstr;
      Result := Result + last;
      Exit;
    end;
    top := Copy(inputstr, 1, index); // 取出 编码字符前的 非 unic 编码的字符，如数字
    temp := Copy(inputstr, index + 1, 6); // 取出编码，包括 \u,如\u4e3f
    Delete(temp, 1, 2);
    Delete(inputstr, 1, index + 6);
    Result := Result + top + WideChar(StrToInt('$' + temp));
  end;
end;

procedure TRevThread.UpdateListView_360;
var
  //解析json
  AJson, AJson_content, AJson_ext: TQJson;
  sHTML: string;
  i, j: Integer;
  sUrl_MapInfo: string;
  sShopName, sTel, sPhone, sPoint, sPoi_address, sCityname, sStd_tag: string;
  nNumCnt: Integer;  //360地图查询的总条数
  nPageCnt: Integer; //360地图对应一个城市的查询条数
  Qryflag: Boolean;
  sUnixTime: string;
begin
  //获取总条数
  FCityCode := HTTPEncode(UTF8Encode(FCityCode));
  nPageCnt := Get360MapInfoCnt(FCityCode, FWd);
 {
   batch=1 第一页 从1开始计数
   number=10 每页10行
   keyword=玩具
   cityname= 城市名
 }
  for j := 0 to nPageCnt do
  begin
    if not (frmMapInfo.FHttpFlag) then
      Exit;
    sUnixTime := GetUnixTime;
    sUrl_MapInfo := 'https://restapi.map.so.com/newapi?jsoncallback=jQuery18309076796343886822_' + sUnixTime + '&keyword=' + FWd + '&cityname=' + FCityCode + '&batch=' + IntToStr(j) + '&number=10&scheme=https&regionType=rectangle&sid=1000&region=&_=' + sUnixTime;
    sHTML := GetHTTPS(sUrl_MapInfo);
    if sHTML = '' then
      Break;
    AJson := TQJson.Create;
    try
      AJson.Parse(sHTML);
      if AJson.AsString = '' then
        Break;

      if AJson.ValueByName('poi', '') = '' then
        Break;
      AJson_content := AJson.ItemByName('poi');

    {
      360地图商家信息
      店铺名:poi\name
      联系电话:poi\tel
      地图坐标:poi\x + poi\x
      区域:poi\city
      地址:poi\address
      行业:poi\type
   }
      for i := 0 to AJson_content.Count - 1 do
      begin
        try
          sShopName := AJson_content[i].ItemByName('name').AsString;
          sPhone := AJson_content[i].ValueByName('tel', '');
          sPoint := AJson_content[i].ItemByName('x').AsString + AJson_content[i].ItemByName('y').AsString;
          sCityname := AJson_content[i].ItemByName('city').AsString;
          sPoi_address := AJson_content[i].ValueByName('address', '');
          sStd_tag := AJson_content[i].ValueByName('type', '');
        except
          Break;
        end;
        //处理手机号码，为空的不添加显示
        sPhone := GetPhoneNum(sPhone);
        sPhone := SetPhoneNum(sPhone);
        if Trim(sPhone) = '' then
          Continue;

        //listview增加数据
        frmMapInfo.lvMapInfo.Items.BeginUpdate;
        with frmMapInfo.lvMapInfo.items.add do
        begin
          subitems.add(IntToStr(frmMapInfo.lvMapInfo.items.Count));
          subitems.add(sShopName);
          subitems.add(sPhone);
          subitems.add(sPoint);
          subItems.add(sPoi_address);
          subItems.add(sCityname);
          subitems.add(sStd_tag);
          subitems.add(FKeyWord);
        end;
        frmMapInfo.lvMapInfo.Items.EndUpdate;
        frmMapInfo.lvMapInfo.Items.Item[frmMapInfo.lvMapInfo.Items.Count - 1].MakeVisible(false);
        frmMapInfo.lvMapInfo.SetFocus;

        frmMapInfo.edt_Cnt.Text := IntToStr(frmMapInfo.lvMapInfo.Items.Count);
        frmMapInfo.edt_Status.Text := sShopName;
        frmMapInfo.edt_Cityname.Text := sCityname;
        frmMapInfo.edt_KeyWord.Text := FKeyWord;
      end;
      Application.ProcessMessages;
    finally
      AJson.Free;
    end;
  end;
end;

procedure TRevThread.UpdateListView_Baidu;
var
  //解析json
  AJson, AJson_content: TQJson;
  sHTML: string;
  i, j: Integer;
  sUrl_MapInfo: string;
  sShopName, sTel, sPhone, sPoint, sPoi_address, sCityname, sStd_tag: string;
  nNumCnt: Integer;  //百度地图查询的总条数
  nPageCnt: Integer; //百度地图对应一个城市的查询条数
  Qryflag: Boolean;
begin
  { 百度地图商家信息
   店铺名:content\ext\detail_info\name
   联系电话:content\ext\detail_info\phone
   地图坐标:
   content\ext\detail_info\point\x
   content\ext\detail_info\point\x
   地址:content\ext\detail_info\poi_address
   区域:current_city\name
   行业:content\ext\detail_info\std_tag
  }
  //获取总条数
  {
  nNumCnt := GetBaiduMapInfoCnt(FCityCode, FWd);
  if nNumCnt < 0 then
    Exit;
  nPageCnt := 0;
  nPageCnt := nNumCnt div 10;
  if (nNumCnt mod 10) > 0 then
    nPageCnt := nPageCnt + 1;

  if nPageCnt = 0 then     //防止总条数小于10的情况
    nPageCnt := 1;
  }
  Qryflag := True;
  while Qryflag do
  begin
    if not (frmMapInfo.FHttpFlag) then
      Exit;
    sUrl_MapInfo := 'http://api.map.baidu.com/?qt=s&c=' + FCityCode + '&wd=' + FWd + '&rn=10&ie=utf-8&oue=1&fromproduct=jsapi&res=api&callback=BMap._rd._cbk74658' + '&ak=' + sBaiduMapAppid + '&pn=' + IntToStr(j);
    sHTML := GetHTML(sUrl_MapInfo);
    if sHTML = '' then
      Exit;
    AJson := TQJson.Create;
    try
      AJson.Parse(sHTML);
      if AJson.AsString = '' then
        Exit;

      sCityname := AJson.ItemByName('current_city').ValueByName('name', '');

      if AJson.ValueByName('content', '') = '' then
        Exit;

      AJson_content := AJson.ItemByName('content');
      if AJson_content.Count < 10 then
        Qryflag := False;

      for i := 0 to AJson_content.Count - 1 do
      begin
        if AJson_content[i].ValueByName('ext', '') <> '' then
        begin
          try
            sShopName := AJson_content[i].ItemByName('ext').ItemByName('detail_info').ValueByName('name', '');
            sPhone := AJson_content[i].ItemByName('ext').ItemByName('detail_info').ValueByName('phone', '');
            if AJson_content[i].ItemByName('ext').ItemByName('detail_info').ItemByName('point').ValueByName('x', '') <> '' then
              sPoint := AJson_content[i].ItemByName('ext').ItemByName('detail_info').ItemByName('point').ItemByName('x').AsString + ',' + AJson_content[i].ItemByName('ext').ItemByName('detail_info').ItemByName('point').ItemByName('y').AsString;
            sPoi_address := AJson_content[i].ItemByName('ext').ItemByName('detail_info').ValueByName('poi_address', '');
            sStd_tag := AJson_content[i].ItemByName('ext').ItemByName('detail_info').ValueByName('std_tag', '');
          except
            Break;
          end;
          //处理手机号码，为空的不添加显示
          sPhone := GetPhoneNum(sPhone);
          sPhone := SetPhoneNum(sPhone);
          if Trim(sPhone) = '' then
            Continue;

          //listview增加数据
          frmMapInfo.lvMapInfo.Items.BeginUpdate;
          with frmMapInfo.lvMapInfo.items.add do
          begin
            subitems.add(IntToStr(frmMapInfo.lvMapInfo.items.Count));
            subitems.add(sShopName);
            subitems.add(sPhone);
            subitems.add(sPoint);
            subItems.add(sPoi_address);
            subItems.add(sCityname);
            subitems.add(sStd_tag);
            subitems.add(FKeyWord);
          end;
          frmMapInfo.lvMapInfo.Items.EndUpdate;
          //定位到最后一条数据
          frmMapInfo.lvMapInfo.Items.Item[frmMapInfo.lvMapInfo.Items.Count - 1].MakeVisible(false);
          frmMapInfo.lvMapInfo.SetFocus;

          frmMapInfo.edt_Cnt.Text := IntToStr(frmMapInfo.lvMapInfo.Items.Count);
          frmMapInfo.edt_Status.Text := sShopName;
          frmMapInfo.edt_Cityname.Text := sCityname;
          frmMapInfo.edt_KeyWord.Text := FKeyWord;
        end;
      end;
      Application.ProcessMessages;
    finally
      AJson.Free;
    end;
    j := j + 1;
    //frmMapInfo.Memo1.Lines.Add(sUrl_MapInfo);
  end;
end;

procedure TRevThread.UpdateListView_GaoDe;
var
  //解析json
  AJson, AJson_content, AJson_ext: TQJson;
  sHTML: string;
  i, j: Integer;
  sUrl_MapInfo: string;
  sShopName, sTel, sPhone, sPoint, sPoi_address, sCityname, sStd_tag: string;
  nNumCnt: Integer;  //高德地图查询的总条数
  nPageCnt: Integer; //高德地图对应一个城市的查询条数
  Qryflag: Boolean;
begin
{
  //获取总条数
  nNumCnt := GetGaodeMapInfoCnt(FCityCode, FWd);
  if nNumCnt < 0 then
    Exit;

  nPageCnt := nNumCnt div 10;
  if nPageCnt = 0 then     //防止总条数小于10的情况
    nPageCnt := 1;  }
 {
   page=1 第一页 从1开始计数
   offset=10 每页10行
   keywords=玩具
   key=97e813f8def77584512baea65fcd2c46  --这个key有效
   city=110100 城市代码
 }
  Qryflag := True;
  j := 1;
  while Qryflag do
  begin
    if not (frmMapInfo.FHttpFlag) then
      Exit;
    sUrl_MapInfo := 'http://restapi.amap.com/v3/place/text?s=rsv3&children=&key=' + sGaodeMapAppid + '&offset=10&page=' + IntToStr(j) + '&city=' + FCityCode + '&extensions=all&language=zh_cn&callback=jsonp_925081_&keywords=' + FWd;
    sHTML := GetHTML(sUrl_MapInfo);
    if sHTML = '' then
      break;
    AJson := TQJson.Create;
    try
      AJson.Parse(sHTML);
      if AJson.AsString = '' then
        break;

      if AJson.ValueByName('pois', '') = '' then
        break;
      AJson_content := AJson.ItemByName('pois');
      if AJson_content.Count < 10 then
        Qryflag := False;
    {
      高德地图商家信息
      店铺名:pois\name
      联系电话:pois\tel
      地图坐标:pois\location
      区域:pois\cityname
      地址:pois\adname +  pois\address
      行业:pois\type
   }
      for i := 0 to AJson_content.Count - 1 do
      begin
        try
          sShopName := AJson_content[i].ItemByName('name').AsString;
          sPhone := AJson_content[i].ValueByName('tel', '');
          sPoint := AJson_content[i].ItemByName('location').AsString;
          sCityname := AJson_content[i].ItemByName('cityname').AsString;
          sPoi_address := AJson_content[i].ValueByName('adname', '') + AJson_content[i].ValueByName('address', '');
          sStd_tag := AJson_content[i].ValueByName('type', '');
        except
          Break;
        end;
                //处理手机号码，为空的不添加显示
        if Trim(sPhone) = '[]' then
          Continue;
        sPhone := GetPhoneNum(sPhone);
        sPhone := SetPhoneNum(sPhone);
        if Trim(sPhone) = '' then
          Continue;

        //listview增加数据
        frmMapInfo.lvMapInfo.Items.BeginUpdate;
        with frmMapInfo.lvMapInfo.items.add do
        begin
          subitems.add(IntToStr(frmMapInfo.lvMapInfo.items.Count));
          subitems.add(sShopName);
          subitems.add(sPhone);
          subitems.add(sPoint);
          subItems.add(sPoi_address);
          subItems.add(sCityname);
          subitems.add(sStd_tag);
          subitems.add(FKeyWord);
        end;
        frmMapInfo.lvMapInfo.Items.EndUpdate;
        //定位到最后一条数据
        frmMapInfo.lvMapInfo.Items.Item[frmMapInfo.lvMapInfo.Items.Count - 1].MakeVisible(false);
        frmMapInfo.lvMapInfo.SetFocus;

        frmMapInfo.edt_Cnt.Text := IntToStr(frmMapInfo.lvMapInfo.Items.Count);
        frmMapInfo.edt_Status.Text := sShopName;
        frmMapInfo.edt_Cityname.Text := sCityname;
        frmMapInfo.edt_KeyWord.Text := FKeyWord;
      end;
      Application.ProcessMessages;
    finally
      AJson.Free;
    end;
    j := j + 1;
    //frmMapInfo.Memo1.Lines.Add(sUrl_MapInfo);
  end;
end;

procedure TRevThread.UpdateListView_Tencent;
var
  //解析json
  AJson, AJson_content, AJson_ext: TQJson;
  sHTML: string;
  i, j: Integer;
  sUrl_MapInfo: string;
  sShopName, sTel, sPhone, sPoint, sPoi_address, sCityname, sStd_tag: string;
  nNumCnt: Integer;  //腾讯地图查询的总条数
  nPageCnt: Integer; //腾讯地图对应一个城市的查询条数
  Qryflag: Boolean;
  sUnixTime: string;
  nStatus: Integer;
  sCityCode: string;
begin
  //获取总条数
  sCityCode := HTTPEncode(UTF8Encode(FCityCode));
  nNumCnt := GetTencentMapInfoCnt(sCityCode, FWd);
 {
   boundary=region(北京,0)  搜索范围
   page_size=10 每页10行
   page_index =1 第几页
   keyword=玩具
   key= 开发者秘钥
   //API 参考网址： http://lbs.qq.com/webservice_v1/guide-search.html
 }
  Qryflag := True;
  j := 1;
  while Qryflag do
  begin
    if not (frmMapInfo.FHttpFlag) then
      Exit;
    sUnixTime := GetUnixTime;
    sUrl_MapInfo := 'http://apis.map.qq.com/ws/place/v1/search?boundary=region(' + sCityCode + ',0)&page_size=20&page_index=' + IntToStr(j) + '&keyword=' + FWd + '&orderby=_distance&key=' + sTencentMapAppid;
    sHTML := GetHTML(sUrl_MapInfo);
    if sHTML = '' then
      Exit;
    AJson := TQJson.Create;
    try
      AJson.Parse(sHTML);
      if AJson.AsString = '' then
        Exit;

      nStatus := AJson.ItemByName('status').AsInteger;
  //    if nStatus <> 0 then
  //       Exit;
      if AJson.ValueByName('data', '') = '' then
        Exit;
      AJson_content := AJson.ItemByName('data');
      if AJson_content.Count < 20 then
        Qryflag := False;
      if (nNumCnt < j*20) then
        Exit;
    {
      腾讯地图商家信息
      店铺名:data\title
      联系电话:data\tel
      地图坐标:data\location\lat + data\location\lng
      区域:data\ad_info\city
      地址:data\address
      行业:data\category
   }
      for i := 0 to AJson_content.Count - 1 do
      begin
        try
          sShopName := AJson_content[i].ValueByName('title', '');
          sPhone := AJson_content[i].ValueByName('tel', '');
          sPoint := AJson_content[i].ItemByName('location').ValueByName('lat', '') + ',' + AJson_content[i].ItemByName('location').ValueByName('lng', '');
          sCityname := AJson_content[i].ItemByName('ad_info').ValueByName('city', '');
          sPoi_address := AJson_content[i].ValueByName('address', '');
          sStd_tag := AJson_content[i].ValueByName('category', '');
        except
          Break;
        end;
        //处理手机号码，为空的不增加显示
        sPhone := GetPhoneNum(sPhone);
        sPhone := SetPhoneNum(sPhone);
        if Trim(sPhone) = '' then
          Continue;

        //listview增加数据
        frmMapInfo.lvMapInfo.Items.BeginUpdate;
        with frmMapInfo.lvMapInfo.items.add do
        begin
          subitems.add(IntToStr(frmMapInfo.lvMapInfo.items.Count));
          subitems.add(sShopName);
          subitems.add(sPhone);
          subitems.add(sPoint);
          subItems.add(sPoi_address);
          subItems.add(sCityname);
          subitems.add(sStd_tag);
          subitems.add(FKeyWord);
        end;
        frmMapInfo.lvMapInfo.Items.EndUpdate;
        //定位到最后一条数据
        frmMapInfo.lvMapInfo.Items.Item[frmMapInfo.lvMapInfo.Items.Count - 1].MakeVisible(false);
        frmMapInfo.lvMapInfo.SetFocus;

        frmMapInfo.edt_Cnt.Text := IntToStr(frmMapInfo.lvMapInfo.Items.Count);
        frmMapInfo.edt_Status.Text := sShopName;
        frmMapInfo.edt_Cityname.Text := sCityname;
        frmMapInfo.edt_KeyWord.Text := FKeyWord;
      end;
      Application.ProcessMessages;
    finally
      AJson.Free;
      //LockWindowUpdate(0);
    end;
    j := j + 1;
    //frmMapInfo.Memo1.Lines.Add(sUrl_MapInfo);
  end;
end;

end.

