Unit uGameClasses;

Interface
Uses
  Types, Windows, SysUtils, uNewTypes, uMiscFunctions;
Function GetIndex(S: Integer): Integer;
Type
  TPlayerState = Record
    HoldingCards: Boolean;
    Bankroll: Double;
    LatestBet: Double;
  End;
Type
  TPlayer = Record
    AlreadyFolded: Array[TStage] Of Boolean;
    Seat: Integer;
    Name: String;
    PlayedAt: Array[TStage] Of Boolean;
    WasHoldingJustBefore: Array[TStage] Of Boolean;
    Bankroll: Double;
    StartBankroll: Double;
    FinishBankroll: Double;
    SmallBlinder: Boolean;
    BigBlinder: Boolean;
    Dealt: Boolean;
    InHand: Boolean;
    LatestBetOfThisPlayer: Array[Tstage] Of Double;
    PocketRange: Array Of Int64;
    Action: Array[TStage] Of Integer;
    Folded: Array[TStage] Of Boolean;
    StageInvestment: Array[TStage] Of Double;
    InvestmentToBankroll: Array[TStage] Of Double;
    InvestmentToPot: Array[TStage] Of Double;
    ProjectedInvestment: Array[TStage] Of Double;
    TotalInvestment: Double;
    WinOdds: Double;
    HandStrength: Double;
  End;

Type
  THand = Record
    Betting: Array[TStage] Of Array Of Array[0..8] Of Double;
    CurrentPot: Double;
    LatestBetInStage: Array[TStage] Of Double;
    BlindsPosted: Boolean;
    GoodPreFlopInvestment: Boolean;
    iHole1, iHole2, iFlop1, iFlop2, iFlop3, iTurn, iRiver: Integer;
    OpponentsIn: Array[TStage] Of Integer;
    BettingSequence: Array[TStage] Of Array Of Integer;
    Procedure AllIn;
    Procedure Betit;
    Procedure Call;
    Procedure ClickIt(X, Y: Integer);
    Procedure Fold;
    Procedure ReCreateCircle(TheButton: Integer);
  End;

Type
  TGame = Record
    CurrentDealer, Number, PreviousDealer, Played: Integer;
    Stats: Array Of Array[0..8] Of TPlayer;
    SameHand, NewHand: Boolean;
    SB, BB: Double;
    Handle: HWND;
    // Destructor Destroy; Override;
  End;
Var
  Players: Array[0..8] Of TPlayer;
Implementation
Uses
  uMain, uGlobalVariables, uGlobalConstants;
{ TODO : fill the procedure CLEANRECORDS that is called right after a hand is finished }

Procedure CleanRecords;
Begin

End;

Function GetIndex(S: Integer): Integer;
Var
  I: Integer;
Begin
  Result := -1;
  For I := 0 To 8 Do
  Begin
    If Players[I].Seat = S Then
    Begin
      Result := I;
      Break;
    End;
  End;
End;

Procedure THand.ReCreateCircle(TheButton: Integer);
Var
  Seat, I, FixedPlayer, Player, J: Integer;
Begin
  For I := 0 To 8 Do
  Begin
    Players[I].SmallBlinder := False;
    Players[I].BigBlinder := False;
  End;
  For I := 0 To 8 Do
    For J := 0 To 3 Do
      Players[I].AlreadyFolded[TStage(J)] := False;
  For I := 0 To 8 Do
    For J := 0 To 3 Do
      Players[I].Folded[TStage(J)] := False;
  For I := 0 To 8 Do
    For J := 0 To 3 Do
      Players[I].LatestBetOfThisPlayer[TStage(J)] := 0;

  For J := 0 To 3 Do
    Hand.LatestBetInStage[TStage(J)] := 0;

  For J := 0 To 3 Do
  Begin
    SetLength(BettingSequence[TStage(J)], 0);
  End;

  Player := TheButton;
  For I := 0 To 8 Do
  Begin
    inc(Player);
    FixedPlayer := FixedPos(Player, 9);
    Players[I].Seat := FixedPlayer;
    //  Players[I].Name := GetPlayerName(FixedPlayer);
  End;
  iHole1 := -1;
  iHole2 := -1;
  iFlop1 := -1;
  iFlop2 := -1;
  iFlop3 := -1;
  iTurn := -1;
  iRiver := -1;
  For I := 0 To 8 Do
    For J := 0 To 3 Do
      Players[I].Action[TStage(J)] := 0;
