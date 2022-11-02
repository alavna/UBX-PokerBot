Unit uMain;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uGameClasses, StrUtils,
  JclStrings, uHashTables, CodeSiteLogging, uNewTypes, RzTabs;

Type
  TFrmInfo = Class(TForm)
    RaizePageControl: TRzPageControl;
    TabSheet1: TRzTabSheet;
    rztbshtTabSheet2: TRzTabSheet;
    shpWhite: TShape;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    h1img: TImage;
    h2img: TImage;
    f1img: TImage;
    f2img: TImage;
    f3img: TImage;
    timg: TImage;
    rimg: TImage;
    btnBtnAttach: TButton;
    AutoCheck: TCheckBox;
    mmo1: TMemo;
    Procedure btnBtnAttachClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
    Procedure btn3Click(Sender: TObject);
    Procedure btnrecognizeClick(Sender: TObject);
    Procedure btn1Click(Sender: TObject);
    Procedure btn2Click(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }

  End;
Var
  FrmInfo: TFrmInfo;

Implementation
Uses
  uBrain, uGlobalVariables, uGlobalConstants, uMiscFunctions, uTableInfo;

{$R *.dfm}
{$R IMAGES.res}
{$R CARDS.res}
{$R CARDSB.res}
{$R NAMES.res}
{$R POTDIGITS.res}
{$R COMMANDBUTTONDIGITS.res}
{$R COMMANDS.res}

Procedure TFrmInfo.btn1Click(Sender: TObject);
Var
  A, B: Integer;
Begin
  mmo1.Lines.Add(IntToStr(RGB(8, 8, 8)));
  //  For A := 0 To img1.Picture.Bitmap.Width - 1 Do
  //    For B := 0 To img1.Picture.Bitmap.Height - 1 Do
  //    Begin
  //      If (GetRValue(img1.Picture.Bitmap.Canvas.Pixels[A, B]) < 60) And (GetBValue(img1.Picture.Bitmap.Canvas.Pixels[A, B]) < 60)
  //        And (GetGValue(img1.Picture.Bitmap.Canvas.Pixels[A, B]) < 60) Then
  //        img1.Picture.Bitmap.Canvas.Pixels[A, B] := RGB(0, 0, 0)
  //      Else
  //        img1.Picture.Bitmap.Canvas.Pixels[A, B] := RGB(255, 255, 255);
  //    End;
  //  Randomize;
  //  A := Random(50000);
  //  img1.Picture.Bitmap.SaveToFile('C:\Users\alavna\Desktop\ubpictures\' + IntToStr(A) + '.bmp');
End;

Procedure TFrmInfo.btn2Click(Sender: TObject);
Var
  X, Y, I: Integer;
  ae: Array Of Int64;
  S: String;
  dc: HDC;
  pot: Double;
  sw: TStopWatch;
  elapsedMiliseconds: cardinal;
Begin
  Game.Handle := $00110BFA;
  sw := TStopWatch.Create();

  For I := 0 To 8 Do
  Begin
    sw.Start;
    pot := GetPlayerBankroll(I);
    sw.Stop;
    elapsedMiliseconds := sw.ElapsedMiliseconds;
    CodeSite.Send(IntToStr(elapsedMiliseconds));
    mmo1.Lines.Add('Bankroll: ' + FloatToStr(pot));
  End;

  sw.Start;
  pot := GetThePot(PreFlop, False);
  sw.Stop;
  mmo1.Lines.Add('The Pot: ' + FloatToStr(pot));

  elapsedMiliseconds := sw.ElapsedMiliseconds;
  CodeSite.Send(IntToStr(elapsedMiliseconds));
  //  I := 0;
  //  SetLength(ae, 0);
  //  For X := 0 To 8 Do
  //  Begin
  //    For Y := 0 To 792 Do
  //    Begin
  //      If PocketGroups[X, Y] > 0 Then
  //      Begin
  //        Inc(I);
  //        SetLength(ae, I);
  //        ae[I - 1] := PocketGroups[X, Y];
  //      End;
  //    End;
  //  End;
  //  X := Length(ae);
  //  S := '';
  //  For I := 0 To X - 1 Do
  //    S := S + IntToStr(ae[I]) + ',' + slinebreak;
  //  mmo1.Lines.Add(S);
  //  FrmInfo.Caption:=IntToStr(x);
End;

Procedure TFrmInfo.btn3Click(Sender: TObject);
Var
  I, Y, X: Integer;
Begin
  //  For X := 0 To 97 Do
  //    For Y := 0 To 23 Do
  //    Begin
  //      If (TColor32Entry(img1.Bitmap.Pixel[X, Y]).R > 100) And (TColor32Entry(img1.Bitmap.Pixel[X, Y]).B > 100)
  //        And
  //        (TColor32Entry(img1.Bitmap.Pixel[X, Y]).G > 100) Then
  //      Begin
  //        img1.Bitmap.SetPixelTS(X, Y, Color32(RGB(255, 255, 255)));
  //      End
  //      Else
  //      Begin
  //        img1.Bitmap.SetPixelTS(X, Y, Color32(RGB(0, 0, 0)));
  //      End;
  //    End;
  //  img1.Bitmap := img1.Bitmap;
