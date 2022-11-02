Unit uBrain;

Interface
Uses
  Types, uGameClasses, SysUtils,
  Generics.Collections, uNewTypes, uGlobalVariables, uMiscFunctions, CodeSiteLogging, Math, uGlobalConstants, uHandAnalysis,
  uHashTables;

Procedure Brain;
Procedure PlayRiver;
Procedure PlayTurn;
Procedure PlayFlop;
Procedure PlayPreFlop;
Procedure ShowBetting(Stage: TStage);
Function RecordBetting(PreviousPot: Double; Stage: TStage): Double;
Procedure AnalyseBetting(Stage: TStage);
Function Action(I: Integer): String;

Implementation
Uses
  uFormUtils, uMain, uTableInfo;

Function PlayerOnSeat(I: Integer): Integer;
Var
  J: Integer;
Begin
  For J := 0 To 8 Do
    If I = Players[J].Seat Then
    Begin
      Result := J;
      Break;
    End;
End;

Procedure SaveHand;
Var
  I, L: Integer;
Begin
  L := Length(Game.Stats);
  SetLength(Game.Stats, L + 1);
  For I := 0 To 8 Do
  Begin
    Game.Stats[L, I] := Players[PlayerOnSeat(I)];
  End;
End;

Function Action(I: Integer): String;
Begin
  Result := '';
  If (I And Checking) > 0 Then
    Result := Result + 'Checking ';
  If (I And FoldingVersusNil) > 0 Then
    Result := Result + 'Folding ';
  If (I And CallingBet) > 0 Then
    Result := Result + 'Calling ';
  If (I And Raising) > 0 Then
    Result := Result + 'Raising ';
  If (I And Betting) > 0 Then
    Result := Result + 'ReRaising ';
End;

Function HowManyUniques(PlayerArray: TArrayOfDouble): Integer;
Var
  I, L, Uniques: Integer;
  SortedArray: TArrayOfDouble;
Begin
  Uniques := 0;
  L := Length(PlayerArray);
  If L > 0 Then
  Begin
    Uniques := 1;
    SortedArray := QuickSortDoubles(PlayerArray);
    For I := 1 To L - 1 Do
    Begin
      If SortedArray[I] <> SortedArray[I - 1] Then
        Inc(Uniques);
    End;
  End;
  Result := Uniques;
End;
//Delete arrays between first action and last
//merge arrays  0 0 0 1 0 0 0 0
//              0 0 0 1 0 1 0 0
//              0 0 0 1 0 1 0 2
//              0 0 0 4 0 0 0 2
//              0 0 0 4 0 0 0 6
//              0 0 0 6 0 0 0 6

//how many betting rounds
//see in every player array how many unique numbers there are then put them in an array
//then sort the array and see how many unique numbers there are at the topmost
//this will be the betting rounds

//NOW IT LOOKS LIKE THIS
//merge arrays  1 0 0
//              1 1 0
//              1 1 2
//              4 0 2    3   2
//              4 0 6    5   4
//              6 0 6

Procedure WhatPlayersDid(Stage: TStage);
Var
  PlayerArray: TArrayOfDouble;
  I, L, J, N, X, Positives, Player, FirstBettor: Integer;
  S: String;
  UniqueN, ActivePlayers: Array Of Integer;
  Function PlayedHisTurn(ThePlayer: Integer): Boolean;
  Var
    D: Integer;
  Begin
    Result := False;
    For D := ThePlayer To 8 Do
      If (Hand.Betting[Stage, J, D] > 0) Then
      Begin
        Result := True;
        Break;
      End;
  End;
Begin
  S := '';
  L := Length(Hand.Betting[Stage]);
  SetLength(PlayerArray, 0);
  SetLength(UniqueN, 0);
  //SetActivePlayers
  I := 0;
  For Player := 0 To 8 Do
    For J := 0 To L - 1 Do
      If ((Hand.Betting[Stage, J, Player] > 0) Or (PlayersIn[Stage, Player])) And PlayedHisTurn(Player) Then
      Begin
        Inc(I);
        SetLength(ActivePlayers, I);
        ActivePlayers[I - 1] := Player;
        Break;
      End;

  For Player := 0 To 8 Do
    If Hand.Betting[Stage, J, Player] > 0 Then
    Begin
      FirstBettor := Player;
      Break;
    End;

  //  LatestBet := Game.BB; //2
