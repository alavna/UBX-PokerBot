Unit uHandAnalysis;
{
here in the win odds we will create the 1340 holes and
classify them into premium and trash.suited connectors..connector with 2 apart etcc..
then according to stats on the table we use some of these hole categories in
our calculations
}
Interface
Uses
  Jclcounter, uHashTables, uNewTypes, uGlobalVariables;
Function PocketGroup(pocket: int64): Integer;
Function WhatHand(I: Integer): String;
//Function Hands(shared, dead: int64; numberOfCards: Integer): int64;
Function HandPotential(pocket, board: int64; NOpponents: Integer; duration: Double): TPpotNpot;
Function OldHandPotential(pocket, board: int64; NOpponents: Integer; duration: Double): TPpotNpot;
Function RandomHand(shared, dead: int64; ncards: Integer): int64;
Function GetOldHandStrength(pocket, board: int64; NOpponnents: Integer): Double;
Function GetHandStrength(pocket, board: int64; NOpponnents: Integer): Double;
Function GetWinOdds(pocket, board: int64; numOpponents: Integer): Double;
Function GetOldWinOdds(pocket, board: int64; numOpponents: Integer): Double;
Function Eval7(TheCards: int64; NumberOfCards: Integer): Integer; Inline;
Function Evaluate(TheCards: int64): cardinal; overload;
Function Evaluate(TheCards: int64; NumberOfCards: Integer): cardinal; overload;
Function Card(S: String): int64;
//Function OpponentsMayHave(Stage: TStage; pocket, board: int64): String;
Implementation

Function Card(S: String): int64;
Var
  I: Integer;
Begin
  result := -1;
  For I := 0 To 51 Do
  Begin
    If CardTable[I] = S Then
    Begin
      Result := CardMasks[I];
      Exit;
    End;
  End;
End;

Function PocketGroup(pocket: int64): Integer;
Var
  I, X: Integer;
Begin
  Result := -1;
  For I := 0 To 8 Do
  Begin
    For X := 0 To 792 Do
    Begin
      If pocket = PocketGroups[I, X] Then
      Begin
        Result := I;
        Break;
      End;
    End;
  End;
End;

Function BitCount(bitField: int64): Integer;
Begin
  Result :=
    bits[(bitField And $00000000000000FF)] +
    bits[((bitField And $000000000000FF00) Shr 8)] +
    bits[((bitField And $0000000000FF0000) Shr 16)] +
    bits[((bitField And $00000000FF000000) Shr 24)] +
    bits[((bitField And $000000FF00000000) Shr 32)] +
    bits[((bitField And $0000FF0000000000) Shr 40)] +
    bits[((bitField And $00FF000000000000) Shr 48)] +
    bits[((bitField And $FF00000000000000) Shr 56)];
End;

Function RandomPocket(A: Int64; Dead: int64; B: Integer): int64;
Var
  Pocket: int64;
Begin
  Pocket := 0;
  Repeat
    Pocket := PlayableGroup[Random(534)];
  Until (Dead And Pocket) = 0;
  Result := Pocket;
End;

Function RandomHand(shared, dead: int64; ncards: Integer): int64;
Var
  mask, card, A: int64;
  Count, I: Integer;
Begin
  A := 1;
  mask := shared; //Mask equal the flop 3 cards mask shared
  Count := ncards - BitCount(shared);
  //shared contains the flop 3 cards se we want to randomize only 4 cards:4+3=7
  For I := 0 To Count - 1 Do //generate the four cards
  Begin
    Repeat
      card := (A Shl Random(52));
    Until ((dead Or mask) And card) = 0;
    mask := mask Or card;
  End;
  Result := mask Or shared;
End;

Function OldHandPotential(pocket, board: int64; NOpponents: Integer; duration: Double): TPpotNpot;
Var
  TheResult: TPpotNpot;
  HP: Array[0..2, 0..2] Of Integer;
  Count, ncards: Integer;
  ourbest, ourrank: cardinal;
  opp1Pocket: int64;
  opp1rank: int64;
  index: Integer;
  boardmask: int64;
  opp1best: int64;
  opp2Pocket: int64;
  opp2rank: cardinal;
  opp2best: cardinal;
  TheCounter: TJclCounter;
  opp3Pocket: int64;
  opp3rank: cardinal;
  opp3best: cardinal;
  opp4Pocket: int64;
  opp4rank: cardinal;
  opp4best: cardinal;
  opp5Pocket: int64;
  opp5rank: cardinal;
  opp5best: cardinal;
  opp6Pocket: int64;
  opp6rank: cardinal;
  opp6best: cardinal;
  opp7Pocket: int64;
  opp7rank: cardinal;
  opp7best: cardinal;
  opp8Pocket: int64;
  opp8rank: cardinal;
  opp8best: cardinal;
  opp9Pocket: int64;
  opp9rank: cardinal;
  opp9best: cardinal;
Const
  ahead = 2;
  tied = 1;
  behind = 0;
