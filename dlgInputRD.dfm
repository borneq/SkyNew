object InputRD: TInputRD
  Left = 0
  Top = 0
  Caption = 'InputRD'
  ClientHeight = 275
  ClientWidth = 284
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 48
    Top = 56
    Width = 95
    Height = 13
    Caption = 'Podaj rektascensj'#281':'
  end
  object Label2: TLabel
    Left = 48
    Top = 88
    Width = 87
    Height = 13
    Caption = 'Podaj deklinacje  :'
  end
  object Label3: TLabel
    Left = 48
    Top = 168
    Width = 40
    Height = 13
    Caption = 'Azymut:'
  end
  object Label4: TLabel
    Left = 48
    Top = 200
    Width = 58
    Height = 13
    Caption = 'Wysoko'#347#263'  :'
  end
  object Edit1: TEdit
    Left = 152
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'Edit1'
  end
  object Edit2: TEdit
    Left = 152
    Top = 85
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 120
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Calculate'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Edit3: TEdit
    Left = 152
    Top = 165
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'Edit1'
  end
  object Edit4: TEdit
    Left = 152
    Top = 197
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'Edit1'
  end
  object Button2: TButton
    Left = 198
    Top = 242
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 5
  end
end