//  N := Length(ActivePlayers);
//  If N > 0 Then
//    For J := 0 To L - 1 Do
//    Begin
//      For Player := 0 To N - 1 Do
//      Begin
       // If Hand.Betting[Stage, J, ActivePlayers[Player]] <> Players[ActivePlayers[Player]].LatestBet Then
//        Begin
//          If (Hand.Betting[Stage, J, ActivePlayers[Player]] = 0) And (IsPlayerIn(ActivePlayers[Player])) Then
//            Players[ActivePlayers[Player]].Action[Stage] := Check Or
//              Players[ActivePlayers[Player]].Action[Stage];
//          If (Hand.Betting[Stage, J, ActivePlayers[Player]] = 0) And (IsPlayerIn(ActivePlayers[Player]) = False) And
//            (Hand.LatestBet
//            = Game.BB) Then
//            Players[ActivePlayers[Player]].Action[Stage] := FoldACall Or
//              Players[ActivePlayers[Player]].Action[Stage];
//          If (Hand.Betting[Stage, J, ActivePlayers[Player]] = 0) And (IsPlayerIn(ActivePlayers[Player]) = False) And
//            (Hand.LatestBet
//            > Game.BB) Then
//            Players[ActivePlayers[Player]].Action[Stage] := FoldARaise Or
//              Players[ActivePlayers[Player]].Action[Stage];
//          //if players bet equals BB or SB then CallABlind or Action
//          If ((Hand.Betting[Stage, J, ActivePlayers[Player]] = Game.BB) Or (Hand.Betting[Stage, J, ActivePlayers[Player]] =
//            Game.SB)) Then
//          Begin
//            Players[ActivePlayers[Player]].Action[Stage] := CallABlind Or
//              Players[ActivePlayers[Player]].Action[Stage];
//            Players[ActivePlayers[Player]].LatestBet := Hand.Betting[Stage, J, ActivePlayers[Player]];
//          End;
//          //if players bet equal the previous bet and it is more than BB then CallARaise or action
//          If (Hand.Betting[Stage, J, ActivePlayers[Player]] = Hand.LatestBet) And (Hand.LatestBet > Game.BB) Then
//          Begin
//            Players[ActivePlayers[Player]].Action[Stage] := CallARaise Or
//              Players[ActivePlayers[Player]].Action[Stage];
//            Players[ActivePlayers[Player]].LatestBet := Hand.Betting[Stage, J, ActivePlayers[Player]];
//          End;
//          //if players bet is more than previous bet and the previous bet was more than BB then RaiseARaise
//          If Hand.Betting[Stage, J, ActivePlayers[Player]] > Hand.LatestBet Then
//          Begin
//            If Hand.LatestBet > Game.BB Then
//              Players[ActivePlayers[Player]].Action[Stage] := RaiseARaise Or
//                Players[ActivePlayers[Player]].Action[Stage];
//            If Hand.LatestBet = Game.BB Then
//              Players[ActivePlayers[Player]].Action[Stage] := RaiseACall Or
//                Players[ActivePlayers[Player]].Action[Stage];
//            Hand.LatestBet := Hand.Betting[Stage, J, ActivePlayers[Player]];
//            Players[ActivePlayers[Player]].LatestBet := Hand.Betting[Stage, J, ActivePlayers[Player]];
//          End;
//          If Hand.Betting[Stage, J, ActivePlayers[Player]] = 0 Then
//          Begin
//            Positives := 0;
//            For X := J + 1 To L - 1 Do
//            Begin
//              If Hand.Betting[Stage, X, ActivePlayers[Player]] > 0 Then
//              Begin
//                Inc(positives);
//                Break;
//              End
//            End;
//            If Positives = 0 Then
//            Begin
//              If Hand.LatestBet > Game.BB Then
//                Players[ActivePlayers[Player]].Action[Stage] := FoldARaise Or
//                  Players[ActivePlayers[Player]].Action[Stage];
//              If Hand.LatestBet = Game.BB Then
//                Players[ActivePlayers[Player]].Action[Stage] := FoldACall Or
//                  Players[ActivePlayers[Player]].Action[Stage];
//            End;
//          End;
//        End;
//      End;
   // End;