Begin
  If (BitCount(pocket) < 2) Or (BitCount(board) < 3) Then
  Begin
    TheResult[0] := 1000;
    TheResult[1] := 1000;
    Result := TheResult;
    Exit;
  End;
  StartCount(TheCounter, False);
  Count := 0;
  ncards := BitCount(pocket Or board);
  ourrank := Evaluate(pocket Or board);
  HP[0, 0] := 0;
  HP[0, 1] := 0;
  HP[0, 2] := 0;
  HP[1, 0] := 0;
  HP[1, 1] := 0;
  HP[1, 2] := 0;
  HP[2, 0] := 0;
  HP[2, 1] := 0;
  HP[2, 2] := 0;
  Case NOpponents Of
    1:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do

        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp1rank := Evaluate(opp1Pocket Or board, ncards);

          If (ourrank > opp1rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          If (ourbest > opp1best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    2:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp2Pocket := RandomHand(0, pocket Or board Or opp1Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    3:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp2Pocket := RandomHand(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
             //   count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //   count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    4:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp2Pocket := RandomHand(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    5:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp2Pocket := RandomHand(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    6:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp2Pocket := RandomHand(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp6Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);
          opp6rank := Evaluate(opp6Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) And (ourrank > opp6rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) And (ourrank >= opp6rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket,
            5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          opp6best := Evaluate(opp6Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) And (ourbest > opp6best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) And (ourbest >= opp6best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //   count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    7:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp2Pocket := RandomHand(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp6Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket, 2);
          opp7Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);
          opp6rank := Evaluate(opp6Pocket Or board);
          opp7rank := Evaluate(opp7Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) And (ourrank > opp6rank) And (
            ourrank > opp7rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) And (ourrank >= opp6rank) And (
            ourrank >= opp7rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or
            opp7Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          opp6best := Evaluate(opp6Pocket Or boardmask, 7);
          opp7best := Evaluate(opp7Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) And (ourbest > opp6best) And (
            ourbest > opp7best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) And (ourbest >= opp6best) And (
            ourbest >= opp7best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    8:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp2Pocket := RandomHand(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp6Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket, 2);
          opp7Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket, 2);
          opp8Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or opp7Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);
          opp6rank := Evaluate(opp6Pocket Or board);
          opp7rank := Evaluate(opp7Pocket Or board);
          opp8rank := Evaluate(opp8Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) And (ourrank > opp6rank) And (
            ourrank > opp7rank) And (ourrank > opp8rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) And (ourrank >= opp6rank) And (
            ourrank >= opp7rank) And (ourrank >= opp8rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or
            opp7Pocket Or opp8Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          opp6best := Evaluate(opp6Pocket Or boardmask, 7);
          opp7best := Evaluate(opp7Pocket Or boardmask, 7);
          opp8best := Evaluate(opp8Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) And (ourbest > opp6best) And (
            ourbest > opp7best) And (ourbest > opp8best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) And (ourbest >= opp6best) And (
            ourbest >= opp7best) And (ourbest >= opp8best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    9:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomHand(0, pocket Or board, 2);
          opp2Pocket := RandomHand(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp6Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket, 2);
          opp7Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket, 2);
          opp8Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or opp7Pocket, 2);
          opp9Pocket := RandomHand(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or opp7Pocket Or opp8Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);
          opp6rank := Evaluate(opp6Pocket Or board);
          opp7rank := Evaluate(opp7Pocket Or board);
          opp8rank := Evaluate(opp8Pocket Or board);
          opp9rank := Evaluate(opp9Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) And (ourrank > opp6rank) And (
            ourrank > opp7rank) And (ourrank > opp8rank) And (
            ourrank > opp9rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) And (ourrank >= opp6rank) And (
            ourrank >= opp7rank) And (ourrank >= opp8rank) And (
            ourrank >= opp9rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or
            opp7Pocket Or opp8Pocket Or opp9Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          opp6best := Evaluate(opp6Pocket Or boardmask, 7);
          opp7best := Evaluate(opp7Pocket Or boardmask, 7);
          opp8best := Evaluate(opp8Pocket Or boardmask, 7);
          opp9best := Evaluate(opp9Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) And (ourbest > opp6best) And (
            ourbest > opp7best) And (ourbest > opp8best) And (
            ourbest > opp9best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) And (ourbest >= opp6best) And (
            ourbest >= opp7best) And (ourbest >= opp8best) And (
            ourbest >= opp9best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;

  End;

  //while (TheCounter.RunElapsedTime) < duration do
  //  begin
  //    opp1Pocket := RandomHand(0, pocket or board, 2); //first get a random pocket for the the first opponent
  //    opp1rank := Evaluate(opp1Pocket or board, ncards); //rank it 5 cards
  //    if (ourrank > opp1rank) then
  //    begin
  //      index := ahead;
  //    end
  //    else if (ourrank >= opp1rank) then
  //    begin
  //      index := tied;
  //    end
  //    else
  //    begin
  //      index := behind;
  //    end;
  //
  //    boardmask := RandomHand(board, pocket or opp1Pocket, 5);
  //    ourbest := Evaluate(pocket or boardmask, 7);
  //    opp1best := Evaluate(opp1Pocket or boardmask, 7);
  //    if (ourbest > opp1best) then
  //    begin
  //      HP[index, ahead] := HP[index, ahead] + 1;
  //    end
  //    else if (ourbest >= opp1best) then
  //    begin
  //      HP[index, tied] := HP[index, tied] + 1;
  //    end
  //    else
  //    begin
  //      HP[index, behind] := HP[index, behind] + 1;
  //    end;
  //    count := count + 1;
  //  end;

  StopCount(TheCounter);
  TheResult[0] := (HP[behind, ahead] + (HP[behind, tied] / 2) + (HP[tied, ahead] / 2)) / (Count);
  TheResult[1] := (HP[ahead, behind] + (HP[ahead, tied] / 2) + (HP[tied, behind] / 2)) / (Count);
  Result := TheResult;
End;

Function GetOldHandStrength(pocket, board: int64; NOpponnents: Integer): Double;
Var
  win, Count: Double;
  ourrank: cardinal;
  oppcards: int64;
  opprank: cardinal;
  opp1cards: int64;
  opp2cards: int64;
  opp1rank: cardinal;
  opp2rank: cardinal;
  opp3cards: int64;
  opp3rank: cardinal;
  opp4cards: int64;
  opp4rank: cardinal;
  opp5cards: int64;
  opp5rank: cardinal;
  opp6cards: int64;
  opp6rank: cardinal;
  opp7cards: int64;
  opp7rank: cardinal;
  opp8cards: int64;
  opp8rank: cardinal;
  opp9cards: int64;
  opp9rank: cardinal;
Begin
  Result := 0;
  win := 0.0;
  Count := 0.0;
  ourrank := Evaluate(pocket Or board);
  Case NOpponnents Of
    1:
      Begin
        While Count < MontecarloCount Do
        Begin
          oppcards := RandomHand(0, pocket Or board, 2);
          opprank := Evaluate(oppcards Or board);
          If (ourrank > opprank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank = opprank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
    2:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomHand(0, pocket Or board, 2);
          opp2cards := RandomHand(0, pocket Or board Or opp1cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    3:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomHand(0, pocket Or board, 2);
          opp2cards := RandomHand(0, pocket Or board Or opp1cards, 2);
          opp3cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    4:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomHand(0, pocket Or board, 2);
          opp2cards := RandomHand(0, pocket Or board Or opp1cards, 2);
          opp3cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or
            opp3cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    5:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomHand(0, pocket Or board, 2);
          opp2cards := RandomHand(0, pocket Or board Or opp1cards, 2);
          opp3cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or
            opp3cards, 2);
          opp5cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or opp4cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    6:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomHand(0, pocket Or board, 2);
          opp2cards := RandomHand(0, pocket Or board Or opp1cards, 2);
          opp3cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or
            opp3cards, 2);
          opp5cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or opp4cards, 2);
          opp6cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);
          opp6rank := Evaluate(opp6cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) And (ourrank > opp6rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) And
            (ourrank >= opp6rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
    7:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomHand(0, pocket Or board, 2);
          opp2cards := RandomHand(0, pocket Or board Or opp1cards, 2);
          opp3cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or
            opp3cards, 2);
          opp5cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or opp4cards, 2);
          opp6cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards, 2);
          opp7cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards Or opp6cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);
          opp6rank := Evaluate(opp6cards Or board);
          opp7rank := Evaluate(opp7cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) And (ourrank > opp6rank) And
            (ourrank > opp7rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) And
            (ourrank >= opp6rank) And (ourrank >= opp7rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
    8:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomHand(0, pocket Or board, 2);
          opp2cards := RandomHand(0, pocket Or board Or opp1cards, 2);
          opp3cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or
            opp3cards, 2);
          opp5cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or opp4cards, 2);
          opp6cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards, 2);
          opp7cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards Or opp6cards, 2);
          opp8cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards Or opp6cards Or opp7cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);
          opp6rank := Evaluate(opp6cards Or board);
          opp7rank := Evaluate(opp7cards Or board);
          opp8rank := Evaluate(opp8cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) And (ourrank > opp6rank) And
            (ourrank > opp7rank) And (ourrank > opp8rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) And
            (ourrank >= opp6rank) And (ourrank >= opp7rank) And
            (ourrank >= opp8rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
    9:
      Begin

        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomHand(0, pocket Or board, 2);
          opp2cards := RandomHand(0, pocket Or board Or opp1cards, 2);
          opp3cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or
            opp3cards, 2);
          opp5cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or opp4cards, 2);
          opp6cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards, 2);
          opp7cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards Or opp6cards, 2);
          opp8cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards Or opp6cards Or opp7cards, 2);
          opp9cards :=
            RandomHand(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards Or opp6cards Or opp7cards Or opp8cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);
          opp6rank := Evaluate(opp6cards Or board);
          opp7rank := Evaluate(opp7cards Or board);
          opp8rank := Evaluate(opp8cards Or board);
          opp9rank := Evaluate(opp9cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) And (ourrank > opp6rank) And
            (ourrank > opp7rank) And (ourrank > opp8rank) And
            (ourrank > opp9rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) And
            (ourrank >= opp6rank) And (ourrank >= opp7rank) And
            (ourrank >= opp8rank) And (ourrank >= opp9rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
  End;
  If Count > 0 Then
    Result := win / Count;
End;

Function GetOldWinOdds(pocket, board: int64; numOpponents: Integer): Double;
Var
  win, Count, tie, lose: Double;
  boardmask, opp1, opp2, opp3, opp4, opp5, opp6, opp7, opp8, opp9: int64;
  playerHandVal, opp1HandVal, opp2HandVal, opp3HandVal, opp4HandVal,
    opp5HandVal, opp6HandVal, opp7HandVal, opp8HandVal,
    opp9HandVal: cardinal;
  //include the dead cards by oring with the pocket
Begin
  Result := 0;
  win := 0;
  tie := 0;
  lose := 0;
  Count := 0;
  Case numOpponents Of
    1:
      Begin
        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          Count := Count + 1;
          If (playerHandVal > opp1HandVal) Then
            win := win + 1
          Else If (playerHandVal = opp1HandVal) Then
            tie := tie + 1
          Else
            lose := lose + 1;
        End;
        Result := (win + tie / 2.0) / (win + tie + lose);
        Exit;
      End;
    2:
      Begin

        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          opp2 := RandomHand(0, pocket Or boardmask Or opp1, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    3:
      Begin

        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          opp2 := RandomHand(0, pocket Or boardmask Or opp1, 2);
          opp3 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;

    4:
      Begin
        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          opp2 := RandomHand(0, pocket Or boardmask Or opp1, 2);
          opp3 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2, 2);
          opp4 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    5:
      Begin
        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          opp2 := RandomHand(0, pocket Or boardmask Or opp1, 2);
          opp3 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2, 2);
          opp4 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    6:
      Begin
        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          opp2 := RandomHand(0, pocket Or boardmask Or opp1, 2);
          opp3 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2, 2);
          opp4 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4, 2);
          opp6 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);
          opp6HandVal := Eval7(opp6 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) And (playerHandVal >
            opp6HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) And (playerHandVal
            >= opp6HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    7:
      Begin
        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          opp2 := RandomHand(0, pocket Or boardmask Or opp1, 2);
          opp3 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2, 2);
          opp4 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4, 2);
          opp6 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5, 2);
          opp7 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5 Or opp6, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);
          opp6HandVal := Eval7(opp6 Or boardmask, 7);
          opp7HandVal := Eval7(opp7 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) And (playerHandVal >
            opp6HandVal) And (playerHandVal > opp7HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) And (playerHandVal
            >= opp6HandVal) And (playerHandVal >= opp7HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    8:
      Begin
        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          opp2 := RandomHand(0, pocket Or boardmask Or opp1, 2);
          opp3 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2, 2);
          opp4 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4, 2);
          opp6 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5, 2);
          opp7 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5 Or opp6, 2);
          opp8 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5 Or opp6 Or opp7, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);
          opp6HandVal := Eval7(opp6 Or boardmask, 7);
          opp7HandVal := Eval7(opp7 Or boardmask, 7);
          opp8HandVal := Eval7(opp8 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) And (playerHandVal >
            opp6HandVal) And (playerHandVal > opp7HandVal) And (playerHandVal >
            opp8HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) And (playerHandVal
            >= opp6HandVal) And (playerHandVal >= opp7HandVal) And (playerHandVal
            >= opp8HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    9:
      Begin
        While Count < MontecarloCount Do
        Begin
          boardmask := RandomHand(board, pocket, 5);
          opp1 := RandomHand(0, pocket Or boardmask, 2);
          opp2 := RandomHand(0, pocket Or boardmask Or opp1, 2);
          opp3 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2, 2);
          opp4 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4, 2);
          opp6 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5, 2);
          opp7 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5 Or opp6, 2);
          opp8 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5 Or opp6 Or opp7, 2);
          opp9 := RandomHand(0, pocket Or boardmask Or opp1 Or opp2 Or opp3 Or
            opp4 Or opp5 Or opp6 Or opp7 Or opp8, 2);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);
          opp6HandVal := Eval7(opp6 Or boardmask, 7);
          opp7HandVal := Eval7(opp7 Or boardmask, 7);
          opp8HandVal := Eval7(opp8 Or boardmask, 7);
          opp9HandVal := Eval7(opp9 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) And (playerHandVal >
            opp6HandVal) And (playerHandVal > opp7HandVal) And (playerHandVal >
            opp8HandVal) And (playerHandVal > opp9HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) And (playerHandVal
            >= opp6HandVal) And (playerHandVal >= opp7HandVal) And (playerHandVal
            >= opp8HandVal) And (playerHandVal >=
            opp9HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;
  End;
  If Count > 0 Then
    Result := (win) / (Count);

End;

Function GetWinOdds(pocket, board: int64; numOpponents: Integer): Double;
Var
  win, Count, tie, lose: Double;
  boardmask, opp1, opp2, opp3, opp4, opp5, opp6, opp7, opp8, opp9: int64;
  playerHandVal, opp1HandVal, opp2HandVal, opp3HandVal, opp4HandVal,
    opp5HandVal, opp6HandVal, opp7HandVal, opp8HandVal,
    opp9HandVal: cardinal;
  //include the dead cards by oring with the pocket
Begin
  Result := 0;
  win := 0;
  tie := 0;
  lose := 0;
  Count := 0;
  Case numOpponents Of
    1:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          boardmask := RandomHand(board, opp1 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          Count := Count + 1;
          If (playerHandVal > opp1HandVal) Then
            win := win + 1
          Else If (playerHandVal = opp1HandVal) Then
            tie := tie + 1
          Else
            lose := lose + 1;
        End;
        Result := (win + tie / 2.0) / (win + tie + lose);
        Exit;
      End;
    2:
      Begin

        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          opp2 := RandomPocket(0, pocket Or board Or opp1, 2);
          boardmask := RandomHand(board, opp1 Or opp2 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    3:
      Begin

        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          opp2 := RandomPocket(0, pocket Or board Or opp1, 2);
          opp3 := RandomPocket(0, pocket Or board Or opp1 Or opp2, 2);
          boardmask := RandomHand(board, opp1 Or opp2 Or opp3 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;

    4:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          opp2 := RandomPocket(0, pocket Or board Or opp1, 2);
          opp3 := RandomPocket(0, pocket Or board Or opp1 Or opp2, 2);
          opp4 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3, 2);
          boardmask := RandomHand(board, opp1 Or opp2 Or opp3 Or opp4 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    5:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          opp2 := RandomPocket(0, pocket Or board Or opp1, 2);
          opp3 := RandomPocket(0, pocket Or board Or opp1 Or opp2, 2);
          opp4 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4, 2);
          boardmask := RandomHand(board, opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    6:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          opp2 := RandomPocket(0, pocket Or board Or opp1, 2);
          opp3 := RandomPocket(0, pocket Or board Or opp1 Or opp2, 2);
          opp4 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4, 2);
          opp6 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5, 2);
          boardmask := RandomHand(board, opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);
          opp6HandVal := Eval7(opp6 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) And (playerHandVal >
            opp6HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) And (playerHandVal
            >= opp6HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    7:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          opp2 := RandomPocket(0, pocket Or board Or opp1, 2);
          opp3 := RandomPocket(0, pocket Or board Or opp1 Or opp2, 2);
          opp4 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4, 2);
          opp6 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5, 2);
          opp7 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6, 2);
          boardmask := RandomHand(board, opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6 Or opp7 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);
          opp6HandVal := Eval7(opp6 Or boardmask, 7);
          opp7HandVal := Eval7(opp7 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) And (playerHandVal >
            opp6HandVal) And (playerHandVal > opp7HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) And (playerHandVal
            >= opp6HandVal) And (playerHandVal >= opp7HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    8:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          opp2 := RandomPocket(0, pocket Or board Or opp1, 2);
          opp3 := RandomPocket(0, pocket Or board Or opp1 Or opp2, 2);
          opp4 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4, 2);
          opp6 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5, 2);
          opp7 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6, 2);
          opp8 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6 Or opp7, 2);
          boardmask := RandomHand(board, opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6 Or opp7 Or opp8 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);
          opp6HandVal := Eval7(opp6 Or boardmask, 7);
          opp7HandVal := Eval7(opp7 Or boardmask, 7);
          opp8HandVal := Eval7(opp8 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) And (playerHandVal >
            opp6HandVal) And (playerHandVal > opp7HandVal) And (playerHandVal >
            opp8HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) And (playerHandVal
            >= opp6HandVal) And (playerHandVal >= opp7HandVal) And (playerHandVal
            >= opp8HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;

    9:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1 := RandomPocket(0, pocket Or board, 2);
          opp2 := RandomPocket(0, pocket Or board Or opp1, 2);
          opp3 := RandomPocket(0, pocket Or board Or opp1 Or opp2, 2);
          opp4 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3, 2);
          opp5 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4, 2);
          opp6 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5, 2);
          opp7 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6, 2);
          opp8 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6 Or opp7, 2);
          opp9 := RandomPocket(0, pocket Or board Or opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6 Or opp7 Or opp8, 2);
          boardmask := RandomHand(board, opp1 Or opp2 Or opp3 Or opp4 Or opp5 Or opp6 Or opp7 Or opp8 Or opp9 Or pocket, 5);
          playerHandVal := Eval7(pocket Or boardmask, 7);
          opp1HandVal := Eval7(opp1 Or boardmask, 7);
          opp2HandVal := Eval7(opp2 Or boardmask, 7);
          opp3HandVal := Eval7(opp3 Or boardmask, 7);
          opp4HandVal := Eval7(opp4 Or boardmask, 7);
          opp5HandVal := Eval7(opp5 Or boardmask, 7);
          opp6HandVal := Eval7(opp6 Or boardmask, 7);
          opp7HandVal := Eval7(opp7 Or boardmask, 7);
          opp8HandVal := Eval7(opp8 Or boardmask, 7);
          opp9HandVal := Eval7(opp9 Or boardmask, 7);

          If (playerHandVal > opp1HandVal) And (playerHandVal > opp2HandVal) And
            (
            playerHandVal > opp3HandVal) And (playerHandVal > opp4HandVal) And
            (playerHandVal > opp5HandVal) And (playerHandVal >
            opp6HandVal) And (playerHandVal > opp7HandVal) And (playerHandVal >
            opp8HandVal) And (playerHandVal > opp9HandVal) Then
          Begin
            win := win + 1;
          End
          Else If (playerHandVal >= opp1HandVal) And (playerHandVal >=
            opp2HandVal) And (
            playerHandVal >= opp3HandVal) And (playerHandVal >= opp4HandVal) And
            (playerHandVal >= opp5HandVal) And (playerHandVal
            >= opp6HandVal) And (playerHandVal >= opp7HandVal) And (playerHandVal
            >= opp8HandVal) And (playerHandVal >=
            opp9HandVal) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1.0;

        End;
      End;
  End;
  If Count > 0 Then
    Result := (win) / (Count);

