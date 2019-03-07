program Test;

uses
  Vcl.Forms,
  Test.UI.FrmMain in 'Test.UI.FrmMain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  System.ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
