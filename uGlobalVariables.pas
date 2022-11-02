Unit uGlobalVariables;

Interface
Uses
  uGameClasses, uNewTypes, Graphics;
Var
  Circle: Array[0..8] Of Integer;
  BetPotBtnIsThere, CallBtnIsThere, FoldBtnIsThere, RaiseBtnIsThere,
    BetBtnIsThere, CheckBtnIsThere, FoldAndShowBtnIsThere,
    FoldSmallBtnIsThere, BetItBtnIsThere: Boolean;
  Pocket169Table: Array[0..168] Of Array Of int64;
  StartingDealer: Integer;
  Hand: THand;
  Game: TGame;
  PlayersIn: Array[TStage] Of Array[0..8] Of Boolean;
  BMCOMMANDDIGITS: Array[0..12] Of TBitmap;
  BMPOTDIGITSARRAY: Array[0..12] Of Array Of Array Of Integer;
  BMPOTDIGITS: Array[0..12] Of TBitmap;
  BMSTOREDLETTERS: Array[0..39] Of TBitmap;
  BMSTOREDLETTERSARRAY: Array[0..39] Of Array Of Array Of Integer;
  BMSTOREDDIGITS: Array[0..13] Of TBitmap;
  BMSTOREDDIGITSARRAY: Array[0..13] Of Array Of Array Of Integer;
  BMSTOREDHOLE: Array[0..51] Of TBitmap;
  BMSTOREDBOARD: Array[0..51] Of TBitmap;
  SeatsList: Array[0..8] Of TSeat;
  MontecarloCount: Integer;
  PreviousPot: Double;

Implementation

End.