End;

Function Evaluate(TheCards: int64): cardinal; Overload;
Begin
  Result := Eval7(TheCards, BitCount(TheCards));
End;

Function Evaluate(TheCards: int64; NumberOfCards: Integer): cardinal; Overload;
Begin
  Result := Eval7(TheCards, NumberOfCards);
End;

Function Eval7(TheCards: int64; NumberOfCards: Integer): Integer; Inline;
Var
  SC, SH, SD, SS, n_dups, n_ranks, ranks, st, T, kickers, Top, second,
    tc, retval, four_mask, three_mask, two_mask: Integer;
Begin
  retval := 0;
  SC := (TheCards Shr 0) And $1FFF;
  SD := (TheCards Shr 13) And $1FFF;
  SH := (TheCards Shr 26) And $1FFF;
  SS := (TheCards Shr 39) And $1FFF;

  ranks := SC Or SD Or SH Or SS;
  n_ranks := nBitsTable[ranks];
  n_dups := NumberOfCards - n_ranks;
  If n_ranks >= 5 Then
  Begin
    If nBitsTable[SS] >= 5 Then
    Begin
      If (straightTable[SS] <> 0) Then
      Begin
        Result := 134217728 + (straightTable[SS] Shl 16);
        Exit;
      End
      Else
      Begin
        retval := 83886080 + topFiveCardsTable[SS];
      End;
    End

    Else If (nBitsTable[SC] >= 5) Then
    Begin
      If (straightTable[SC] <> 0) Then
      Begin
        Result := 134217728 + (straightTable[SC] Shl 16);
        Exit;
      End
      Else
      Begin
        retval := 83886080 + topFiveCardsTable[SC];
      End;
    End
    Else If (nBitsTable[SD] >= 5) Then
    Begin
      If (straightTable[SD] <> 0) Then
      Begin
        Result := 134217728 + (straightTable[SD] Shl 16);
        Exit;
      End
      Else
      Begin
        retval := 83886080 + topFiveCardsTable[SD];
      End;
    End
    Else If (nBitsTable[SH] >= 5) Then
    Begin
      If (straightTable[SH] <> 0) Then
      Begin
        Result := 134217728 + (straightTable[SH] Shl 16);
        Exit;
      End
      Else
      Begin
        retval := 83886080 + topFiveCardsTable[SH];
      End;
    End
    Else
    Begin
      st := straightTable[ranks];
      If (st <> 0) Then
      Begin
        retval := 67108864 + (st Shl 16);
      End;
    End;
    If (retval <> 0) And (n_dups < 3) Then
    Begin
      Result := retval;
      Exit;
    End;
  End;

  Case n_dups Of
    0:
      Begin
        Result := 0 + topFiveCardsTable[ranks];
        Exit;
      End;
    1:
      Begin
        two_mask := ranks Xor (SC Xor SD Xor SH Xor SS);
        retval := (16777216 + (topCardTable[two_mask] Shl 16));
        T := ranks Xor two_mask;
        kickers := (topFiveCardsTable[T] Shr 4) And Not $F;
        retval := retval + kickers;
        Result := retval;
      End;

    2:
      Begin
        two_mask := ranks Xor (SC Xor SD Xor SH Xor SS);
        If (two_mask <> 0) Then
        Begin
          T := ranks Xor two_mask;
          retval := (33554432 +
            (topFiveCardsTable[two_mask] And ($000F0000 Or $0000F000)) +
            (topCardTable[T] Shl 8));
          Result := retval;
          Exit;
        End
        Else
        Begin
          three_mask := ((SC And SD) Or (SH And SS)) And ((SC And SH) Or (SD And
            SS));
          retval := (50331648 + (topCardTable[three_mask] Shl 16));
          T := ranks Xor three_mask;
          second := topCardTable[T];
          retval := retval + (second Shl 12);
          T := T Xor (1 Shl second);
          retval := retval + (topCardTable[T] Shl 8);
          Result := retval;
        End;
      End
  Else
    Begin
      four_mask := SH And SD And SC And SS;
      If (four_mask <> 0) Then
      Begin
        tc := topCardTable[four_mask];
        retval := (117440512 + (tc Shl 16) +
          ((topCardTable[ranks Xor (1 Shl tc)]) Shl 12));
        Result := retval;
        Exit;
      End;

      two_mask := ranks Xor (SC Xor SD Xor SH Xor SS);
      If (nBitsTable[two_mask] <> n_dups) Then
      Begin
        three_mask := ((SC And SD) Or (SH And SS)) And ((SC And SH) Or (SD And
          SS));
        retval := 100663296;
        tc := topCardTable[three_mask];
        retval := retval + (tc Shl 16);
        T := (two_mask Or three_mask) Xor (1 Shl tc);
        retval := retval + (topCardTable[T] Shl 12);
        Result := retval;
      End;

      If (retval <> 0) Then
      Begin
        Result := retval;
        Exit;
      End
      Else
      Begin
        retval := 33554432;
        Top := topCardTable[two_mask];
        retval := retval + (Top Shl 16);
        second := topCardTable[two_mask Xor (1 Shl Top)];
        retval := retval + (second Shl 12);
        retval := retval + ((topCardTable[ranks Xor (1 Shl Top) Xor
          (1 Shl second)]) Shl 8);
        Result := retval;
        Exit;
      End;
      Exit;
    End;
  End;
