Unit uTableInfo;

Interface
Uses
  Windows, Graphics, SysUtils, uGameClasses, StrUtils, JclStrings, uNewTypes, uGlobalVariables, uGlobalConstants,
  uMiscFunctions, codesitelogging;
//HAND STATE FUNCS
Function ButtonsAreThere: boolean;
Function Board: boolean;
Function GetBoardCard(X, Y: Integer): Integer;
Function GetHoleCard(X, Y: Integer): Integer;
Function NewHand: boolean;
Function SameHand: boolean;
//function WaitForDiffBtns: string;
Function NoButtonsAreThere: Boolean;
Procedure GetBettingOptions;
Function ClockIsThere: Boolean;
Procedure SetTableBets(Stage: TStage);
Procedure WaitForVisibility;
Function MyHolesDealt: Boolean;
//OCR FUNCTIONS
Function AtPreFlop: Boolean;
Function AtFlop: Boolean;
Function AtTurn: Boolean;
Function AtRiver: Boolean;
Function FlopFound: boolean;
Function GetDealer(SetCurrentDealer: boolean): Integer;
Function GetPlayerBankroll(Player: Integer): Double;
Function GetPlayerBets(Player: Integer): Double;
Function GetPlayerName(Player: Integer): String;
Function GetPlayersIn(Stage: TStage): Integer;
Function GetThePot(Stage: TStage; Setit: Boolean): Double;
Function HoleFound: boolean;
Function IsPlayerIn(Player: Integer): Boolean;
Function PlayersDealt: boolean;
Function PotChanged(Stage: TStage): Boolean;
Function RiverFound: boolean;
Function TurnFound: boolean;
Procedure SetFlop;
Procedure SetHole;
//Procedure SetPlayerBankroll(I: Integer);
Procedure SetRiver;
Procedure SetTurn;
Function NoCardsDealt: Boolean;
Function DealingStarted: Boolean;
Function EvenOneHoleDealt: Boolean;
Implementation
Uses
  uMain;

Function EvenOneHoleDealt: Boolean;
Var
  DC: HDC;
  Color, Color1: Cardinal;
Begin
  Result := False;
  DC := GetDC(Game.Handle);
  Color := GetPixel(DC, FirstHoleFlagX, FirstHoleFlagY);
  Color1 := GetPixel(DC, SecondHoleFlagX, SecondHoleFlagY);
  ReleaseDC(Game.Handle, DC);
  If ((GetRValue(Color) > 240) And (GetBValue(Color) > 240) And (GetGValue(Color) > 240)) Or
    ((GetRValue(Color1) > 240) And (GetBValue(Color1) > 240) And (GetGValue(Color1) > 240)) Then
    Result := True;
End;

Function MyHolesDealt: Boolean;
Var
  DC: HDC;
  Color, Color1: Cardinal;
Begin
  Result := False;
  DC := GetDC(Game.Handle);
  Color := GetPixel(DC, FirstHoleFlagX, FirstHoleFlagY);
  Color1 := GetPixel(DC, SecondHoleFlagX, SecondHoleFlagY);
  ReleaseDC(Game.Handle, DC);
  If (GetRValue(Color) > 240) And (GetBValue(Color) > 240) And (GetGValue(Color) > 240) And
    (GetRValue(Color1) > 240) And (GetBValue(Color1) > 240) And (GetGValue(Color1) > 240) Then
    Result := True;
End;

Function DealingStarted: Boolean;
Var
  I: Integer;
Begin
  Result := False;
  For I := 0 To 8 Do
    If IsPlayerIn(Circle[I]) Then
    Begin
      Result := True;
      Break;
    End;
End;

Function NoCardsDealt: Boolean;
Var
  I: Integer;
Begin
  Result := True;
  For I := 0 To 8 Do
    If IsPlayerIn(Circle[I]) Then
    Begin
      Result := False;
      Break;
    End;
End;

Function ClockIsThere: Boolean;
Var
  DC: HDC;
  Color: Cardinal;
Begin
  Result := False;
  DC := GetDC(Game.Handle);
  Color := GetPixel(DC, ClockX, ClockY);
  ReleaseDC(Game.Handle, DC);
  If (GetRValue(Color) = 8) And (GetGValue(Color) = 8) And (GetBValue(Color) = 8) Then
    Result := True;
End;

