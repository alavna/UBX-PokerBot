Program UBX;

uses
  Forms,
  uMain in 'uMain.pas' {FrmInfo},
  uGameClasses in 'uGameClasses.pas',
  uHandAnalysis in 'uHandAnalysis.pas',
  uHashTables in 'uHashTables.pas',
  uTableInfo in 'uTableInfo.pas',
  uBrain in 'uBrain.pas',
  uFormUtils in 'uFormUtils.pas',
  uNewTypes in 'uNewTypes.pas',
  uGlobalVariables in 'uGlobalVariables.pas',
  uGlobalConstants in 'uGlobalConstants.pas',
  uMiscFunctions in 'uMiscFunctions.pas';

{$R *.res}

Begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmInfo, FrmInfo);
  Application.Run;
End.

