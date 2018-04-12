object frmSetCity: TfrmSetCity
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #28155#21152#22478#24066#21517#31216
  ClientHeight = 358
  ClientWidth = 246
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object TreeList_city: TcxTreeList
    Left = 0
    Top = 0
    Width = 246
    Height = 310
    Align = alTop
    Bands = <
      item
      end>
    Navigator.Buttons.CustomButtons = <>
    TabOrder = 0
    object cxTreeList1Column1: TcxTreeListColumn
      Caption.AlignHorz = taCenter
      Caption.Text = #22478#24066#21015#34920
      DataBinding.ValueType = 'String'
      Options.Editing = False
      Width = 205
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object btn_Sure: TButton
    Left = 25
    Top = 316
    Width = 75
    Height = 25
    Caption = #30830#35748
    TabOrder = 1
    OnClick = btn_SureClick
  end
  object btn_Close: TButton
    Left = 140
    Top = 315
    Width = 75
    Height = 25
    Caption = #21462#28040
    TabOrder = 2
    OnClick = btn_CloseClick
  end
end
