Unit uGlobalConstants;

Interface
Uses
  uNewTypes;
Const
  FoldingVersusNil: Integer = $1;
  FoldingVersusBets: Integer = $2;
  Checking: Integer = $4;
  CallingBet: Integer = $8;
  CallingRaise: Integer = $10;
  Betting: Integer = $20;
  Raising: Integer = $40;
  FoldAfterInvest: Integer = $80;
  PostedSB: Integer = $100;
  PostedBB: Integer = $200;
  //  CheckRaiseACall: Integer = 80; {16 or 64 and 32 or 64}
  //  CheckRaiseARaise: Integer = 96;
Const
  {***BetDigits AND CONSTANTS***order: $,1,2,3,4,5,6,7,8,9,0,.,********************************************************}
  BetStrings: Array[0..11] Of String = ('$', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.');
  BetBits: Array[0..11] Of Cardinal = (1450564, 1179904, 1315340, 1319428, 1097936, 1254212, 1565252,
    1573404, 1499716, 1516068, 1565188, 1052672);
  BetsWidth: Integer = 80;
  BetsHeight: Integer = 10;
  ColorOfBets: Integer = 4115454;

  {************************************POT STRING RELATED CONSTANTS************************************}
  PotStrings: Array[0..12] Of String = ('0', '2', '3', '4', '5', '6', '7', '8', '9', '$', '1', ',', '.');
  PotStringsUsable: Array[0..10] Of String = ('0', '2', '3', '4', '5', '6', '7', '8', '9', '1', '.');
  PotRes: Array[0..12] Of String = ('PZERO', 'PTWO', 'PTHREE', 'PFOUR', 'PFIVE', 'PSIX', 'PSEVEN', 'PEIGHT', 'PNINE', 'PDOLLAR',
    'PONE', 'PCOMMA', 'PDOT');
  PotX: Integer = 110;
  PotY: Integer = 3;
  PotWidth: Integer = 150;
  PotHeight: Integer = 9;
  {*******************************COMMAND BUTTON COMMANDS*********************************************}

  {*******************************COMMAND BUTTON DIGITS*********************************************}
  ButtonDigits: Array[0..12] Of String = ('0', '2', '3', '4', '5', '6', '7', '8', '9', '$', '1', ',', '.');
  ButtonDigitsRes: Array[0..12] Of String = ('CZERO', 'CTWO', 'CTHREE', 'CFOUR', 'CFIVE', 'CSIX', 'CSEVEN', 'CEIGHT',
    'CNINE', 'CDOLLAR', 'CONE', 'CCOMMA', 'CDOT');

  {***********BANKROLL AND PLAYER NAMES CONSTANTS---LETTERS ARRANGED FROM WIDER TO THINNER*************}
  NameStrings: Array[0..39] Of String = ('W', 'X', 'Y', 'V', 'M', 'R', 'Q', 'O', 'K', 'U', 'S', 'P', 'N', 'H',
    'G', 'D', 'C', 'B', 'A', '0', '2', '3', '4', '5', '6', '7', '8', '9', 'E', 'J', 'L', 'T', 'Z', 'c', '$',
    'F', '1', '.', 'I', ',');
  BankrollStrings: Array[0..13] Of String = ('0', '2', '3', '4', '5', '6', '7', '8', '9', 'c', '$', '1', '.', ',');
  NameRes: Array[0..39] Of String = ('W', 'X', 'Y', 'V', 'M', 'R', 'Q', 'O', 'K', 'U', 'S', 'P', 'N', 'H',
    'G', 'D', 'C', 'B', 'A', 'ZERO', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE',
    'E', 'J', 'L', 'T', 'Z', 'CENT', 'DOLLAR', 'F', 'ONE', 'DOT', 'I', 'COMMA');
  DigitRes: Array[0..13] Of String = ('ZERO', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE',
    'CENT', 'DOLLAR', 'ONE', 'DOT', 'COMMA');
  BankrollWidth: Integer = 98;
  BankrollHeight: Integer = 10;
  NameWidth: Integer = 98;
  NameHeight: Integer = 10;

  {**********ACTION BUTTONS***********}
Const
  ClockX: Integer = 732;
  ClockY: Integer = 364;
  BetsToCallX: Integer = 385;
  BetsToCallY: Integer = 461;
  BetsToCallW: Integer = 94;
  BetsToCallH: Integer = 8;
  ActionBX: Integer = 267;
  ActionBY: Integer = 471;
  ActionBColor: Integer = 5945315;
  BetItBtnX: Integer = 716;
  BetItBtnY: Integer = 413;
  FoldSmallBtnX: Integer = 338;
  FoldSmallBtnY: Integer = 453;
  FoldAndShowBtnX: Integer = 277;
  FoldAndShowBtnY: Integer = 446;
  FoldBtnX: Integer = 310;
  FoldBtnY: Integer = 453;
  RaiseBtnX: Integer = 529;
  RaiseBtnY: Integer = 446;
  BetBtnX: Integer = 533;
  BetBtnY: Integer = 446;
  CheckBtnX: Integer = 415;
  CheckBtnY: Integer = 453;
  CallBtnX: Integer = 422;
  CallBtnY: Integer = 446;
  BetPotBtnX: Integer = 627;
  BetPotBtnY: Integer = 446;
  BtnsW: Integer = 10;
  BtnsH: Integer = 6;
  FoldSmallBtnPixels: TArray60 = (0, 190, 188, 186, 183, 180, 0, 0, 0, 0, 0, 0,
    0, 50, 50, 50, 49, 49, 0, 225, 224, 222, 220, 218, 194,
    160, 90, 89, 157, 219, 128, 0, 0, 0, 0, 125, 0, 91, 161, 160, 90, 0, 0, 225,
    226, 225, 225, 0, 0, 90, 160, 160, 90, 0, 126, 0, 0, 0, 0,
    127);
  RaiseBtnPixels: TArray60 = (194, 194, 193, 192, 192, 190, 0, 0, 0, 0, 0, 0,
    51, 51, 0, 51, 51, 50, 159, 0, 225, 226, 225, 224, 0, 0, 225,
    226, 226, 225, 191, 223, 225, 126, 91, 226, 0, 222, 126, 0, 0, 0, 0, 221, 0,
    126, 127, 0, 0, 220, 0, 222, 224, 0, 0, 49, 0, 89, 50,
    50);
  BetBtnPixels: TArray60 = (192, 192, 193, 194, 194, 193, 0, 0, 0, 0, 0, 0, 0,
    50, 50, 51, 51, 0, 0, 221, 223, 224, 225, 0, 0, 124, 157,
    159, 90, 0, 49, 0, 0, 0, 0, 90, 215, 122, 88, 89, 158, 223, 213, 185, 123,
    124, 157, 223, 150, 0, 0, 0, 0, 190, 0, 119, 0, 122, 0, 0);
  BetItBtnPixels: TArray60 = (180, 178, 175, 172, 168, 165, 0, 0, 0, 0, 0, 0, 0,
    49, 48, 48, 46, 0, 0, 218, 216, 213, 210, 0, 0, 125, 156,
    154, 86, 0, 51, 0, 0, 0, 0, 86, 226, 126, 89, 89, 157, 218, 224, 194, 126,
    126, 159, 221, 160, 0, 0, 0, 0, 193, 0, 126, 0, 128, 0, 0);
  BetPotBtnPixels: TArray60 = (168, 165, 161, 158, 156, 152, 0, 0, 0, 0, 0, 0,
    0, 45, 44, 44, 43, 0, 0, 206, 203, 199, 195, 0, 0, 118, 146,
    145, 80, 0, 49, 0, 0, 0, 0, 80, 219, 122, 86, 85, 148, 204, 221, 189, 122,
    121, 151, 208, 159, 0, 0, 0, 0, 182, 0, 126, 0, 124, 0, 0);
  CallBtnPixels: TArray60 = (223, 158, 90, 90, 161, 225, 158, 0, 0, 0, 0, 161,
    0, 50, 159, 160, 51, 0, 0, 221, 222, 224, 225, 0, 0, 220,
    221, 222, 224, 0, 49, 88, 220, 222, 89, 50, 185, 218, 219, 125, 89, 223, 0,
    216, 123, 0, 0, 0, 0, 213, 0, 123, 124, 0, 0, 212, 0, 216,
    218, 0);
  CheckBtnPixels: TArray60 = (210, 148, 82, 80, 140, 192, 151, 0, 0, 0, 0, 139,
    0, 48, 148, 146, 45, 0, 0, 214, 210, 208, 204, 0, 0, 216,
    213, 210, 207, 0, 50, 87, 216, 213, 84, 46, 157, 157, 156, 154, 151, 149, 0,
    0, 0, 0, 0, 0, 50, 50, 89, 88, 87, 86, 0, 224, 222, 220,
    218, 216);
  FoldBtnPixels: TArray60 = (0, 189, 187, 185, 182, 179, 0, 0, 0, 0, 0, 0, 0,
    50, 50, 49, 49, 49, 0, 224, 222, 220, 218, 216, 193, 160, 90,
    88, 156, 218, 128, 0, 0, 0, 0, 124, 0, 90, 160, 159, 89, 0, 0, 226, 226,
    224, 224, 0, 0, 90, 160, 160, 90, 0, 126, 0, 0, 0, 0, 127);
  FoldAndShowBtnPixels: TArray60 = (0, 193, 191, 190, 189, 186, 0, 0, 0, 0, 0,
    0, 0, 51, 51, 50, 50, 50, 0, 226, 225, 225, 224, 222, 193,
    160, 90, 90, 160, 224, 126, 0, 0, 0, 0, 126, 0, 90, 160, 161, 90, 0, 0, 223,
    225, 225, 226, 0, 0, 89, 158, 160, 90, 0, 124, 0, 0, 0, 0,
    127);

  {**********************SEATS***********************}
Const
  SeatMe0: TSeat = (
    BetsX: 354;
    BetsY: 291;
    Position: 0;
    CardsX: 0;
    CardsY: 0; //we already know these i am just initlizing..of no usage here
    BankrollX: 345;
    BankrollY: 424;
    NameX: 345;
    NameY: 411;
    CardsColor: 0;
    );
  Seat1: TSeat = (
    BetsX: 207;
    BetsY: 260;
    Position: 1;
    CardsX: 246;
    CardsY: 293; //we already know these i am just initlizing..of no usage here
    BankrollX: 140;
    BankrollY: 363;
    NameX: 140;
    NameY: 350;
    CardsColor: 1836229;
    );
  Seat2: TSeat = (
    BetsX: 106;
    BetsY: 210;
    Position: 2;
    CardsX: 90;
    CardsY: 242; //we already know these i am just initlizing..of no usage here
    BankrollX: 9;
    BankrollY: 323;
    NameX: 9;
    NameY: 310;
    CardsColor: 1836230;
    );
  Seat3: TSeat = (
    BetsX: 191;
    BetsY: 159;
    Position: 3;
    CardsX: 125;
    CardsY: 169;
    BankrollX: 5;
    BankrollY: 121;
    NameX: 5;
    NameY: 108;
    CardsColor: 1836227;
    );
  Seat4: TSeat = (
    BetsX: 274;
    BetsY: 143;
    Position: 4;
    CardsX: 240;
    CardsY: 125;
    BankrollX: 165;
    BankrollY: 87;
    NameX: 165;
    NameY: 74;
    CardsColor: 1836224;
    );
  Seat5: TSeat = (
    BetsX: 499;
    BetsY: 143;
    Position: 5;
    CardsX: 545;
    CardsY: 125;
    BankrollX: 514;
    BankrollY: 87;
    NameX: 514;
    NameY: 74;
    CardsColor: 1836229;
    );
  Seat6: TSeat = (
    BetsX: 540; //the x limit to the left border of the river is 530
    BetsY: 159;
    Position: 6;
    CardsX: 670;
    CardsY: 164;
    BankrollX: 664;
    BankrollY: 125;
    NameX: 664;
    NameY: 112;
    CardsColor: 1835961;
    );
  Seat7: TSeat = (
    BetsX: 580; //the x limit to the left border of the river is 590
    BetsY: 214;
    Position: 7;
    CardsX: 690;
    CardsY: 242;
    BankrollX: 677;
    BankrollY: 313;
    NameX: 677;
    NameY: 300;
    CardsColor: 1836227;
    );
  Seat8: TSeat = (
    BetsX: 532; //the x limit to the left border of the river is 590
    BetsY: 271;
    Position: 8;
    CardsX: 555;
    CardsY: 290;
    BankrollX: 542;
    BankrollY: 363;
    NameX: 542;
    NameY: 350;
    CardsColor: 1836224;
    );
  //here are ultimatebet cards that can be fetched from hole cards(only,not
  //from the board where cards have smaller size)
  //C:A2345678910jqk D:A2345678910jqk H:A2345678910jqk S:A2345678910jqk
    // converts card number into the equivalent text string.
    /// <exclude/>
  FirstHoleFlagX: Integer = 346;
  FirstHoleFlagY: Integer = 320;
  SecondHoleFlagX: Integer = 372;
  SecondHoleFlagY: Integer = 320;
  FirstHoleX: Integer = 343;
  FirstHoleY: Integer = 319;
  SecondHoleX: Integer = 369;
  SecondHoleY: Integer = 319;
  Board1X: Integer = 267;
  Board1Y: Integer = 150;
  Board2X: Integer = 318;
  Board2Y: Integer = 150;
  Board3X: Integer = 370;
  Board3Y: Integer = 150;
  Board4X: Integer = 421;
  Board4Y: Integer = 150;
  Board5X: Integer = 473;
  Board5Y: Integer = 150;
  //  TheButtonX: Array[0..5] Of Integer = (313, 53, 143, 445, 701, 656);
  //  TheButtonY: Array[0..5] Of Integer = (317, 216, 139, 105, 192, 269);
  DealerButtonX: Array[0..8] Of Integer = (319, 148, 53, 142, 282, 578, 696,
    659,
    503);
  DealerButtonY: Array[0..8] Of Integer = (316, 283, 216, 139, 109, 126, 183,
    266,
    311);

Implementation

End.