Procedure SetFlop;
Begin
  Hand.iFlop1 := GetBoardCard(Board1X, Board1Y);
  If Hand.iFlop1 > -1 Then
  Begin
    Delay(1);
    Hand.iFlop2 := GetBoardCard(Board2X, Board2Y);
    If Hand.iFlop2 > -1 Then
    Begin
      Delay(1);
      Hand.iFlop3 := GetBoardCard(Board3X, Board3Y);
    End;
  End;
End;

Procedure SetTurn;
Begin
  Hand.iTurn := GetBoardCard(Board4X, Board4Y);
End;

Procedure SetRiver;
Begin
  Hand.iRiver := GetBoardCard(Board5X, Board5Y);
End;

Procedure SetHole;
Begin
  Hand.iHole1 := GetHoleCard(FirstHoleX, FirstHoleY);
  If Hand.iHole1 > -1 Then
  Begin
    Hand.iHole2 := GetHoleCard(SecondHoleX, SecondHoleY);
  End;
End;

Function HoleFound: boolean;
Begin
  Result := False;
  If (Hand.iHole1 > -1) And (Hand.iHole2 > -1) Then
    Result := True;
End;

Function FlopFound: boolean;
Begin
  Result := False;
  If Hand.iFlop1 > -1 Then
    If Hand.iFlop2 > -1 Then
      If Hand.iFlop3 > -1 Then
        Result := True;
End;

Function TurnFound: boolean;
Begin
  Result := False;
  If Hand.iTurn > -1 Then
    Result := True;
End;

Function RiverFound: boolean;
Begin
  Result := False;
  If Hand.iRiver > -1 Then
    Result := True;
End;

Function PlayersDealt: Boolean;
Var
  DC: HDC;
  I: Integer;
Begin
  Result := False;
  For I := 0 To 8 Do
  Begin
    DC := GetDC(Game.Handle);
    Try
      If SeatsList[I].CardsColor = GetPixel(DC, SeatsList[I].CardsX,
        SeatsList[I].CardsY) Then
      Begin
        Result := True;
        Break;
      End;
    Finally
      ReleaseDC(Game.Handle, DC);
    End;
  End;
End;

Function GetPlayerName(Player: Integer): String;
Var
  DC: HDC;
  BMCAPTURED: TBitmap;
  A, B, LetterNo, Column, Diff, Row, StartingColumn, X: Integer;
  S: String;
Begin
  X := Players[Player].Seat;
  Result := '';
  BMCAPTURED := TBitmap.Create;
  Try
    BMCAPTURED.Width := NameWidth;
    BMCAPTURED.Height := NameHeight;
    DC := GetDC(Game.Handle);
    BitBlt(BMCAPTURED.Canvas.Handle, 0, 0, NameWidth, NameHeight, DC, SeatsList[X].NameX, SeatsList[X].NameY,
      SRCCOPY);
    ReleaseDC(Game.Handle, DC);
    //now binarize what you captured
    For A := 0 To NameWidth - 1 Do
      For B := 0 To NameHeight - 1 Do
      Begin
        If (GetRValue(BMCAPTURED.Canvas.Pixels[A, B]) > 100) And (GetBValue(BMCAPTURED.Canvas.Pixels[A, B]) > 100)
          And (GetGValue(BMCAPTURED.Canvas.Pixels[A, B]) > 100) Then
          BMCAPTURED.Canvas.Pixels[A, B] := RGB(255, 255, 255)
        Else
          BMCAPTURED.Canvas.Pixels[A, B] := RGB(0, 0, 0);
      End;
    //now recognize
    S := '';
    StartingColumn := 0;
    While (StartingColumn < 98) Do
    Begin
      For LetterNo := 0 To 38 Do
      Begin
        Diff := 0;
        For Column := 0 To BMSTOREDLETTERS[LetterNo].Width - 1 Do
          For Row := 0 To 9 Do
          Begin
            If BMSTOREDLETTERS[LetterNo].Canvas.Pixels[Column, Row] <> BMCAPTURED.Canvas.Pixels[Column + StartingColumn, Row]
              Then
              DIFF := DIFF + 1;
          End;
        If Diff = 0 Then
        Begin
          StartingColumn := StartingColumn + BMSTOREDLETTERS[LetterNo].Width - 1;
          S := S + NameStrings[LetterNo];
        End;
      End;
      Inc(StartingColumn);
    End;
    Result := S;
  Finally
    BMCAPTURED.Free;
  End;