End;

Function HandType(I: Integer): Integer;
Begin
  Result := I Shr 24;
End;

//Function Hands(shared, dead: int64; numberOfCards: Integer): int64;
//Var
//  A, B, C, D, E, F, G, Caso: Integer;
//  _card1, _card2, _card3, _card4, _card5, _card6, _card7: int64;
//  _n2, _n3, _n4, _n5, _n6: int64;
//Const
//  CardMasksTableSize: Integer = 52;
//Begin
//  dead := dead Or shared;
//  Caso := (numberOfCards - BitCount(shared));
//  Case Caso Of
//    7:
//      Begin
//        For A := 0 To CardMasksTableSize - 7 Do
//        Begin
//          _card1 := CardMasksTable[A];
//          If ((dead And _card1) = 0) Then //if card1 is not a dead card
//          Begin
//            For B := A + 1 To CardMasksTableSize - 6 Do
//            Begin
//              _card2 := CardMasksTable[B];
//              If ((dead And _card2) = 0) Then
//              Begin
//                _n2 := _card1 Or _card2;
//                For C := B + 1 To CardMasksTableSize - 5 Do
//                Begin
//                  _card3 := CardMasksTable[C];
//                  If ((dead And _card3) = 0) Then
//                  Begin
//                    _n3 := _n2 Or _card3;
//                    For D := C + 1 To CardMasksTableSize - 4 Do
//                    Begin
//                      _card4 := CardMasksTable[D];
//                      If ((dead And _card4) = 0) Then
//                      Begin
//                        _n4 := _n3 Or _card4;
//                        For E := D + 1 To CardMasksTableSize - 3 Do
//                        Begin
//                          _card5 := CardMasksTable[E];
//                          If ((dead And _card5) = 0) Then
//                          Begin
//                            _n5 := _n4 Or _card5;
//                            For F := E + 1 To CardMasksTableSize - 2 Do
//                            Begin
//                              _card6 := CardMasksTable[F];
//                              If ((dead And _card6) = 0) Then
//                              Begin
//                                _n6 := _n5 Or _card6;
//                                For G := F + 1 To CardMasksTableSize - 1 Do
//                                Begin
//                                  _card7 := CardMasksTable[G];
//                                  If ((dead And _card7) = 0) Then
//                                  Begin
//                                    Result := _n6 Or _card7 Or shared;
//                                  End;
//                                End;
//                              End;
//                            End;
//                          End;
//                        End;
//                      End;
//                    End;
//                  End;
//                End;
//              End;
//            End;
//          End;
//        End;
//      End;
//  End;
//
//End;

