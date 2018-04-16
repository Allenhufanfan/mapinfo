unit uRegister;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Clipbrd, iocp_clients, iocp_base, qjson;

type
  TfrmRegister = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    edt_Regcode: TEdit;
    edt_ActiCode: TEdit;
    btnCopyRegCode: TButton;
    btn_Acit: TButton;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    btnCopyQQ: TButton;
    btnCopyEmail: TButton;
    Panel3: TPanel;
    lbl_qq: TLabel;
    lbl_email: TLabel;
    InMessageClient: TInMessageClient;
    InCertifyClient: TInCertifyClient;
    InConnection: TInConnection;
    procedure btn_AcitClick(Sender: TObject);
    procedure btnCopyEmailClick(Sender: TObject);
    procedure btnCopyQQClick(Sender: TObject);
    procedure btnCopyRegCodeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InConnectionAfterConnect(Sender: TObject);
    procedure InMessageClientReturnResult(Sender: TObject; Result: TResultParams);
    procedure SetUI(sReg_code, sActi_code: string);
    //function ChkReginfo():Boolean;
  private
    { Private declarations }
    FAddflag: Boolean;
  public
    { Public declarations }
    procedure GetIndentify();
    procedure Showmsg();
  end;
var
  frmRegister: TfrmRegister;

implementation

{$R *.dfm}

uses
  uMapInfo;

procedure TfrmRegister.btn_AcitClick(Sender: TObject);
var
  bResult: Boolean;
begin
   //激活软件
  FAddflag := True;
  GetIndentify;
end;

procedure TfrmRegister.btnCopyEmailClick(Sender: TObject);
begin
  Clipboard.SetTextBuf(PChar(lbl_email.Caption));
  Showmsg;
end;

procedure TfrmRegister.btnCopyQQClick(Sender: TObject);
begin
  Clipboard.SetTextBuf(PChar(lbl_email.Caption));
  Showmsg;
end;

procedure TfrmRegister.btnCopyRegCodeClick(Sender: TObject);
begin
  Clipboard.SetTextBuf(PChar(edt_Regcode.Text));
  Showmsg;
end;

procedure TfrmRegister.FormShow(Sender: TObject);
begin
  //InConnection.Active := True;
end;

procedure TfrmRegister.GetIndentify;
var
  AJson: TQJson;
begin
  AJson := TQJson.Create;
  AJson.Add('funcid').AsString := '10000';
  AJson.Add('reg_code').AsString := edt_Regcode.Text;
  AJson.Add('acti_code').AsString := edt_ActiCode.Text;
  InMessageClient.SendMsg(AJson.AsString, 10000);
end;

procedure TfrmRegister.InConnectionAfterConnect(Sender: TObject);
begin
  //登录
  InCertifyClient.UserName := '123';
  InCertifyClient.Password := '456';
  InCertifyClient.Login;
end;

procedure TfrmRegister.InMessageClientReturnResult(Sender: TObject; Result: TResultParams);
var
  sActi_code: string;
  AJson_result: TQJson;
  bInsertResult: Boolean;
begin
  AJson_result := TQJson.Create;
  try
    case Result.ActResult of
      arOK:
        begin
          AJson_result.Parse(Result.AsString['result']);
          if AJson_result.ItemByName('errorcode').AsInteger = 0 then
          begin
            //验证成功，写入
            bInsertResult := frmMapInfo.FSqliteDataModule.SetSqlReginfo(edt_Regcode.Text, edt_ActiCode.Text);
            if bInsertResult then
            begin
              Application.MessageBox('注册成功', '提示', MB_OK + MB_ICONINFORMATION);
              edt_ActiCode.Enabled := False;
            end
            else
              Application.MessageBox('注册失败[-100]，请联系客服', '错误', MB_OK + MB_ICONSTOP);
          end
          else
            Application.MessageBox('序列号错误,注册失败[-200]，请联系客服', '错误', MB_OK + MB_ICONSTOP);
        end;
      arFail:
        ShowMessage(Result.AsString['error']);
        //Application.MessageBox('注册失败[-300]，请联系客服', '错误', MB_OK + MB_ICONSTOP);
    end;
  finally
    AJson_result.Free;
  end;
end;

procedure TfrmRegister.SetUI(sReg_code, sActi_code: string);
begin
  edt_Regcode.Text := sReg_code;
  edt_ActiCode.Text := sActi_code;
  if edt_ActiCode.Text = '' then
  begin
    edt_ActiCode.Enabled := True;
    Panel1.Caption := '软件注册-未注册';
    InConnection.Active := True;
  end
  else
  begin
    edt_ActiCode.Enabled :=False;
    btn_Acit.Enabled := False;
    Panel1.Caption := '软件注册-已注册';
  end;
  Panel1.Font.Color := clRed;
end;

procedure TfrmRegister.Showmsg;
begin
   MessageBox(Handle, '已复制到剪切板！', '提示', MB_OK + MB_ICONINFORMATION);
end;

end.