End;

Function GetPlayerBankroll(Player: Integer): Double;
Var
  DC: HDC;
  BMCAPTURED: TBitmap;
  BMCAPTUREDARRAY: Array[0..97, 0..9] Of Integer;
  A, B, LetterNo, Column, Diff, Row, StartingColumn, X, L: Integer;
  S: String;
  TheFactor: Double;
Begin
  // X := Player;
  X := Players[Player].Seat;
  TheFactor := 1;
  BMCAPTURED := TBitmap.Create;
  BMCAPTURED.Width := BankrollWidth;
  BMCAPTURED.Height := BankrollHeight;
  DC := GetDC(Game.Handle);
  BitBlt(BMCAPTURED.Canvas.Handle, 0, 0, BankrollWidth, BankrollHeight, DC, SeatsList[X].BankrollX, SeatsList[X].BankrollY,
    SRCCOPY);
  ReleaseDC(Game.Handle, DC);
  //now binarize what you captured
  For A := 0 To BankrollWidth - 1 Do
    For B := 0 To BankrollHeight - 1 Do
    Begin
      If (GetRValue(BMCAPTURED.Canvas.Pixels[A, B]) > 100) And (GetBValue(BMCAPTURED.Canvas.Pixels[A, B]) > 100)
        And (GetGValue(BMCAPTURED.Canvas.Pixels[A, B]) > 100) Then
        BMCAPTUREDARRAY[A, B] := RGB(255, 255, 255)
      Else
        BMCAPTUREDARRAY[A, B] := RGB(0, 0, 0);
      //        BMCAPTURED.Canvas.Pixels[A, B] := RGB(255, 255, 255)
      //      Else
      //        BMCAPTURED.Canvas.Pixels[A, B] := RGB(0, 0, 0);
    End;
  //now recognize
  S := '';
  StartingColumn := 0;
  While (StartingColumn < 98) Do
  Begin
    For LetterNo := 0 To 13 Do
    Begin
      Diff := 0;
      L := Length(BMSTOREDDIGITSARRAY[LetterNo]);
      For Column := 0 To L - 1 Do
        For Row := 0 To 9 Do
        Begin
          If BMSTOREDDIGITSARRAY[LetterNo, Column, Row] <> BMCAPTUREDARRAY[Column + StartingColumn, Row] Then
            //          If BMSTOREDLETTERSARRAY[LetterNo, Column, Row] <> BMCAPTURED.Canvas.Pixels[Column + StartingColumn, Row] Then
                        // If BMSTOREDLETTERS[LetterNo].Canvas.Pixels[Column, Row] <> BMCAPTURED.Canvas.Pixels[Column + StartingColumn, Row] Then
            DIFF := DIFF + 1;
        End;
      If Diff = 0 Then
      Begin
        StartingColumn := StartingColumn + L - 1;
        S := S + BankrollStrings[LetterNo];
      End;
    End;
    Inc(StartingColumn);
  End;
  BMCAPTURED.Free;
  //remove the dollar and the comma
 // FrmInfo.CodeSite.Send('bankroll is ' + S);
  If AnsiContainsStr(S, 'c') Then
  Begin
    TheFactor := 0.01;
  End;
  S := CleanString(S);
  If IsNumeric(S) Then
  Begin
    Result := StrToFloat(S) * TheFactor;
    //    dc := GetDC(game.Handle);
    //    TextOut(dc, SeatsList[X].BankrollX + 30, SeatsList[X].BankrollY + 30, PWideChar(WideString(S)), Length(S));
    //    ReleaseDC(game.Handle, dc);
  End
  Else
    Result := 0;
End;

//Procedure SetPlayerBankroll(I: Integer;Stage:TStage);
//Var
//  R: Double;
//Begin
//  R := GetPlayerBankroll(I);
//  With Players[I] Do
//  Begin
//    Bankroll := R;
//  End;
//End;

Function PotChanged(Stage: TStage): Boolean;
Begin
  Result := True;
  If GetThePot(Stage, False) = Hand.CurrentPot Then
    Result := False;
End;

Function AtPreFlop: Boolean;
Var
  A: Integer;
Begin
  Result := True;
  A := GetBoardCard(Board3X, Board3Y);
  If A > -1 Then
    Result := False;
End;

Function IsPlayerIn(Player: Integer): Boolean;
Var
  DC: HDC;
  Color: Cardinal;
  X: Integer;