Function GetHandStrength(pocket, board: int64; NOpponnents: Integer): Double;
Var
  win, Count: Double;
  ourrank: cardinal;
  oppcards: int64;
  opprank: cardinal;
  opp1cards: int64;
  opp2cards: int64;
  opp1rank: cardinal;
  opp2rank: cardinal;
  opp3cards: int64;
  opp3rank: cardinal;
  opp4cards: int64;
  opp4rank: cardinal;
  opp5cards: int64;
  opp5rank: cardinal;
  opp6cards: int64;
  opp6rank: cardinal;
  opp7cards: int64;
  opp7rank: cardinal;
  opp8cards: int64;
  opp8rank: cardinal;
  opp9cards: int64;
  opp9rank: cardinal;
Begin
  Result := 0;
  win := 0.0;
  Count := 0.0;
  ourrank := Evaluate(pocket Or board);
  Case NOpponnents Of
    1:
      Begin
        While Count < MontecarloCount Do
        Begin
          oppcards := RandomPocket(0, pocket Or board, 2);
          opprank := Evaluate(oppcards Or board);
          If (ourrank > opprank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank = opprank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
    2:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomPocket(0, pocket Or board, 2);
          opp2cards := RandomPocket(0, pocket Or board Or opp1cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    3:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomPocket(0, pocket Or board, 2);
          opp2cards := RandomPocket(0, pocket Or board Or opp1cards, 2);
          opp3cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    4:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomPocket(0, pocket Or board, 2);
          opp2cards := RandomPocket(0, pocket Or board Or opp1cards, 2);
          opp3cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    5:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomPocket(0, pocket Or board, 2);
          opp2cards := RandomPocket(0, pocket Or board Or opp1cards, 2);
          opp3cards :=
            RandomPocket(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards :=
            RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or
            opp3cards, 2);
          opp5cards :=
            RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or opp4cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;

        End;
      End;
    6:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomPocket(0, pocket Or board, 2);
          opp2cards := RandomPocket(0, pocket Or board Or opp1cards, 2);
          opp3cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards, 2);
          opp5cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards, 2);
          opp6cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards Or opp5cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);
          opp6rank := Evaluate(opp6cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) And (ourrank > opp6rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) And
            (ourrank >= opp6rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
    7:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomPocket(0, pocket Or board, 2);
          opp2cards := RandomPocket(0, pocket Or board Or opp1cards, 2);
          opp3cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards, 2);
          opp5cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards, 2);
          opp6cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards Or opp5cards, 2);
          opp7cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards Or opp5cards Or
            opp6cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);
          opp6rank := Evaluate(opp6cards Or board);
          opp7rank := Evaluate(opp7cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) And (ourrank > opp6rank) And
            (ourrank > opp7rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) And
            (ourrank >= opp6rank) And (ourrank >= opp7rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
    8:
      Begin
        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomPocket(0, pocket Or board, 2);
          opp2cards := RandomPocket(0, pocket Or board Or opp1cards, 2);
          opp3cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards, 2);
          opp5cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards, 2);
          opp6cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards Or opp5cards, 2);
          opp7cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards Or opp5cards Or
            opp6cards, 2);
          opp8cards :=
            RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards
            Or
            opp4cards Or opp5cards Or opp6cards Or opp7cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);
          opp6rank := Evaluate(opp6cards Or board);
          opp7rank := Evaluate(opp7cards Or board);
          opp8rank := Evaluate(opp8cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) And (ourrank > opp6rank) And
            (ourrank > opp7rank) And (ourrank > opp8rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) And
            (ourrank >= opp6rank) And (ourrank >= opp7rank) And
            (ourrank >= opp8rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
    9:
      Begin

        While Count < MontecarloCount Do
        Begin
          opp1cards := RandomPocket(0, pocket Or board, 2);
          opp2cards := RandomPocket(0, pocket Or board Or opp1cards, 2);
          opp3cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards, 2);
          opp4cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards, 2);
          opp5cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards, 2);
          opp6cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or opp4cards Or opp5cards, 2);
          opp7cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or
            opp4cards Or opp5cards Or opp6cards, 2);
          opp8cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or
            opp4cards Or opp5cards Or opp6cards Or opp7cards, 2);
          opp9cards := RandomPocket(0, pocket Or board Or opp1cards Or opp2cards Or opp3cards Or
            opp4cards Or opp5cards Or opp6cards Or opp7cards Or opp8cards, 2);
          opp1rank := Evaluate(opp1cards Or board);
          opp2rank := Evaluate(opp2cards Or board);
          opp3rank := Evaluate(opp3cards Or board);
          opp4rank := Evaluate(opp4cards Or board);
          opp5rank := Evaluate(opp5cards Or board);
          opp6rank := Evaluate(opp6cards Or board);
          opp7rank := Evaluate(opp7cards Or board);
          opp8rank := Evaluate(opp8cards Or board);
          opp9rank := Evaluate(opp9cards Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And
            (ourrank > opp3rank) And (ourrank > opp4rank) And
            (ourrank > opp5rank) And (ourrank > opp6rank) And
            (ourrank > opp7rank) And (ourrank > opp8rank) And
            (ourrank > opp9rank) Then
          Begin
            win := win + 1;
          End
          Else If (ourrank >= opp1rank) And
            (ourrank >= opp2rank) And (ourrank >= opp3rank) And
            (ourrank >= opp4rank) And (ourrank >= opp5rank) And
            (ourrank >= opp6rank) And (ourrank >= opp7rank) And
            (ourrank >= opp8rank) And (ourrank >= opp9rank) Then
          Begin
            win := win + 0.5;
          End;
          Count := Count + 1;
        End;
      End;
  End;
  If Count > 0 Then
    Result := win / Count;
End;

Function HandPotential(pocket, board: int64; NOpponents: Integer; duration: Double): TPpotNpot;
Var
  TheResult: TPpotNpot;
  HP: Array[0..2, 0..2] Of Integer;
  Count, ncards: Integer;
  ourbest, ourrank: cardinal;
  opp1Pocket: int64;
  opp1rank: int64;
  index: Integer;
  boardmask: int64;
  opp1best: int64;
  opp2Pocket: int64;
  opp2rank: cardinal;
  opp2best: cardinal;
  TheCounter: TJclCounter;
  opp3Pocket: int64;
  opp3rank: cardinal;
  opp3best: cardinal;
  opp4Pocket: int64;
  opp4rank: cardinal;
  opp4best: cardinal;
  opp5Pocket: int64;
  opp5rank: cardinal;
  opp5best: cardinal;
  opp6Pocket: int64;
  opp6rank: cardinal;
  opp6best: cardinal;
  opp7Pocket: int64;
  opp7rank: cardinal;
  opp7best: cardinal;
  opp8Pocket: int64;
  opp8rank: cardinal;
  opp8best: cardinal;
  opp9Pocket: int64;
  opp9rank: cardinal;
  opp9best: cardinal;
Const
  ahead = 2;
  tied = 1;
  behind = 0;
Begin
  If (BitCount(pocket) < 2) Or (BitCount(board) < 3) Then
  Begin
    TheResult[0] := 1000;
    TheResult[1] := 1000;
    Result := TheResult;
    Exit;
  End;
  StartCount(TheCounter, False);
  Count := 0;
  ncards := BitCount(pocket Or board);
  ourrank := Evaluate(pocket Or board);
  HP[0, 0] := 0;
  HP[0, 1] := 0;
  HP[0, 2] := 0;
  HP[1, 0] := 0;
  HP[1, 1] := 0;
  HP[1, 2] := 0;
  HP[2, 0] := 0;
  HP[2, 1] := 0;
  HP[2, 2] := 0;
  Case NOpponents Of
    1:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do

        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp1rank := Evaluate(opp1Pocket Or board, ncards);

          If (ourrank > opp1rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          If (ourbest > opp1best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    2:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp2Pocket := RandomPocket(0, pocket Or board Or opp1Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    3:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp2Pocket := RandomPocket(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
             //   count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //   count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    4:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp2Pocket := RandomPocket(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    5:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp2Pocket := RandomPocket(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    6:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp2Pocket := RandomPocket(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp6Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket,
            2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);
          opp6rank := Evaluate(opp6Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) And (ourrank > opp6rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) And (ourrank >= opp6rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket,
            5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          opp6best := Evaluate(opp6Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) And (ourbest > opp6best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) And (ourbest >= opp6best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //   count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    7:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp2Pocket := RandomPocket(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp6Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket,
            2);
          opp7Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);
          opp6rank := Evaluate(opp6Pocket Or board);
          opp7rank := Evaluate(opp7Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) And (ourrank > opp6rank) And (
            ourrank > opp7rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) And (ourrank >= opp6rank) And (
            ourrank >= opp7rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or
            opp7Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          opp6best := Evaluate(opp6Pocket Or boardmask, 7);
          opp7best := Evaluate(opp7Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) And (ourbest > opp6best) And (
            ourbest > opp7best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) And (ourbest >= opp6best) And (
            ourbest >= opp7best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    8:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp2Pocket := RandomPocket(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp6Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket,
            2);
          opp7Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket, 2);
          opp8Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or opp7Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);
          opp6rank := Evaluate(opp6Pocket Or board);
          opp7rank := Evaluate(opp7Pocket Or board);
          opp8rank := Evaluate(opp8Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) And (ourrank > opp6rank) And (
            ourrank > opp7rank) And (ourrank > opp8rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) And (ourrank >= opp6rank) And (
            ourrank >= opp7rank) And (ourrank >= opp8rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or
            opp7Pocket Or opp8Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          opp6best := Evaluate(opp6Pocket Or boardmask, 7);
          opp7best := Evaluate(opp7Pocket Or boardmask, 7);
          opp8best := Evaluate(opp8Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) And (ourbest > opp6best) And (
            ourbest > opp7best) And (ourbest > opp8best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) And (ourbest >= opp6best) And (
            ourbest >= opp7best) And (ourbest >= opp8best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;
    9:
      Begin
        While (TheCounter.RunElapsedTime) < duration Do
        Begin
          opp1Pocket := RandomPocket(0, pocket Or board, 2);
          opp2Pocket := RandomPocket(0, pocket Or board Or opp1Pocket, 2);
          opp3Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket, 2);
          opp4Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket, 2);
          opp5Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket, 2);
          opp6Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket,
            2);
          opp7Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket, 2);
          opp8Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or opp7Pocket, 2);
          opp9Pocket := RandomPocket(0, pocket Or board Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or opp7Pocket Or opp8Pocket, 2);
          opp1rank := Evaluate(opp1Pocket Or board);
          opp2rank := Evaluate(opp2Pocket Or board);
          opp3rank := Evaluate(opp3Pocket Or board);
          opp4rank := Evaluate(opp4Pocket Or board);
          opp5rank := Evaluate(opp5Pocket Or board);
          opp6rank := Evaluate(opp6Pocket Or board);
          opp7rank := Evaluate(opp7Pocket Or board);
          opp8rank := Evaluate(opp8Pocket Or board);
          opp9rank := Evaluate(opp9Pocket Or board);

          If (ourrank > opp1rank) And (ourrank > opp2rank) And (
            ourrank > opp3rank) And (ourrank > opp4rank) And (
            ourrank > opp5rank) And (ourrank > opp6rank) And (
            ourrank > opp7rank) And (ourrank > opp8rank) And (
            ourrank > opp9rank) Then
          Begin
            index := ahead;
          End
          Else If (ourrank >= opp1rank) And (ourrank >= opp2rank) And (
            ourrank >= opp3rank) And (ourrank >= opp4rank) And (
            ourrank >= opp5rank) And (ourrank >= opp6rank) And (
            ourrank >= opp7rank) And (ourrank >= opp8rank) And (
            ourrank >= opp9rank) Then
          Begin
            index := tied;
          End
          Else
          Begin
            index := behind;
          End;

          boardmask := RandomHand(board, pocket Or opp1Pocket Or opp2Pocket Or opp3Pocket Or opp4Pocket Or opp5Pocket Or
            opp6Pocket Or
            opp7Pocket Or opp8Pocket Or opp9Pocket, 5);
          ourbest := Evaluate(pocket Or boardmask, 7);
          opp1best := Evaluate(opp1Pocket Or boardmask, 7);
          opp2best := Evaluate(opp2Pocket Or boardmask, 7);
          opp3best := Evaluate(opp3Pocket Or boardmask, 7);
          opp4best := Evaluate(opp4Pocket Or boardmask, 7);
          opp5best := Evaluate(opp5Pocket Or boardmask, 7);
          opp6best := Evaluate(opp6Pocket Or boardmask, 7);
          opp7best := Evaluate(opp7Pocket Or boardmask, 7);
          opp8best := Evaluate(opp8Pocket Or boardmask, 7);
          opp9best := Evaluate(opp9Pocket Or boardmask, 7);
          If (ourbest > opp1best) And (ourbest > opp2best) And (
            ourbest > opp3best) And (ourbest > opp4best) And (
            ourbest > opp5best) And (ourbest > opp6best) And (
            ourbest > opp7best) And (ourbest > opp8best) And (
            ourbest > opp9best) Then
          Begin
            HP[index, ahead] := HP[index, ahead] + 1;
            //if (index == behind || index == tied)
            //    count:=count+1;
          End
          Else If (ourbest >= opp1best) And (ourbest >= opp2best) And (
            ourbest >= opp3best) And (ourbest >= opp4best) And (
            ourbest >= opp5best) And (ourbest >= opp6best) And (
            ourbest >= opp7best) And (ourbest >= opp8best) And (
            ourbest >= opp9best) Then
          Begin
            HP[index, tied] := HP[index, tied] + 1;
            //if (index == behind || index == ahead)
            //    count:=count+1;
          End
          Else
          Begin
            HP[index, behind] := HP[index, behind] + 1;
            //if (index == ahead || index == tied)
            //    count:=count+1;
          End;
          Count := Count + 1;
        End;
      End;

  End;

  //while (TheCounter.RunElapsedTime) < duration do
  //  begin
  //    opp1Pocket := RandomHand(0, pocket or board, 2); //first get a random pocket for the the first opponent
  //    opp1rank := Evaluate(opp1Pocket or board, ncards); //rank it 5 cards
  //    if (ourrank > opp1rank) then
  //    begin
  //      index := ahead;
  //    end
  //    else if (ourrank >= opp1rank) then
  //    begin
  //      index := tied;
  //    end
  //    else
  //    begin
  //      index := behind;
  //    end;
  //
  //    boardmask := RandomHand(board, pocket or opp1Pocket, 5);
  //    ourbest := Evaluate(pocket or boardmask, 7);
  //    opp1best := Evaluate(opp1Pocket or boardmask, 7);
  //    if (ourbest > opp1best) then
  //    begin
  //      HP[index, ahead] := HP[index, ahead] + 1;
  //    end
  //    else if (ourbest >= opp1best) then
  //    begin
  //      HP[index, tied] := HP[index, tied] + 1;
  //    end
  //    else
  //    begin
  //      HP[index, behind] := HP[index, behind] + 1;
  //    end;
  //    count := count + 1;
  //  end;

  StopCount(TheCounter);
  TheResult[0] := (HP[behind, ahead] + (HP[behind, tied] / 2) + (HP[tied, ahead] / 2)) / (Count);
  TheResult[1] := (HP[ahead, behind] + (HP[ahead, tied] / 2) + (HP[tied, behind] / 2)) / (Count);
  Result := TheResult;
