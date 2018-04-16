object frmRegister: TfrmRegister
  Left = 439
  Top = 219
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #36719#20214#27880#20876
  ClientHeight = 312
  ClientWidth = 529
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 529
    Height = 312
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #36719#20214#27880#20876#26041#27861
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 521
        Height = 284
        Align = alClient
        Color = 15982294
        ParentBackground = False
        TabOrder = 0
        object Label2: TLabel
          Left = 21
          Top = 71
          Width = 83
          Height = 23
          Caption = #32852#31995'QQ : '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label4: TLabel
          Left = 21
          Top = 9
          Width = 475
          Height = 59
          AutoSize = False
          Caption = 
            '    '#26412#36719#20214#20165#20026#24037#20316#25552#20379#19968#23450#30340#20415#21033#24615#65292#31105#27490#20351#29992#26412#36719#20214#20174#20107#36829#27861#36829#35268#34892#20026#65292#21542#21017#21518#26524#33258#36127#65281#26410#27880#20876#29256#19981#33021#20351#29992#37096#20998#21151#33021#65292#22914#38656#20351#29992#23436#25972#29256#65292 +
            #35831#36141#20080#27491#24335#29256#12290#36141#20080#35831#32852#31995#23458#26381#33719#21462#24207#21015#21495#12290
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clTeal
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object Label5: TLabel
          Left = 21
          Top = 110
          Width = 83
          Height = 23
          Caption = 'QQ'#37038#31665' : '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lbl_qq: TLabel
          Left = 110
          Top = 71
          Width = 90
          Height = 23
          Caption = '201999133'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lbl_email: TLabel
          Left = 110
          Top = 110
          Width = 170
          Height = 23
          Caption = '201999133@qq.com'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -19
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Panel1: TPanel
          Left = 11
          Top = 163
          Width = 493
          Height = 23
          ParentCustomHint = False
          Caption = #36719#20214#27880#20876
          Ctl3D = True
          DoubleBuffered = False
          ParentBackground = False
          ParentColor = True
          ParentCtl3D = False
          ParentDoubleBuffered = False
          ParentShowHint = False
          ShowHint = False
          TabOrder = 0
        end
        object Panel2: TPanel
          Left = 11
          Top = 185
          Width = 493
          Height = 88
          Color = 15982294
          ParentBackground = False
          TabOrder = 1
          object Label1: TLabel
            Left = 11
            Top = 19
            Width = 36
            Height = 13
            Caption = #26426#22120#30721
          end
          object Label3: TLabel
            Left = 11
            Top = 52
            Width = 36
            Height = 13
            Caption = #24207#21015#21495
          end
          object edt_Regcode: TEdit
            Left = 53
            Top = 15
            Width = 324
            Height = 21
            ReadOnly = True
            TabOrder = 0
          end
          object edt_ActiCode: TEdit
            Left = 53
            Top = 48
            Width = 324
            Height = 21
            TabOrder = 1
          end
          object btnCopyRegCode: TButton
            Left = 383
            Top = 13
            Width = 85
            Height = 25
            Caption = #22797#21046#26426#22120#30721
            TabOrder = 2
            OnClick = btnCopyRegCodeClick
          end
          object btn_Acit: TButton
            Left = 383
            Top = 44
            Width = 85
            Height = 25
            Caption = #27880#20876#36719#20214
            TabOrder = 3
            OnClick = btn_AcitClick
          end
        end
        object btnCopyQQ: TButton
          Left = 349
          Top = 74
          Width = 75
          Height = 25
          Caption = #22797#21046'QQ'
          TabOrder = 2
          OnClick = btnCopyQQClick
        end
        object btnCopyEmail: TButton
          Left = 349
          Top = 108
          Width = 75
          Height = 25
          Caption = #22797#21046#37038#31665
          TabOrder = 3
          OnClick = btnCopyEmailClick
        end
      end
    end
  end
  object InMessageClient: TInMessageClient
    Connection = InConnection
    OnReturnResult = InMessageClientReturnResult
    Left = 160
    Top = 136
  end
  object InCertifyClient: TInCertifyClient
    Connection = InConnection
    Left = 160
    Top = 80
  end
  object InConnection: TInConnection
    MessageClient = InMessageClient
    ServerAddr = '47.106.94.188'
    AfterConnect = InConnectionAfterConnect
    Left = 272
    Top = 80
  end
end