Begin
  X := Players[Player].Seat;
  Result := False;
  DC := GetDC(Game.Handle);
  Color := GetPixel(DC, SeatsList[X].CardsX, SeatsList[X].CardsY);
  ReleaseDC(Game.Handle, DC);
  If SeatsList[X].CardsColor = Color Then
    Result := True;
End;

Procedure SetTableBets(Stage: TStage);
Var
  TheTimesBettingWasRecorded, Player: Integer;
Begin
  TheTimesBettingWasRecorded := Length(Hand.Betting);
  Inc(TheTimesBettingWasRecorded);
  SetLength(Hand.Betting[Stage], TheTimesBettingWasRecorded);
  For Player := 0 To 8 Do
  Begin
    Hand.Betting[Stage, TheTimesBettingWasRecorded - 1, Player] := GetPlayerBets(Player);
  End;
End;

Function GetPlayerBets(Player: Integer): Double;
Var
  DC: HDC;
  BMCAPTURED: TBitmap;
  A, B, Y, J, X: Cardinal;
  C: COLORREF;
  S: String;
Begin
  X := Players[Player].Seat;
  BMCAPTURED := TBitmap.Create;
  Try
    BMCAPTURED.Width := BetsWidth;
    BMCAPTURED.Height := BetsHeight;
    BMCAPTURED.PixelFormat := pf24bit;
    DC := GetDC(Game.Handle);
    BitBlt(BMCAPTURED.Canvas.Handle, 0, 0, BetsWidth, BetsHeight, DC, SeatsList[X].BetsX, SeatsList[X].BetsY, SRCCOPY);
    ReleaseDC(Game.Handle, DC);
    S := '';
    B := 1;
    X := 0;
    While (X < BetsWidth) Do
    Begin
      For A := 0 To 1 Do
      Begin
        For Y := 0 To BetsHeight - 1 Do
        Begin
          B := B Shl 1;
          //C := GetGValue(BMCAPTURED.Canvas.Pixels[X + A, Y]);
          C := GetGValue(GetPixel(BMCAPTURED.Canvas.Handle, X + A, Y));
          If C = 203 Then
            B := B Or 1;
        End;
      End;
      X := X + 1;
      For J := 0 To 11 Do
      Begin
        If (B = BetBits[J]) And (B <> BetBits[0]) Then
        Begin
          S := S + BetStrings[J];
        End;
      End;
      B := 1;
    End;
    If IsNumeric(S) Then
      Result := StrToFloat(S)
    Else
      Result := 0;
  Finally
    BMCAPTURED.Free;
  End;
End;

Function GetThePot(Stage: TStage; Setit: Boolean): Double;
Var
  sw: TStopWatch;
  elapsedMiliseconds: cardinal;
  DC: HDC;
  BMCAPTURED: TBitmap;
  BMCAPTUREDARRAY: Array[0..149, 0..9] Of Integer;
  A, B, LetterNo, Column, Diff, Row, StartingColumn, L: Integer;
  S: String;
Begin
  BMCAPTURED := TBitmap.Create;
  Try
    BMCAPTURED.Width := PotWidth;
    BMCAPTURED.Height := PotHeight;
    DC := GetDC(Game.Handle);
    BitBlt(BMCAPTURED.Canvas.Handle, 0, 0, PotWidth, PotHeight, DC, PotX, PotY, SRCCOPY);
    ReleaseDC(Game.Handle, DC);
    //now binarize what you captured
    For A := 0 To PotWidth - 1 Do
      For B := 0 To PotHeight - 1 Do
      Begin
        If (GetRValue(BMCAPTURED.Canvas.Pixels[A, B]) > 200) And (GetBValue(BMCAPTURED.Canvas.Pixels[A, B]) > 200)
          And (GetGValue(BMCAPTURED.Canvas.Pixels[A, B]) > 200) Then
          BMCAPTUREDARRAY[A, B] := RGB(255, 255, 255)
        Else
          BMCAPTUREDARRAY[A, B] := RGB(0, 0, 0)
            //            BMCAPTURED.Canvas.Pixels[A, B] := RGB(255, 255, 255)
