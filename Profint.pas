//PROFILE-NO
{$O-}
{$D-}
{$Q-}
{$R-}
{$B-}
{$I-}
{$X+}
{$WARNINGS OFF }

unit Profint;

interface

USES
  Dialogs,
  Windows;

TYPE

{$IFDEF VER90 }
  TMyComp  = Comp;
{$ELSE }
  {$IFDEF VER100 }
    TMyComp  = Comp;
  {$ELSE }
    TMyComp  = Int64;
  {$ENDIF }
{$ENDIF }

  TMyLargeInteger = RECORD
                    CASE Byte OF
                     0 : ( LowPart  : DWord; HighPart : LongInt );
                     1 : ( QuadPart : TMyComp );
                  END;
  TPLargeInteger = ^TMyLargeInteger;

{$DEFINE PROFD6ORBETTER}
{$IFDEF VER100} {$DEFINE PROFD3ORD4} {$UNDEF PROFD6ORBETTER} {$ENDIF }
{$IFDEF VER120} {$DEFINE PROFD3ORD4} {$UNDEF PROFD6ORBETTER} {$ENDIF }
{$IFDEF VER130} {$UNDEF PROFD6ORBETTER} {$ENDIF }
{$IFDEF VER170} {$DEFINE PROFD2005ORBETTER} {$ENDIF }
{$IFDEF VER180} {$DEFINE PROFD2005ORBETTER} {$ENDIF }
{$IFDEF VER200} {$DEFINE PROFD2005ORBETTER} {$ENDIF }

{$IFDEF VER90}  { Delphi 2 }
  {$UNDEF PROFD6ORBETTER}
  TObjFunction = FUNCTION ( Text, Caption : PChar;
                            Flags : Word ) : Integer OF Object;
{$ELSE}
  {$IFDEF PROFD3ORD4} { Delphi 3 or 4 }
    TObjFunction = FUNCTION ( Text, Caption : PChar;
                                Flags : Longint ) : Integer OF Object;
  {$ELSE }  { Delphi 5 OR Better }
     TObjFunction = FUNCTION ( CONST Text, Caption : PChar;
                                Flags : Longint ) : Integer OF Object;
  {$ENDIF}
{$ENDIF}

// Profiler-Measurement-Functions
PROCEDURE ProfStop  ( l : DWord; h : Integer);    external 'PROFMEAS.DLL';
FUNCTION  ProfEnter ( mptr : Pointer; prozNr : Integer ) : TPLargeInteger; external 'PROFMEAS.DLL';
FUNCTION  ProfExit  ( lc   : DWord;   hc : Integer; prozNr : Integer ) : TPLargeInteger; external 'PROFMEAS.DLL';
PROCEDURE ProfActivate;     external 'PROFMEAS.DLL';
PROCEDURE ProfDeActivate;   external 'PROFMEAS.DLL';
PROCEDURE ProfSetComment  ( comm   : PChar );     external 'PROFMEAS.DLL';
PROCEDURE ProfAppendResults ( progEnd : Boolean );external 'PROFMEAS.DLL';

// Post-Mortem-Review-Functions
PROCEDURE PomoEnter       ( prozNr : Word );      external 'PROFMEAS.DLL';
PROCEDURE PomoExceStr     ( name   : PChar );     external 'PROFMEAS.DLL';
PROCEDURE PomoExce;
PROCEDURE PomoExit        ( prozNr : Word );      external 'PROFMEAS.DLL';

// Functions to interrupt and continue measurement for calls which could set the
//  Process idle. Use these calls to implement own Non-measured Calls. If METHODS
//  can set a process idle, the only possibility is, to put these calls into your
//  sources (included by an IFDEF-statement).
//  USE 2 or more spaces between IFDEF and PROFILE, otherwise it will be deleted
//  by the ProDelphi. Example:
//
//  {$IFDEF     PROFILE } StopCounting;     {$ENDIF }
//    ObjectReference.MethodThatMightSetProcessIdle;
//  {$IFDEF     PROFILE } ContinueCounting; {$ENDIF }

// Normal procedures that set the process idle can be handled like the Sleep-
//  function in this unit.
PROCEDURE StopCounting;                           external 'PROFMEAS.DLL';
PROCEDURE ContinueCounting;                       external 'PROFMEAS.DLL';

