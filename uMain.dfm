object FrmInfo: TFrmInfo
  Left = 0
  Top = 0
  Caption = 'UBX'
  ClientHeight = 303
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object RaizePageControl: TRzPageControl
    Left = 1
    Top = 2
    Width = 392
    Height = 301
    ActivePage = TabSheet1
    TabIndex = 0
    TabOrder = 0
    FixedDimension = 19
    object TabSheet1: TRzTabSheet
      Caption = 'INFO'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object mmo1: TMemo
        Left = 3
        Top = 3
        Width = 406
        Height = 54
        Lines.Strings = (
          'mmo1')
        TabOrder = 0
      end
    end
    object rztbshtTabSheet2: TRzTabSheet
      Caption = 'BOT'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object shpWhite: TShape
        Left = 0
        Top = 0
        Width = 293
        Height = 20
      end
      object lbl1: TLabel
        Left = 8
        Top = 2
        Width = 17
        Height = 13
        AutoSize = False
        Color = clWhite
        ParentColor = False
      end
      object lbl2: TLabel
        Left = 40
        Top = 2
        Width = 17
        Height = 13
        AutoSize = False
        Color = clWhite
        ParentColor = False
      end
      object lbl3: TLabel
        Left = 88
        Top = 2
        Width = 17
        Height = 13
        AutoSize = False
        Color = clWhite
        ParentColor = False
      end
      object lbl4: TLabel
        Left = 120
        Top = 2
        Width = 17
        Height = 13
        AutoSize = False
        Color = clWhite
        ParentColor = False
      end
      object lbl5: TLabel
        Left = 152
        Top = 2
        Width = 17
        Height = 13
        AutoSize = False
        Color = clWhite
        ParentColor = False
      end
      object lbl6: TLabel
        Left = 200
        Top = 2
        Width = 17
        Height = 13
        AutoSize = False
        Color = clWhite
        ParentColor = False
      end
      object lbl7: TLabel
        Left = 256
        Top = 2
        Width = 17
        Height = 13
        AutoSize = False
        Color = clWhite
        ParentColor = False
      end
      object h1img: TImage
        Left = 16
        Top = 2
        Width = 15
        Height = 13
      end
      object h2img: TImage
        Left = 48
        Top = 2
        Width = 15
        Height = 13
      end
      object f1img: TImage
        Left = 96
        Top = 2
        Width = 15
        Height = 13
      end
      object f2img: TImage
        Left = 128
        Top = 2
        Width = 15
        Height = 13
      end
      object f3img: TImage
        Left = 160
        Top = 2
        Width = 15
        Height = 13
      end
      object timg: TImage
        Left = 208
        Top = 2
        Width = 15
        Height = 13
      end
      object rimg: TImage
        Left = 264
        Top = 2
        Width = 15
        Height = 13
      end
      object btnBtnAttach: TButton
        Left = 297
        Top = 0
        Width = 44
        Height = 21
        Caption = 'Attach'
        TabOrder = 0
        OnClick = btnBtnAttachClick
      end
      object AutoCheck: TCheckBox
        Left = 344
        Top = 3
        Width = 42
        Height = 17
        Caption = 'Auto'
        TabOrder = 1
      end
    end
  end
end