End;

Procedure AnalyseBetting(Stage: TStage);
Var
  Player, L, I: Integer;
  PlayerArray, NewArray: TArrayOfDouble;
  Pot, Investment, Bankroll, C: Double;
Begin
  //Hand.LatestBetInStage[Stage] := Game.BB;
  L := Length(Hand.Betting[Stage]);
  If L > 0 Then
  Begin
    Pot := GetThePot(Stage, False);
    For Player := 0 To 8 Do
    Begin
      SetLength(PlayerArray, 0);
      For I := 0 To L - 1 Do
      Begin
        SetLength(PlayerArray, I + 1);
        PlayerArray[I] := Hand.Betting[Stage, I, Player];
      End;
      //Now set investment
      NewArray := QuickSortDoubles(PlayerArray);
      Players[Player].StageInvestment[Stage] := NewArray[L - 1];
      //      Bankroll := GetPlayerBankroll(Player);
      Investment := Players[Player].StageInvestment[Stage];
      //      Players[Player].Bankroll := Bankroll;
      //      If Bankroll > 0 Then
      //      Begin
      //        Players[Player].InvestmentToPot[Stage] := Investment / Pot;
      //        Players[Player].InvestmentToBankroll[Stage] := Investment / (Bankroll + Investment);
      //      End
      //      Else
      //      Begin
      //        Players[Player].InvestmentToPot[Stage] := 0;
      //        Players[Player].InvestmentToBankroll[Stage] := 0;
      //      End;
      //WhatPlayersDid(Stage);
    End;
  End;
  //FrmInfo.mmo1.Clear;
  For I := 0 To 8 Do
  Begin
    FrmInfo.mmo1.Lines.Add('Player' + IntToStr(I) + ' invested:' + FloatToStr(Players[I].StageInvestment[Stage]));
  End;
End;

Function HowManyPlayersToMe: Integer;
Var
  I, Player: Integer;
Begin
  I := 0;
  For Player := 0 To 8 Do
  Begin
    If Players[Player].Seat <> 0 Then
      Inc(I)
    Else
    Begin
      Result := I;
      Break;
    End;
  End;
End;

Procedure Brain;
Var
  sw: TStopWatch;
  elapsedMiliseconds: Cardinal;
  I, NextPlayer, FixedNextPlayer, Player, dada: Integer;
  Bet: Double;
  Flag: Boolean;
Begin
  {*********Clean player and hand records and other global variables*********}