// Function for Starting the Online-Operation windoe
PROCEDURE ProfOnlineOperation;                    external 'ProfOnFo.DLL';
PROCEDURE ProfCloseOnlineOperation;               external 'ProfOnFo.DLL';

// Delphi-Functions that set process idle
PROCEDURE ShowMessage ( CONST Msg  : String );

{$IFNDEF VER90 }
PROCEDURE ShowMessageFmt(const Msg : string; Params : array of const );
{$ENDIF}

          // If you need to compile the VCL, the next functions must be deleted,
          // Sorry ! The USES statement for Dialogs has to be moved to the
          // Implementation part !!!
{$IFDEF PROFD2005ORBETTER }
function  MessageDlg( const Msg : String;         AType   : TMsgDlgType;
                      AButtons  : TMsgDlgButtons; HelpCtx : Longint ) : Integer; Overload;

function  MessageDlgPos( const Msg : string;         DlgType : TMsgDlgType;
                         Buttons   : TMsgDlgButtons; HelpCtx: Longint;
                         X, Y      : Integer) : Integer; Overload;

function  MessageDlg( const Msg : String;         AType   : TMsgDlgType;
                      AButtons  : TMsgDlgButtons; HelpCtx : Longint;
                      DefaultButton : TMsgDlgBtn) : Integer; Overload;

function  MessageDlgPos( const Msg : string;         DlgType : TMsgDlgType;
                         Buttons   : TMsgDlgButtons; HelpCtx : Longint;
                         X, Y      : Integer;        DefaultButton : TMsgDlgBtn) : Integer; Overload;
{$ELSE }
function  MessageDlg( const Msg : String;         AType   : TMsgDlgType;
                      AButtons  : TMsgDlgButtons; HelpCtx : Longint ) : Integer;

function  MessageDlgPos( const Msg : string;         DlgType : TMsgDlgType;
                         Buttons   : TMsgDlgButtons; HelpCtx : Longint;
                         X, Y      : Integer) : Integer;
{$ENDIF }

{$IFNDEF VER90}  { Delphi 2 }
  {$IFDEF PROFD2005ORBETTER }
  function MessageDlgPosHelp( const Msg : string;         DlgType : TMsgDlgType;
                              Buttons   : TMsgDlgButtons; HelpCtx : Longint;
                              X, Y      : Integer;  const HelpFileName : string)
                             : Integer; Overload;

  function MessageDlgPosHelp( const Msg : string;         DlgType : TMsgDlgType;
                              Buttons   : TMsgDlgButtons; HelpCtx : Longint;
                              X, Y      : Integer;  const HelpFileName : string;
                              DefaultButton : TMsgDlgBtn)
                             : Integer; Overload;
  {$ELSE }
  function MessageDlgPosHelp( const Msg : string;         DlgType : TMsgDlgType;
                              Buttons   : TMsgDlgButtons; HelpCtx : Longint;
                              X, Y      : Integer;  const HelpFileName : string)
                             : Integer;

  {$ENDIF }
{$ENDIF}

// Delphi-TApplication-Functions that set process idle (handled in DLL)
PROCEDURE ProcessMessages;
PROCEDURE HandleMessage;

{$IFDEF VER90 }
FUNCTION  AMessageBox( Text, Caption  : PChar;
                       Flags : Word ) : Integer;
{$ELSE }
  {$IFDEF PROFD6ORBETTER}
    FUNCTION  AMessageBox( Text, Caption   : PChar;
                           Flags : Longint = MB_OK): Integer;
  {$ELSE }
    FUNCTION  AMessageBox( Text, Caption   : PChar;
                           Flags : Longint): Integer;
  {$ENDIF}
{$ENDIF }

// Windows-Functions that set process idle
{ FUNCTION  DispatchMessage(CONST lpMsg  : TMsg) : Longint; }
FUNCTION  DialogBox( hInstance  : HINST; lpTemplate   : PChar;
                     hWndParent : HWND;  lpDialogFunc : TFNDlgProc): Integer;
FUNCTION  DialogBoxIndirect( hInstance  : HINST; const lpDialogTemplate : TDlgTemplate;
                             hWndParent : HWND;        lpDialogFunc     : TFNDlgProc): Integer;