//          Else
//            BMCAPTURED.Canvas.Pixels[A, B] := RGB(0, 0, 0)
      End;
    //now recognize
    S := '';
    StartingColumn := 0;
    While (StartingColumn < PotWidth) Do
    Begin
      For LetterNo := 0 To 12 Do
      Begin
        Diff := 0;
        L := Length(BMPOTDIGITSARRAY[LetterNo]);
        //For Column := 0 To BMPOTDIGITS[LetterNo].Width - 1 Do
        For Column := 0 To L - 1 Do
          For Row := 0 To 8 Do
          Begin
            If BMPOTDIGITSARRAY[LetterNo, Column, Row] <> BMCAPTUREDARRAY[Column + StartingColumn, Row] Then
              //             If BMPOTDIGITSARRAY[LetterNo, Column, Row] <> BMCAPTURED.Canvas.Pixels[Column + StartingColumn, Row] Then
                             // If BMPOTDIGITS[LetterNo].Canvas.Pixels[Column, Row] <> BMCAPTURED.Canvas.Pixels[Column + StartingColumn, Row] Then
              DIFF := DIFF + 1;
          End;
        If Diff = 0 Then
        Begin
          StartingColumn := StartingColumn + L - 1;
          S := S + PotStrings[LetterNo];
        End;
      End;
      Inc(StartingColumn);
    End;
    //remove the dollar and the comma
   // frminfo.mmo1.Lines.add(S);
    S := CleanString(S);
    If IsNumeric(S) Then
    Begin
      If Setit Then
      Begin
        Hand.CurrentPot := StrToFloat(S);
        Result := Hand.CurrentPot;
      End
      Else
        Result := StrToFloat(S);
    End
    Else
      Result := 0;
  Finally
    BMCAPTURED.Free;
  End;
End;

Function GetBoardCard(X, Y: Integer): Integer;
Var
  DC: HDC;
  BMCAPTURED: TBitmap;
  I, A, B: Integer;
  P, Q: PByte;
  Diff: int64;
  Ah: Double;
Begin
  Result := -1;
  BMCAPTURED := TBitmap.Create;
  Try
    BMCAPTURED.Width := 15;
    BMCAPTURED.Height := 25;
    BMCAPTURED.PixelFormat := pf24bit;
    DC := GetDC(Game.Handle);
    BitBlt(BMCAPTURED.Canvas.Handle, 0, 0, 15, 25, DC, X, Y + 4, SRCCOPY);
    ReleaseDC(Game.Handle, DC);
    For I := 0 To 51 Do
    Begin
      Diff := 0;
      For B := 0 To BMCAPTURED.Height - 1 Do
      Begin
        P := BMCAPTURED.Scanline[B];
        Q := BMSTOREDBOARD[I].Scanline[B];
        For A := 0 To BMCAPTURED.Width - 1 Do
        Begin
          Diff := Diff + Sqr(P^ - Q^);
          inc(P);
          inc(Q);
          Diff := Diff + Sqr(P^ - Q^);
          inc(P);
          inc(Q);
          Diff := Diff + Sqr(P^ - Q^);
          inc(P);
          inc(Q);
        End;
      End;
      Ah := Sqrt(Diff / (500));
      If Ah < 1 Then
      Begin
        Result := I;
        Break;
      End;
    End;
  Finally
    BMCAPTURED.Free;
  End;
End;

Function GetHoleCard(X, Y: Integer): Integer;
Var
  DC: HDC;
  BMCAPTURED: TBitmap;
  I: Integer;
  A, B: Integer;
  P, Q: PByte;
  Diff: int64;
  Ah: Double;
Begin
  Result := -1;
  BMCAPTURED := TBitmap.Create;
  Try
    BMCAPTURED.Width := 20;
    BMCAPTURED.Height := 25;
    BMCAPTURED.PixelFormat := pf24bit;
    DC := GetDC(Game.Handle);
    BitBlt(BMCAPTURED.Canvas.Handle, 0, 0, 20, 25, DC, X, Y + 15, SRCCOPY);
    ReleaseDC(Game.Handle, DC);
    For I := 0 To 51 Do
    Begin
      Diff := 0;
      For B := 0 To BMCAPTURED.Height - 1 Do
      Begin
        P := BMCAPTURED.Scanline[B];
        Q := BMSTOREDHOLE[I].Scanline[B];
        For A := 0 To BMCAPTURED.Width - 1 Do
        Begin
          Diff := Diff + Sqr(P^ - Q^);
          inc(P);
          inc(Q);
          Diff := Diff + Sqr(P^ - Q^);
          inc(P);
          inc(Q);
          Diff := Diff + Sqr(P^ - Q^);
          inc(P);
          inc(Q);
        End;
      End;
      Ah := Sqrt(Diff / (500));
      If Ah < 1 Then
      Begin
        Result := I;
        Break;
      End;
    End;
  Finally
    BMCAPTURED.Free;
  End;