{****************Get The New Dealer******************}

  Repeat
    Delay(1);
    GetDealer(True);
  Until (Game.CurrentDealer > -1) And (Game.CurrentDealer <> Game.PreviousDealer);
  Game.PreviousDealer := Game.CurrentDealer;
  CodeSite.Send('Delaer');
  {*****************Set POSITION field for players in Players****************}
  Hand.ReCreateCircle(Game.CurrentDealer);
  CodeSite.send('Create Circle');

  {*************Bu da lazým olur belki hazýr olsun*************}
  Hand.BlindsPosted := False;
  NextPlayer := Game.CurrentDealer;
  For I := 0 To 8 Do
  Begin
    NextPlayer := NextPlayer + 1;
    FixedNextPlayer := FixedPos(NextPlayer, 9);
    Circle[I] := FixedNextPlayer;
  End;

  {***************Watch blinding until someone is dealt***************}

  //if nobody is dealt yet then keep on recording betting until somebody is dealt

  While SameHand Do
  Begin
    {**Record Blinds**}
    For Player := 0 To 8 Do
    Begin
      Delay(1);
      Flag := EvenOneHoleDealt;
      If Not Flag Then
      Begin
        Bet := GetPlayerBets(Circle[Player]);
        If Bet > 0 Then
        Begin
          If Bet = Game.SB Then
          Begin
            Players[Circle[Player]].SmallBlinder := True;
            Players[Circle[Player]].Action[PreFlop] := Players[Circle[Player]].Action[PreFlop] Or PostedSB;
          End;
          If Bet = Game.BB Then
          Begin
            Players[Circle[Player]].BigBlinder := True;
            Players[Circle[Player]].Action[PreFlop] := Players[Circle[Player]].Action[PreFlop] Or PostedBB;
          End;
          Players[Circle[Player]].LatestBetOfThisPlayer[PreFlop] := Bet;
          Hand.BlindsPosted := True;
        End
        Else
        Begin
          Players[Circle[Player]].SmallBlinder := False;
          Players[Circle[Player]].BigBlinder := False;
        End;
      End;
    End;
    If Flag Then
      Break;
  End;
  CodeSite.send('Blinding');
  For I := 0 To 8 Do
    With Players[I] Do
    Begin
      StartBankroll := GetPlayerBankroll(I);
    End;
  For I := 0 To 8 Do
    With Players[I] Do
    Begin
      If SmallBlinder Or BigBlinder Then
        FrmInfo.mmo1.Lines.Add('player' + IntToStr(I) + ' is a blinder'); //should i publish the SEAT or the POSITION
    End;

  {******************Set the holes and show them if found****************************}
  {?????????????????????????first check if the cards we given to you by checking one pixel
  then if the cards are given then you start reading which holes they were????the same for the board cards??????????????????????}

  Repeat
    Delay(1);
    If NewHand Then
      Break;
  Until MyHolesDealt;
  CodeSite.send('Finding white on cards');

  If MyHolesDealt Then
    Repeat
      Delay(1);
      SetHole;
      If NewHand Then
        Break;
    Until HoleFound;
  CodeSite.send('Finding holes');

  If HoleFound Then
    ShowHole;
  CodeSite.send('Show holes');
  {****************Flag players who were dealt***************}
  Delay(500);
  GetPlayersIn(PreFlop);
  For I := 0 To 8 Do
    If Players[I].InHand Then
    Begin
      Players[I].WasHoldingJustBefore[PreFlop] := True;
      Players[I].Dealt := True;
    End
    Else
    Begin
      Players[I].WasHoldingJustBefore[PreFlop] := False;
      Players[I].Dealt := False;
    End;

  For I := 1 To 8 Do
    If Players[I].InHand Then
      PlayersIn[PreFlop, I] := True
    Else
      PlayersIn[PreFlop, I] := False;

  {**********************************************}
  For I := 0 To 3 Do
    SetLength(Hand.Betting[TStage(I)], 0);
  {**********************************************}
  Delay(50);
  {********************Record Betting Then Play when CLOCKISTHERE**************************}

  PreviousPot := 0;
  While AtPreFlop And SameHand Do
  Begin
    While AtPreFlop And SameHand And (Not ClockIsThere) Do
    Begin
      Delay(10);
      PreviousPot := RecordBetting(PreviousPot, Preflop);
    End;
    If ClockIsThere Then
    Begin
      AnalyseBetting(PreFlop);
      For Dada := 0 To 8 Do
        FrmInfo.mmo1.Lines.Add('Player' + IntToStr(dada) + Action(Players[dada].Action[PreFlop]));
      PlayPreflop;
      While ClockIsThere Do
      Begin
        Delay(1);
      End;
      Delay(100);
      While AtPreFlop And SameHand And (Not ClockIsThere) Do
      Begin
        Delay(10);
        PreviousPot := RecordBetting(PreviousPot, Preflop);
      End;
    End;
  End;
  AnalyseBetting(Preflop);
  {***********************Find the flop cards or continue to a new game***********************}
  Repeat
    Delay(1);
    SetFlop;
    If NewHand Then
      Break;
  Until FlopFound;
  If FlopFound Then
    ShowFlop;
  {**********************************************}
  GetPlayersIn(Flop);
  For I := 0 To 8 Do
    Players[I].PlayedAt[Flop] := False;
  For I := 0 To 8 Do
    If Players[I].InHand Then
      Players[I].WasHoldingJustBefore[Flop] := True
    Else
      Players[I].WasHoldingJustBefore[Flop] := False;
  For I := 1 To 8 Do
    If Players[I].InHand Then
      PlayersIn[Flop, I] := True
    Else
      PlayersIn[Flop, I] := False;
  Delay(50);
  {**********************************************}
  PreviousPot := 0;
  While AtFlop And SameHand Do
  Begin
    While AtFlop And SameHand And (Not ClockIsThere) Do
    Begin
      Delay(10);
      PreviousPot := RecordBetting(PreviousPot, flop);
    End;
    If ClockIsThere Then
    Begin
      AnalyseBetting(Flop);
      For Dada := 0 To 8 Do
        FrmInfo.mmo1.Lines.Add('Player' + IntToStr(dada) + Action(Players[dada].Action[flop]));
      Playflop;
      While ClockIsThere Do
      Begin
        Delay(1);
      End;
      Delay(100);
      While AtFlop And SameHand And (Not ClockIsThere) Do
      Begin
        Delay(10);
        PreviousPot := RecordBetting(PreviousPot, flop);
      End;
      // ShowBetting(PreFlop);
    End;
  End;
  AnalyseBetting(Flop);
  {***********************Find the TURN cards or continue to a new game***********************}
  Repeat
    Delay(1);
    SetTurn;
    If NewHand Then
      Break;
  Until TurnFound;
  If TurnFound Then
    ShowTurn;
  {**********************************************}
  GetPlayersIn(Turn);
  For I := 0 To 8 Do
    Players[I].PlayedAt[Turn] := False;
  For I := 0 To 8 Do
    If Players[I].InHand Then
      Players[I].WasHoldingJustBefore[Turn] := True
    Else
      Players[I].WasHoldingJustBefore[Turn] := False;
  For I := 1 To 8 Do
    If Players[I].InHand Then
      PlayersIn[Turn, I] := True
    Else
      PlayersIn[Turn, I] := False;
  Delay(50);
  {**********************************************}
  PreviousPot := 0;
  While AtTurn And SameHand Do
  Begin
    While AtTurn And SameHand And (Not ClockIsThere) Do
    Begin
      Delay(10);
      PreviousPot := RecordBetting(PreviousPot, turn);
    End;
    If ClockIsThere Then
    Begin
      AnalyseBetting(Turn);
      For Dada := 0 To 8 Do
        FrmInfo.mmo1.Lines.Add('Player' + IntToStr(dada) + Action(Players[dada].Action[turn]));
      Playturn;
      While ClockIsThere Do
      Begin
        Delay(1);
      End;
      Delay(100);
      While AtTurn And SameHand And (Not ClockIsThere) Do
      Begin
        Delay(10);
        PreviousPot := RecordBetting(PreviousPot, turn);
      End;
    End;
  End;
  AnalyseBetting(Turn);
  {***********************Find the RIVER cards or continue to a new game***********************}
  Repeat
    Delay(1);
    SetRiver;
    If NewHand Then
      Break;
  Until RiverFound;
  If RiverFound Then
    ShowRiver;
  {**********************************************}
  GetPlayersIn(River);
  For I := 0 To 8 Do
    Players[I].PlayedAt[River] := False;
  For I := 0 To 8 Do
    If Players[I].InHand Then
      Players[I].WasHoldingJustBefore[River] := True
    Else
      Players[I].WasHoldingJustBefore[River] := False;
  For I := 1 To 8 Do
    If Players[I].InHand Then
      PlayersIn[River, I] := True
    Else
      PlayersIn[River, I] := False;
  Delay(50);
  {**********************************************}
  PreviousPot := 0;
  While AtRiver And SameHand Do
  Begin
    While AtRiver And SameHand And (Not ClockIsThere) Do
    Begin
      Delay(10);
      PreviousPot := RecordBetting(PreviousPot, River);
    End;
    If ClockIsThere Then
    Begin
      AnalyseBetting(River);
      For Dada := 0 To 8 Do
        FrmInfo.mmo1.Lines.Add('Player' + IntToStr(dada) + Action(Players[dada].Action[River]));
      PlayRiver;
      While ClockIsThere Do
      Begin
        Delay(1);
      End;
      Delay(100);
      While AtRiver And SameHand And (Not ClockIsThere) Do
      Begin
        Delay(10);
        PreviousPot := RecordBetting(PreviousPot, River);
      End;
    End;
  End;
  AnalyseBetting(River);

  Repeat
    Delay(1);
  Until Not SameHand;
  //set total investments of players
  //save hand history
  inc(Game.Number);
  FrmInfo.mmo1.Clear;
  FrmInfo.mmo1.Lines.Add(IntToStr(Game.Number));
  FormCleaner;
  For I := 0 To 8 Do
    With Players[I] Do
    Begin
      FinishBankroll := GetPlayerBankroll(I);
    End;
  SaveHand;
  //CleanRecords;
  Brain;