FUNCTION  MessageBox ( hWnd : HWND; lpText, lpCaption: PChar; uType : UINT ) : Integer;
FUNCTION  MessageBoxEx( hWnd : HWND; lpText, lpCaption: PChar; uType : UINT; lang : Word ) : Integer;

{$IFNDEF VER90 }
  {$IFDEF UNICODE }
  FUNCTION SignalObjectAndWait ( h1, h2 : Cardinal;
                                 ms     : Cardinal;
                                 al     : LongBool) : Cardinal;
  {$ELSE }
  FUNCTION  SignalObjectAndWait ( h1, h2 : THandle;
                                  ms     : DWord;
                                  al     : BOOL) : BOOL;
  {$ENDIF }
{$ENDIF}

FUNCTION  WaitForSingleObject ( h1     : THandle;
                                MS     : DWORD ) : DWORD;

FUNCTION  WaitForSingleObjectEx ( h1   : THandle;
                                  MS   : DWORD;
                                  al   : BOOL ) : DWORD;

FUNCTION  WaitForMultipleObjects ( ct  : DWORD;
                                   CONST pH : PWOHandleArray;
                                   wait     : BOOL;
                                   ms       : DWORD ) : DWORD;

FUNCTION  WaitForMultipleObjectsEx ( ct  : DWORD;
                                     CONST pH : PWOHandleArray;
                                     wait     : BOOL;
                                     ms       : DWORD;
                                     al       : Boolean) : DWORD;

FUNCTION  MsgWaitForMultipleObjects ( ct      : DWORD;
                                      VAR pHandles;
                                      wait    : BOOL;
                                      ms      : DWORD;
                                      wm      : DWORD ) : DWORD;

{$IFNDEF VER90 }
FUNCTION  MsgWaitForMultipleObjectsEx ( ct     : DWORD;
                                        VAR pHandles;
                                        ms     : DWORD;
                                        wm     : DWORD;
                                        fl     : DWORD ) : DWORD;
{$ENDIF}

PROCEDURE Sleep   (zeit : DWORD );
FUNCTION  SleepEx (zeit : DWORD; alertable : BOOL ) : DWORD;
FUNCTION  WaitCommEvent ( hd  : THandle; VAR em : DWORD;
                          lpo : POverlapped ) : BOOL;
FUNCTION  WaitForInputIdle ( hp : THandle; ms : DWORD ) : DWORD;
FUNCTION  WaitMessage : BOOL;

{$IFDEF UNICODE }
FUNCTION WaitNamedPipe ( np : PWideChar; ms : Cardinal ) : BOOL;
{$ELSE }
FUNCTION  WaitNamedPipe ( np : PAnsiChar; ms : DWORD ) : BOOL;
{$ENDIF }

IMPLEMENTATION
USES
  Forms,
  SysUtils;

TYPE
  TObjProzedur = PROCEDURE OF Object;

// Profiler-Internal-Functions, DO NOT USE
FUNCTION  ProfGlobalInit1 : Boolean;              external 'PROFMEAS.DLL';
PROCEDURE ProfGlobalInit2 ( j : Integer );        external 'PROFMEAS.DLL';
PROCEDURE ProfUnInitTimer;                        external 'PROFMEAS.DLL';
FUNCTION  ProfIsInitialised : Integer;            external 'PROFMEAS.DLL';
FUNCTION  ProfMustBeUnInitialised : Integer;      external 'PROFMEAS.DLL';

// Calibration - Function - DO NOT USE
PROCEDURE CalcQPCTime802;                         external 'PROFCALI.DLL';
PROCEDURE ProfSetDelphiVersion ( vers : Integer );external 'PROFCALI.DLL';

// Check if CPU is intel-Compatible
PROCEDURE PruefeKompatibilitaet;
VAR
  tsh, tsl : DWORD;
BEGIN
  Try
    asm
      DW 310FH;
      mov tsh,edx
      mov tsl,eax
    end;
  Except
    Windows.MessageBox(0, 'This CPU is not Intel-Compatible', 'ProDelphi - ERROR', MB_OK);
    halt(0);
  End;
END;

PROCEDURE ShowMessage ( CONST Msg  : String );
BEGIN
  StopCounting;
  Dialogs.ShowMessage(Msg);
  ContinueCounting;
