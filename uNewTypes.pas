Unit uNewTypes;

Interface
Uses
  Types, Windows, Forms, Graphics, uHashTables, GR32, Messages, Classes, SysUtils;
Type
  TArrayOfDouble = Array Of Double;
Type
  Arrayint64 = Array Of Int64;
Type
  TStage = (PreFlop, Flop, Turn, River, Showdown);
  //denote cards being dealt for that stage  flop meaning after-flop..turn=after turn..and river meaning after-river
Type
  TRGBTripleArray = Array[Word] Of TRGBTriple;
  pRGBTripleArray = ^TRGBTripleArray;
Type
  TArray60 = Array[0..59] Of Integer;
Type
  TPpotNpot = Array[0..1] Of Double;
Type
  TPlayersBets = Array[0..8] Of Double;
Type
  TSeat = Record
    BetsX, BetsY, Position, CardsX, CardsY, BankrollX, BankrollY, NameX, NameY:
    Integer;
    CardsColor: COLORREF;
    //for the name we just count white pixels and it denotes the name
  End;
Type
  TPlayerStat = Record
    Dealt, SeeFlop, SeeTurn, SeeRiver, StayShowdown: Integer;
  End;
Implementation

End.

