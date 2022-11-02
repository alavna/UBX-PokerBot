Unit uMiscFunctions;

Interface
Uses
  uHashTables, Windows, Messages, Classes, Types, SysUtils, Forms, uNewTypes, uGlobalConstants, DateUtils;
Type
  TStopWatch = Class
  Private
    fFrequency: TLargeInteger;
    fIsRunning: boolean;
    fIsHighResolution: boolean;
    fStartCount, fStopCount: TLargeInteger;
    Procedure SetTickStamp(Var lInt: TLargeInteger);
    Function GetElapsedTicks: TLargeInteger;
    Function GetElapsedMiliseconds: TLargeInteger;
    Function GetElapsed: String;
  Public
    Constructor Create(Const startOnCreate: boolean = False);
    Procedure Start;
    Procedure Stop;
    Property IsHighResolution: boolean Read fIsHighResolution;
    Property ElapsedTicks: TLargeInteger Read GetElapsedTicks;
    Property ElapsedMiliseconds: TLargeInteger Read GetElapsedMiliseconds;
    Property Elapsed: String Read GetElapsed;
    Property IsRunning: boolean Read fIsRunning;
  End;
Function ArraysAlike60(A, B: TArray60): boolean;
Function CleanString(S: String): String;
Function FindIt(S: String): Integer;
Function CheckGroup: Integer;
Function IsNumeric(Value: Variant): boolean;
Function NearThat(X, Y: Integer): boolean;
Procedure Delay(Milliseconds: longint);
Function AllZeros(T: TArrayOfDouble): Boolean;
Function SendKeys(SendKeysString: PAnsiChar; Wait: Boolean): Boolean;
//Procedure Delay(Milliseconds: Cardinal);
Procedure QuickSort(Var A: Array Of Integer; iLo, iHi: Integer);
Function QuickSortDoubles(A: TArrayOfDouble): TArrayOfDouble;
Procedure SetPlayersFromSB;
Function FixedPos(I, TotlaNumber: Integer): Integer;
Implementation
Uses
  uGlobalVariables, uMain;

Constructor TStopWatch.Create(Const startOnCreate: boolean = False);
Begin
  Inherited Create;

  fIsRunning := False;

  fIsHighResolution := QueryPerformanceFrequency(fFrequency);
  If Not fIsHighResolution Then
    fFrequency := MSecsPerSec;

  If startOnCreate Then
    Start;
End;

Function TStopWatch.GetElapsedTicks: TLargeInteger;
Begin
  result := fStopCount - fStartCount;
End;

Procedure TStopWatch.SetTickStamp(Var lInt: TLargeInteger);
Begin
  If fIsHighResolution Then
    QueryPerformanceCounter(lInt)
  Else
    lInt := MilliSecondOf(Now);
End;

Function TStopWatch.GetElapsed: String;
Var
  dt: TDateTime;
Begin
  dt := ElapsedMiliseconds / MSecsPerSec / SecsPerDay;
  result := Format('%d days, %s', [Trunc(dt), FormatDateTime('hh:nn:ss.z', Frac(dt))]);
End;

Function TStopWatch.GetElapsedMiliseconds: TLargeInteger;
Begin
  result := (MSecsPerSec * (fStopCount - fStartCount)) Div fFrequency;
End;

Procedure TStopWatch.Start;
Begin
  SetTickStamp(fStartCount);
  fIsRunning := true;
End;

Procedure TStopWatch.Stop;
Begin
  SetTickStamp(fStopCount);
  fIsRunning := False;
End;

Function FixedPos(I, TotlaNumber: Integer): Integer;
Begin
  If I < 0 Then
    Result := TotlaNumber - Abs(I)
  Else If I > (TotlaNumber - 1) Then
    Result := Abs(TotlaNumber - I)
  Else
    Result := I;
End;

Procedure SetPlayersFromSB;
Var
  NextPlayer, FixedNextPlayer, I: Integer;
Begin
  NextPlayer := Game.CurrentDealer;
  For I := 0 To 8 Do
  Begin
    NextPlayer := NextPlayer + 1;
    FixedNextPlayer := FixedPos(NextPlayer, 9);
    Circle[I] := FixedNextPlayer;
  End;
End;

Procedure Delay(Milliseconds: longint);
{by Hagen Reddmann}
Var
  Tick: DWord;
  Event: THandle;
Begin
  //  If Not AppClosed Then
  //  Begin
  Event := CreateEvent(Nil, False, False, Nil);
  Try
    Tick := GetTickCount + Milliseconds;
    While (Tick > GetTickCount) Do
    Begin
      Sleep(1);
      Application.ProcessMessages;
    End;
  Finally
    CloseHandle(Event);
  End;
  // End;