End;

Procedure PlayPreflop;
Begin
  {Their pre-flop strategy is dependent on a player's expected position in the later betting rounds.
  For example, they discuss a tactical raise, called ``buying the button", which is used in late
  position in the pre-flop to hopefully scare away the players behind you to become the last player
   to act in future betting rounds. }
    {
    we need:
    investment amount made by players.
    percentage of their investments to their bankrolls
    percentage of ours to our bankrolls
    loosness and tightness of the table
    loosness and tightness of players
    }

  GetPlayersIn(PreFlop);
  {First we check to see if our hole is playable}
  // FrmInfo.CodeSite.Send('the group is :' + IntToStr(CheckGroup));
  //  If CheckGroup < 3 Then
  //  Begin
  //    Inc(Game.Played);
  //    Hand.Allin;
  //    FrmInfo.mmo1.Lines.Add(IntToStr(Game.Played));
  //  End
  //  Else
  //    Hand.Fold;
  If CheckGroup < 8 Then
  Begin
    {
    We have FOLD,BET,RAISE,CHECK and CALL options.
    First decide to be in or not then decide if to call or raise or bet or check or fold
    .When to fold a hole?
      -if I have to bet beyond my investment limit for a specific hole whether
    }

    {***********See my position is it late middle button early dealer or what*******************************}
   // A := PlayersAfterPlayer(0, Preflop);

    {*****************decide to be in or not***********************}
    //get the odds of winning
    Players[0].WinOdds := GetWinOdds(CardMasks[Hand.iHole1] Or CardMasks[Hand.iHole2], 0, Hand.OpponentsIn[PreFlop]);

    If Players[0].Winodds > (1 / (1 + Hand.OpponentsIn[PreFlop])) Then
      Hand.GoodPreFlopInvestment := True
    Else
      Hand.GoodPreFlopInvestment := False;

    If Hand.GoodPreFlopInvestment Then
      Hand.AllIn
    Else
      Hand.Fold;

    CodeSite.Send('Odds of Winning: ' + FloatToStr(Players[0].WinOdds));

    //get the hand strength
    Players[0].HandStrength := GetHandStrength(CardMasks[Hand.iHole1] Or CardMasks[Hand.iHole2], 0,
      Hand.OpponentsIn[PreFlop]);

    CodeSite.Send('Hand Strength: ' + FloatToStr(Players[0].HandStrength));
  End
  Else
    Hand.Fold;