End;

Function WhatHand(I: Integer): String;
Begin
  Case I Of
    0: Result := 'High card'; //high
    1: Result := '1 Pair'; //pair
    2: Result := '2 Pairs'; //two pair
    3: Result := '3 of a kind'; //tok
    4: Result := 'Straight'; //straight
    5: Result := 'Flush'; //flush
    6: Result := 'Full house'; //full house
    7: Result := '4 of a kind'; //FOK
    8: Result := 'Straight flush';
    //straight flush
  End;
End;
//Function DrawOdds(Stage: TStage; pocket, board: int64): TArrayOf8Integers;
//Var
//  HC, P, TP, TOK, STR, FL, FH, FOK, SF, I, J, Count: integer;
//  playerHandVal: cardinal;
//  ResultArray: TArrayOf8Integers;
//  CardsToBeUsedPostFlop: Array[0..46] Of int64;
//  CardsToBeUsedPostTurn: Array[0..45] Of int64;
//Begin
//  For I := 0 To 7 Do
//    ResultArray[I] := 0;
//  Game.BoardsAndHole := pocket Or board;
//  HC := 0; P := 0; TP := 0; TOK := 0; STR := 0; FL := 0; FH := 0; FOK := 0; SF := 0;
// //First live cards
//  Count := 0;
//  For I := 0 To 51 Do
//  Begin
//    If (Cards[I] And Game.BoardsAndHole) = 0 Then
//    Begin
//      Count := Count + 1;
//      If Stage = PostFlop Then
//      Begin
//        CardsToBeUsedPostFlop[Count - 1] := Cards[I];
//      End;
//      If Stage = PostTurn Then
//      Begin
//        CardsToBeUsedPostTurn[Count - 1] := Cards[I];
//      End;
//    End;
//  End;
//   //now in case the stage is Flop then prepare the comps of 2 remaining cards
//  Count := 0;
//  If Stage = PostFlop Then
//  Begin
//    For I := 0 To 45 Do
//      For J := I + 1 To 46 Do
//      Begin
//        Count := Count + 1;
//        playerHandVal := Eval7(pocket Or board Or CardsToBeUsedPostFlop[I] Or CardsToBeUsedPostFlop[J], 7);
//        If (Game.CurrentMadeHand Shr 24) = 0 Then
//        Begin
//          If (playerHandVal Shr 24) = 8 Then
//          Begin
//            SF := SF + 1;
//          End;
//          If (playerHandVal Shr 24) = 7 Then
//          Begin
//            FOK := FOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 6 Then
//          Begin
//            FH := FH + 1;
//          End;
//          If (playerHandVal Shr 24) = 5 Then
//          Begin
//            FL := FL + 1;
//          End;
//          If (playerHandVal Shr 24) = 4 Then
//          Begin
//            STR := STR + 1;
//          End;
//          If (playerHandVal Shr 24) = 3 Then
//          Begin
//            TOK := TOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 2 Then
//          Begin
//            TP := TP + 1;
//          End;
//          If (playerHandVal Shr 24) = 1 Then
//          Begin
//            P := P + 1;
//          End;
//        End;
//
//        If (Game.CurrentMadeHand Shr 24) = 1 Then
//        Begin
//          If (playerHandVal Shr 24) = 8 Then
//          Begin
//            SF := SF + 1;
//          End;
//          If (playerHandVal Shr 24) = 7 Then
//          Begin
//            FOK := FOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 6 Then
//          Begin
//            FH := FH + 1;
//          End;
//          If (playerHandVal Shr 24) = 5 Then
//          Begin
//            FL := FL + 1;
//          End;
//          If (playerHandVal Shr 24) = 4 Then
//          Begin
//            STR := STR + 1;
//          End;
//          If (playerHandVal Shr 24) = 3 Then
//          Begin
//            TOK := TOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 2 Then
//          Begin
//            TP := TP + 1;
//          End;
//        End; //
//        If (Game.CurrentMadeHand Shr 24) = 2 Then
//        Begin
//          If (playerHandVal Shr 24) = 8 Then
//          Begin
//            SF := SF + 1;
//          End;
//          If (playerHandVal Shr 24) = 7 Then
//          Begin
//            FOK := FOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 6 Then
//          Begin
//            FH := FH + 1;
//          End;
//          If (playerHandVal Shr 24) = 5 Then
//          Begin
//            FL := FL + 1;
//          End;
//          If (playerHandVal Shr 24) = 4 Then
//          Begin
//            STR := STR + 1;
//          End;
//          If (playerHandVal Shr 24) = 3 Then
//          Begin
//            TOK := TOK + 1;
//          End;
//        End;
//        If (Game.CurrentMadeHand Shr 24) = 3 Then
//        Begin
//          If (playerHandVal Shr 24) = 8 Then
//          Begin
//            SF := SF + 1;
//          End;
//          If (playerHandVal Shr 24) = 7 Then
//          Begin
//            FOK := FOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 6 Then
//          Begin
//            FH := FH + 1;
//          End;
//          If (playerHandVal Shr 24) = 5 Then
//          Begin
//            FL := FL + 1;
//          End;
//          If (playerHandVal Shr 24) = 4 Then
//          Begin
//            STR := STR + 1;
//          End;
//          If (playerHandVal Shr 24) = 3 Then
//          Begin
//            TOK := TOK + 1;
//          End;
//        End;
//        If (Game.CurrentMadeHand Shr 24) = 4 Then
//        Begin
//          If (playerHandVal Shr 24) = 8 Then
//          Begin
//            SF := SF + 1;
//          End;
//          If (playerHandVal Shr 24) = 7 Then
//          Begin
//            FOK := FOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 6 Then
//          Begin
//            FH := FH + 1;
//          End;
//          If (playerHandVal Shr 24) = 5 Then
//          Begin
//            FL := FL + 1;
//          End;
//          If (playerHandVal Shr 24) = 4 Then
//          Begin
//            STR := STR + 1;
//          End;
//        End;
//        If (Game.CurrentMadeHand Shr 24) = 5 Then
//        Begin
//          If (playerHandVal Shr 24) = 8 Then
//          Begin
//            SF := SF + 1;
//          End;
//          If (playerHandVal Shr 24) = 7 Then
//          Begin
//            FOK := FOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 6 Then
//          Begin
//            FH := FH + 1;
//          End;
//          If (playerHandVal Shr 24) = 5 Then
//          Begin
//            FL := FL + 1;
//          End;
//        End;
//        If (Game.CurrentMadeHand Shr 24) = 6 Then
//        Begin
//          If (playerHandVal Shr 24) = 8 Then
//          Begin
//            SF := SF + 1;
//          End;
//          If (playerHandVal Shr 24) = 7 Then
//          Begin
//            FOK := FOK + 1;
//          End;
//          If (playerHandVal Shr 24) = 6 Then
//          Begin
//            FH := FH + 1;
//          End;
//        End;
//        If (Game.CurrentMadeHand Shr 24) = 7 Then
//        Begin
//          If (playerHandVal Shr 24) = 8 Then
//          Begin
//            SF := SF + 1;
//          End;
//          If (playerHandVal Shr 24) = 7 Then
//          Begin
//            FOK := FOK + 1;
//          End;
//        End;
//      End;
//  End;
//
//
//  If Stage = PostTurn Then
//  Begin
//    For I := 0 To 45 Do
//    Begin
//      Count := Count + 1;
//      playerHandVal := Eval7(pocket Or board Or CardsToBeUsedPostTurn[I], 7);
//
//      If (Game.CurrentMadeHand Shr 24) = 0 Then
//      Begin
//        If (playerHandVal Shr 24) = 8 Then
//        Begin
//          SF := SF + 1;
//        End;
//        If (playerHandVal Shr 24) = 7 Then
//        Begin
//          FOK := FOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 6 Then
//        Begin
//          FH := FH + 1;
//        End;
//        If (playerHandVal Shr 24) = 5 Then
//        Begin
//          FL := FL + 1;
//        End;
//        If (playerHandVal Shr 24) = 4 Then
//        Begin
//          STR := STR + 1;
//        End;
//        If (playerHandVal Shr 24) = 3 Then
//        Begin
//          TOK := TOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 2 Then
//        Begin
//          TP := TP + 1;
//        End;
//        If (playerHandVal Shr 24) = 1 Then
//        Begin
//          P := P + 1;
//        End;
//      End;
//
//      If (Game.CurrentMadeHand Shr 24) = 1 Then
//      Begin
//        If (playerHandVal Shr 24) = 8 Then
//        Begin
//          SF := SF + 1;
//        End;
//        If (playerHandVal Shr 24) = 7 Then
//        Begin
//          FOK := FOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 6 Then
//        Begin
//          FH := FH + 1;
//        End;
//        If (playerHandVal Shr 24) = 5 Then
//        Begin
//          FL := FL + 1;
//        End;
//        If (playerHandVal Shr 24) = 4 Then
//        Begin
//          STR := STR + 1;
//        End;
//        If (playerHandVal Shr 24) = 3 Then
//        Begin
//          TOK := TOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 2 Then
//        Begin
//          TP := TP + 1;
//        End;
//      End; //
//      If (Game.CurrentMadeHand Shr 24) = 2 Then
//      Begin
//        If (playerHandVal Shr 24) = 8 Then
//        Begin
//          SF := SF + 1;
//        End;
//        If (playerHandVal Shr 24) = 7 Then
//        Begin
//          FOK := FOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 6 Then
//        Begin
//          FH := FH + 1;
//        End;
//        If (playerHandVal Shr 24) = 5 Then
//        Begin
//          FL := FL + 1;
//        End;
//        If (playerHandVal Shr 24) = 4 Then
//        Begin
//          STR := STR + 1;
//        End;
//        If (playerHandVal Shr 24) = 3 Then
//        Begin
//          TOK := TOK + 1;
//        End;
//      End;
//      If (Game.CurrentMadeHand Shr 24) = 3 Then
//      Begin
//        If (playerHandVal Shr 24) = 8 Then
//        Begin
//          SF := SF + 1;
//        End;
//        If (playerHandVal Shr 24) = 7 Then
//        Begin
//          FOK := FOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 6 Then
//        Begin
//          FH := FH + 1;
//        End;
//        If (playerHandVal Shr 24) = 5 Then
//        Begin
//          FL := FL + 1;
//        End;
//        If (playerHandVal Shr 24) = 4 Then
//        Begin
//          STR := STR + 1;
//        End;
//        If (playerHandVal Shr 24) = 3 Then
//        Begin
//          TOK := TOK + 1;
//        End;
//      End;
//      If (Game.CurrentMadeHand Shr 24) = 4 Then
//      Begin
//        If (playerHandVal Shr 24) = 8 Then
//        Begin
//          SF := SF + 1;
//        End;
//        If (playerHandVal Shr 24) = 7 Then
//        Begin
//          FOK := FOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 6 Then
//        Begin
//          FH := FH + 1;
//        End;
//        If (playerHandVal Shr 24) = 5 Then
//        Begin
//          FL := FL + 1;
//        End;
//        If (playerHandVal Shr 24) = 4 Then
//        Begin
//          STR := STR + 1;
//        End;
//      End;
//      If (Game.CurrentMadeHand Shr 24) = 5 Then
//      Begin
//        If (playerHandVal Shr 24) = 8 Then
//        Begin
//          SF := SF + 1;
//        End;
//        If (playerHandVal Shr 24) = 7 Then
//        Begin
//          FOK := FOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 6 Then
//        Begin
//          FH := FH + 1;
//        End;
//        If (playerHandVal Shr 24) = 5 Then
//        Begin
//          FL := FL + 1;
//        End;
//      End;
//      If (Game.CurrentMadeHand Shr 24) = 6 Then
//      Begin
//        If (playerHandVal Shr 24) = 8 Then
//        Begin
//          SF := SF + 1;
//        End;
//        If (playerHandVal Shr 24) = 7 Then
//        Begin
//          FOK := FOK + 1;
//        End;
//        If (playerHandVal Shr 24) = 6 Then
//        Begin
//          FH := FH + 1;
//        End;
//      End;
//      If (Game.CurrentMadeHand Shr 24) = 7 Then
//      Begin
//        If (playerHandVal Shr 24) = 8 Then
//        Begin
//          SF := SF + 1;
//        End;
//        If (playerHandVal Shr 24) = 7 Then
//        Begin
//          FOK := FOK + 1;
//        End;
//      End;
//    End;
//  End;
//  If P <> 0 Then
//    ResultArray[0] := P / Count;
//  If TP <> 0 Then
//    ResultArray[1] := TP / Count;
//  If TOK <> 0 Then
//    ResultArray[2] := TOK / Count;
//  If STR <> 0 Then
//    ResultArray[3] := STR / Count;
//  If FL <> 0 Then
//    ResultArray[4] := FL / Count;
//  If FH <> 0 Then
//    ResultArray[5] := FH / Count;
//  If FOK <> 0 Then
//    ResultArray[6] := FOK / Count;
//  If SF <> 0 Then
//    ResultArray[7] := SF / Count;
//  Result := ResultArray;
//End;
//
//Function OpponentsMayHave(Stage: TStage; pocket, board: int64): String;
//Var
//  I, J, Count, R: integer;
//  playerHandVal: cardinal;
//  CardsToBeUsedPostFlop: Array[0..46] Of int64;
//  CardsToBeUsedPostTurn: Array[0..45] Of int64;
//  CardsToBeUsedPostRiver: Array[0..44] Of int64;
//  BetterAr: Array Of integer;
//Begin
//  Game.BoardsAndHole := pocket Or board;
// //First live cards
//  Count := 0;
//  For I := 0 To 51 Do
//  Begin
//    If (Cards[I] And Game.BoardsAndHole) = 0 Then
//    Begin
//      Count := Count + 1;
//      If Stage = PostFlop Then
//      Begin
//        CardsToBeUsedPostFlop[Count - 1] := Cards[I];
//      End;
//      If Stage = PostTurn Then
//      Begin
//        CardsToBeUsedPostTurn[Count - 1] := Cards[I];
//      End;
//      If Stage = PostRiver Then
//      Begin
//        CardsToBeUsedPostRiver[Count - 1] := Cards[I];
//      End;
//    End;
//  End;
//   //now in case the stage is Flop then prepare the comps of 2 remaining cards
//  Count := 0;
//  If Stage = PostFlop Then
//  Begin
//    For I := 0 To 45 Do
//      For J := I + 1 To 46 Do
//      Begin
//        playerHandVal := Eval7(board Or CardsToBeUsedPostFlop[I] Or CardsToBeUsedPostFlop[J], 5);
//        If playerHandVal > Game.CurrentMadeHand Then
//        Begin
//          Count := Count + 1;
//          setlength(BetterAr, Count);
//          BetterAr[Count - 1] := playerHandVal;
//        End;
//      End;
//  End;
//
//  If Stage = PostTurn Then
//  Begin
//    For I := 0 To 44 Do
//      For J := I + 1 To 45 Do
//      Begin
//        playerHandVal := Eval7(board Or CardsToBeUsedPostTurn[I] Or CardsToBeUsedPostTurn[J], 6);
//        If playerHandVal > Game.CurrentMadeHand Then
//        Begin
//          Count := Count + 1;
//          setlength(BetterAr, Count);
//          BetterAr[Count - 1] := playerHandVal;
//        End;
//      End;
//  End;
//
//  If Stage = PostRiver Then
//  Begin
//    For I := 0 To 43 Do
//      For J := I + 1 To 44 Do
//      Begin
//        playerHandVal := Eval7(board Or CardsToBeUsedPostRiver[I] Or CardsToBeUsedPostRiver[J], 7);
//        If playerHandVal > Game.CurrentMadeHand Then
//        Begin
//          Count := Count + 1;
//          setlength(BetterAr, Count);
//          BetterAr[Count - 1] := playerHandVal;
//        End;
//      End;
//  End;
//
//  If Count > 0 Then
//  Begin
//    QuickSort(BetterAr, 0, high(BetterAr));
//    R := BetterAr[Count - 1] Shr 24;
//    Case R Of
//      0: Result := 'High card'; //high
//      1: Result := 'One pair'; //pair
//      2: Result := 'Two pairs'; //two pair
//      3: Result := 'Three of a kind'; //tok
//      4: Result := 'Straight'; //straight
//      5: Result := 'Flush'; //flush
//      6: Result := 'Full house'; //full house
//      7: Result := 'Four of a kind'; //FOK
//      8: Result := 'Straight flush'; //straight flush
//    End;
//  End;
//End;
End.