End;

Function AtRiver: Boolean;
Begin
  Result := False;
  If (GetBoardCard(Board5X, Board5Y) > -1) Then
    Result := True;
End;

Function AtTurn: Boolean;
Begin
  Result := False;
  If (GetBoardCard(Board4X, Board4Y) > -1) And (GetBoardCard(Board5X, Board5Y) = -1) Then
    Result := True;
End;

Function AtFlop: Boolean;
Begin
  Result := False;
  If (GetBoardCard(Board3X, Board3Y) > -1) And (GetBoardCard(Board4X, Board4Y) = -1) Then
    Result := True;
End;

Function Board: boolean;
Begin
  Result := False;
  If GetBoardCard(Board3X, Board3Y) > -1 Then
    Result := True;
End;

Function NoButtonsAreThere: Boolean;
Begin
  Result := True;
  GetBettingOptions;
  If BetPotBtnIsThere Or CallBtnIsThere Or FoldBtnIsThere Or RaiseBtnIsThere Or
    BetBtnIsThere Or CheckBtnIsThere Or
    FoldAndShowBtnIsThere Or FoldSmallBtnIsThere Or BetItBtnIsThere Then
    Result := False;
End;

Function ButtonsAreThere: boolean;
Begin
  Result := False;
  GetBettingOptions;
  If BetPotBtnIsThere Or CallBtnIsThere Or FoldBtnIsThere Or RaiseBtnIsThere Or
    BetBtnIsThere Or CheckBtnIsThere Or
    FoldAndShowBtnIsThere Or FoldSmallBtnIsThere Or BetItBtnIsThere Then
    Result := True;
End;

Function NewHand: boolean;
Begin
  Result := False;
  If Not SameHand Then
    Result := True;
End;

Function GetPlayersIn(Stage: TStage): Integer;
Var
  DC: HDC;
  NumberOfPlayers: Integer;
  I: Integer;
Begin
  NumberOfPlayers := 0;
  For I := 0 To 8 Do
      Players[I].InHand := False;
  For I := 0 To 8 Do
  Begin
    DC := GetDC(Game.Handle);
    If SeatsList[Players[I].Seat].CardsColor = GetPixel(DC, SeatsList[Players[I].Seat].CardsX,
      SeatsList[Players[I].Seat].CardsY) Then
    Begin
      NumberOfPlayers := NumberOfPlayers + 1;
      Players[I].InHand := True;
    End;
    ReleaseDC(Game.Handle, DC);
  End;
  Hand.OpponentsIn[Stage] := NumberOfPlayers;
  Result := NumberOfPlayers;
  //+1 to include myself
End;

Function GetDealer(SetCurrentDealer: boolean): Integer;
Var
  DC: HDC;
  I, C: COLORREF;
  ButPos: Integer;
Begin
  ButPos := -2;
  For I := 0 To 8 Do
  Begin
    DC := GetDC(Game.Handle);
    C := GetPixel(DC, DealerButtonX[I], DealerButtonY[I]);
    ReleaseDC(Game.Handle, DC);
    If GetGValue(C) = 16 Then
    Begin
      ButPos := I;
      Break
    End;
  End;
  If SetCurrentDealer Then
    Game.CurrentDealer := Butpos;
  Result := ButPos;
End;

Procedure WaitForVisibility;
Var
  DC: HDC;
  I, C: COLORREF;
  ButPos: Integer;
Begin
  ButPos := -1;
  Repeat
    For I := 0 To 8 Do
    Begin
      DC := GetDC(Game.Handle);
      C := GetPixel(DC, DealerButtonX[I], DealerButtonY[I]);
      ReleaseDC(Game.Handle, DC);
      If GetGValue(C) = 16 Then
      Begin
        ButPos := I;
        Break
      End;
    End;
  Until (Butpos > -1);
End;

Procedure GetBettingOptions;
Var
  X, Y, B, D, E, Q, A, J, I: Integer;
  C: TArray60;
  DC: HDC;
  S: String;
  TheColor: COLORREF;
  B1, B2, B3, B4, B5, B6, B7: Boolean;