End;

Procedure PlayRiver;
Begin
End;

Procedure PlayTurn;
Begin
End;

Function ExpectedBet(OurAction: Integer; Opponent: Integer): Integer;
Begin

End;

Function ExpectedReaction(OurAction: Integer; Opponent: Integer): Integer;
Begin

End;

Procedure SetExpectedToRealActionDuo(ExpectedAction: Integer; Opponent: Integer);
Begin

End;

Function IPutOpponentOn(Opponent: Integer): Integer;
Begin

End;

Procedure PlayFlop;
Var
  Winodds, ROI, RISK: Double;
  Foldit, Raiseit, Callit, Checkit: Boolean;
Begin
  //decide how much you want to bet for the winnodss and potential and strength you have
  //for example if the winodds is %90 and the risk is %10 then you may bet %90 of your bankroll
  //Also the amount we bet if we have the nuts should make opponents they should stay in the hand
  //if we have a drawing hand with high winodds then it should let other players leave or stay accroding to the winnodds
  //if we have a pair or a set draw it should be an explorating bet

  //for example if it is a small pot (nobody betting) and you have high card then you may want to bet
  //bet amount by the value of the pot first and by the expected actions of other players
  Winodds := GetWinOdds(CardMasks[Hand.iHole1] Or CardMasks[Hand.iHole2], CardMasks[Hand.iFlop1] Or CardMasks[Hand.iFlop2] Or
    CardMasks[Hand.iFlop3], Hand.OpponentsIn[PreFlop]);
End;

Procedure ShowBetting(Stage: TStage);
Var
  S: String;
  I, Seat, TimesBettingRecorded: Integer;
