Unit uFormUtils;

Interface
Uses
  uMain, uHashTables, uTableInfo, uGlobalVariables;

Procedure ShowHole;
Procedure ShowFlop;
Procedure ShowTurn;
Procedure ShowRiver;
Procedure FillMemo(S: String);
Procedure FormCleaner;

Implementation

Procedure FormCleaner;
Begin
  With FrmInfo Do
  Begin
    lbl1.Caption := '';
    lbl2.Caption := '';
    lbl3.Caption := '';
    lbl4.Caption := '';
    lbl5.Caption := '';
    lbl6.Caption := '';
    lbl7.Caption := '';
    h1img.Picture := Nil;
    h2img.Picture := Nil;
    f1img.Picture := Nil;
    f2img.Picture := Nil;
    f3img.Picture := Nil;
    timg.Picture := Nil;
    rimg.Picture := Nil;
  End;
End;

Procedure FillMemo(S: String);
Begin
  FrmInfo.mmo1.Lines.Add(S);
End;

Function Rank(Card: Int64): Integer;
Var
  I: Integer;
Begin
  For I := 0 To 52 Do
  Begin
    If Card = CardMasks[I] Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;

Procedure ShowHole;
Begin
  FrmInfo.lbl1.Caption := RankChar[Hand.iHole1];
  FrmInfo.h1img.Picture.Bitmap.LoadFromResourceName(hinstance, SuitTbl[Hand.iHole1]);
  FrmInfo.lbl2.Caption := RankChar[Hand.iHole2];
  FrmInfo.h2img.Picture.Bitmap.LoadFromResourceName(hinstance, SuitTbl[Hand.iHole2]);
End;

Procedure ShowFlop;
Begin
  If FlopFound Then
  Begin
    FrmInfo.lbl3.Caption := RankChar[Hand.iFlop1];
    FrmInfo.f1img.Picture.Bitmap.LoadFromResourceName(hinstance, SuitTbl[Hand.iFlop1]);
    FrmInfo.lbl4.Caption := RankChar[Hand.iFlop2];
    FrmInfo.f2img.Picture.Bitmap.LoadFromResourceName(hinstance, SuitTbl[Hand.iFlop2]);
    FrmInfo.lbl5.Caption := RankChar[Hand.iFlop3];
    FrmInfo.f3img.Picture.Bitmap.LoadFromResourceName(hinstance, SuitTbl[Hand.iFlop3]);
  End;
End;

Procedure ShowTurn;
Begin
  If TurnFound Then
  Begin
    FrmInfo.lbl6.Caption := RankChar[Hand.iTurn];
    FrmInfo.timg.Picture.Bitmap.LoadFromResourceName(hinstance, SuitTbl[Hand.iTurn]);
  End;
End;

Procedure ShowRiver;
Begin
  If RiverFound Then
  Begin
    FrmInfo.lbl7.Caption := RankChar[Hand.iRiver];
    FrmInfo.rimg.Picture.Bitmap.LoadFromResourceName(hinstance, SuitTbl[Hand.iRiver]);
  End;
End;

End.