End;

Function CheckGroup: Integer;
Var
  X, Y: Integer;
  Hole1, Hole2, Holes: Int64;
Begin
  Result := -1;
  Hole1 := Hand.iHole1;
  Hole2 := Hand.iHole2;
  Holes := CardMasks[Hole1] Or CardMasks[Hole2];
  For X := 0 To 8 Do
  Begin
    For Y := 0 To 792 Do
    Begin
      If Holes = PocketGroups[X, Y] Then
      Begin
        Result := X;
        Break;
      End;
    End;
  End;
End;
//Procedure Delay(Msecs: Integer);
//Var
//  FirstTickCount: LongInt;
//Begin
//  FirstTickCount := GetTickCount;
//  Repeat
//    Application.ProcessMessages; // This procedure process another Windows' Messages and avoids the form stop responding.
//  Until ((GetTickCount - FirstTickCount) >= LongInt(Msecs)) Or AppClosed;
//
//End;

Function CleanString(S: String): String;
Var
  I, Y, L: Integer;
  S1: String;
Begin
  Result := '';
  L := Length(S);
  S1 := '';
  If L > 0 Then
    For I := 1 To L Do
    Begin
      For Y := 0 To 10 Do
        If S[I] = PotStringsUsable[Y] Then
          S1 := S1 + S[I];
    End;
  Result := S1;
End;

Function NearThat(X, Y: Integer): boolean;
Begin
  Result := False;
  If (Abs(X - Y)) < 3 Then
    Result := True;
End;

Function ArraysAlike60(A, B: TArray60): boolean;
Var
  I, Diff: Integer;
Begin
  Result := True;
  Diff := 0;
  For I := 0 To 59 Do
  Begin
    If A[I] <> B[I] Then
    Begin
      Diff := Diff + 1;
      If (A[I] - B[I] = 1) Or (B[I] - A[I] = 1) Then
        Diff := Diff - 1;
    End;
  End;
  If diff > 3 Then
    Result := False;
End;

Function IsNumeric(Value: Variant): boolean;
// <-- string has been changed in Variant. About 3 times slower but more generic.
Var
  Number: Extended;
  Error: Integer;
Begin
  Val(Value, Number, Error);
  result := (Error = 0);
End;

Function AllZeros(T: TArrayOfDouble): Boolean;
Var
  L, I: Integer;
Begin
  Result := True;
  L := Length(T);
  If L > 0 Then
    For I := 0 To L - 1 Do
      If T[I] > 0 Then
      Begin
        Result := False;
        Break;
      End;
End;

Function ToInteger(A: Double): Integer;
Var
  S: String;
Begin
  S := FloatToStr(A);
  Result := StrToInt(S);
End;

Function QuickSortDoubles(A: TArrayOfDouble): TArrayOfDouble;
Var
  I, L, K: Integer;
  T: Array Of Integer;
Begin
  L := Length(A);
  SetLength(T, L);
  For I := 0 To L - 1 Do
  Begin
    K := ToInteger(A[I] * 1000);
    T[I] := K;
  End;
  QuickSort(T, Low(T), High(T));
  For I := 0 To L - 1 Do
    A[I] := T[I] / 1000;
  Result := A;
End;

Procedure QuickSort(Var A: Array Of Integer; iLo, iHi: Integer);
Var
  Lo, Hi, Mid, T: Integer;
Begin
  Lo := iLo;
  Hi := iHi;
  Mid := A[(Lo + Hi) Div 2];
  Repeat
    While A[Lo] < Mid Do
    Begin
      inc(Lo);
    End;
    While A[Hi] > Mid Do
    Begin
      Dec(Hi);
    End;
    If Lo <= Hi Then
    Begin
      T := A[Lo];
      A[Lo] := A[Hi];
      A[Hi] := T;
      inc(Lo);
      Dec(Hi);
    End;
  Until Lo > Hi;
  If Hi > iLo Then
  Begin
    QuickSort(A, iLo, Hi);
  End;
  If Lo < iHi Then
  Begin
    QuickSort(A, Lo, iHi);
  End;
End;

Function FindIt(S: String): Integer;
Var
  I: Integer;
Begin
  Result := 0;
  For I := 0 To 51 Do
  Begin
    If S = CardTable[I] Then
    Begin
      Result := I;
      Exit;
    End;
  End;
End;

