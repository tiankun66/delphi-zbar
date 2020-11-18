object FormZBar: TFormZBar
  Left = 0
  Top = 0
  Caption = 'FormZBar'
  ClientHeight = 483
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 23
  object moLog: TMemo
    Left = 0
    Top = 253
    Width = 505
    Height = 230
    Align = alClient
    Lines.Strings = (
      'moLog')
    TabOrder = 0
    ExplicitLeft = 52
    ExplicitTop = 48
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 505
    Height = 253
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 19
      Width = 38
      Height = 23
      Caption = #21629#20196
    end
    object cbComm: TComboBox
      Left = 52
      Top = 16
      Width = 216
      Height = 31
      ItemHeight = 23
      TabOrder = 0
      Text = 'cbComm'
      Items.Strings = (
        '--help'
        '--version'
        '--quiet'
        '--verbose'
        '--verbose='
        '--display'
        '--nodisplay'
        '--set'
        '--xml'
        '--noxml'
        '--raw'
        'S'
        'h'
        'q'
        'v'
        'd')
    end
    object btnAdd: TButton
      Left = 280
      Top = 22
      Width = 75
      Height = 25
      Caption = #26032#22686
      TabOrder = 1
      OnClick = btnAddClick
    end
    object boxComm: TListBox
      Left = 52
      Top = 60
      Width = 216
      Height = 173
      ItemHeight = 23
      TabOrder = 2
    end
    object btnRun: TButton
      Left = 280
      Top = 164
      Width = 75
      Height = 69
      Caption = #22519#34892
      TabOrder = 3
      OnClick = btnRunClick
    end
    object Button2: TButton
      Left = 280
      Top = 60
      Width = 75
      Height = 25
      Caption = #28165#38500
      TabOrder = 4
      OnClick = Button2Click
    end
  end
  object tmrBegin: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrBeginTimer
    Left = 448
    Top = 24
  end
  object tmrRun: TTimer
    Enabled = False
    OnTimer = tmrRunTimer
    Left = 440
    Top = 144
  end
end