End;

//Destructor THand.Destroy;
//Var
//  I: Integer;
//Begin
//  // // PreflopBetList.Free;
  //  //PreflopStateList.Free;
  //  iHole1 := -1;
  //  iHole2 := -1;
  //  iFlop1 := -1;
  //  iFlop2 := -1;
  //  iFlop3 := -1;
  //  iTurn := -1;
  //  iRiver := -1;
  //  SBPlayer := -1;
  //  BBPlayer := -1;
  //  I := 0;
  //  While I < 9 Do
  //  Begin
  //    Players[I].Free;
  //    I := I + 1;
  //  End;
  //  Players.Free;
//End;

Procedure THand.ClickIt(X, Y: Integer);
Var
  tmp: TPoint;
Begin
  Delay(1);
  If FrmInfo.AutoCheck.Checked Then
  Begin
    GetCursorPos(tmp);
    SetCursorPos(X + 8, Y + 28);
    mouse_event(mouseeventf_leftdown, 0, 0, 0, 0);
    mouse_event(mouseeventf_leftup, 0, 0, 0, 0);
    Delay(50);
    mouse_event(mouseeventf_leftdown, 0, 0, 0, 0);
    mouse_event(mouseeventf_leftup, 0, 0, 0, 0);
    Delay(50);
    mouse_event(mouseeventf_leftdown, 0, 0, 0, 0);
    mouse_event(mouseeventf_leftup, 0, 0, 0, 0);
    Delay(50);
    mouse_event(mouseeventf_leftdown, 0, 0, 0, 0);
    mouse_event(mouseeventf_leftup, 0, 0, 0, 0);
    //    Delay(1000);
    //    SetCursorPos(tmp.X, tmp.Y);
    //    mouse_event(mouseeventf_leftdown, 0, 0, 0, 0);
    //    mouse_event(mouseeventf_leftup, 0, 0, 0, 0);
    SetCursorPos(0, 0);
  End;
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

Procedure THand.AllIn;
Var
  tmp: TPoint;
  Rect: TRect;
  bank: Double;
  banks: String;
Begin
  Delay(1);
  If FrmInfo.AutoCheck.Checked Then
  Begin
    GetWindowRect(Game.Handle, Rect);
    GetCursorPos(tmp);
    SetCursorPos(rect.left + 500, rect.top + 452);
    mouse_event(mouseeventf_leftdown, 0, 0, 0, 0);
    mouse_event(mouseeventf_leftup, 0, 0, 0, 0);
    bank := Players[0].Bankroll;
    banks := FloatToStr(bank);
    SendKeys(PAnsiChar(AnsiString(banks)), False);
    Delay(500);
    BetIt;
  End;
End;

Procedure THand.Betit;
Var
  Rect: TRect;
Begin
  GetWindowRect(Game.Handle, Rect);
  If BetItBtnIsThere Then
    ClickIt(Rect.Left + BetItBtnX, Rect.Top + BetItBtnY);
  // FrmInfo.CodeSite.Send('I clicked');
End;

Procedure THand.Call;
Var
  Rect: TRect;
Begin
  GetWindowRect(Game.Handle, Rect);
  //click the fold button
  If CallBtnIsThere Then
    ClickIt(Rect.Left + CallBtnX, Rect.Top + CallBtnY)
  Else If CheckBtnIsThere Then
    ClickIt(Rect.Left + CheckBtnX, Rect.Top + CheckBtnY);
  // FrmInfo.CodeSite.Send('I clicked');
End;

Procedure THand.Fold;
Var
  Rect: TRect;
Begin
  GetWindowRect(Game.Handle, Rect);
  //click the fold button
  If CheckBtnIsThere Then
    ClickIt(Rect.Left + CheckBtnX, Rect.Top + CheckBtnY)
  Else If FoldBtnIsThere Then
    ClickIt(Rect.Left + FoldBtnX, Rect.Top + FoldBtnY)
  Else If FoldAndShowBtnIsThere Then
    ClickIt(Rect.Left + FoldSmallBtnX, Rect.Top + FoldSmallBtnY);
  // FrmInfo.CodeSite.Send('I clicked');
End;
End.