END;

{$IFNDEF VER90 }
PROCEDURE ShowMessageFmt(const Msg : string; Params : array of const );
BEGIN
  StopCounting;
  Dialogs.ShowMessageFmt(Msg, Params);
  ContinueCounting;
END;

FUNCTION AMessageBox( Text, Caption     : PChar;
                      Flags : LongInt ) : Integer;
BEGIN
  StopCounting;
  Result := Application.MessageBox(Text, Caption,Flags);
  ContinueCounting;
END;

{$ELSE }

FUNCTION AMessageBox( Text, Caption    : PChar;
                      Flags : Word  )  : Integer;
BEGIN
  StopCounting;
  Result := Application.MessageBox(Text, Caption,Flags);
  ContinueCounting;
END;
{$ENDIF }

PROCEDURE HandleMessage;
BEGIN
  asm DW 310FH; call ProfStop; end; Try; asm mov edx,1; xor eax,eax; call ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end;
  Application.HandleMessage;
  finally; asm DW 310FH; mov ecx,1; call ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end;
END;

PROCEDURE ProcessMessages;
BEGIN
  asm DW 310FH; call ProfStop; end; Try; asm mov edx,1; xor eax,eax; call ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end;
  Application.ProcessMessages;
  finally; asm DW 310FH; mov ecx,1; call ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end;
END;

FUNCTION MessageDlg( const Msg : String;         AType   : TMsgDlgType;
                     AButtons  : TMsgDlgButtons; HelpCtx : Longint ) : Integer;
BEGIN
  StopCounting;
  Result := Dialogs.MessageDlg(Msg,
                               AType,
                               AButtons,
                               HelpCtx);
  ContinueCounting;
END;

FUNCTION MessageDlgPos( const Msg : string;         DlgType : TMsgDlgType;
                        Buttons   : TMsgDlgButtons; HelpCtx: Longint;
                        X, Y      : Integer) : Integer;
BEGIN
  StopCounting;
  Result := Dialogs.MessageDlgPos(Msg,
                                  DlgType,
                                  Buttons,
                                  HelpCtx,
                                  X, Y);
  ContinueCounting;
END;

{$IFDEF PROFD2005ORBETTER }
function MessageDlg( const Msg     : String;         AType   : TMsgDlgType;
                     AButtons      : TMsgDlgButtons; HelpCtx : Longint;
                     DefaultButton : TMsgDlgBtn ) : Integer;
BEGIN
  StopCounting;
  Result := Dialogs.MessageDlg(Msg,
                               AType,
                               AButtons,
                               HelpCtx,
                               DefaultButton);
  ContinueCounting;
END;

FUNCTION MessageDlgPos( const Msg : string;         DlgType       : TMsgDlgType;
                        Buttons   : TMsgDlgButtons; HelpCtx       : Longint;
                        X, Y      : Integer;        DefaultButton : TMsgDlgBtn ) : Integer;
BEGIN
  StopCounting;
  Result := Dialogs.MessageDlgPos(Msg,
                                  DlgType,
                                  Buttons,
                                  HelpCtx,
                                  X, Y,
                                  DefaultButton);
  ContinueCounting;
END;
{$ENDIF }
{$IFNDEF VER90}  { Delphi 2 }
function MessageDlgPosHelp( const Msg : string;         DlgType      : TMsgDlgType;
                            Buttons   : TMsgDlgButtons; HelpCtx      : Longint;
                            X, Y      : Integer;  const HelpFileName : string)
                           : Integer;
BEGIN
  StopCounting;
  Result := Dialogs.MessageDlgPosHelp(Msg,
                                      DlgType,
                                      Buttons,
                                      HelpCtx,
                                      X, Y,
                                      HelpFileName);
  ContinueCounting;
END;
  {$IFDEF PROFD2005ORBETTER }
  function MessageDlgPosHelp( const Msg : string;         DlgType : TMsgDlgType;
                              Buttons   : TMsgDlgButtons; HelpCtx : Longint;
                              X, Y      : Integer;  const HelpFileName : string;
                              DefaultButton : TMsgDlgBtn)
                             : Integer;
  BEGIN
    StopCounting;
    Result := Dialogs.MessageDlgPosHelp(Msg,
                                        DlgType,
                                        Buttons,
                                        HelpCtx,
                                        X, Y,
                                        HelpFileName,
                                        DefaultButton);
    ContinueCounting;
  END;
  {$ENDIF }
{$ENDIF }