Begin
  With Hand Do
  Begin
    TimesBettingRecorded := Length(Betting[Stage]);
    For I := 0 To TimesBettingRecorded - 1 Do
    Begin
      S := '';
      For Seat := 0 To 8 Do
      Begin
        S := S + FloatToStr(Betting[Stage, I, Seat]) + ', ';
      End;
      FrmInfo.mmo1.Lines.Add(S);
      FrmInfo.mmo1.Lines.Add('Recorded ' + IntToStr(TimesBettingRecorded) + ' times');
    End;
  End;
End;

Function SomebodyFolded(Stage: TStage): Boolean;
Var
  I: Integer;
Begin
  Result := False;
  For I := 0 To 8 Do
    If (Players[I].WasHoldingJustBefore[Stage]) And (IsPlayerIn(I) = False) And (Players[I].AlreadyFolded[Stage]
      = False) Then
    Begin
      Players[I].AlreadyFolded[Stage] := True;
      Result := True;
      CodeSite.Send('SomeBody Folded');
      Break;
    End;
End;

Function RecordBetting(PreviousPot: Double; Stage: TStage): Double;
Var
  Player, I, FlagLastPlayer: Integer;
  CurrentPot, Bet: Double;
Begin
  FlagLastPlayer := -1;
  WaitForVisibility;
  CurrentPot := GetThePot(PreFlop, False);
  GetPlayersIn(Stage);
  //if pot increased or somebody folds
  If (CurrentPot > PreviousPot) Or SomebodyFolded(Stage) Then
  Begin
    // SetTableBets(Stage);
    For I := 0 To 8 Do
      Begin
        Bet := GetPlayerBets(I);
        If (Players[I].WasHoldingJustBefore[Stage]) And (Not IsPlayerIn(I)) And (Not Players[I].AlreadyFolded[Stage]) Then
        Begin
          If Players[I].LatestBetOfThisPlayer[Stage] > 0 Then
            Players[I].Action[Stage] := FoldAfterInvest Or Players[I].Action[Stage];
          If Hand.LatestBetInStage[Stage] = 0 Then
            Players[I].Action[Stage] := FoldingVersusNil Or Players[I].Action[Stage];
          If Hand.LatestBetInStage[Stage] > 0 Then
            Players[I].Action[Stage] := FoldingVersusBets Or Players[I].Action[Stage];
          Players[I].Folded[Stage] := True;
          Players[I].AlreadyFolded[Stage] := True;
          FlagLastPlayer := I;
        End;
        //if there is a change in the bets of one player we analyze what action happened before him then we set him too
        If (Bet <> Players[I].LatestBetOfThisPlayer[Stage]) And (Not Players[I].Folded[Stage]) Then
        Begin
          Players[I].LatestBetOfThisPlayer[Stage] := Bet;
          Hand.LatestBetInStage[Stage] := Bet;
          If (Bet = Hand.LatestBetInStage[Stage]) Then
          Begin
            If Hand.LatestBetInStage[Stage] = Game.BB Then
              Players[I].Action[Stage] := CallingBet Or Players[I].Action[Stage];
            If Hand.LatestBetInStage[Stage] > Game.BB Then
              Players[I].Action[Stage] := CallingRaise Or Players[I].Action[Stage];
          End;
          If (Bet > Hand.LatestBetInStage[Stage]) Then
          Begin
            If Hand.LatestBetInStage[Stage] = 0 Then
              Players[I].Action[Stage] := Betting Or Players[I].Action[Stage];
            If Hand.LatestBetInStage[Stage] > 0 Then
              Players[I].Action[Stage] := Raising Or Players[I].Action[Stage];
          End;
          FlagLastPlayer := I;
        End;
      End;
    If FlagLastPlayer > 0 Then
      For I := 0 To FlagLastPlayer - 1 Do
      Begin
        If ((Players[I].LatestBetOfThisPlayer[Stage] = 0) And (Not Players[I].Folded[Stage])) Or
          ((Players[I].Action[PreFlop] And PostedBB <> 0) And (Players[I].StageInvestment[PreFlop] = Game.BB) And (Stage =
            PreFlop)) Then
          Players[I].Action[Stage] := Checking Or Players[I].Action[Stage];
      End;
  End;
  Result := CurrentPot;
End;

End.