//Procedure Delay(Milliseconds: Cardinal);
//{by Hagen Reddmann}
//Var
//  Tick: Cardinal;
//  Event: THandle;
//Begin
//  Event := CreateEvent(Nil, False, False, Nil);
//  Try
//    Tick := GetTickCount + Milliseconds;
//    While (Tick > GetTickCount) Do
//    Begin
//      Delay(1);
//      Application.ProcessMessages;
//    End;
//  Finally
//    CloseHandle(Event);
//  End;
//End;

Function SendKeys(SendKeysString: PAnsiChar; Wait: Boolean): Boolean;
Type
  WBytes = Array[0..Pred(SizeOf(Word))] Of Byte;

  TSendKey = Record
    Name: ShortString;
    VKey: Byte;
  End;

Const
  {Array   of   keys   that   SendKeys   recognizes.

  If   you   add   to   this   list,   you   must   be   sure   to   keep   it   sorted   alphabetically
  by   Name   because   a   binary   search   routine   is   used   to   scan   it.}

  MaxSendKeyRecs = 41;
  SendKeyRecs: Array[1..MaxSendKeyRecs] Of TSendKey =
    (
    (Name: 'BKSP'; VKey: VK_BACK),
    (Name: 'BS'; VKey: VK_BACK),
    (Name: 'BACKSPACE'; VKey: VK_BACK),
    (Name: 'BREAK'; VKey: VK_CANCEL),
    (Name: 'CAPSLOCK'; VKey: VK_CAPITAL),
    (Name: 'CLEAR'; VKey: VK_CLEAR),
    (Name: 'DEL'; VKey: VK_DELETE),
    (Name: 'DELETE'; VKey: VK_DELETE),
    (Name: 'DOWN'; VKey: VK_DOWN),
    (Name: 'END'; VKey: VK_END),
    (Name: 'ENTER'; VKey: VK_RETURN),
    (Name: 'ESC'; VKey: VK_ESCAPE),
    (Name: 'ESCAPE'; VKey: VK_ESCAPE),
    (Name: 'F1'; VKey: VK_F1),
    (Name: 'F10'; VKey: VK_F10),
    (Name: 'F11'; VKey: VK_F11),
    (Name: 'F12'; VKey: VK_F12),
    (Name: 'F13'; VKey: VK_F13),
    (Name: 'F14'; VKey: VK_F14),
    (Name: 'F15'; VKey: VK_F15),
    (Name: 'F16'; VKey: VK_F16),
    (Name: 'F2'; VKey: VK_F2),
    (Name: 'F3'; VKey: VK_F3),
    (Name: 'F4'; VKey: VK_F4),
    (Name: 'F5'; VKey: VK_F5),
    (Name: 'F6'; VKey: VK_F6),
    (Name: 'F7'; VKey: VK_F7),
    (Name: 'F8'; VKey: VK_F8),
    (Name: 'F9'; VKey: VK_F9),
    (Name: 'HELP'; VKey: VK_HELP),
    (Name: 'HOME'; VKey: VK_HOME),
    (Name: 'INS'; VKey: VK_INSERT),
    (Name: 'LEFT'; VKey: VK_LEFT),
    (Name: 'NUMLOCK'; VKey: VK_NUMLOCK),
    (Name: 'PGDN'; VKey: VK_NEXT),
    (Name: 'PGUP'; VKey: VK_PRIOR),
    (Name: 'PRTSC'; VKey: VK_PRINT),
    (Name: 'RIGHT'; VKey: VK_RIGHT),
    (Name: 'SCROLLLOCK'; VKey: VK_SCROLL),
    (Name: 'TAB'; VKey: VK_TAB),
    (Name: 'UP'; VKey: VK_UP)
    );

  {Extra   VK   constants   missing   from   Delphi's   Windows   API   interface}
  VK_NULL = 0;
  VK_SemiColon = 186;
  VK_Equal = 187;
  VK_Comma = 188;
  VK_Minus = 189;
  VK_Period = 190;
  VK_Slash = 191;
  VK_BackQuote = 192;
  VK_LeftBracket = 219;
  VK_BackSlash = 220;
  VK_RightBracket = 221;
  VK_Quote = 222;
  VK_Last = VK_Quote;

  ExtendedVKeys: Set Of byte =
    [VK_Up,
    VK_Down,
    VK_Left,
    VK_Right,
    VK_Home,
    VK_End,
    VK_Prior, {PgUp}
    VK_Next, {PgDn}
    VK_Insert,
    VK_Delete];

Const
  INVALIDKEY = $FFFF {Unsigned   -1};
  VKKEYSCANSHIFTON = $01;
  VKKEYSCANCTRLON = $02;
  VKKEYSCANALTON = $04;
  UNITNAME = 'SendKeys';
Var
  UsingParens, ShiftDown, ControlDown, AltDown, FoundClose: Boolean;
  PosSpace: Byte;
  I, L: Integer;
  NumTimes, MKey: Word;
  KeyString: String[20];
  AllocationSize: Integer;

  Procedure DisplayMessage(Message: PWideChar);
  Begin
    MessageBox(0, Message, UNITNAME, 0);
  End;

  Function BitSet(BitTable, BitMask: Byte): Boolean;
  Begin
    Result := ByteBool(BitTable And BitMask);
  End;

  Procedure SetBit(Var BitTable: Byte; BitMask: Byte);
  Begin
    BitTable := BitTable Or Bitmask;
  End;

  Procedure KeyboardEvent(VKey, ScanCode: Byte; Flags: Longint);
  Var
    KeyboardMsg: TMsg;
  Begin
    keybd_event(VKey, ScanCode, Flags, 0);
    If (Wait) Then
      While (PeekMessage(KeyboardMsg, 0, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE)) Do
      Begin
        TranslateMessage(KeyboardMsg);
        DispatchMessage(KeyboardMsg);
      End;
  End;

  Procedure SendKeyDown(VKey: Byte; NumTimes: Word; GenUpMsg: Boolean);
  Var
    Cnt: Word;
    ScanCode: Byte;
    NumState: Boolean;
    KeyBoardState: TKeyboardState;
  Begin
    If (VKey = VK_NUMLOCK) Then
    Begin
      NumState := ByteBool(GetKeyState(VK_NUMLOCK) And 1);
      GetKeyboardState(KeyBoardState);
      If NumState Then
        KeyBoardState[VK_NUMLOCK] := (KeyBoardState[VK_NUMLOCK] And Not 1)
      Else
        KeyBoardState[VK_NUMLOCK] := (KeyBoardState[VK_NUMLOCK] Or 1);
      SetKeyboardState(KeyBoardState);
      Exit;
    End;

    ScanCode := Lo(MapVirtualKey(VKey, 0));
    For Cnt := 1 To NumTimes Do
      If (VKey In ExtendedVKeys) Then
      Begin
        KeyboardEvent(VKey, ScanCode, KEYEVENTF_EXTENDEDKEY);
        If (GenUpMsg) Then
          KeyboardEvent(VKey, ScanCode, KEYEVENTF_EXTENDEDKEY Or KEYEVENTF_KEYUP)
      End
      Else
      Begin
        KeyboardEvent(VKey, ScanCode, 0);
        If (GenUpMsg) Then
          KeyboardEvent(VKey, ScanCode, KEYEVENTF_KEYUP);
      End;
  End;

  Procedure SendKeyUp(VKey: Byte);
  Var
    ScanCode: Byte;
  Begin
    ScanCode := Lo(MapVirtualKey(VKey, 0));
    If (VKey In ExtendedVKeys) Then
      KeyboardEvent(VKey, ScanCode, KEYEVENTF_EXTENDEDKEY And KEYEVENTF_KEYUP)
    Else
      KeyboardEvent(VKey, ScanCode, KEYEVENTF_KEYUP);
  End;

  Procedure SendKey(MKey: Word; NumTimes: Word; GenDownMsg: Boolean);
  Begin
    If (BitSet(Hi(MKey), VKKEYSCANSHIFTON)) Then
      SendKeyDown(VK_SHIFT, 1, False);
    If (BitSet(Hi(MKey), VKKEYSCANCTRLON)) Then
      SendKeyDown(VK_CONTROL, 1, False);
    If (BitSet(Hi(MKey), VKKEYSCANALTON)) Then
      SendKeyDown(VK_MENU, 1, False);
    SendKeyDown(Lo(MKey), NumTimes, GenDownMsg);
    If (BitSet(Hi(MKey), VKKEYSCANSHIFTON)) Then
      SendKeyUp(VK_SHIFT);
    If (BitSet(Hi(MKey), VKKEYSCANCTRLON)) Then
      SendKeyUp(VK_CONTROL);
    If (BitSet(Hi(MKey), VKKEYSCANALTON)) Then
      SendKeyUp(VK_MENU);
  End;

  {Implements   a   simple   binary   search   to   locate   special   key   name   strings}

  Function StringToVKey(KeyString: ShortString): Word;
  Var
    Found, Collided: Boolean;
    Bottom, Top, Middle: Byte;
  Begin
    Result := INVALIDKEY;
    Bottom := 1;
    Top := MaxSendKeyRecs;
    Found := False;
    Middle := (Bottom + Top) Div 2;
    Repeat
      Collided := ((Bottom = Middle) Or (Top = Middle));
      If (KeyString = SendKeyRecs[Middle].Name) Then
      Begin
        Found := True;
        Result := SendKeyRecs[Middle].VKey;
      End
      Else
      Begin
        If (KeyString > SendKeyRecs[Middle].Name) Then
          Bottom := Middle
        Else
          Top := Middle;
        Middle := (Succ(Bottom + Top)) Div 2;
      End;
    Until (Found Or Collided);
    If (Result = INVALIDKEY) Then
      DisplayMessage('Invalid   Key   Name');
  End;

  Procedure PopUpShiftKeys;
  Begin
    If (Not UsingParens) Then
    Begin
      If ShiftDown Then
        SendKeyUp(VK_SHIFT);
      If ControlDown Then
        SendKeyUp(VK_CONTROL);
      If AltDown Then
        SendKeyUp(VK_MENU);
      ShiftDown := False;
      ControlDown := False;
      AltDown := False;
    End;
  End;

Begin
  AllocationSize := MaxInt;
  Result := False;
  UsingParens := False;
  ShiftDown := False;
  ControlDown := False;
  AltDown := False;
  I := 0;
  L := StrLen(SendKeysString);
  If (L > AllocationSize) Then
    L := AllocationSize;
  If (L = 0) Then
    Exit;

  While (I < L) Do
  Begin
    Case SendKeysString[I] Of
      '(':
        Begin
          UsingParens := True;
          Inc(I);
        End;
      ')':
        Begin
          UsingParens := False;
          PopUpShiftKeys;
          Inc(I);
        End;
      '%':
        Begin
          AltDown := True;
          SendKeyDown(VK_MENU, 1, False);
          Inc(I);
        End;
      '+':
        Begin
          ShiftDown := True;
          SendKeyDown(VK_SHIFT, 1, False);
          Inc(I);
        End;
      '^':
        Begin
          ControlDown := True;
          SendKeyDown(VK_CONTROL, 1, False);
          Inc(I);
        End;
      '{':
        Begin
          NumTimes := 1;
          If (SendKeysString[Succ(I)] = '{') Then
          Begin
            MKey := VK_LEFTBRACKET;
            SetBit(Wbytes(MKey)[1], VKKEYSCANSHIFTON);
            SendKey(MKey, 1, True);
            PopUpShiftKeys;
            Inc(I, 3);
            Continue;
          End;
          KeyString := '';
          FoundClose := False;
          While (I <= L) Do
          Begin
            Inc(I);
            If (SendKeysString[I] = '}') Then
            Begin
              FoundClose := True;
              Inc(I);
              Break;
            End;
            KeyString := KeyString + UpCase(SendKeysString[I]);
          End;
          If (Not FoundClose) Then
          Begin
            DisplayMessage('No   Close');
            Exit;
          End;
          If (SendKeysString[I] = '}') Then
          Begin
            MKey := VK_RIGHTBRACKET;
            SetBit(Wbytes(MKey)[1], VKKEYSCANSHIFTON);
            SendKey(MKey, 1, True);
            PopUpShiftKeys;
            Inc(I);
            Continue;
          End;
          PosSpace := Pos('   ', KeyString);
          If (PosSpace <> 0) Then
          Begin
            NumTimes := StrToInt(Copy(KeyString, Succ(PosSpace), Length(KeyString) - PosSpace));
            KeyString := Copy(KeyString, 1, Pred(PosSpace));
          End;
          If (Length(KeyString) = 1) Then
            MKey := VkKeyScanA(KeyString[1])
          Else
            MKey := StringToVKey(KeyString);
          If (MKey <> INVALIDKEY) Then
          Begin
            SendKey(MKey, NumTimes, True);
            PopUpShiftKeys;
            Continue;
          End;
        End;
      '~':
        Begin
          SendKeyDown(VK_RETURN, 1, True);
          PopUpShiftKeys;
          Inc(I);
        End;
    Else
      Begin
        MKey := VkKeyScanA(SendKeysString[I]);
        If (MKey <> INVALIDKEY) Then
        Begin
          SendKey(MKey, 1, True);
          PopUpShiftKeys;
        End
        Else
          DisplayMessage('Invalid   KeyName');
        Inc(I);
      End;
    End;
  End;
  Result := true;
  PopUpShiftKeys;
End;
End.

