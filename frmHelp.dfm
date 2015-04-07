object HelpForm: THelpForm
  Left = 0
  Top = 0
  Caption = 'HelpForm'
  ClientHeight = 488
  ClientWidth = 345
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    345
    488)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 345
    Height = 451
    ActivePage = TabSheet1
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'About'
    end
    object TabSheet2: TTabSheet
      Caption = 'Opis'
      ImageIndex = 2
    end
    object TabSheet3: TTabSheet
      Caption = 'Keys'
      ImageIndex = 1
      object ListView1: TListView
        Left = 0
        Top = 0
        Width = 337
        Height = 423
        Align = alClient
        Columns = <
          item
            Caption = 'Keys'
          end
          item
            Caption = 'Action'
            Width = 200
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
  end
  object Button1: TButton
    Left = 265
    Top = 457
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