FUNCTION  DialogBox( hInstance  : HINST; lpTemplate   : PChar;
                     hWndParent : HWND;  lpDialogFunc : TFNDlgProc): Integer;
BEGIN
  StopCounting;
  Result := Windows.DialogBox(hInstance, lpTemplate, hWndParent, lpDialogFunc);
  ContinueCounting;
END;

FUNCTION  DialogBoxIndirect( hInstance  : HINST; const lpDialogTemplate : TDlgTemplate;
                             hWndParent : HWND;        lpDialogFunc     : TFNDlgProc): Integer;
BEGIN
  StopCounting;
  Result := Windows.DialogBoxIndirect(hInstance, lpDialogTemplate, hWndParent, lpDialogFunc);
  ContinueCounting;
END;

FUNCTION MessageBox ( hWnd : HWND; lpText, lpCaption: PChar; uType : UINT ) : Integer;
BEGIN
  StopCounting;
  Result := Windows.MessageBox(hWnd, lpText, lpCaption, uType);
  ContinueCounting;
END;

FUNCTION MessageBoxEx ( hWnd : HWND; lpText, lpCaption: PChar; uType : UINT; lang : Word ) : Integer;
BEGIN
  StopCounting;
  Result := Windows.MessageBoxEx(hWnd, lpText, lpCaption, uType, lang);
  ContinueCounting;
END;

{ FUNCTION DispatchMessage( CONST lpMsg: TMsg ) : Longint;
BEGIN
  StopCounting;
  Result := Windows.DispatchMessage(lpMsg);
  ContinueCounting;
END; }

PROCEDURE Sleep( zeit : DWORD );
BEGIN
  StopCounting;
  Windows.Sleep(zeit);
  ContinueCounting;
END;

FUNCTION SleepEx( zeit : DWORD; alertable : BOOL ) : DWORD;
BEGIN
  StopCounting;
  Result := Windows.SleepEx(zeit, alertable);
  ContinueCounting;
END;
{$IFNDEF VER90 }
  {$IFDEF UNICODE }
  FUNCTION SignalObjectAndWait ( h1, h2 : Cardinal;
                                 ms     : Cardinal;
                                 al     : LongBool) : Cardinal;
  BEGIN
    StopCounting;
    Result := Windows.SignalObjectAndWait(h1, h2, ms, al);
    ContinueCounting;
  END;
  {$ELSE }
  FUNCTION SignalObjectAndWait ( h1, h2 : THandle;
                                 ms     : DWord;
                                 al     : BOOL) : BOOL;
  BEGIN
    StopCounting;
    Result := Windows.SignalObjectAndWait(h1, h2, ms, al);
    ContinueCounting;
  END;
  {$ENDIF }
{$ENDIF }

FUNCTION WaitForSingleObject ( h1     : THandle;
                               MS     : DWORD ) : DWORD;
BEGIN
  StopCounting;
  Result := Windows.WaitForSingleObject ( h1, MS );
  ContinueCounting;
END;

FUNCTION WaitForSingleObjectEx ( h1   : THandle;
                                 MS   : DWORD;
                                 al   : BOOL ) : DWORD;
BEGIN
  StopCounting;
  Result := Windows.WaitForSingleObjectEx (h1, MS, al);
  ContinueCounting;
END;

FUNCTION WaitForMultipleObjects ( ct  : DWORD;
                                  CONST pH : PWOHandleArray;
                                  wait     : BOOL;
                                  ms       : DWORD ) : DWORD;
BEGIN
  StopCounting;
  Result := Windows.WaitForMultipleObjects(ct, pH, wait, ms);
  ContinueCounting;
END;

FUNCTION WaitForMultipleObjectsEx ( ct  : DWORD;
                                    CONST pH : PWOHandleArray;
                                    wait     : BOOL;
                                    ms       : DWORD;
                                    al       : Boolean ) : DWORD;
BEGIN
  StopCounting;
  Result := Windows.WaitForMultipleObjectsEx(ct, pH, wait, ms, al);
  ContinueCounting;