End;

Procedure TFrmInfo.btnrecognizeClick(Sender: TObject);
Var
  Themap: TBitmap;
  LetterNo, Column, X, F, I, Diff, Row, StartingColumn, Look: Integer;
  S: String;
Begin
  //  Themap := TBitmap32.Create;
  //  Themap := img1.Bitmap;
  //  S := '';
  //  StartingColumn := 0;
  //  While StartingColumn < 97 Do
  //  Begin
  //    For LetterNo := 0 To 39 Do
  //    Begin
  //      Diff := 0;
  //      Look := 0;
  //      For Column := 0 To BMSTOREDLETTERS[LetterNo].Width - 1 Do
  //        For Row := 0 To 9 Do
  //        Begin
  //          If BMSTOREDLETTERS[LetterNo].Pixel[Column, Row] <> Themap.Pixel[Column + StartingColumn, Row] Then
  //            DIFF := DIFF + 1
  //          Else
  //            LOOk := LOOK + 1;
  //        End;
  //      If Diff = 0 Then
  //      Begin
  //        StartingColumn := StartingColumn + BMSTOREDLETTERS[LetterNo].Width - 1;
  //        S := S + NameStrings[LetterNo];
  //      End;
  //    End;
  //    Inc(StartingColumn);
  //  End;
  //  mmo1.Lines.Add(S);
  //  Themap := Nil;
  ////  Themap.Free;
End;

Function IsUniqueToAll(X, Y: Integer): Boolean;
Var
  I: Integer;
  TheArr, TheArr1: Array Of Integer;
Begin
  Result := True;
  SetLength(TheArr, 40);
  SetLength(TheArr1, 40);
  For I := 0 To 39 Do
  Begin
    TheArr[I] := BMSTOREDLETTERSARRAY[I, X, Y];
  End;
  QuickSort(TheArr, Low(TheArr), High(TheArr));
  For I := 1 To 39 Do
    If (TheArr[I] = TheArr[I - 1]) Then
    Begin
      Result := False;
      Break;
    End;
End;

Procedure CreateBitmaps;
Var
  I, X, Y, J, TheSame, TheDiff, Unique: Integer;
  PointsArray: Array Of TPoint;
Begin
  For I := 0 To 12 Do
  Begin
    BMPOTDIGITS[I] := TBitmap.Create;
    BMPOTDIGITS[I].LoadFromResourceName(hinstance, PotRes[I]);
    SetLength(BMPOTDIGITSARRAY[I], BMPOTDIGITS[I].Width);
    For J := 0 To BMPOTDIGITS[I].Width - 1 Do
      SetLength(BMPOTDIGITSARRAY[I, J], BMPOTDIGITS[I].Height);
    For X := 0 To BMPOTDIGITS[I].Width - 1 Do
      For Y := 0 To BMPOTDIGITS[I].Height - 1 Do
        BMPOTDIGITSARRAY[I, X, Y] := BMPOTDIGITS[I].Canvas.Pixels[X, Y];
  End;

  For I := 0 To 51 Do
  Begin
    BMSTOREDHOLE[I] := TBitmap.Create;
    BMSTOREDHOLE[I].LoadFromResourceName(hinstance, AnsiUpperCase(CardTable[I]));
    BMSTOREDBOARD[I] := TBitmap.Create;
    BMSTOREDBOARD[I].LoadFromResourceName(hinstance, AnsiUpperCase(CardTable[I]) + 'B');
  End;
  For I := 0 To 39 Do
  Begin
    BMSTOREDLETTERS[I] := TBitmap.Create;
    BMSTOREDLETTERS[I].LoadFromResourceName(hinstance, AnsiUpperCase(NameRes[I]));
    For X := 0 To BMSTOREDLETTERS[I].Width - 1 Do
      For Y := 0 To 9 Do
      Begin
        If (GetRValue(BMSTOREDLETTERS[I].Canvas.Pixels[X, Y]) > 100) And (GetBValue(BMSTOREDLETTERS[I].Canvas.Pixels[X, Y]) > 100)
          And
          (GetGValue(BMSTOREDLETTERS[I].Canvas.Pixels[X, Y]) > 100) Then
          BMSTOREDLETTERS[I].Canvas.Pixels[X, Y] := RGB(255, 255, 255)
        Else
          BMSTOREDLETTERS[I].Canvas.Pixels[X, Y] := RGB(0, 0, 0);
      End;

    SetLength(BMSTOREDLETTERSARRAY[I], BMSTOREDLETTERS[I].Width);
    For J := 0 To BMSTOREDLETTERS[I].Width - 1 Do
      SetLength(BMSTOREDLETTERSARRAY[I, J], BMSTOREDLETTERS[I].Height);
    For X := 0 To BMSTOREDLETTERS[I].Width - 1 Do
      For Y := 0 To BMSTOREDLETTERS[I].Height - 1 Do
        BMSTOREDLETTERSARRAY[I, X, Y] := BMSTOREDLETTERS[I].Canvas.Pixels[X, Y];
  End;
  For I := 0 To 13 Do
  Begin
    BMSTOREDDIGITS[I] := TBitmap.Create;
    BMSTOREDDIGITS[I].LoadFromResourceName(hinstance, AnsiUpperCase(DigitRes[I]));
    For X := 0 To BMSTOREDDIGITS[I].Width - 1 Do
      For Y := 0 To 9 Do
      Begin
        If (GetRValue(BMSTOREDDIGITS[I].Canvas.Pixels[X, Y]) > 100) And (GetBValue(BMSTOREDDIGITS[I].Canvas.Pixels[X, Y]) > 100)
          And
          (GetGValue(BMSTOREDDIGITS[I].Canvas.Pixels[X, Y]) > 100) Then
          BMSTOREDDIGITS[I].Canvas.Pixels[X, Y] := RGB(255, 255, 255)
        Else
          BMSTOREDDIGITS[I].Canvas.Pixels[X, Y] := RGB(0, 0, 0);
      End;

    SetLength(BMSTOREDDIGITSARRAY[I], BMSTOREDDIGITS[I].Width);
    For J := 0 To BMSTOREDDIGITS[I].Width - 1 Do
      SetLength(BMSTOREDDIGITSARRAY[I, J], BMSTOREDDIGITS[I].Height);
    For X := 0 To BMSTOREDDIGITS[I].Width - 1 Do
      For Y := 0 To BMSTOREDDIGITS[I].Height - 1 Do
        BMSTOREDDIGITSARRAY[I, X, Y] := BMSTOREDDIGITS[I].Canvas.Pixels[X, Y];
  End;