Begin
  S := '';
  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      TheColor := GetPixel(DC, BetPotBtnX + X, BetPotBtnY + Y);
      ReleaseDC(Game.Handle, DC);
      C[D] := GetGValue(TheColor);
      D := D + 1;
    End;
  End;

  If ArraysAlike60(C, BetPotBtnPixels) Then
    BetPotBtnIsThere := True;
  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      C[D] := GetGValue(GetPixel(DC, CallBtnX + X, CallBtnY + Y));
      ReleaseDC(Game.Handle, DC);
      D := D + 1;
    End;
  End;
  If ArraysAlike60(C, CallBtnPixels) Then
    CallBtnIsThere := True;

  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      C[D] := GetGValue(GetPixel(DC, FoldBtnX + X, FoldBtnY + Y));
      ReleaseDC(Game.Handle, DC);
      D := D + 1;
    End;
  End;
  If ArraysAlike60(C, FoldBtnPixels) Then
    FoldBtnIsThere := True;
  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      C[D] := GetGValue(GetPixel(DC, RaiseBtnX + X, RaiseBtnY + Y));
      ReleaseDC(Game.Handle, DC);
      D := D + 1;
    End;
  End;
  If ArraysAlike60(C, RaiseBtnPixels) Then
    RaiseBtnIsThere := True;

  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      C[D] := GetGValue(GetPixel(DC, BetBtnX + X, BetBtnY + Y));
      ReleaseDC(Game.Handle, DC);
      D := D + 1;
    End;
  End;
  If ArraysAlike60(C, BetBtnPixels) Then
    BetBtnIsThere := True;
  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      C[D] := GetGValue(GetPixel(DC, CheckBtnX + X, CheckBtnY + Y));
      ReleaseDC(Game.Handle, DC);
      D := D + 1;
    End;
  End;
  If ArraysAlike60(C, CheckBtnPixels) Then
    CheckBtnIsThere := True;
  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      C[D] := GetGValue(GetPixel(DC, FoldAndShowBtnX + X, FoldAndShowBtnY + Y));
      ReleaseDC(Game.Handle, DC);
      D := D + 1;
    End;
  End;
  If ArraysAlike60(C, FoldAndShowBtnPixels) Then
    FoldAndShowBtnIsThere := True;
  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      C[D] := GetGValue(GetPixel(DC, FoldSmallBtnX + X, FoldSmallBtnY + Y));
      ReleaseDC(Game.Handle, DC);
      D := D + 1;
    End;
  End;
  If ArraysAlike60(C, FoldSmallBtnPixels) Then
    FoldSmallBtnIsThere := True;
  D := 0;
  For X := 0 To 9 Do
  Begin
    For Y := 0 To 5 Do
    Begin
      DC := GetDC(Game.Handle);
      C[D] := GetGValue(GetPixel(DC, BetItBtnX + X, BetItBtnY + Y));
      ReleaseDC(Game.Handle, DC);
      D := D + 1;
    End;
  End;
  If ArraysAlike60(C, BetItBtnPixels) Then
    BetItBtnIsThere := True;
  {******************Auto betting buttons*******************}
  B1 := NearThat(GetBValue(GetPixel(DC, 274, 466)), 80);
  B2 := NearThat(GetBValue(GetPixel(DC, 385, 466)), 80);
  B3 := NearThat(GetBValue(GetPixel(DC, 495, 466)), 80);
  B4 := NearThat(GetBValue(GetPixel(DC, 385, 450)), 80);
  B5 := NearThat(GetBValue(GetPixel(DC, 497, 450)), 80);
  If B1 Or B2 Or B3 Or B4 Or B5 Then
  Begin
    BetItBtnIsThere := False;
    FoldSmallBtnIsThere := False;
    CheckBtnIsThere := False;
    FoldAndShowBtnIsThere := False;
    RaiseBtnIsThere := False;
    BetBtnIsThere := False;
    CallBtnIsThere := False;
    FoldBtnIsThere := False;
    BetPotBtnIsThere := False;
  End;
End;

Function SameHand: boolean;
Var
  A: Integer;
Begin
  Result := False;
  Repeat
    Delay(10);
    A := GetDealer(False);
  Until (A > -1);
  If (A = Game.CurrentDealer) And (A = Game.PreviousDealer) Then
    Result := True;
End;

End.