END;

FUNCTION MsgWaitForMultipleObjects ( ct     : DWORD;
                                     VAR pHandles;
                                     wait   : BOOL;
                                     ms     : DWORD;
                                     wm     : DWORD ) : DWORD;
BEGIN
  StopCounting;
  Result := Windows.MsgWaitForMultipleObjects(ct, pHandles, wait, ms, wm);
  ContinueCounting;
END;

{$IFNDEF VER90 }
FUNCTION MsgWaitForMultipleObjectsEx ( ct     : DWORD;
                                       VAR pHandles;
                                       ms     : DWORD;
                                       wm     : DWORD;
                                       fl     : DWORD ) : DWORD;
BEGIN
  StopCounting;
  Result := Windows.MsgWaitForMultipleObjectsEx(ct, pHandles, ms, wm, fl);
  ContinueCounting;
END;
{$ENDIF}
FUNCTION WaitCommEvent ( hd : THandle; VAR em : DWORD; lpo : POverlapped ) : BOOL;
BEGIN
  StopCounting;
  Result := Windows.WaitCommEvent(hd, em, lpo);
  ContinueCounting;
END;

FUNCTION WaitForInputIdle ( hp : THandle; ms : DWORD ) : DWORD;
BEGIN
  StopCounting;
  Result := Windows.WaitForInputIdle(hp, ms);
  ContinueCounting;
END;

FUNCTION WaitMessage : BOOL;
BEGIN
  StopCounting;
  Result := Windows.WaitMessage;
  ContinueCounting;
END;

{$IFDEF UNICODE }
FUNCTION WaitNamedPipe ( np : PWideChar; ms : Cardinal ) : BOOL;
BEGIN
  StopCounting;
  Result := Windows.WaitNamedPipe(np, ms);
  ContinueCounting;
END;
{$ELSE }
FUNCTION WaitNamedPipe ( np : PAnsiChar; ms : DWORD ) : BOOL;
BEGIN
  StopCounting;
  Result := Windows.WaitNamedPipe(np, ms);
  ContinueCounting;
END;
{$ENDIF }

PROCEDURE PomoExce;
VAR
  exnames : String;
{$IFDEF UNICODE }
  exnamea : UTF8String;
{$ENDIF }
  exname  : Array[0..200] OF Char;
  ExOb    : TObject;
BEGIN
  exname[0] := Char(0);
  ExOb := ExceptObject;
  IF Assigned(ExOb) THEN BEGIN
    IF ExceptObject IS Exception THEN BEGIN
      exnames := Exception(ExceptObject).Message;
{$IFNDEF UNICODE }
      StrPLCopy(exname, exnames, SizeOf(exname));
{$ELSE }
      exnamea := UTF8Encode(exnames);
      StrPLCopy(exname, exnamea, SizeOf(exname));
{$ENDIF }
    END;
  END;
  PomoExceStr(exname);
END;

INITIALIZATION
  IF ProfIsInitialised = 1 THEN BEGIN
    PruefeKompatibilitaet;
    IF ProfGlobalInit1 = TRUE THEN BEGIN
{$IFDEF VER90 }
      ProfSetDelphiVersion( 2 );
{$ELSE }
  {$IFDEF VER100 }
      ProfSetDelphiVersion( 3 );
  {$ELSE }
    {$IFDEF VER120 }
      ProfSetDelphiVersion( 4 );
    {$ELSE }
      {$IFDEF VER130 }
        ProfSetDelphiVersion( 5 );
      {$ELSE }
        {$IFDEF VER140 }
          ProfSetDelphiVersion( 6 );
        {$ELSE }
          {$IFDEF VER150 }
            ProfSetDelphiVersion( 7 );
          {$ELSE }
            ProfSetDelphiVersion( 8 );
          {$ENDIF }
        {$ENDIF }
      {$ENDIF }
    {$ENDIF }
  {$ENDIF }
{$ENDIF }
      CalcQPCTime802;
    END;
    ProfGlobalInit2(0);
    ProfSetComment('None');
  END;
FINALIZATION
  IF ProfMustBeUnInitialised = 1 THEN BEGIN
    ProfSetComment('At finishing application');
    ProfAppendResults(TRUE);
    ProfUnInitTimer;
  END;
end.