End;

Procedure DestroyBitmaps;
Var
  I: Integer;
Begin
  For I := 0 To 13 Do
    If Assigned(BMSTOREDDIGITS[I]) Then
      FreeAndNil(BMSTOREDDIGITS[I]);
  For I := 0 To 12 Do
    If Assigned(BMPOTDIGITS[I]) Then
    Begin
      // BMPOTDIGITS[I] := Nil;
      FreeAndNil(BMPOTDIGITS[I]);
      // BMPOTDIGITS[I].Free;
    End;
  For I := 0 To 39 Do
    If Assigned(BMSTOREDLETTERS[I]) Then
    Begin
      FreeAndNil(BMSTOREDLETTERS[I]);
      // BMSTOREDLETTERS[I].Free;
    End;
  For I := 0 To 51 Do
    If Assigned(BMSTOREDHOLE[I]) Then
      FreeAndNil(BMSTOREDHOLE[I]);
  // BMSTOREDHOLE[I].Free;
  For I := 0 To 51 Do
    If Assigned(BMSTOREDBOARD[I]) Then
      FreeAndNil(BMSTOREDBOARD[I]);
  //BMSTOREDBOARD[I].Free;
End;

Procedure TFrmInfo.btnBtnAttachClick(Sender: TObject);
Var
  Buff: Array[0..255] Of char;
  S, S1: String;
  I, X, Y: Integer;
  p: TPlayer;
Begin
  Game.Handle := FindWindow('DxWndClass', Nil);
  GetWindowText(Game.Handle, Buff, 255);
  S := StrBetween(Buff, Char(36), Char(47));
  S1 := StrAfter(Char(47), Buff);
  S1 := StrBetween(S1, Char(36), Char(32));
  If Not AnsiContainsText(Buff, 'Hold') Then
  Begin
    ShowMessage('did not find the table');
  End;
  If AnsiContainsText(Buff, 'Hold') Then
  Begin
    If IsNumeric(S) Then
      Game.SB := StrToFloat(S);
    If IsNumeric(S1) Then
      Game.BB := StrToFloat(S1);
    MontecarloCount := 15000;
    S := '';
    S1 := '';
    Brain;
  End;
End;

Procedure TFrmInfo.FormClose(Sender: TObject; Var Action: TCloseAction);
Begin
  DestroyBitmaps;
  Halt;
End;

Procedure TFrmInfo.FormCreate(Sender: TObject);
Begin
  FrmInfo.Show;
  DecimalSeparator := '.';
  CreateBitmaps;
  SeatsList[0] := SeatMe0;
  SeatsList[1] := Seat1;
  SeatsList[2] := Seat2;
  SeatsList[3] := Seat3;
  SeatsList[4] := Seat4;
  SeatsList[5] := Seat5;
  SeatsList[6] := Seat6;
  SeatsList[7] := Seat7;
  SeatsList[8] := Seat8;
End;

End.

